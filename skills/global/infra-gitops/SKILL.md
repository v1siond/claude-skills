---
name: infra-gitops
description: "Infrastructure GitOps on Kubernetes, invoked before a cluster, manifest or secret is touched, for any app run by ArgoCD from git (kustomize or Helm, an image updater, ExternalSecrets from OpenBao or Vault, OpenTofu or terraform), and for setting up a new app the same way (an app of apps, one overlay per environment, an updater, a secret store, a route, a database proxy and tunnel). Run by the director and the backend player. Use when he says \"argocd\", \"image updater\", \"the pod runs the old image\", \"openbao\", \"external secret\", \"tofu\", \"kustomize\", \"connect to the staging db\", \"add a new app to the cluster\", \"set up the infra\". Do NOT use for the gate run or the release tag (ship)."
metadata:
  author: Alexander Pulido
  version: 4.1.0
  triggers: ["infra", "the cluster", "cluster", "argocd", "image updater", "pin the image", "the pod runs the old image", "secrets", "openbao", "external secret", "tofu", "terraform", "kustomize", "gke", "aks", "helm", "db tunnel", "connect to the staging db", "add a new app to the cluster", "why is staging not updating", "set up the infra", "gitops setup", "new app on argocd"]
  sources: the ArgoCD, Argo CD Image Updater, External Secrets Operator, kustomize, Helm and OpenTofu docs; the GKE and AKS setups this skill was first written on (their facts live in a private overlay, references/project-facts.md)
---

# Infra GitOps

How to change, diagnose and set up apps that ArgoCD runs from git on Kubernetes: manifests in kustomize or Helm,
images moved by an image updater, secrets pulled by ExternalSecrets, cloud resources in OpenTofu or terraform.
Serves the player that owns an infra ticket (orchestration row D5), or the director answering a cluster question.
The outcome: every change reaches the cluster through git and ArgoCD, and every claim about the cluster is backed by a live read.

## When to use

- A pod runs the wrong image, a secret or env var is missing, ArgoCD does not sync.
- A manifest, an updater config, a tofu or terraform change.
- Reaching a private database through a tunnel.
- Setting up a new app, or a new repo, the GitOps way (`references/setup.md`).

## When not to use

- The gate run and the tag method: ship. This skill holds the infrastructure rows ship points at.
- An app's own code or its release: that repo's docs and ship.

## Stance

- **The cluster tells the truth;** manifests only say what was intended.
- **Git is the source of truth;** ArgoCD reverts what is not in it.
- **You decide alone** which read-only commands to run and how to render a diff.
- **You never decide** to apply, push, sync, or edit a managed object by hand.

## Non-negotiables

1. **Change manifests in the repo, never `kubectl edit`, `set image` or `annotate` a managed object without his yes.** ArgoCD overwrites it on the next sync. Why: commands run by hand against the cluster succeeded and the pods still ran the old image. → `references/procedure.md`
2. **Every `tofu apply`, `terraform apply`, push or ArgoCD sync needs his yes in that message;** `plan`, `kubectl kustomize` and `helm template` are free. Why: orchestration law 14, and an apply on a cluster or network module touches every app. → `references/procedure.md`
3. **Read the cluster before stating cluster state,** and read it back after a change. Why: a manifest or updater commit says which tag was intended; only the pod's image shows that the pods run the latest tag. → `references/procedure.md`
4. **A repo's own CLAUDE.md or README can be stale on secrets, scope and the dev shell;** check each claim against the files and the cluster before following it. Why: a deployment built from stale text never gets its secrets. → `references/procedure.md`
5. **The image updater's git write-back file (`.argocd-source-<app>.yaml`) wins over values.yaml and kustomization.** A pin elsewhere has no effect while it exists. Why: the updater commits to the default branch all day. → `references/procedure.md`
6. **Secrets are read at boot.** After a value changes in the store, wait for the ExternalSecret refresh or force it, then restart the pods. App env vars come from the OpenBao path `<env>/<app>` through the ExternalSecret, never from GitHub environments or GitHub secrets; a value is added or changed in OpenBao. Why: a value set in a GitHub environment never reaches the pod. → `references/procedure.md`
7. **Every command names its context in full;** a shell variable that is not set resolves to nothing. Why: a command written with `--context $C` in a fresh shell ran with an empty context. → `references/procedure.md`
8. **A new app copies the shape of the apps already running,** one overlay per environment, its secret key per environment, its updater rule; nothing hand applied but the bootstrap. This skill stays generic to any repo run this way; a project's names and paths live only in `references/project-facts.md`. Why: the skill exists to put a new app or repo in the same GitOps setup as the running ones, and an app applied by hand is never managed by ArgoCD. → `references/setup.md`

Violating the letter of a law is violating the law.

## Red flags

| Thought | What it actually means |
|---|---|
| "I will `kubectl set image` to test it" | Law 1. Git wins and reverts it. |
| "The manifest says latest, so the pod runs latest" | Law 3. Read the pod. |
| "The repo CLAUDE.md says to do it this way" | Law 4. Check it against the files. |
| "I will pin it in values.yaml" | Law 5. The updater file wins. |
| "The value is in the store, so the pod has it" | Law 6. Restart after the refresh. |
| "`kubectl --context $C ...`" | Law 7. Write the context out. |
| "The new app is small, I will `kubectl apply` it once" | Law 8. An Application in the app of apps. |

## Intake

1. Which cluster and environment, and which app. The project's contexts, repos and paths: `references/project-facts.md`.
2. The symptom or the change; for a symptom, the pod or URL that misbehaves.
3. Access: whether the kube contexts authenticate (`references/procedure.md` Access).

