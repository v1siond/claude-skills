#!/usr/bin/env python3
"""Synthesize an original score for a film from its cut list, so the music and the cuts share one source.

  score.py --segments segments.json out.wav      total, cuts, seed (and bpm when 118 to 128) from segments.json
  score.py --duration 30 --bpm 124 --cuts 6,13.3 out.wav
  score.py --style pad --segments segments.json out.wav   the old slow pad (80 bpm feel), only when asked
  score.py --check music.wav --segments segments.json     true peak, loudness, gaps, tempo, hit per cut
  score.py --self-test                                    renders short films and checks them

Style "ad" (the default) is an upbeat internet ad track in A major at 118 to 128 bpm (124 when the cut list
carries no tempo in that range): a punchy four on the floor kick, claps on 2 and 4, offbeat open hats and
16th closed hats, a rolling 16th bass ducked by the kick (sidechain), syncopated chord plucks over
A E F#m D (I V vi IV), and a four bar hook in a pluck with a dotted eighth ping pong delay. Parts:
  intro      0 to the first cut: plucks open from a dark filter, hats fade in, the kick enters halfway,
             a snare roll in the last bar
  main       the full groove; every 16 bars the hook plays 8 bars whole and 8 bars as a call with space
  breather   from the cut nearest the middle to the first cut 6 to 14 s later: kick and claps out, bass and
             plucks filtered down, then back in on that cut
  end        the last cut (or 4 s before the end when the last part is longer than 10 s): a big hit and a
             ringing tonic chord that decays to the end
Every cut gets a noise riser (up to 2 beats, never more than half the gap to the previous cut), a 35 ms
duck of the whole mix just before it, and a hit (boom, click and crash) starting on the cut sample. The
groove keeps its own grid from t=0; risers and hits follow the cut times, which need not be on the grid.
Room for a voice-over: the energy sits in the drums and bass, the melodic parts stay low in register and
the master dips 1 to 4 kHz by about 3.5 dB.

Seeded and built from numpy only, so the same inputs write the same file; no network, no samples, no licence
to check. Writes 48 kHz stereo 16-bit PCM, peak at 0.8; run `encode.sh loud` on it before the mux. Refuses
to overwrite an existing output.
"""
from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys
import tempfile
import wave

import numpy as np

SR = 48000
PEAK = 0.8
FPS = 30

# ---------------------------------------------------------------------------------------------- ad style
AD_BPM, AD_BPM_RANGE = 124.0, (118.0, 128.0)
KEY = "A major"
PROGRESSION = [  # one chord per bar: (bass root, pluck voicing), midi notes
    ("A", 33, [57, 61, 64]),
    ("E", 40, [56, 59, 64]),
    ("F#m", 42, [54, 57, 61]),
    ("D", 38, [54, 57, 62]),
]
HOOK = [  # (bar of the four, 16th step, midi, length in 16ths); one rhythm, moved over the chords
    [(0, 76, 2), (3, 73, 1), (4, 76, 2), (7, 78, 1), (8, 76, 2), (11, 73, 1), (12, 71, 2), (14, 73, 2)],
    [(0, 71, 2), (3, 68, 1), (4, 71, 2), (7, 76, 1), (8, 71, 2), (11, 68, 1), (12, 66, 2), (14, 68, 2)],
    [(0, 73, 2), (3, 69, 1), (4, 73, 2), (7, 76, 1), (8, 73, 2), (11, 69, 1), (12, 71, 2), (14, 73, 2)],
    [(0, 74, 2), (3, 73, 1), (4, 71, 2), (7, 69, 1), (8, 66, 3), (12, 69, 1), (14, 71, 2)],
]
PLUCK_STEPS = [0, 3, 6, 10, 12]  # syncopated chord plucks inside one bar of 16ths
GAIN = dict(kick=0.95, clap=0.30, hat=0.075, ohat=0.10, bass=0.30, sub=0.30, pluck=0.075, hook=0.14,
            hook_delay=0.30, riser=0.16, hit=0.8, roll=0.18, bed=0.022)
SUCK = 0.035          # seconds of duck before each cut
SUCK_DEPTH = 0.3      # mix gain at the bottom of the duck
MID_DIP_DB = -3.5     # master bell centred on 2 kHz, spanning about 1 to 4 kHz


