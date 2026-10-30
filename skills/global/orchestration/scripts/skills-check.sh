#!/bin/bash
# Row Dc skills check. Usage: skills-check.sh <agent transcript .jsonl>
# Reads the `Skills you run:` line of the agent's first prompt and every skill it loaded (a Skill tool call,
# or a Read of <skill>/SKILL.md). Prints `skills: ok` (exit 0) when each listed skill was loaded;
# otherwise one `MISSING <skill>` line per skill and `skills: FAIL` (exit 1). No line in the prompt is a FAIL.
python3 - "$1" <<'PY'
import json, re, sys
listed, loaded, first = [], set(), None
for line in open(sys.argv[1], errors="replace"):
    try:
        d = json.loads(line)
    except Exception:
        continue
    m = d.get("message") or {}
    c = m.get("content")
    if first is None and m.get("role") == "user":
        first = c if isinstance(c, str) else " ".join(x.get("text", "") for x in c or [] if isinstance(x, dict))
        hit = re.search(r"^Skills you run:\s*(.+)$", first, re.M)
        listed = [x.strip(" .`") for x in re.split(r"[,;]", hit.group(1))] if hit else []
        listed = [x.split(" ")[0].strip(" .`") for x in listed if x]  # the line may run on: "a, b. Invoke ..."
    if isinstance(c, list):
        for x in c:
            if x.get("type") != "tool_use":
                continue
            i = x.get("input") or {}
            if x.get("name") == "Skill":
                loaded.add(str(i.get("skill", "")).split(":")[-1])
            if x.get("name") == "Read" and str(i.get("file_path", "")).endswith("/SKILL.md"):
                loaded.add(i["file_path"].split("/")[-2])
if not listed:
    print("FAIL no `Skills you run:` line in the first prompt"); print("skills: FAIL"); sys.exit(1)
missing = [s for s in listed if s not in loaded]
for s in missing:
    print("MISSING " + s)
print("listed=%d loaded=%d missing=%d" % (len(listed), len(set(listed) & loaded), len(missing)))
print("skills: ok" if not missing else "skills: FAIL"); sys.exit(1 if missing else 0)
PY
