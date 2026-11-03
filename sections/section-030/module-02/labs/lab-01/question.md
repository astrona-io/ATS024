---
draft: true
exam_objectives:
- Configure workload autoscaling
---
# Repair And Tune A Broken Autoscaler

> UNTESTED: this task has not yet been run against a live environment.

## Scenario

The `scout` Deployment has an HPA that never works. Repair it and then slow its scale-down.

## Starting state

The `starfleet` namespace has the Deployment `scout` with two replicas and an HPA named `scout` with a minimum of 2, a maximum of 4 and a CPU target of 60 percent. The HPA reports no measurements. The metrics server is running. The namespace `outpost` has an unrelated client Pod.

Select the private cluster first:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-024-lab-030-02-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-024-lab-030-02-01" || exit 1
```

## Required result

The HPA `scout` must read CPU measurements and report `ScalingActive` as `True`. Repair the cause in the object that is broken, and do not delete the HPA or the Deployment. Then edit the HPA so that its maximum is 6 and its behavior is as follows. Scale-up adds at most 2 Pods every 60 seconds. Scale-down waits a stabilization window of 600 seconds and removes at most 1 Pod every 120 seconds. The CPU target stays at 60 percent.

## Verify The Result

The grader reads the Deployment, the HPA fields and the HPA status. It waits for the controller to report a current utilization, so allow a few minutes after your change. It also checks that the original HPA and Deployment objects are still the ones in the cluster.

## Hints

- The condition message of the HPA names the missing input.
- A utilization target needs a request on every container of the Pod.
- `kubectl apply` on the same name edits the HPA in place.
