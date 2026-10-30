# infra-gitops

| | |
|---|---|
| Type | engineering |
| Scope | global (every repo with an ArgoCD cluster) |
| Source | [`skills/global/infra-gitops/SKILL.md`](../../../skills/global/infra-gitops/SKILL.md), version 4.0.0 |
| Run by | the director and the backend player |

## What it is for

Changing, diagnosing and setting up apps that ArgoCD runs from git: kustomize or Helm manifests, an image updater
that writes back to git, ExternalSecrets from OpenBao or Vault, cloud resources in OpenTofu or terraform.

## When to use it, and when not

Use it when a pod runs the wrong image, a secret is missing, ArgoCD does not sync, a manifest or tofu change is
due, a private database is needed through a tunnel, or a new app must be set up the same way as the running ones
(`references/setup.md`). Do not use it for the gate run or the release tag (ship).

## The rules in short

Git is the source of truth and the cluster tells the truth. Read live state before a claim and after a change;
never hand edit a managed object; every apply, push or sync waits for his yes; the updater's
`.argocd-source-<app>.yaml` wins over any other pin; secrets are read at boot, so restart after a refresh.

## Project facts

Context names, cloud ids, repo paths and release rows of a real project are not in this repo: the skill points at
a private overlay (`references/project-facts.md`). Keep your own the same way.