def midi_hz(m: float) -> float:
    return 440.0 * 2 ** ((m - 69) / 12)


def fft_filter(x: np.ndarray, gain_of_hz) -> np.ndarray:
    """Zero phase filter: multiply the spectrum by gain_of_hz(f). Padded so the tail does not wrap."""
    n = len(x) + 4096
    f = np.fft.rfftfreq(n, 1 / SR)
    return np.fft.irfft(np.fft.rfft(x, n) * gain_of_hz(f), n)[: len(x)]


class Bank:
    """Filtered noise made once per seed; each drum hit reads a fresh slice, so every hit differs a little."""

    def __init__(self, rng: np.random.Generator):
        self.rng = rng
        white = rng.standard_normal(SR * 4)
        self.hat = fft_filter(white, lambda f: np.clip((f - 6500) / 3000, 0, 1))
        self.clap = fft_filter(white, lambda f: np.exp(-0.5 * (np.log2(np.maximum(f, 1) / 1300) / 0.7) ** 2))
        self.crash = fft_filter(white, lambda f: np.clip((f - 4500) / 3000, 0, 1))
        self.low = fft_filter(white, lambda f: 1 / (1 + (f / 700) ** 2))
        self.high = fft_filter(white, lambda f: np.clip((f - 3000) / 4000, 0, 1))
        for name in ("hat", "clap", "crash", "low", "high"):
            buf = getattr(self, name)
            setattr(self, name, buf / np.sqrt(np.mean(buf ** 2)))

    def take(self, name: str, n: int) -> np.ndarray:
        buf = getattr(self, name)
        start = int(self.rng.integers(0, len(buf) - n))
        return buf[start:start + n]


def additive_saw(midi: float, n: int, fc0: float, fc1: float, tau: float) -> np.ndarray:
    """A saw built from harmonics, each weighted by a two pole lowpass whose cutoff falls fc0 to fc1."""
    f = midi_hz(midi)
    t = np.arange(n) / SR
    fc = fc1 + (fc0 - fc1) * np.exp(-t / tau)
    out = np.zeros(n)
    for k in range(1, max(1, int(min(9000.0, 3 * fc0) / f)) + 1):
        out += np.sin(2 * np.pi * k * f * t) / k / np.sqrt(1 + (k * f / fc) ** 4)
    return out


_cache: dict = {}


def cached(key, make):
    if key not in _cache:
        _cache[key] = make()
    return _cache[key]


def kick_sound() -> np.ndarray:
    tt = np.arange(int(0.42 * SR)) / SR
    freq = 48 + 110 * np.exp(-tt * 38)
    body = np.sin(2 * np.pi * np.cumsum(freq) / SR) * np.exp(-tt * 7.5)
    click = np.sin(2 * np.pi * 1800 * tt) * np.exp(-tt * 900) * 0.35
    return np.tanh(1.8 * (body + click)) / np.tanh(1.8)


def env_decay(n: int, rate: float, attack: float = 0.001) -> np.ndarray:
    tt = np.arange(n) / SR
    return np.minimum(tt / attack, 1) * np.exp(-tt * rate)


class Mix:
    def __init__(self, n: int):
        self.n = n
        self.buses = {name: np.zeros((2, n)) for name in ("drums", "bass", "music", "hook", "fx")}

    def add(self, bus: str, at: float, sig: np.ndarray, gain: float, pan: float = 0.0, delay_r: int = 0) -> None:
        s = int(round(at * SR))
        if s >= self.n or s + len(sig) <= 0:
            return
        if s < 0:
            sig, s = sig[-s:], 0
        m = min(len(sig), self.n - s)
        left, right = np.cos((pan + 1) * np.pi / 4) * np.sqrt(2), np.sin((pan + 1) * np.pi / 4) * np.sqrt(2)
        b = self.buses[bus]
        b[0, s:s + m] += sig[:m] * gain * left
        sr = s + delay_r
        if sr < self.n:
            mr = min(len(sig), self.n - sr)
            b[1, sr:sr + mr] += sig[:mr] * gain * right


