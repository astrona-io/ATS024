---
draft: true
exam_objectives:
- Configure workload autoscaling
---
# Prerequisites

Use `astrona`, `kubectl` and a shell. Podman or Docker must be available to run the private kind cluster. No other tool is needed.

This lab runs in its own kind cluster with Kubernetes 1.35, one control-plane node, one worker node and the metrics server. Select its private kubeconfig before every command, and check the context name so that no other cluster is changed:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-024-lab-030-03-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-024-lab-030-03-01" || exit 1
```

**Status: UNTESTED - never run against a live cluster.**
