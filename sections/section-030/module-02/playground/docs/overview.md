---
draft: true
exam_objectives:
- Configure workload autoscaling
---
# Playground: Tune HPA Metrics And Scaling Behavior

This private kind cluster is for free practice. Nothing is graded. It runs Kubernetes 1.35 with one control-plane node, one worker node and the metrics server.

## What is running

| Namespace | Object | What it is |
| --- | --- | --- |
| `starfleet` | Deployment `probe` | Two replicas that request 50m CPU and 32Mi memory |
| `starfleet` | Deployment `scout` | Two replicas without any resource request |
| `starfleet` | Pod `shuttle` | A client with `wget` for sending load |
| `outpost` | Pod `drifter` | A client in another namespace |

No HorizontalPodAutoscaler exists yet.

## Connect

```sh
export KUBECONFIG="$(astrona kubeconfig ats-024-playground-030-02)"
test "$(kubectl config current-context)" = "kind-astro-ats-024-playground-030-02" || exit 1
```

## Things to try

- Create an HPA for `probe` with a CPU and a memory target, and read `currentMetrics` in its status.
- Add a `behavior` block with a `scaleDown` window of 60 seconds, send load from `shuttle` with a `wget` loop, stop it, and time how long the count takes to fall.
- Create an HPA for `scout`, read the `ScalingActive` condition message, and repair it with `kubectl set resources`.
- Add an `Object` metric to an HPA and read the condition message that says the custom metrics API is missing.
- Set `selectPolicy: Disabled` for `scaleDown`, apply it, and check that the count never falls.
