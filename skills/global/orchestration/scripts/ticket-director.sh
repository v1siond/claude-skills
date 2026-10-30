#!/bin/bash
# One orchestration per ticket (SKILL.md law 6). Usage: ticket-director.sh <workspace> <ticket>
# Prints the brief the head director passes to the Agent tool (general-purpose, model opus, run in the background,
# so he sees it in the session's agents panel), and marks the ticket folder live. Refuses a 4th live director
# or a second one on the same ticket: `REFUSED <why>`. The slot is the folder's director.live file; the head director
# removes it when it folds the ticket's end status (READY TO REVIEW or STOP) into ORCHESTRA.md.
W=$1; T=$2; MAX=3
[ -f "$W/ORCHESTRA.md" ] || { echo "REFUSED no $W/ORCHESTRA.md"; exit 1; }
D=$(ls -d "$W/score/$T"-* "$W/score/${T//./-}"-* "$W/score/$T" 2>/dev/null | head -1); D=${D:-$W/score/$T}; mkdir -p "$D"
[ -f "$D/director.live" ] && { echo "REFUSED $T already has a live director ($D/director.live)"; exit 1; }
live=$(ls "$W"/score/*/director.live 2>/dev/null | wc -l)
[ "$live" -lt "$MAX" ] || { echo "REFUSED $live ticket directors live, the cap is $MAX"; exit 1; }
date -u +%FT%TZ > "$D/director.live"
cat <<EOF
You are the ticket director of row $T of $W/ORCHESTRA.md, and of that row only (orchestration law 6).
Invoke skill orchestration and run its Pipeline rows D1 to D7 for this ticket. The row's text on the live Score is his words; grep $W/PROMPT-LOG.md for every quote of his on this row.
Resume: when $D/log.md exists, read it and the row files first and continue from the last row it records; never redo a row that has its Output.
Write only in $D: log.md (one line per Pipeline row done, with its Output), status.txt (one line, the row status), and the row files. Never edit ORCHESTRA.md or PROMPT-LOG.md; the head director folds your files in.
Your players: launch them with the Agent tool, at most 2 live at once; run the orchestration scripts/agent-load.sh before each launch; each player prompt carries its Skills you run: line and says "no Agent tool, do the ticket yourself" and "never end your turn while a run of yours is live"; TaskStop each one when its report lands. Never end your turn while a player or a background run of yours is live: an ended director hears nothing, so wait for it in the foreground (while kill -0 PID; do sleep 20; done, with a 600000 ms timeout) or on its notification.
A STOP the skill gives to him (new work with no approved spec): write status.txt as STOP: <the question, with its context> and end.
At D7: status.txt READY TO REVIEW, the report in $D/report.md, then end with a 5 line summary. His look is not waited on. Never push.
EOF
