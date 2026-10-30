# Procedure, infra-gitops

The commands behind the pipeline steps of SKILL.md. A project's contexts, repos and paths: `project-facts.md`.

## Access

- List contexts with `kubectl config get-contexts`; write the full name in every command (law 7).
- A context whose name points at a retired cluster is stale; the project facts name the live ones.
- If auth fails, say so and ask him to log in (`gcloud auth login`, `az login`), typed by him with `!`.

## Step 1, sync

`git fetch` and work from the remote default branch. A local checkout on a feature branch is usually behind: the image updater commits to the default branch all day.

## Step 3, live state

- `kubectl --context <ctx> -n <ns> get deploy,pods -o wide`
- the pod image: `kubectl --context <ctx> -n <ns> get pod <pod> -o jsonpath='{..image}'`
- `kubectl --context <ctx> -n <ns> get externalsecret` (status SecretSynced)
- `kubectl --context <ctx> -n argocd get applications`

## Step 4, from inside the pod

`kubectl --context <ctx> -n <ns> exec -it <pod> -- <the app's remote shell>`: for an Elixir release, `/app/bin/<release> rpc '<expr>'`; for others, the runtime's console.

## Step 5, a manifest change

Edit on a feature branch, render with `kubectl kustomize <env>/apps/<app>` (kustomize) or `helm template <chart>` (Helm), diff against the live object (`kubectl diff -k` or the rendered file beside `kubectl get -o yaml`), show him the diff.

## Step 6, cloud resources

Enter the repo's dev shell (devenv, nix develop, or the toolchain its README names), then per module: `tofu init && tofu plan` (or `terraform init && terraform plan`). Apply only on his yes. Never apply two modules in one command.

## How the moving parts fit

- **Image updater, two styles.** The `ImageUpdater` CRD (Argo CD Image Updater 1.x) in the argocd app folder, or annotations on each Application (0.x: `image-list`, `<alias>.update-strategy`, `<alias>.ignore-tags`, `write-back-method: git`). Both write `.argocd-source-<app>.yaml` with a commit to the default branch. `newest-build` with `ignoreTags: ["latest"]` moves on every pushed sha; `semver` moves only on a version tag.
- **Secrets.** One `ExternalSecret` per app: `secretStoreRef` a `ClusterSecretStore` (OpenBao or Vault), `dataFrom.extract.key: <env>/<app>`, `refreshInterval` (1h is common), target Secret named after the app, read by the Deployment as `envFrom`.
- **The repo's own docs.** Check every claim of the repo's CLAUDE.md or README against the files (law 4): the dev shell, the secret path, which environments exist.

## Troubleshooting

- Pod runs an old image after a green build: the updater has not committed, or `ignoreTags` or the strategy filtered the tag (only `latest` pushed). `kubectl --context <ctx> -n argocd logs deploy/argocd-image-updater`, and the latest write-back commit.
- A pin in values.yaml has no effect: `.argocd-source-<app>.yaml` overrides it. Pin there, with his yes, and remove the pin after.
- Env var missing in the pod: the key is not in the store at `<env>/<app>`, or the pod started before the refresh. Check the ExternalSecret status, force a refresh (`kubectl annotate externalsecret <name> force-sync=$(date +%s) --overwrite`, with his yes), then restart.
- A private database: through the tunnel host the project facts name (an IAP or bastion ssh with `-L 5432:127.0.0.1:5432`), then `psql -h 127.0.0.1`, read-only SELECTs only; production only with his yes.
- One app still carries `vault.hashicorp.com/agent-inject` annotations: it reads secrets the old way. Report it; no migration without his yes.
