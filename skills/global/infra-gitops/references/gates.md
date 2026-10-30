# Pre-deploy gates, infrastructure repos

Held in this skill, out of the global ship, which keeps the method and points here. When a row and the repo's CI file disagree, the file wins; fix this row and ship's script profile in the same turn. A project's own rows: `project-facts.md`.

| Repo kind | Gates the protocol runs | With his yes only |
|---|---|---|
| kustomize | `kubectl kustomize <dir>` renders for every overlay; `tofu fmt -check -recursive` | `tofu plan` per module (it reads live state) |
| Helm | `helm lint` per chart; `helm template` renders | `terraform plan` per module |
| terraform | `terraform fmt -check -recursive terraform`; `terraform validate` per module | `terraform plan` |
