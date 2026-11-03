---
draft: true
exam_objectives:
- Configure workload autoscaling
---
# Make The Budget And The Autoscaler Agree

> UNTESTED: this task has not yet been run against a live environment.

## Scenario

A node drain would hang on the `scout` workload. Change the autoscaler so that one Pod can be evicted.

## Starting state

The `starfleet` namespace has the Deployment `scout` with two replicas, an HPA named `scout` with a minimum of 2 and a maximum of 4, and a PodDisruptionBudget named `scout` that requires at least two available Pods. The budget allows no disruption.

Select the private cluster first:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-024-lab-030-04-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-024-lab-030-04-01" || exit 1
```

## Required result

The PodDisruptionBudget must stay as it is, with `minAvailable` of 2, and it must allow at least one disruption. Change the HPA so that its minimum is at least 3 and its maximum is not lower than the minimum. Wait until at least three `scout` replicas are ready. Keep the HPA, the budget and the Deployment as the original objects.

## Verify The Result

The grader reads the HPA bounds, the ready replicas and the `disruptionsAllowed` field in the budget status. It waits for the controller, so allow a minute after the change. Deleting the budget or lowering its `minAvailable` fails the checks.

## Hints

- Allowed disruptions are the healthy Pods minus the Pods that the budget requires.
- Keep the budget and change the autoscaler.
- The HPA minimum is the lowest replica count it will set.
