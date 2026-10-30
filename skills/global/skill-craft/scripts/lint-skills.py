#!/usr/bin/env python3
"""Lint every skill under /home/visiond/projects/claude/skills (or the folders given) against the skill framework
(`references/skill-framework.md`: the 14 sections and the writing tests W1 to W19 a script can check), the Anthropic
skills guide and his house rules. Exit 1 when any skill prints FAIL.

  lint-skills.py                      all skills, global/ and specific/*/
  lint-skills.py <skill-dir>...       only these
  lint-skills.py --counts             also print, per check, how many skills fail or warn on it
  lint-skills.py --no-sections-warn   framework checks print FAIL instead of WARN

A full run (no folder argument) also checks the public files (PUBLIC_ROOTS) for the terms listed in
~/.claude/local-skills/public-terms.txt, one literal per line, and FAILs with file:line, never the term; with no
such file it says nothing. Project rows and retired names live in the private overlay, skills/specific
(trigger-queries.json and retired.txt), read when present.

Install: python3 with PyYAML (`pip install pyyaml`). Pass output for one skill: `ok   <name>`.

Two kinds of check:
  hard       the checks this lint always had (frontmatter, W18 description and name, triggers, siblings, canon,
             symlink, trigger row, body length, dashes, linked paths, scripts executable, collisions, quote). Always FAIL.
  framework  the 14 sections in order, the title, body-min (80 lines), W9, W15, W16, the
             letter-of-the-law line and the Definition of done box. With --sections-warn they print WARN and do not
             set the exit code.
--sections-warn is the default until the director says the skills reset is done, because the skills
not yet rewritten in the framework would otherwise all FAIL and block every other check. When the director says
it is done, flip the default to False in main() and delete this paragraph.
"""
from __future__ import annotations
import argparse, json, re, sys, pathlib
from collections import Counter
import yaml

# Skills live in skills/global/<name> and skills/specific/<common|project>/<name>, symlinked into ~/.claude/skills.
ROOT = pathlib.Path("/home/visiond/projects/claude/skills")
NAME_RE = re.compile(r"^[a-z0-9]+(-[a-z0-9]+)*$")
DASHES = re.compile("[\u2014\u2013]")
LINK_RE = re.compile(r"`((?:references|scripts|examples)/[^`\s]+)`")
LINKS = pathlib.Path.home() / ".claude" / "skills"
QUERIES = ROOT / "global/skill-craft/references/trigger-queries.json"
# The private overlay (skills/specific, its own repo) keeps the project skills' rows and retired names.
PRIVATE_QUERIES = ROOT / "specific/trigger-queries.json"
PRIVATE_RETIRED = ROOT / "specific/retired.txt"
# Proper names and ids of his projects, kept outside every repo; the public tree must hold none of them.
TERMS = pathlib.Path.home() / ".claude/local-skills/public-terms.txt"
PUBLIC_ROOTS = ["skills/global", "agents", "harness", "docs", "standards", "README.md"]
# Plugin skills a Do NOT line may name; the harness installs them outside this tree.
PLUGIN_SKILLS = {"frontend-design:frontend-design", "anthropic-skills:deep-research", "superpowers:receiving-code-review",
                 "superpowers:systematic-debugging", "superpowers:brainstorming", "code-review:code-review"}
# Phrases two skills claim on purpose, so the router prints both.
SHARED = {"ui development": {"ui", "engineering-standards"}}
BODY_MAX = 200  # skill-framework.md: 80 to 200 lines in SKILL.md, detail in references/
BODY_MIN = 80   # same rule; under 80 lines the 14 sections cannot each hold a check
REF_CONTENTS_AT = 100  # W16: a reference over 100 lines opens with ## Contents (Anthropic best practices)
ROWS = {r["skill"] for q in (QUERIES, PRIVATE_QUERIES) if q.exists() for r in json.loads(q.read_text())}
CLAIMS = {}  # (scope, phrase) -> [skill]

# The 14 framework sections, in order (skill-framework.md "The sections, in this order", rows 2 to 14).
SECTIONS = ["When to use", "When not to use", "Stance", "Non-negotiables", "Red flags", "Intake", "Pipeline",
            "Gotchas", "Deliverables", "Check it before you show it", "Critic loop", "Definition of done",
            "References", "Evals"]
