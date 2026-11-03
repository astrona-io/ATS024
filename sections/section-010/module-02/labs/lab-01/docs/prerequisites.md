---
draft: true
exam_objectives:
- Understand application deployments and how to perform rolling update and rollbacks
---
# Prerequisites

Use astrona, kubectl, Python 3, Podman and a shell. This environment is separate from the module playground.

Use a host shell with the private kubeconfig for this independent kind environment. A kubeconfig identifies the cluster and credentials used by kubectl, the Kubernetes command-line tool.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-024-lab-010-02-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-024-lab-010-02-01" || exit 1
```

Keep this connection selected for every command.
