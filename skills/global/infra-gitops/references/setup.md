# Setup: a new app, or a new infra repo, the GitOps way

The shape a running API app has (one Elixir or Rails API behind a route, its database through a proxy, its secrets in OpenBao, its image moved by the updater). Copy a running app's folder first; this list is what that copy must hold. Every write below goes to git and reaches the cluster through ArgoCD, after his yes on the push (law 2).

## Contents

- The repo tree
- A new app, file by file
- A new cluster, once
- Check

## The repo tree

```
<env>/                      one per environment: staging/, production/ (mirrors)
  apps/0-apps/              app of apps: one Application per app, pointing at <env>/apps/<app>
  apps/<app>/               kustomize dir of one app
  apps/argocd/              ArgoCD itself and the image updater config
  bootstrap/                applied once by hand to a new cluster: kubectl apply -k <env>/bootstrap
  tofu/<module>/            cluster, network, secret store, tunnel host; remote state in a bucket
```

A Helm repo has the same parts: `k8s/argocd-apps/<env>/<app>` charts and a `0-apps-<env>` chart of Applications.

## A new app, file by file

| File | Holds | Copy from |
|---|---|---|
| `<env>/apps/<app>/kustomization.yaml` | `namespace: <env>`, the resource list, the image name | a running app |
| `deployment.yaml` | image without a tag pin, `envFrom` the app's Secret, probes, resources | a running app |
| `service.yaml` | the port the route sends to | a running app |
| `http_route.yaml` (Gateway API) or an Ingress | host per environment, the certificate | a running app |
| `external-secret.yaml` | `ClusterSecretStore` of the cluster, key `<env>/<app>` | a running app |
| `pdb.yaml` | `minAvailable: 1` when replicas are 2 or more | a running app |
| the database proxy workload | the instance connection for this environment | a running app with a database |
| `<env>/apps/0-apps/<app>.yaml` | the Application: repo, path `<env>/apps/<app>`, automated sync | a running app's Application |
| the image updater rule | the image, `newest-build` and `ignoreTags: ["latest"]` for staging, the production strategy the project uses | the updater config |
| the secret values | written to the store at `<env>/<app>` by him, never committed | (none in git) |

The app's CI pushes an image tagged with the short sha (plus `latest`) to the registry the updater watches. Without that tag the updater never moves (Gotchas row 1).

## A new cluster, once

1. `tofu plan` then, on his yes, apply the network, cluster, secret store and tunnel modules, in that order.
2. `kubectl --context <ctx> apply -k <env>/bootstrap` on his yes: ArgoCD, its repo credentials and the app of apps.
3. ArgoCD syncs every app from `0-apps`; the secret store needs its unseal and its first values before any app's ExternalSecret syncs.

## Check

1. `kubectl kustomize <env>/apps/<app> | grep -c '^kind:'` prints the number of files in the table the app uses.
2. `kubectl kustomize <env>/apps/0-apps | grep -c "path: <env>/apps/<app>"` prints 1.
3. After his yes and the sync: `get application <app>` shows Synced and Healthy, `get externalsecret` SecretSynced, and the route answers.
