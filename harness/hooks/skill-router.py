#!/usr/bin/env python3
"""UserPromptSubmit hook: name the skills a prompt needs, in one line, so they trigger every time.

The table is built from the skills themselves: every ~/.claude/skills/*/SKILL.md frontmatter carries
metadata.triggers (lowercase phrases, a trailing * marks a stem) and, for a project skill, metadata.root
(its repo folder or a list of them). Global skills match in every folder, project skills only under their
root and are listed first. A project skill with metadata.always: true is listed on every prompt under its root,
matched or not, so its repo's expert loads even when no phrase is typed. HAND holds the few rows a phrase list cannot say. The skills are kept by the
skill-craft skill; who runs which skill is in orchestration references/skill-map.md.
"""
import json, os, re, sys, pathlib

try:
    import yaml
except ImportError:  # the hook must never break a prompt
    yaml = None

SKILLS = pathlib.Path.home() / ".claude" / "skills"
# The catalogue sits at the root of the skills tree the installed skill links point into.
CATALOG = str((SKILLS / "skill-craft").resolve().parents[1] / "SKILLS.md")
MAX_HITS = 6

# Rows a phrase list cannot express: a URL, a ticket code (case sensitive), a key chord, a lookahead.
HAND = [
    ("ship", r"\brelease\b(?! notes)|\btag\b", 0),
    ("research", r"https?://(?!\S*youtu)", 0),
    ("research", r"youtu\.?be", 0),
    ("orchestration", r"\b[A-Z]\d{1,2}\b", "case"),
    ("motion-video", r"\bfilms?\b|\bcaptions?\b|\bsegments\b|cuts? on the beat|\bscore (under|over|for) (it|the)", 0),
]

# A review goes first: the skill, the screen (ui) or review.
REVIEW = r"^\W*(please |can you |now )?(\w+ )?review\b|\breview (this|the|my|our|it|that|these|for|\S+\.\w+)\b|\b(security|performance|perf|code|test|senior|ui|ux|design) review|review as a senior"
UI_WORDS = r"\b(ui|ux|design|screen|page|panel|layout|dashboard|landing)\b"

WORK = r"\b(fix|build|implement|add|make|change|work on|continue|next ticket|pick up|finish)\b"
NON_DEV = {"writing", "session-start", "skill-craft"}


def phrase_rx(phrase):
    stem = phrase.endswith("*")
    parts = []
    for ch in phrase.rstrip("*"):
        if ch == " ": parts.append(r"[\s-]+")
        elif ch == "-": parts.append(r"[\s-]?")
        elif ch == "'": parts.append(r"['’]?")
        else: parts.append(re.escape(ch))
    tail = r"[a-z0-9]*" if stem else r"(?:s|es|ed|ing|d)?(?![a-z0-9])"
    return r"(?<![a-z0-9])" + "".join(parts) + tail


def frontmatter(md):
    text = md.read_text(errors="ignore")
    m = re.match(r"^---\n(.*?)\n---\n", text, re.S)
    return yaml.safe_load(m.group(1)) if m else None


def in_scope(cwd, root):
    if not root: return True
    roots = root if isinstance(root, list) else [root]
    return any(cwd == r or cwd.startswith(r.rstrip("/") + "/") for r in roots)


def load(cwd):
    """[(name, is_project, compiled phrase regex, always)] for the skills in scope."""
    table = []
    for md in sorted(SKILLS.glob("*/SKILL.md")):
        try: fm = frontmatter(md)
        except Exception: continue
        if not fm: continue
        meta = fm.get("metadata") or {}
        root = meta.get("root")
        if not in_scope(cwd, root): continue
        trig = [str(t).lower() for t in meta.get("triggers") or []]
        rx = re.compile("|".join(phrase_rx(t) for t in trig)) if trig else None
        table.append((fm.get("name", md.parent.name), bool(root), rx, bool(root and meta.get("always"))))
    return table


def review_skill(low):
    if not re.search(REVIEW, low): return None
    if re.search(r"\bskills?\b", low): return "skill-craft"
    if re.search(UI_WORDS, low): return "ui"
    return "review"


def match(prompt, cwd):
    low = prompt.lower()
    table = load(cwd)
    names = {n for n, _, _, _ in table}
    scored = []
    for name, is_project, rx, always in table:
        found = [m.group(0) for m in rx.finditer(low)] if rx else []
        if found:
            scored.append((not is_project, -max(len(f.split()) for f in found), name))
        elif always:  # after the matched project skills, before the globals
            scored.append((False, 0, name))
    for name, rx, flag in HAND:
        if name not in names or any(s[2] == name for s in scored): continue
        if re.search(rx, prompt if flag == "case" else low):
            project = next(p for n, p, _, _ in table if n == name)
            scored.append((not project, -1, name))
    hits = [name for _, _, name in sorted(scored)]
    review = review_skill(low)
    if review:
        hits = [h for h in hits if h != review]
        hits.insert(0, review)
    return hits[:MAX_HITS]


def line(prompt, cwd):
    hits = match(prompt, cwd)
    dev = [h for h in hits if h not in NON_DEV]
    work = re.search(WORK, prompt.lower()) or re.search(r"\b[A-Z]\d{1,2}\b", prompt)
    if "orchestration" in hits or (work and dev):
        rest = [h for h in hits if h != "orchestration"]
        return ("SKILL CHECK: orchestration is the workflow for this task (the director sizes it and casts the"
                " players). Cast the players' skills from orchestration references/skill-map.md."
                + (" Matched for this prompt: " + ", ".join(rest) + "." if rest else ""))
    if not hits:
        return ("SKILL CHECK: no trigger matched. Before acting, read the name list at the top of " + CATALOG
                + " and then only the section of the skill that fits; invoke it. If none does, say so in one"
                " line and add one (skill skill-craft).")
    return "SKILL CHECK: " + ", ".join(hits) + ". Invoke the ones that fit with the Skill tool before acting, and work by their steps."


def main():
    if os.environ.get("SKILL_ROUTER_OFF") or yaml is None: return
    try: data = json.load(sys.stdin)
    except ValueError: return
    prompt = data.get("prompt") or ""
    if "<task-notification>" in prompt or "SYSTEM NOTIFICATION" in prompt: return
    print(line(prompt, data.get("cwd") or ""))


if __name__ == "__main__":
    main()
