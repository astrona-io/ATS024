---
draft: true
exam_objectives:
- Configure workload autoscaling
---
# Capstone: Autoscale, Resize And Protect A Workload

> UNTESTED: this task has not yet been run against a live environment.

## Scenario

The `scout` workload needs a working, bounded autoscaler that leaves room for a node drain, and the `bridge` Pod needs more CPU.

## Starting state

The `starfleet` namespace has the Deployment `scout` with two replicas, an HPA named `scout` with a minimum of 2, a maximum of 4 and a CPU target of 60 percent, and a PodDisruptionBudget named `scout` that requires two available Pods. It also has the Pod `bridge` with a CPU request and limit of 100m and a memory request and limit of 64Mi. The HPA does not report measurements.

Select the private cluster first:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-024-lab-030-cap)"
test "$(kubectl config current-context)" = "kind-astro-ats-024-lab-030-cap" || exit 1
```

## Required result

Make the autoscaler for `scout` work, with a CPU target of 60 percent, a minimum of 3 and a maximum of 5. Scale-down must wait a stabilization window of at least 300 seconds and remove at most 1 Pod every 120 seconds. The budget must stay as it is, with `minAvailable` of 2, and must allow at least one disruption. Raise the CPU request and limit of the `bridge` Pod to 400m in place: same Pod, no restart, `Guaranteed` QoS, memory unchanged. Wait until three `scout` replicas are ready. Keep the HPA, the budget and the Deployment as the original objects.

## Verify The Result

The grader reads the Deployment, the HPA fields and status, the budget status and the applied resources of `bridge`. It waits for the controller, so allow a few minutes after your last change.
