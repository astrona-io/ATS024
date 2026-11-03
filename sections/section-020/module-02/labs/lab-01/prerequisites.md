# Prerequisites

- The `astrona` command-line tool, installed and working.
- A container engine that kind can use (Podman or Docker) with about 2 GiB of free memory.
- `kubectl`.
- You know how to read and edit a Deployment, and the difference between `env` and `envFrom`.

The lab starts a single-node kind cluster (Kubernetes 1.35). Use the kubeconfig of the lab and keep it selected:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-024-lab-020-02-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-024-lab-020-02-01" || exit 1
```
