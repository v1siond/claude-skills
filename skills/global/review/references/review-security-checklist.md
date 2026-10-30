# Security checklist, per stack

Grep starters are where to LOOK, not findings. Every hit still needs a path from an attacker.

## Elixir and Phoenix

| Check | Grep starter | Safe form |
|---|---|---|
| SQL injection | `fragment(".*#\{`, `Repo.query(` with interpolation | `fragment("lower(?)", ^value)`, params list |
| Atom exhaustion | `String.to_atom(`, `:erlang.binary_to_atom` | `String.to_existing_atom/1` or a whitelist map |
| Command injection | `System.cmd("sh"`, `:os.cmd` | `System.cmd(bin, [arg1, arg2])` |
| XSS | `raw(`, `Phoenix.HTML.raw` | default escaping, sanitize with a library if HTML is needed |
| Mass assignment | `cast(` permitting `is_admin`, `role`, `owner_id`, `user_id` | set those from the session, never from params |
| Missing auth | routes outside `pipe_through [:require_authenticated_user]` | move into the authed scope |
| IDOR | `Repo.get!(Thing, id)` in a controller | scope by owner: `Repo.get_by!(Thing, id: id, owner_id: user.id)`, 404 on miss |
| Unsafe term | `binary_to_term(` | `binary_to_term(bin, [:safe])` |
| Secrets | `config/*.exs` literals, `*.pem`, `*.json` service accounts | `System.fetch_env!/1` in `runtime.exs` |
| Webhooks | a webhook controller with no signature check | verify the HMAC before parsing |

## TypeScript, React, Vue

| Check | Grep starter |
|---|---|
| XSS | `dangerouslySetInnerHTML`, `v-html`, `innerHTML =` |
| Tokens in storage | `localStorage.setItem(` with a token |
| Open redirect | `window.location = ` from a query param |
| Secrets in the bundle | `NEXT_PUBLIC_`, `VITE_` holding a secret key |
| Dependencies | `npm audit --omit=dev` |

## Kubernetes and CI

| Check | Where |
|---|---|
| Secrets in manifests | `kind: Secret` with `data:` committed, values in `values.yaml` |
| Privileged pods | `privileged: true`, `runAsUser: 0`, `hostPath` |
| CI secrets echoed | `.gitlab-ci.yml` scripts that `echo $` a secret var |
| Image tags | `:latest` in prod manifests (ArgoCD image-updater ignores it) |
