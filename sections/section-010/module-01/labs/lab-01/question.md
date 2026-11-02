---
draft: true
exam_objectives:
- Understand application deployments and how to perform rolling update and rollbacks
---
# Perform A Rolling Template Update

Complete a readiness-gated update with explicit rollout capacity. Use the isolated `starfleet` environment to verify the result.

## Objective

Complete a readiness-gated update with explicit rollout capacity.

## Starting state

The application and client fixtures are healthy. Complete the required change without replacing unrelated resources.

Use a host shell with this lab's private kubeconfig. A kubeconfig identifies the cluster and credentials used by kubectl, the Kubernetes command-line tool. This environment is separate from the ungraded playground.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-024-lab-010-01-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-024-lab-010-01-01" || exit 1
```

Keep this connection selected throughout the task. Every script supplied by the lab refuses a different context.


## Required result

Update `probe` to version `v2` through its `VERSION` environment value. Keep two replicas, a RollingUpdate strategy with `maxSurge: 1` and `maxUnavailable: 0`, and the readiness probe. The current generation must have two updated, ready and available replicas. The client must receive version two.

## Verify The Result

The grader checks the stated resource fields and live evidence. Wait for controller convergence before submitting. Inspect actual results rather than relying on a sample transcript.
