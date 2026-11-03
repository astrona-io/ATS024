# Prerequisites

- The `astrona` command-line tool, installed and working.
- A container engine that kind can use (Podman or Docker) with about 2 GiB of free memory.
- `kubectl`.
- You know how to inject ConfigMap and Secret values as variables and as files, the Secret types, and the fields of the downward API.

The lab starts a single-node kind cluster (Kubernetes 1.35). Use the kubeconfig of the lab and keep it selected:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-024-lab-020-cap)"
test "$(kubectl config current-context)" = "kind-astro-ats-024-lab-020-cap" || exit 1
```