# quote: his feedback is turned into an instruction, never pasted (skill-framework.md Rules). A `*"..."*` quote or a
# dated `10-24: "..."` quote outside backticks, or a *prompts*.md file, means feedback was pasted instead of turned into a step.
HIS_QUOTE = re.compile(r"\*\"[^\"]+\"\*|\b[01]\d-[0-3]\d(?: [0-2]\d:[0-5]\d)?[,:)]? *\*?\"|\b[Hh]is words, [01]\d-")  # italic, dated like 10-24: "..., or a "His words, 10-24" lead-in
LAW_LINE = "Violating the letter of a law is violating the law."
FIX_NEXT = "what you would fix next"
FRAMEWORK = {"sections", "body-min", "W9", "W15", "W16", "law-line", "dod-box"}
# W9: shouting added by us. Status tokens and acronyms are single words, so only these three and runs of 3 or more
# capitalised words count. A line that states the rule names the words in backticks or quotes (QUOTED strips them)
# or as a list of 3 or more different words joined by commas, "or" or "and" (LISTED strips it: "no IMPORTANT, CRITICAL or MUST").
SHOUT = re.compile(r"\b(IMPORTANT|CRITICAL|MUST)\b")
_SW = r"(?:IMPORTANT|CRITICAL|MUST|ALWAYS|NEVER)"
LISTED = re.compile(rf"\b{_SW}(?:(?:, (?:or |and )?| or | and ){_SW}){{2,}}\b")  # 3 or more words names the rule; 2 is a shout
CAPS_RUN = re.compile(r"\b[A-Z]{2,}(?:'[A-Z]+)?(?: [A-Z]{2,}(?:'[A-Z]+)?){2,}\b")  # a comma list (BUILT, DONE or PNG, GIF) is tokens
CAPS_SENT = re.compile(r"(?:^[-*>\s]*|[.!?:|] |\*\*)[A-Z]{2,}(?:'[A-Z]+)?(?: [A-Z]{2,}(?:'[A-Z]+)?)+(?:[.!]|\*\*|\s*\||\s*$)")  # a whole sentence in capitals, 2 words or more
QUOTED = re.compile(r"`[^`]*`|\*\"[^\"]*\"\*|\"[^\"]*\"|\u201c[^\u201d]*\u201d")
# W15: skills folded or deleted in the reset (ORCHESTRA.md D3); a live line naming one points nowhere.
RETIRED = {"dev-flow"} | (set(PRIVATE_RETIRED.read_text().split()) if PRIVATE_RETIRED.exists() else set())
SKILL_REF = re.compile(r"(?:\bskills?:? `?|→ `?)([a-z][a-z0-9]*(?:-[a-z0-9]+)+)(?![:\w-])")  # plugin:name is not ours
# Only paths into this machine's tree: /cv or /demo are app routes, /tmp files exist only while a job runs.
ABS_PATH = re.compile(r"`((?:/home/|~/)[^`\s]+)`")


def covers(trigger: str, phrase: str) -> bool:
    return phrase == trigger or (trigger.endswith("*") and phrase.startswith(trigger[:-1]))


def check_triggers(d, fm, desc) -> list[tuple[str, str]]:
    errs, meta = [], fm.get("metadata") or {}
    trig = [str(t).lower() for t in meta.get("triggers") or []]
    if not trig: return [("triggers", "metadata.triggers missing (the router reads it)")]
    for q in re.findall(r'"([^"]+)"', desc):
        if not any(covers(t, q.lower()) for t in trig): errs.append(("triggers", f"quoted phrase not in triggers: {q}"))
    root = meta.get("root")
    roots = root if isinstance(root, list) else [root] if root else []
    for r in roots:
        if not pathlib.Path(r).is_dir(): errs.append(("triggers", f"metadata.root missing on disk: {r}"))
    if d.parent.name not in ("global", "common") and not roots: errs.append(("triggers", "project skill has no metadata.root"))
    if meta.get("always") and not roots: errs.append(("triggers", "metadata.always without metadata.root (the router would print it everywhere)"))
    for scope in roots or ["global"]:
        for t in trig: CLAIMS.setdefault((scope, t), []).append(d.name)
    return errs


def skill_exists(n: str) -> bool:
    return n in PLUGIN_SKILLS or (LINKS / n / "SKILL.md").exists()


def check_siblings(desc) -> list[tuple[str, str]]:
    tail = desc.split("Do NOT use", 1)[-1]
    names = [n.strip() for grp in re.findall(r"\(([^)]*)\)", tail) for n in grp.split(",")]
    return [("siblings", f"Do NOT names a skill that does not exist: {n}") for n in names
            if re.fullmatch(r"[a-z0-9:-]+", n) and not skill_exists(n)]


