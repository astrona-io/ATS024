---
draft: true
exam_objectives:
- Configure Pod admission and scheduling (limits, node affinity, etc.)
---
# Repair An Impossible Node Selector

Use node labels and scheduling evidence to correct an unsatisfiable placement rule. Use the isolated `starfleet` environment to verify the result.

## Objective

Use node labels and scheduling evidence to correct an unsatisfiable placement rule.

## Starting state

The Deployment template selects a node label that no node has. Replacement Pods cannot schedule, while older replicas may still respond.

Use a host shell with this lab's private kubeconfig. A kubeconfig identifies the cluster and credentials used by kubectl, the Kubernetes command-line tool. This environment is separate from the ungraded playground.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-024-lab-050-01-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-024-lab-050-01-01" || exit 1
```

Keep this connection selected throughout the task. Every script supplied by the lab refuses a different context.


## Required result

Replace the impossible node selector on `probe` with `kubernetes.io/os: linux`. Keep two replicas, the application command, image, resources and readiness probe. The current generation must fully roll out and the original client must receive version one. Do not label a node to satisfy the intentional missing selector.

## Verify The Result

The grader checks the stated resource fields and live evidence. Wait for controller convergence before submitting. Inspect actual results rather than relying on a sample transcript.
