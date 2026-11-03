---
draft: true
exam_objectives:
- Configure workload autoscaling
---
# Playground: Scale Workloads Manually And Vertically

This private kind cluster is for free practice. Nothing is graded. It runs Kubernetes 1.35 with one control-plane node and one worker node. The metrics server and the Vertical Pod Autoscaler are not installed.

## What is running

| Namespace | Object | What it is |
| --- | --- | --- |
| `starfleet` | Deployment `scout` | Two replicas that request 50m CPU and 32Mi memory |
| `starfleet` | Pod `bridge` | One container with 100m CPU and 64Mi memory as request and limit, CPU resize without restart, memory resize with restart |
| `starfleet` | Pod `shuttle` | A client |
| `outpost` | Pod `drifter` | A client in another namespace |

## Connect

```sh
export KUBECONFIG="$(astrona kubeconfig ats-024-playground-030-03)"
test "$(kubectl config current-context)" = "kind-astro-ats-024-playground-030-03" || exit 1
```

## Things to try

- Scale `scout` to 5, then to 0, and read the Service endpoints each time.
- Run `kubectl scale --current-replicas=9 --replicas=3 deployment/scout` and read the error.
- Resize the CPU of `bridge` to 200m and check `status.containerStatuses[0].resources` and the restart count.
- Resize the memory of `bridge` and compare the restart count with the CPU resize.
- Request 100 CPUs for `bridge`, read the `PodResizePending` condition, then send a feasible value.
- Resize a Pod of the `scout` Deployment, then roll out the Deployment and compare the sizes.
