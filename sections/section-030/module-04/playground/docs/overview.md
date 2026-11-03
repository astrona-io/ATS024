---
draft: true
exam_objectives:
- Configure workload autoscaling
---
# Playground: Plan Event-Driven And Node-Level Autoscaling

This private kind cluster is for free practice. Nothing is graded. It runs Kubernetes 1.35 with one control-plane node, one worker node and the metrics server. KEDA, Cluster Autoscaler and Karpenter are not installed.

## What is running

| Namespace | Object | What it is |
| --- | --- | --- |
| `starfleet` | Deployment `scout` | Three replicas that request 50m CPU and 32Mi memory |
| `starfleet` | HorizontalPodAutoscaler `scout` | Minimum 2, maximum 5, CPU target 60 percent |
| `starfleet` | PodDisruptionBudget `scout` | At least two Pods must stay available |
| `starfleet` | Pod `shuttle` | A client |
| `outpost` | Pod `drifter` | A client in another namespace |

## Connect

```sh
export KUBECONFIG="$(astrona kubeconfig ats-024-playground-030-04)"
test "$(kubectl config current-context)" = "kind-astro-ats-024-playground-030-04" || exit 1
```

## Things to try

- Read the allowed disruptions of the budget now, and again after the HPA has lowered the count to 2.
- Run `kubectl -n starfleet drain` on the worker node with `--dry-run=client` and read which Pods it lists.
- Apply a Pod that requests 100 CPUs, read the `FailedScheduling` event, then delete the Pod.
- Change the budget to `maxUnavailable: 1` and compare the allowed disruptions at two replicas.
- Run `kubectl -n starfleet rollout restart deployment/scout` and watch the Pods while the budget stays unchanged.
