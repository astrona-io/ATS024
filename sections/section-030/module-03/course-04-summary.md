---
draft: true
exam_objectives:
- Configure workload autoscaling
---
# Summary

Every scalable workload exposes a `scale` subresource that carries the desired and the observed replica count. `kubectl scale` and the HorizontalPodAutoscaler both write it. The last writer wins, so a manual change on a workload that an HPA manages lasts at most one sync period, and a manifest that contains `replicas` overwrites the autoscaler on each apply. The flags `--current-replicas` and `--resource-version` turn a scale into a compare-and-set.

In-place Pod resize, stable since Kubernetes 1.35, changes the CPU and memory of a running container through the `resize` subresource of the Pod. A `resizePolicy` per resource chooses `NotRequired` or `RestartContainer`. The kubelet decides whether the change fits the node, applies it through the container runtime, and reports the result in `status.containerStatuses`. A change that cannot be applied shows as `PodResizePending` with the reason `Infeasible` or `Deferred`. The QoS class cannot change, so a `Guaranteed` Pod needs its requests and limits changed together. A resize of one Pod does not change the template of its Deployment.

The Vertical Pod Autoscaler is an add-on. Its recommender computes target requests, its updater evicts Pods that differ, and its admission controller sets requests on new Pods. The update modes are `Off`, `Initial`, `Recreate` and `Auto`. A VPA and an HPA must not react to the same metric.

- `status.containerStatuses[].resources` shows what a container really runs with.
- A scale to zero keeps the Service but removes every endpoint.
- Start a VPA in `Off` mode and read its recommendation first.

<!-- astrona:playground:destroy -->
