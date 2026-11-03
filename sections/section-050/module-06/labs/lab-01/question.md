# Question

Solve this question on: `terminal`

UNTESTED: not yet run against a live environment.

The team that owns the `outpost` namespace deployed `drifter` with two replicas, but no pod exists. The namespace has the ResourceQuota `compute`, which limits requests and limits for CPU and memory and the number of pods. Do not remove the quota, do not lower or raise its existing values and do not add resources to the `drifter` Deployment.

1. Make the `drifter` Deployment run its two pods by giving every container in `outpost` default values from a LimitRange: request cpu `100m` and memory `64Mi`, limit cpu `200m` and memory `128Mi`.
2. In the same LimitRange, set the maximum for a container to cpu `500m` and memory `256Mi`. A container with a cpu limit of `1` must be rejected at admission.
3. Extend the ResourceQuota `compute` so that the namespace may have at most 3 Deployments (`count/deployments.apps`).

`kubectl` already points at the cluster as the cluster administrator.