def check_canon(d) -> list[tuple[str, str]]:
    canon = d / "references" / "canon.txt"
    if not canon.exists(): return []
    text = "\n".join(f.read_text(errors="ignore") for f in [d / "SKILL.md", *sorted((d / "references").glob("*.md"))])
    out = []
    for ln in canon.read_text().splitlines():
        if not ln.strip() or ln.startswith("#"): continue
        label, rx = ln.split("\t", 1)
        if not re.search(rx, text): out.append(("canon", f"canon rule lost: {label}"))
    return out


def prose_lines(text: str):
    """(line number, line) outside fenced code blocks."""
    fenced = False
    for i, ln in enumerate(text.splitlines(), 1):
        if ln.lstrip().startswith("```"):
            fenced = not fenced
            continue
        if not fenced: yield i, ln


def section_body(body: str, title: str) -> str:
    m = re.search(rf"^## {re.escape(title)}\b[^\n]*\n(.*?)(?=^## |\Z)", body, re.S | re.M)
    return m.group(1) if m else ""


def check_sections(body: str) -> list[tuple[str, str]]:
    """Title, spec line, then exactly the 14 headings in order (a heading may add a suffix: '## Stance: the director')."""
    errs = []
    lines = [ln for _, ln in prose_lines(body)]
    first = next((ln for ln in lines if ln.strip()), "")
    if not first.startswith("# "): errs.append(("sections", "body does not open with the '# Title' line"))
    heads = [ln[3:].strip() for ln in lines if ln.startswith("## ")]
    names = [next((s for s in SECTIONS if h == s or h.startswith(s + ":")), None) for h in heads]
    for h, n in zip(heads, names):
        if n is None: errs.append(("sections", f"heading not in the framework: ## {h}"))
    found = [n for n in names if n]
    for s in SECTIONS:
        if s not in found: errs.append(("sections", f"missing section ## {s}"))
    present = [s for s in SECTIONS if s in found]
    if [n for n in found if n in present] != present or len(found) != len(set(found)):
        errs.append(("sections", f"sections out of order or repeated: {', '.join(found)}"))
    if LAW_LINE not in body: errs.append(("law-line", f"missing '{LAW_LINE}'"))
    dod = section_body(body, "Definition of done")
    boxes = [ln for ln in dod.splitlines() if ln.lstrip().startswith("- [")]
    if not boxes or FIX_NEXT not in boxes[-1]: errs.append(("dod-box", f"Definition of done does not end with the box '{FIX_NEXT}'"))
    if dod and "Anything less, say so plainly." not in dod: errs.append(("dod-box", "Definition of done lacks 'Anything less, say so plainly.'"))
    return errs


def own_md(d: pathlib.Path) -> list[pathlib.Path]:
    """SKILL.md and the reference files."""
    refs = sorted((d / "references").glob("*.md")) if (d / "references").is_dir() else []
    return [d / "SKILL.md", *refs]


def check_quotes(d: pathlib.Path) -> list[tuple[str, str]]:
    errs = [("quote", f"prompts file: {f.relative_to(d)} (turn its feedback into steps, then remove it)") for f in d.rglob("*prompts*.md")]
    for f in own_md(d):
        for i, ln in prose_lines(f.read_text(errors="ignore")):
            if HIS_QUOTE.search(re.sub(r"`[^`]*`", "", ln)): errs.append(("quote", f"{f.relative_to(d)}:{i} his words pasted; write the instruction they ask for"))
    return errs


def shout(ln: str):
    """The first shout in a line, or None. A quoted word, or a list of 3 or more different shout words, names the rule."""
    bare = QUOTED.sub("", re.sub(r'"(IMPORTANT|CRITICAL|MUST)"', "", ln))
    bare = LISTED.sub(lambda m: "" if len(set(re.findall(_SW, m.group(0)))) >= 3 else m.group(0), bare)
    return SHOUT.search(bare) or CAPS_RUN.search(bare) or CAPS_SENT.search(bare)


def check_w9(d: pathlib.Path) -> list[tuple[str, str]]:
    errs = []
    for f in own_md(d):
        text, off = f.read_text(errors="ignore"), 0
        if f.name == "SKILL.md":  # the frontmatter's "Do NOT" is the house shape; line numbers stay file lines
            fm = text.split("\n---\n", 1)[0]
            for j, ln in enumerate(fm.splitlines(), 1):  # the description line itself, without its "Do NOT"
                hit = ln.startswith("description:") and (shout(ln.replace("Do NOT", "")) or shout(" ".join(str(yaml.safe_load(fm.split("---",1)[-1]).get("description","")).split()).replace("Do NOT", "")))
                if hit: errs.append(("W9", f"SKILL.md:{j} shouting in the description: {hit.group(0).lstrip('.!?: ')}"))
            off = fm.count("\n") + 2
            text = text.split("\n---\n", 1)[-1]
        for i, ln in prose_lines(text):
            i += off
            if ln.lstrip().startswith(">"): continue  # a blockquote is a quote
            hit = shout(ln)
            if hit: errs.append(("W9", f"{f.relative_to(d)}:{i} shouting outside a quote: {hit.group(0).lstrip('.!?: ')}"))
    return errs


