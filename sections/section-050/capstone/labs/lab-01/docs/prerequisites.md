---
draft: true
exam_objectives:
- Configure Pod admission and scheduling (limits, node affinity, etc.)
---
# Prerequisites

Use astrona, kubectl, jq and a shell. A container engine (Podman or Docker) must be able to run kind. You should know how to write and apply a Pod or Deployment manifest and how to read the events of a Pod with `kubectl describe`.

The lab starts its own kind cluster (Kubernetes 1.35). Use a host shell with the private kubeconfig for this environment. A kubeconfig identifies the cluster and credentials that kubectl, the Kubernetes command-line tool, uses.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-024-lab-050-cap)"
test "$(kubectl config current-context)" = "kind-astro-ats-024-lab-050-cap" || exit 1
```

Keep this connection selected. Every script of the lab refuses to run against another context.