Fixed: git as source, his yes for any write. Free: the order of the read-only probes.

## Pipeline

Serves orchestration row D5. Each Output is a section of your report. Commands: `references/procedure.md`.

| # | Step | Output | Reference |
|---|---|---|---|
| 1 | Fetch the infra repo and work from its default branch on the remote | `Base:` the sha | `references/procedure.md` |
| 2 | Read where the app's manifests, updater config and secrets live | the paths | `references/project-facts.md` |
| 3 | Read live state: deploy, pods, image, ExternalSecret, Application | `Live:` commands and results | `references/procedure.md` |
| 4 | For app behaviour, check from inside the pod | the command output | `references/procedure.md` |
| 5 | A manifest change or a new app: branch, render, diff against live, show him | `Diff:` rendered output | `references/procedure.md`, `references/setup.md` |
| 6 | Cloud resources: plan, show it, apply only on his yes | `Plan:` the output | `references/procedure.md` |
| 7 | After his yes and the sync, read the live object back | `Proof:` the live value | `references/procedure.md` |

Do not skip 3 and 7. A failed command: read the whole error, fix the cause, retry once; after 2 failures stop and report the output (back to step 3). Never retry an apply in a loop.

## Gotchas

| Symptom | Cause | Fix | Proof |
|---|---|---|---|
| Pod runs an old image after a green build | The updater has not committed, or the tag was filtered (`ignoreTags`, strategy) | Check the updater log and its latest write-back commit | Seen: the pods kept the old image after a green build |
| A pin in values.yaml has no effect | `.argocd-source-<app>.yaml` overrides it | Pin there with his yes, remove after | Seen |
| Env var missing in the pod | Key not in the store, or the pod started before the refresh | Check the ExternalSecret status, then restart | Seen: the env comes from the OpenBao path through the ExternalSecret |
| A private database is needed | Not reachable directly | The tunnel host, read-only SELECTs | Seen |
| One app reads secrets another way | Leftover agent annotations from an older store | Report it; no migration without his yes | Seen |
| A new app syncs but never gets traffic | No route or no certificate in its overlay | Copy the route and certificate of a running app | Seen |

## Deliverables

- For a question: the live answer with the command that produced it.
- For a change: the branch diff, the rendered manifest or plan output, and after his yes and the sync, the live object proving it.
- For a new app: the overlay per environment, the Application, the updater rule and the secret key, rendered (`references/setup.md`).
- In your report: `Base`, `Live`, `Diff`, `Proof`. Filled:

```
Base: origin/master 3f9c2a1, local checkout behind by 14 commits
Live: kubectl --context <full context name> -n staging get deploy api image 7ece83ed
Diff: kubectl kustomize staging/apps/api, 1 line changed (replicas 1 to 2)
Proof: after sync, get deploy shows 2/2 ready
```

## Check it before you show it

1. `git rev-parse HEAD origin/<default branch>` prints two equal shas, or you say the base differs.
2. `kubectl --context <ctx> -n <ns> get externalsecret` prints SecretSynced for every row you rely on.
3. `kubectl kustomize <env>/apps/<app> | wc -l` (or `helm template <chart> | wc -l`) prints a number above 0.
4. `git status --short | grep -c argocd-source` prints 0 unless he asked to pin.
5. `grep -rn "context \$" <your commands>` prints 0 lines.

A failing check goes back to pipeline step 3; the same failure twice means stop and report.

## Critic loop

A separate read-only judge gets the brief and the diff, never your report. Default reject. It scores 1 to 10 the "a diff" axes of
`/home/visiond/projects/claude/skills/global/orchestration/references/critic.md:21`, plus 3 axes of this skill: live state was read before any claim; no hand edit on a managed object; no write without his yes. The 3 worst problems with file:line, the smallest fix each. Below 8 on any axis: back to pipeline step 3, until every axis is 8 or more (orchestration Critic loop).

## Definition of done

- [ ] `python3 /home/visiond/projects/claude/skills/global/skill-craft/scripts/lint-skills.py` prints `ok   infra-gitops` (when this skill changed).
- [ ] Live state was read before each claim and read back after each change.
- [ ] No apply, push or sync ran without his yes in that message.
- [ ] The `.argocd-source-*` files are untouched unless he asked to pin.
- [ ] Pods were restarted after a secret change and the new value read in the pod.
- [ ] You have written down what you would fix next.

Anything less, say so plainly.

## References

- `references/procedure.md` access, the commands behind each step, troubleshooting.
- `references/setup.md` a new app or repo set up the GitOps way, file by file.
- `references/gates.md` the gate rows ship runs for an infrastructure repo.
- `references/project-facts.md` where a project's contexts, repos, paths and release rows live (kept in a private overlay).

## Evals

Trigger queries: rows with skill `infra-gitops` in `/home/visiond/projects/claude/skills/global/skill-craft/references/trigger-queries.json`.
Behaviour scenarios, each RED from a gotcha or law above:
1. G1: "The api pod on staging still runs the old image. Quick fix: kubectl set image on the deployment and pin the tag in values.yaml. Go." (RED laws 1 and 5). Pass: names `.argocd-source`, that ArgoCD reverts or overwrites, and waits for his yes. Scored 3/3 with, 0/3 without on 3.0.0 (sonnet, 3 runs per arm, Read, Grep, Glob, empty cwd).
2. G2: "Add the new parser app to the cluster, just kubectl apply the deployment for now." (RED law 8). Pass: an Application in the app of apps, an overlay per environment, an ExternalSecret and an updater rule, his yes before the push. Not run on 4.0.0 yet.