def check_w15(d: pathlib.Path, body: str, off: int = 0) -> list[tuple[str, str]]:
    """off: the frontmatter line count, so SKILL.md line numbers are file lines."""
    errs = []
    for f in own_md(d):
        text = body if f.name == "SKILL.md" else f.read_text(errors="ignore")
        for i, ln in prose_lines(text):
            i += off if f.name == "SKILL.md" else 0
            for p in ABS_PATH.findall(ln):
                if any(c in p for c in "<>*{}$|") or "..." in p or "/:" in p: continue  # a placeholder or a pattern
                p = re.sub(r"(:\d+.*|#.*|[.,;)]+)$", "", p)
                if not pathlib.Path(p).expanduser().exists(): errs.append(("W15", f"{f.relative_to(d)}:{i} path does not resolve: {p}"))
    for i, ln in prose_lines(body):
        i += off
        bare = QUOTED.sub(lambda m: m.group(0) if m.group(0).startswith("`") else "", ln)
        names = set(SKILL_REF.findall(bare))
        if ln.lstrip("- ").startswith("Skills:"):
            names |= {n.strip(" .`") for n in ln.split(":", 1)[1].split(",")}
        names |= {n for n in RETIRED if re.search(rf"\b{n}\b", bare)}
        for n in sorted(names):
            if NAME_RE.match(n) and "-" in n and not skill_exists(n):
                errs.append(("W15", f"SKILL.md:{i} names a skill that does not exist: {n}"))
    if (d / "references").is_dir():
        for r in sorted((d / "references").iterdir()):
            if r.is_file() and f"references/{r.name}" not in body:
                errs.append(("W15", f"references/{r.name} is not linked from SKILL.md (one level deep)"))
    return errs


def check_w16(d: pathlib.Path) -> list[tuple[str, str]]:
    errs = []
    for r in sorted((d / "references").glob("*.md")) if (d / "references").is_dir() else []:
        text = r.read_text(errors="ignore")
        head = "\n".join(text.splitlines()[:15])  # "opens with": the Contents heading sits in the first 15 lines
        if text.count("\n") > REF_CONTENTS_AT and not re.search(r"^## Contents\b", head, re.M):
            errs.append(("W16", f"references/{r.name} is {text.count(chr(10))} lines and has no ## Contents in its first 15 lines"))
    return errs


def lint(d: pathlib.Path) -> list[tuple[str, str]]:
    errs, md = [], d / "SKILL.md"
    if not md.exists(): return [("frontmatter", "no SKILL.md")]
    if (d / "README.md").exists(): errs.append(("readme", "README.md inside the skill folder"))
    text = md.read_text()
    m = re.match(r"^---\n(.*?)\n---\n", text, re.S)
    if not m: return [("frontmatter", "no frontmatter")]
    try: fm = yaml.safe_load(m.group(1))
    except yaml.YAMLError as e: return [("frontmatter", f"frontmatter YAML: {e}".splitlines()[0])]
    name, desc = fm.get("name", ""), fm.get("description", "")
    if name != d.name: errs.append(("W18", f"name '{name}' != folder '{d.name}'"))
    if not NAME_RE.match(name or ""): errs.append(("W18", "name not kebab-case"))
    if not 1 <= len(desc) <= 1024: errs.append(("W18", f"description length {len(desc)} (1 to 1024)"))
    if "<" in m.group(1) or ">" in m.group(1): errs.append(("W18", "< or > in frontmatter"))
    if "Do NOT use" not in desc: errs.append(("W18", "description has no 'Do NOT use' negative trigger"))
    if not (fm.get("metadata") or {}).get("version"): errs.append(("version", "metadata.version missing"))
    errs += check_triggers(d, fm, desc) + check_siblings(desc) + check_canon(d)
    link = LINKS / d.name
    if not link.exists() or link.resolve() != d.resolve(): errs.append(("symlink", f"symlink missing or wrong: {link}"))
    if d.name not in ROWS: errs.append(("trigger-row", "no row in references/trigger-queries.json"))
    body = text[m.end():]
    lines = body.count("\n")
    if lines > BODY_MAX: errs.append(("body-length", f"body {lines} lines (at most {BODY_MAX}, move detail to references/)"))
    if lines < BODY_MIN: errs.append(("body-min", f"body {lines} lines (at least {BODY_MIN})"))
    for f in d.rglob("*"):
        if f.is_file() and f.suffix in {".md", ".sh", ".py", ".mjs", ".exs", ".json"} and DASHES.search(f.read_text(errors="ignore")):
            errs.append(("dashes", f"em/en dash in {f.relative_to(d)}"))
    for rel in set(LINK_RE.findall(body)):
        if not (d / rel.split("#")[0]).exists(): errs.append(("linked-path", f"linked path missing: {rel}"))
    for s in (d / "scripts").glob("*") if (d / "scripts").exists() else []:
        if s.suffix in {".sh", ".py"} and not s.stat().st_mode & 0o111: errs.append(("script-exec", f"script not executable: {s.name}"))
    errs += check_sections(body) + check_w9(d) + check_w15(d, body, text[:m.end()].count("\n")) + check_w16(d) + check_quotes(d)
    return errs


