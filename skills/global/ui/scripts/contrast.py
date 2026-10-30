#!/usr/bin/env python3
"""WCAG 2.x contrast ratio between colour pairs, with the AA and AAA verdicts.

  contrast.py <fg> <bg> [<fg> <bg> ...]

Colours are hex (#111, #1a1a1a) or rgb(r,g,b). Prints one line per pair: ratio, and pass or fail for
AA normal text (4.5), AA large text and UI parts (3.0), AAA normal (7.0), AAA large (4.5).
Exit code 1 when any pair fails AA normal text, so a loop over a palette can gate on it.
"""
import re
import sys


def parse(colour):
    value = colour.strip().lower()
    rgb = re.fullmatch(r"rgba?\((\d+),\s*(\d+),\s*(\d+)(?:,\s*[\d.]+)?\)", value)
    if rgb:
        return tuple(int(part) for part in rgb.groups())
    hexed = value.lstrip("#")
    if len(hexed) == 3:
        hexed = "".join(ch * 2 for ch in hexed)
    if not re.fullmatch(r"[0-9a-f]{6}", hexed):
        raise ValueError(f"not a colour: {colour}")
    return tuple(int(hexed[i:i + 2], 16) for i in (0, 2, 4))


def channel(value):
    srgb = value / 255
    return srgb / 12.92 if srgb <= 0.04045 else ((srgb + 0.055) / 1.055) ** 2.4


def luminance(rgb):
    red, green, blue = (channel(v) for v in rgb)
    return 0.2126 * red + 0.7152 * green + 0.0722 * blue


def ratio(fg, bg):
    light, dark = sorted((luminance(parse(fg)), luminance(parse(bg))), reverse=True)
    return (light + 0.05) / (dark + 0.05)


def verdict(value, threshold):
    return "pass" if value >= threshold else "FAIL"


def main(args):
    if not args or len(args) % 2:
        sys.exit("usage: contrast.py <fg> <bg> [<fg> <bg> ...]")
    failed = False
    for fg, bg in zip(args[::2], args[1::2]):
        value = ratio(fg, bg)
        failed = failed or value < 4.5
        print(f"{fg} on {bg}: {value:.2f}:1  AA {verdict(value, 4.5)}  AA-large {verdict(value, 3.0)}"
              f"  AAA {verdict(value, 7.0)}  AAA-large {verdict(value, 4.5)}")
    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main(sys.argv[1:])