def plan(duration: float, cuts: list[float], bpm: float) -> dict:
    """The parts of the film as times: intro end, breather window, end hit."""
    bar = 4 * 60.0 / bpm
    intro_end = cuts[0] if cuts and cuts[0] >= bar else min(2 * bar, duration / 4)
    last = cuts[-1] if cuts else duration
    end_at = last if cuts and duration - last <= 10.0 else max(intro_end, duration - 4.0)
    breather = None
    inner = [c for c in cuts if intro_end < c < end_at]
    if inner:
        start = min(inner, key=lambda c: abs(c - duration / 2))
        back = [c for c in inner if 6.0 <= c - start <= 14.0]
        breather = (start, back[0] if back else start + 2 * bar)
        if breather[1] >= end_at - bar:
            breather = None
    return {"intro_end": intro_end, "breather": breather, "end_at": end_at, "bar": bar}


def part_at(t: float, p: dict) -> str:
    if t < p["intro_end"]:
        return "intro"
    if t >= p["end_at"]:
        return "end"
    if p["breather"] and p["breather"][0] <= t < p["breather"][1]:
        return "breather"
    return "main"


def synthesize_ad(duration: float, bpm: float, cuts: list[float], seed: int) -> np.ndarray:
    rng = np.random.default_rng(seed)
    bank = Bank(rng)
    n = int(round(SR * duration))
    mix = Mix(n)
    p = plan(duration, cuts, bpm)
    beat = 60.0 / bpm
    step = beat / 4
    kick = kick_sound()
    near_cut = lambda t: any(c - 0.06 <= t < c + 0.02 for c in cuts)
    kick_times = []

    for i in range(int(np.ceil(duration / step))):
        t = i * step
        part = part_at(t, p)
        if part == "end":
            continue
        s16, bar_i = i % 16, i // 16
        _, root, chord = PROGRESSION[bar_i % 4]
        intro_x = min(1.0, t / max(p["intro_end"], 1e-6))
        # kick: four on the floor; enters halfway through the intro; out in the breather
        if s16 % 4 == 0 and not near_cut(t) and (part == "main" or (part == "intro" and intro_x >= 0.5)):
            mix.add("drums", t, kick, GAIN["kick"] * (0.7 if part == "intro" else 1.0))
            kick_times.append(t)
        # claps on 2 and 4
        if s16 in (4, 12) and part == "main":
            n_c = int(0.22 * SR)
            body = bank.take("clap", n_c) * env_decay(n_c, 22)
            for k, d in enumerate((0.0, 0.009, 0.018)):  # the three hands of a clap
                lead = int(d * SR)
                body[lead:lead + int(0.008 * SR)] += bank.take("clap", int(0.008 * SR)) * (0.8 - 0.2 * k)
            snare = np.sin(2 * np.pi * 185 * np.arange(n_c) / SR) * env_decay(n_c, 30) * 0.6
            mix.add("drums", t, body + snare, GAIN["clap"], pan=0.05)
        # closed hats on every 16th, accented on the 8ths
        hat_gain = {"intro": intro_x ** 1.5, "breather": 0.45, "main": 1.0}[part]
        if hat_gain > 0.02 and not (s16 % 4 == 2 and part == "main"):
            n_h = int(0.05 * SR)
            accent = 1.0 if s16 % 2 == 0 else 0.6
            mix.add("drums", t, bank.take("hat", n_h) * env_decay(n_h, 90), GAIN["hat"] * accent * hat_gain,
                    pan=0.25 if s16 % 2 else -0.15)
        # open hats on the offbeat 8ths
        if s16 % 4 == 2 and part == "main":
            n_o = int(0.2 * SR)
            mix.add("drums", t, bank.take("hat", n_o) * env_decay(n_o, 16), GAIN["ohat"], pan=0.3)
        # snare roll in the last bar of the intro: 8ths, then 16ths, rising
        if part == "intro" and t >= p["intro_end"] - p["bar"] and (s16 % 2 == 0 or t >= p["intro_end"] - p["bar"] / 2):
            n_r = int(0.09 * SR)
            rise = 1 - (p["intro_end"] - t) / p["bar"]
            mix.add("drums", t, bank.take("clap", n_r) * env_decay(n_r, 40), GAIN["roll"] * (0.3 + 0.7 * rise))
        # bass: rolling 16ths between the kicks, an octave up on the last 16th of the bar
        if part in ("main", "breather") and s16 % 4 != 0 and (part == "main" or s16 % 4 == 2):
            note = root + (12 if s16 == 15 else 0)
            fc0, fc1 = (1400.0, 380.0) if part == "main" else (420.0, 220.0)
            n_b = int(step * 0.92 * SR)
            saw = cached(("bass", note, n_b, fc0), lambda: additive_saw(note, n_b, fc0, fc1, 0.05)
                         * env_decay(n_b, 6, 0.003))
            sub_note = root - 12 if root >= 38 else root  # the sub stays between 41 and 55 Hz
            sub = cached(("sub", sub_note, n_b), lambda: np.sin(2 * np.pi * midi_hz(sub_note) * np.arange(n_b) / SR)
                         * env_decay(n_b, 4, 0.004))
            vel = {1: 0.7, 2: 1.0, 3: 0.8}[s16 % 4]
            mix.add("bass", t, saw, GAIN["bass"] * vel)
            mix.add("bass", t, sub, GAIN["sub"] * vel)
        # a quiet held chord under everything, so no bar has a hole in it
        if s16 == 0:
            n_bed = int((16 * step + 0.08) * SR)
            fc_bed = 700.0 if part == "breather" else 1000.0
            bed = cached(("bed", tuple(chord), n_bed, fc_bed), lambda: sum(
                additive_saw(m + d, n_bed, fc_bed, fc_bed, 1.0) for m in chord for d in (-0.1, 0.1))
                * np.minimum(np.minimum(np.arange(n_bed), n_bed - np.arange(n_bed)) / (0.08 * SR), 1))
            mix.add("music", t, bed, GAIN["bed"] * (1.6 if part == "breather" else 1.0 + 0.6 * (part == "intro")))
        # chord plucks, opening from dark in the intro, dark in the breather
        if s16 in PLUCK_STEPS:
            fc0 = {"intro": 350 + 2300 * intro_x ** 2, "breather": 600.0, "main": 2600.0}[part]
            fc0 = round(fc0 / 50) * 50
            n_p = int(0.32 * SR)
            for side, det in ((-0.6, -0.07), (0.6, 0.07)):
                sig = cached(("pluck", tuple(chord), det, fc0), lambda: sum(
                    additive_saw(m + det, n_p, fc0, 300.0, 0.06) for m in chord) * env_decay(n_p, 9, 0.002))
                mix.add("music", t, sig, GAIN["pluck"] * (1.15 if s16 == 0 else 0.9), pan=side,
                        delay_r=int(0.011 * SR) if side > 0 else 0)
        # the hook: whole in the first 8 bars of each 16, a call (first half bar) in the next 8
        if part in ("main", "breather"):
            phrase_b = (bar_i // 8) % 2 == 1
            for st, m, ln in HOOK[bar_i % 4]:
                if st == s16 and not (phrase_b and st >= 8):
                    n_k = int(ln * step * SR)
                    bright = part == "main"
                    sig = cached(("hook", m, n_k, bright), lambda: (
                        np.sin(2 * np.pi * midi_hz(m) * np.arange(n_k) / SR)
                        + (0.28 if bright else 0.1) * np.sin(4 * np.pi * midi_hz(m) * np.arange(n_k) / SR)
                        + (0.10 if bright else 0.0) * np.sin(6 * np.pi * midi_hz(m) * np.arange(n_k) / SR))
                        * env_decay(n_k, 7, 0.003) * np.clip((n_k - np.arange(n_k)) / (0.01 * SR), 0, 1))
                    mix.add("hook", t, sig, GAIN["hook"] * (1.0 if bright else 0.55))

    # risers into every cut, a hit on every cut
    prev = 0.0
    for c in cuts:
        if c >= duration:
            break
        length = min(2 * beat, 0.5 * (c - prev))
        if length > 0.05:
            n_r = int(length * SR)
            x = np.linspace(0, 1, n_r)
            noise = bank.take("low", n_r) * (1 - x) + bank.take("high", n_r) * x
            sweep = np.sin(2 * np.pi * np.cumsum(250 + 900 * x ** 2) / SR) * 0.18
            fade = np.clip((n_r - np.arange(n_r)) / (0.02 * SR), 0, 1)
            soft = 0.6 if part_at(c - 0.01, p) == "breather" else 1.0
            mix.add("fx", c - length, (noise + sweep) * x ** 2.2 * fade, GAIN["riser"] * soft)
        big = 1.5 if (p["breather"] and abs(c - p["breather"][1]) < 1e-6) or c == p["end_at"] else 1.0
        add_hit(mix, bank, c, GAIN["hit"] * big)
        prev = c
    if p["end_at"] < duration and p["end_at"] not in cuts:
        add_hit(mix, bank, p["end_at"], GAIN["hit"] * 1.5)
    add_end_chord(mix, p["end_at"], duration)

    # sidechain: bass and plucks duck under each kick and each hit
    duck = np.ones(n)
    curve = 1 - 0.75 * np.exp(-np.arange(int(beat * SR)) / SR / 0.07)
    for t in kick_times + [c for c in cuts if c < duration]:
        s = int(round(t * SR))
        m = min(len(curve), n - s)
        duck[s:s + m] = np.minimum(duck[s:s + m], curve[:m])
    mix.buses["bass"] *= duck
    mix.buses["music"] *= 0.35 + 0.65 * duck
    mix.buses["hook"] *= 0.6 + 0.4 * duck

    # dotted eighth ping pong on the hook
    hook = mix.buses["hook"].sum(0) / 2
    d = int(3 * step * SR)
    for k in range(1, 4):
        side = 0 if k % 2 else 1
        mix.buses["hook"][side, d * k:] += hook[: n - d * k] * GAIN["hook_delay"] * 0.55 ** (k - 1)

    out = sum(mix.buses.values())
    # the suck before each cut, so the hit lands on a breath
    for c in cuts:
        s, e = int(round((c - SUCK) * SR)), int(round(c * SR))
        if 0 <= s < e <= n:
            out[:, s:e] *= SUCK_DEPTH + (1 - SUCK_DEPTH) * np.cos(np.linspace(0, np.pi / 2, e - s)) ** 2
    return master(out, duration)


def add_hit(mix: Mix, bank: Bank, at: float, gain: float) -> None:
    n_h = int(1.6 * SR)
    tt = np.arange(n_h) / SR
    boom = np.sin(2 * np.pi * np.cumsum(38 + 120 * np.exp(-tt * 25)) / SR) * np.exp(-tt * 4.5)
    click = np.sin(2 * np.pi * 2200 * tt) * np.exp(-tt * 700) * 0.4
    crash = bank.take("crash", n_h) * env_decay(n_h, 2.6, 0.0005) * 0.22
    mix.add("fx", at, np.tanh(1.5 * boom) + click, gain)
    mix.add("fx", at, crash, gain, pan=-0.3)
    mix.add("fx", at, bank.take("crash", n_h) * env_decay(n_h, 2.6, 0.0005) * 0.22, gain, pan=0.3)


def add_end_chord(mix: Mix, at: float, duration: float) -> None:
    n_e = int(max(0.5, duration - at) * SR)
    _, root, chord = PROGRESSION[0]
    tail = np.exp(-np.arange(n_e) / SR / 1.6)
    ring = sum(additive_saw(m, n_e, 1800.0, 500.0, 0.6) for m in chord + [chord[0] + 12]) * tail
    sub = np.sin(2 * np.pi * midi_hz(root) * np.arange(n_e) / SR) * tail
    mix.add("music", at, ring, GAIN["pluck"] * 1.4, pan=-0.2)
    mix.add("music", at, ring, GAIN["pluck"] * 1.4, pan=0.2, delay_r=int(0.013 * SR))
    mix.add("bass", at, sub, GAIN["sub"] * 1.2)


def master(out: np.ndarray, duration: float) -> np.ndarray:
    def eq(f):
        bell = 10 ** (MID_DIP_DB * np.exp(-0.5 * (np.log2(np.maximum(f, 1) / 2000) / 0.65) ** 2) / 20)
        return bell * np.clip(f / 30, 0, 1)
    out = np.stack([fft_filter(ch, eq) for ch in out])
    n = out.shape[1]
    t = np.arange(n) / SR
    out *= np.clip(t / 0.03, 0, 1) * np.clip((duration - t) / 0.3, 0, 1)
    out /= np.max(np.abs(out))
    out = np.tanh(1.8 * out) / np.tanh(1.8)  # glue: a soft clip so the track is dense, not peaky
    return out / np.max(np.abs(out)) * PEAK


# --------------------------------------------------------------------------------------------- pad style
PAD_CHORDS = [[57, 60, 64], [53, 57, 60], [48, 55, 64], [55, 59, 62]]  # Am F C G


def lowpass(x: np.ndarray, a: float) -> np.ndarray:
    n = len(x) + 4096
    w = 2 * np.pi * np.fft.rfftfreq(n)
    h = a / (1 - (1 - a) * np.exp(-1j * w))
    return np.fft.irfft(np.fft.rfft(x, n) * h, n)[: len(x)]


def synthesize_pad(duration: float, bpm: float, cuts: list[float], seed: int) -> np.ndarray:
    """The old slow pad: detuned saws, a light kick between the first and last cut, swells into cuts."""
    beat = 60.0 / bpm
    t = np.arange(int(round(SR * duration))) / SR
    out = np.zeros_like(t)
    span = beat * 8
    for i in range(int(np.ceil(duration / span))):
        mask = (t >= i * span - 0.3) & (t < i * span + span + 0.3)
        tt = t[mask] - i * span
        env = np.clip((tt + 0.3) / 0.6, 0, 1) * np.clip((span + 0.3 - tt) / 0.6, 0, 1)
        chord = PAD_CHORDS[i % 4]
        out[mask] += sum(2 * ((tt * midi_hz(m + d)) % 1.0) - 1 for m in chord + [chord[0] - 12]
                         for d in (-0.08, 0.08)) * env * 0.035
    out = lowpass(out, 0.06)
    tk = np.arange(int(0.35 * SR)) / SR
    k = np.sin(2 * np.pi * np.cumsum(45 + 70 * np.exp(-tk * 30)) / SR) * np.exp(-tk * 9)
    a, b = (cuts[0], cuts[-1]) if cuts else (0.0, duration)
    for i in range(int(np.ceil(a / beat)), int(b / beat)):
        s = int(round(i * beat * SR))
        m = min(len(k), len(out) - s)
        out[s:s + m] += k[:m] * (0.30 if i % 2 == 0 else 0.16)
    rng = np.random.default_rng(seed)
    for c in cuts:
        s, e = max(0, int((c - beat) * SR)), min(len(out), int(c * SR))
        if e > s:
            out[s:e] += rng.standard_normal(e - s) * np.linspace(0, 1, e - s) ** 2 * 0.05
    out *= np.clip(t / min(1.5, duration / 4), 0, 1) * np.clip((duration - t) / min(3.0, duration / 4), 0, 1)
    out = out / np.max(np.abs(out)) * PEAK
    return np.stack([out, out])


# ---------------------------------------------------------------------------------------------- io, check
def write_wav(path: str, stereo: np.ndarray) -> None:
    if os.path.exists(path):
        sys.exit(f"score.py: {path} exists, delete it first")
    pcm = (stereo.T * 32767).astype("<i2")
    with wave.open(path, "wb") as w:
        w.setnchannels(2)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(pcm.tobytes())


def read_wav(path: str) -> np.ndarray:
    raw = subprocess.run(["ffmpeg", "-v", "error", "-i", path, "-f", "f32le", "-ac", "2", "-ar", str(SR), "-"],
                         capture_output=True, check=True).stdout
    return np.frombuffer(raw, "<f4").reshape(-1, 2).T.astype(np.float64)


def from_segments(path: str) -> tuple[float, float | None, list[float], int]:
    film = json.load(open(path, encoding="utf-8"))
    if "total" not in film or "cuts" not in film:
        sys.exit(f"score.py: {path} has no total or cuts; run segments.py times first")
    return film["total"], film.get("bpm"), film["cuts"], film.get("seed", 1)


def ad_bpm(asked: float | None, from_file: float | None) -> float:
    if asked:
        return asked
    lo, hi = AD_BPM_RANGE
    return from_file if from_file and lo <= from_file <= hi else AD_BPM


def estimate_bpm(mono: np.ndarray) -> float:
    low = fft_filter(mono, lambda f: 1 / (1 + (f / 150) ** 4))
    hop = SR // 1000
    env = np.abs(low[: len(low) // hop * hop]).reshape(-1, hop).mean(1)
    onset = np.maximum(np.diff(env), 0)
    onset -= onset.mean()
    spec = np.fft.rfft(onset, 2 * len(onset))
    ac = np.fft.irfft(spec * np.conj(spec))[: len(onset)]
    lo, hi = int(60000 / 180), int(60000 / 90)
    lag = lo + int(np.argmax(ac[lo:hi]))
    a, b, c = ac[lag - 1], ac[lag], ac[lag + 1]
    lag += 0.5 * (a - c) / (a - 2 * b + c) if (a - 2 * b + c) else 0
    return 60000 / lag


def hit_offsets(mono: np.ndarray, cuts: list[float]) -> list[float]:
    """Per cut, the onset within 150 ms whose next 80 ms of air (above 4 kHz) most outweighs the 30 ms before."""
    high = fft_filter(mono, lambda f: np.clip((f - 4000) / 2000, 0, 1))
    hop = SR // 1000
    env = np.abs(high[: len(high) // hop * hop]).reshape(-1, hop).mean(1)
    out = []
    for c in cuts:
        j0 = int(c * 1000)
        best, best_j = -1.0, j0
        for j in range(max(30, j0 - 150), min(len(env) - 80, j0 + 150)):
            r = env[j:j + 80].mean() / (env[j - 30:j].mean() + 1e-9)
            if r > best:
                best, best_j = r, j
        out.append(best_j / 1000 - c)
    return out


def longest_gap(stereo: np.ndarray, floor_db: float = -45.0) -> float:
    mono = stereo.mean(0)[: -int(0.3 * SR)]
    w = int(0.05 * SR)
    rms = np.sqrt((mono[: len(mono) // w * w].reshape(-1, w) ** 2).mean(1))
    quiet = 20 * np.log10(rms + 1e-12) < floor_db
    run = best = 0
    for q in quiet:
        run = run + 1 if q else 0
        best = max(best, run)
    return best * 0.05


def loudness(path: str) -> tuple[float, float]:
    err = subprocess.run(["ffmpeg", "-hide_banner", "-nostats", "-i", path, "-af", "ebur128=peak=true",
                          "-f", "null", "-"], capture_output=True, text=True).stderr
    summary = err[err.rfind("Summary:"):]
    lufs = float(re.search(r"I:\s+(-?[\d.]+) LUFS", summary).group(1))
    peak = float(re.search(r"Peak:\s+(-?[\d.]+|-inf) dBFS", summary).group(1))
    return lufs, peak


def check(path: str, cuts: list[float], bpm: float | None, fps: int) -> bool:
    stereo = read_wav(path)
    mono = stereo.mean(0)
    lufs, tp = loudness(path)
    est = estimate_bpm(mono)
    offs = hit_offsets(mono, cuts)
    gap = longest_gap(stereo)
    frame = 1 / fps
    late = [(c, round(o * 1000)) for c, o in zip(cuts, offs) if abs(o) > frame]
    ok = tp < -1.0 and gap < 0.3 and not late and (bpm is None or abs(est - bpm) < 1.0)
    print(f"check {path}: {stereo.shape[1] / SR:.3f} s, {lufs} LUFS, true peak {tp} dBTP, "
          f"longest gap under -45 dBFS {gap:.2f} s, tempo {est:.2f} bpm"
          + (f" (asked {bpm:g})" if bpm else ""))
    if offs:
        worst = max(abs(o) for o in offs)
        print(f"  hits: {len(offs) - len(late)} of {len(offs)} within one frame ({frame * 1000:.1f} ms), "
              f"worst {worst * 1000:.0f} ms, offsets ms {[round(o * 1000) for o in offs]}")
    if late:
        print(f"  hits off the cut: {late}")
    print(f"  {'ok' if ok else 'FAILED'}")
    return ok


def describe(duration: float, bpm: float, cuts: list[float], style: str) -> str:
    if style == "pad":
        return "parts: pad"
    p = plan(duration, cuts, bpm)
    br = p["breather"]
    parts = [f"intro 0-{p['intro_end']:.2f}"]
    parts += [f"main {p['intro_end']:.2f}-{br[0]:.2f}", f"breather {br[0]:.2f}-{br[1]:.2f}",
              f"main {br[1]:.2f}-{p['end_at']:.2f}"] if br else [f"main {p['intro_end']:.2f}-{p['end_at']:.2f}"]
    parts.append(f"end hit {p['end_at']:.2f}, ring to {duration:.2f}")
    return f"key {KEY}, I V vi IV (A E F#m D); parts: " + ", ".join(parts)


def self_test() -> None:
    folder = tempfile.mkdtemp(prefix="score-test-")
    ok = True
    cuts = [4.0, 7.3, 11.1, 15.6, 19.9, 24.37]  # off the grid on purpose
    a, b = os.path.join(folder, "a.wav"), os.path.join(folder, "b.wav")
    for path in (a, b):
        _cache.clear()
        write_wav(path, synthesize_ad(30.0, 124, cuts, 7))
    same = open(a, "rb").read() == open(b, "rb").read()
    probe = subprocess.run(["ffprobe", "-v", "error", "-show_entries", "stream=sample_rate,channels:format=duration",
                            "-of", "default=nw=1", a], capture_output=True, text=True).stdout
    fmt = "sample_rate=48000" in probe and "channels=2" in probe and "duration=30.0" in probe
    stereo = read_wav(a)
    est = estimate_bpm(stereo.mean(0))
    offs = hit_offsets(stereo.mean(0), cuts)
    gap = longest_gap(stereo)
    peak = np.max(np.abs(stereo))
    p = plan(30.0, cuts, 124)
    has_parts = p["breather"] is not None and p["intro_end"] == 4.0 and p["end_at"] == 24.37
    other = os.path.join(folder, "c.wav")
    _cache.clear()
    write_wav(other, synthesize_ad(30.0, 124, cuts, 8))
    seeded = open(other, "rb").read() != open(a, "rb").read()
    pad = os.path.join(folder, "pad.wav")
    write_wav(pad, synthesize_pad(4.0, 120, [2.0], 7))
    checks = {
        "two renders identical": same,
        "another seed differs": seeded,
        "48 kHz stereo 30.0 s": fmt,
        f"tempo {est:.2f} within 1 of 124": abs(est - 124) < 1.0,
        f"hits within one frame, worst {max(abs(o) for o in offs) * 1000:.0f} ms": max(abs(o) for o in offs) <= 1 / FPS,
        f"no gap, longest {gap:.2f} s": gap < 0.3,
        f"peak {peak:.3f} at most 0.8": peak <= PEAK + 1e-3,
        "intro, breather and end found": has_parts,
        "bpm from file kept in range, 124 outside": ad_bpm(None, 120) == 120 and ad_bpm(None, 80) == 124,
        "pad style still renders": os.path.getsize(pad) > 4 * SR * 4 * 0.9,
    }
    for name, good in checks.items():
        print(f"  {'ok' if good else 'FAILED'}  {name}")
        ok = ok and good
    print(f"self test {'ok' if ok else 'FAILED'}: {folder}")
    sys.exit(0 if ok else 1)


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("out", nargs="?", help="the wav to write")
    ap.add_argument("--segments", help="segments.json written by segments.py times (and beat-snap.py)")
    ap.add_argument("--duration", type=float)
    ap.add_argument("--bpm", type=float, help="tempo; ad style default 124, or the file's when 118 to 128")
    ap.add_argument("--cuts", default="", help="comma separated cut times in seconds")
    ap.add_argument("--seed", type=int, default=None)
    ap.add_argument("--style", choices=("ad", "pad"), default="ad")
    ap.add_argument("--check", metavar="WAV", help="measure a rendered (or loudness normalised) file")
    ap.add_argument("--fps", type=int, default=FPS, help="frame rate for the hit check")
    ap.add_argument("--self-test", action="store_true")
    a = ap.parse_args()
    if a.self_test:
        self_test()
    if a.segments:
        duration, file_bpm, cuts, seed = from_segments(a.segments)
    else:
        duration, file_bpm, seed = a.duration, None, 1
        cuts = [float(c) for c in a.cuts.split(",") if c]
    seed = a.seed if a.seed is not None else seed
    cuts = sorted(cuts)
    bpm = ad_bpm(a.bpm, file_bpm) if a.style == "ad" else (a.bpm or file_bpm or 120)
    if a.check:
        sys.exit(0 if check(a.check, cuts, bpm if a.style == "ad" else None, a.fps) else 1)
    if not a.out or not duration:
        ap.error("give out.wav and --segments, or --duration")
    synth = synthesize_ad if a.style == "ad" else synthesize_pad
    write_wav(a.out, synth(duration, bpm, cuts, seed))
    print(f"score {a.out}: style {a.style}, {duration:.3f} s, {bpm:g} bpm, {len(cuts)} cuts, seed {seed}")
    print("  " + describe(duration, bpm, cuts, a.style))


main()