def check_public_terms() -> list[str]:
    """FAIL lines for every public file line holding a term of TERMS; [] with a note when TERMS is absent."""
    if not TERMS.exists(): return []
    terms = [t.lower() for t in TERMS.read_text().splitlines() if t.strip()]
    repo, out = ROOT.parent, []
    files = [p for r in PUBLIC_ROOTS for p in ([repo / r] if (repo / r).is_file() else (repo / r).rglob("*"))]
    for f in sorted(p for p in files if p.is_file() and "__pycache__" not in p.parts):
        try: lines = f.read_text().splitlines()
        except UnicodeDecodeError: continue  # fonts and images
        for i, ln in enumerate(lines, 1):
            if any(t in ln.lower() for t in terms): out.append(f"{f.relative_to(repo)}:{i}")
    return out


def collisions() -> dict[str, list[tuple[str, str]]]:
    out = {}
    for (scope, t), owners in CLAIMS.items():
        if len(owners) > 1 and set(owners) != SHARED.get(t):
            for o in owners: out.setdefault(o, []).append(("collision", f"trigger '{t}' also claimed by {', '.join(x for x in owners if x != o)} in {scope}"))
    return out


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("dirs", nargs="*")
    # The default stays True until the director says the reset is done (see the docstring); python3 here is 3.8,
    # which has no BooleanOptionalAction, so the pair is spelled out.
    ap.add_argument("--sections-warn", dest="sections_warn", action="store_true", default=True,
                    help="framework checks print WARN (the default)")
    ap.add_argument("--no-sections-warn", dest="sections_warn", action="store_false",
                    help="framework checks print FAIL")
    ap.add_argument("--counts", action="store_true", help="print, per check, the skills that fail or warn on it")
    a = ap.parse_args()
    dirs = [pathlib.Path(x).expanduser().resolve() for x in a.dirs] or sorted(
        p.parent for g in ("global/*/SKILL.md", "specific/*/*/SKILL.md") for p in ROOT.glob(g))
    results = {d: lint(d) for d in dirs}
    clash = collisions()
    bad, per_check, verdicts = 0, Counter(), Counter()
    for d, errs in results.items():
        errs = errs + clash.get(d.name, [])
        hard = [e for e in errs if not (a.sections_warn and e[0] in FRAMEWORK)]
        status = "FAIL" if hard else "WARN" if errs else "ok  "
        verdicts[status.strip()] += 1
        print(f"{status} {d.name}")
        for check, msg in errs:
            print(f"       {'WARN ' if (check, msg) not in hard else ''}[{check}] {msg}")
        for check in {c for c, _ in errs}: per_check[check] += 1
        bad += bool(hard)
    if not a.dirs:
        leaks = check_public_terms()
        if TERMS.exists(): print(f"terms: {len(leaks)} public line(s) hold a private term ({', '.join(PUBLIC_ROOTS)})")
        for where in leaks: print(f"FAIL [terms] {where} holds a term of {TERMS.name}")
        bad += bool(leaks)
    if a.counts:
        print(f"\nskills: {len(results)}  ok {verdicts['ok']}  WARN {verdicts['WARN']}  FAIL {verdicts['FAIL']}")
        print("check         skills hit  kind")
        for check, n in sorted(per_check.items(), key=lambda x: (-x[1], x[0])):
            print(f"{check:<13} {n:>10}  {'framework' if check in FRAMEWORK else 'hard'}")
    sys.exit(1 if bad else 0)


main()
