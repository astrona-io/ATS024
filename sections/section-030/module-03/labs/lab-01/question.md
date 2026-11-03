---
draft: true
exam_objectives:
- Configure workload autoscaling
---
# Resize A Running Pod And Scale A Deployment

> UNTESTED: this task has not yet been run against a live environment.

## Scenario

The `bridge` Pod needs more CPU now, and `scout` needs one more replica. Make both changes without a restart or a new Pod.

## Starting state

The `starfleet` namespace has the Pod `bridge` with one container that has a CPU request and limit of 100m and a memory request and limit of 64Mi. Its resize policy lets CPU change without a restart. It also has the Deployment `scout` with two replicas. No autoscaler manages `scout`.

Select the private cluster first:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-024-lab-030-03-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-024-lab-030-03-01" || exit 1
```

## Required result

Change the CPU request and the CPU limit of the `bridge` container to 300m in place. The Pod must keep its identifier, its container must not restart, its memory values stay 64Mi, and its QoS class stays `Guaranteed`. The kubelet must report the new values as applied, and no resize may be pending. Then scale the Deployment `scout` to three replicas and wait until all three are ready.

## Verify The Result

The grader reads the Pod spec, the applied resources in the Pod status, the restart count and the Pod identifier. A change that deletes and recreates the Pod fails the identifier check. A change to the CPU request only fails, because the limit must match for the QoS class to stay `Guaranteed`.

## Hints

- The subresource is named `resize`.
- A `Guaranteed` Pod needs the request and the limit to stay equal.
- The status shows what the kubelet applied, and the spec shows what you asked for.
