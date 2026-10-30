#!/usr/bin/env python3
"""ci-coverage: fail when the repo's CI runs a check that no pre-deploy gate runs, or runs on a floating runner.

    ci-coverage.py <repo-root> <gates-file>

<gates-file> holds one gate command per line (pre-deploy.sh writes it). Reads .github/workflows/*.yml and
.gitlab-ci.yml. For every CI command that is not an install, setup or deploy line, some gate must start with the
same tool and subcommand (`mix test`, `npm run lint`) and carry every flag of the CI line, plus every KEY=value
the CI step sets in its env (DATABASE_URL, MIX_ENV and ${{ }} secrets aside). A job on `*-latest` fails too:
the runner OS moves under pinned tools (a Playwright pin had no browser for the new Ubuntu, CI went red).
Prints one line per gap and `ci-coverage: ok (<n> CI checks covered)`; exit 1 on any gap.
"""
import glob
import os
import re
import shlex
import sys

import yaml

SKIP = re.compile(
    r"^(npm (ci|install)|npx playwright install|yarn( install)?$|pnpm install|mix (deps\.get|local\.|assets\.setup)"
    r"|bundle install|pip install|sudo |apt(-get)? |echo |cat |cd |mkdir |cp |mv |rm |export |railway |curl |wget )"
)
ENV_IGNORED = {"DATABASE_URL", "MIX_ENV", "CI", "PGHOST", "PGUSER", "PGPASSWORD", "RAILS_ENV", "NODE_ENV"}
PREFIX = re.compile(r"^((env( -u \S+)*|mise exec --|bundle exec|[A-Z_][A-Z0-9_]*=\S+)\s+)+")


def split_lines(run):
    for raw in str(run).splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        for part in re.split(r"\s*&&\s*", line):
            yield part.strip()


def strip_prefix(cmd):
    return PREFIX.sub("", cmd).strip()


def github_checks(root):
    checks, floating = [], []
    for path in sorted(glob.glob(os.path.join(root, ".github/workflows/*.y*ml"))):
        doc = yaml.safe_load(open(path)) or {}
        for job_name, job in (doc.get("jobs") or {}).items():
            runs_on = str(job.get("runs-on", ""))
            if runs_on.endswith("-latest"):
                floating.append(f"{os.path.basename(path)} job {job_name}: runs-on {runs_on}")
            job_env = job.get("env") or {}
            for step in job.get("steps") or []:
                if "run" not in step:
                    continue
                env = {**job_env, **(step.get("env") or {})}
                for cmd in split_lines(step["run"]):
                    checks.append((step.get("name", cmd), cmd, env))
    return checks, floating


def gitlab_checks(root):
    path = os.path.join(root, ".gitlab-ci.yml")
    if not os.path.exists(path):
        return []
    doc = yaml.safe_load(open(path)) or {}
    checks = []
    for name, job in doc.items():
        if not isinstance(job, dict) or "script" not in job:
            continue
        env = job.get("variables") or {}
        for line in job["script"]:
            for cmd in split_lines(line):
                checks.append((name, cmd, env))
    return checks


def covered(cmd, env, gates):
    want = shlex.split(strip_prefix(cmd))
    if len(want) < 2:
        return True
    need_env = [f"{k}={v}" for k, v in env.items()
                if k not in ENV_IGNORED and "${{" not in str(v) and "$" not in str(v)]
    for gate in gates:
        have = tokens(gate)
        # The CI command may sit anywhere in the gate (after env, inside `docker run ... bash -c '...'`).
        starts = [i for i in range(len(have) - 1) if have[i:i + 2] == want[:2]]
        if not any(set(want[2:]) <= set(have[i + 2:]) for i in starts):
            continue
        if all(e in gate for e in need_env):
            return True
    return False


def tokens(cmd):
    """Every word of cmd, with quoted inner commands (bash -c '...') opened up too."""
    try:
        words = shlex.split(cmd)
    except ValueError:
        words = cmd.split()
    out = []
    for w in words:
        out.extend(tokens(w) if " " in w else [w])
    return out


def main():
    root, gates_file = sys.argv[1], sys.argv[2]
    gates = [g.strip() for g in open(gates_file) if g.strip()]
    checks, floating = github_checks(root)
    checks += gitlab_checks(root)
    gaps = [f"floating runner: {f}, pin the OS version (ubuntu-24.04)" for f in floating]
    n = 0
    for name, cmd, env in checks:
        if SKIP.match(strip_prefix(cmd)):
            continue
        n += 1
        if not covered(cmd, env, gates):
            extra = " ".join(f"{k}={v}" for k, v in env.items() if k not in ENV_IGNORED and "$" not in str(v))
            gaps.append(f"no gate runs CI step '{name}': {cmd}" + (f" (with {extra})" if extra else ""))
    for g in gaps:
        print(g)
    if gaps:
        print(f"ci-coverage: {len(gaps)} gap(s), add the gate to the repo profile or pin the runner")
        sys.exit(1)
    print(f"ci-coverage: ok ({n} CI checks covered)")


if __name__ == "__main__":
    main()
