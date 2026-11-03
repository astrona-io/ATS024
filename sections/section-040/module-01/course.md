---
draft: true
exam_objectives:
- Understand the primitives used to create robust, self-healing, application deployments
---
# Reconciliation And Application Health

A Deployment keeps the requested number of Pods alive, and probes tell the kubelet when a container can serve traffic or needs a restart. This module explains both mechanisms and how they differ: reconciliation repairs the number of objects, while probes judge whether each container is useful.

## Learning Goals

- Explain owner-driven replacement and desired state.
- Distinguish process startup from useful service.
- Choose health checks with appropriate recovery actions.
- Identify dependencies that replacement cannot repair.

## Before You Start

You need to know what a Pod, a namespace and a Service are, and the commands `kubectl get`, `kubectl describe` and `kubectl apply`. The playground runs a kind cluster with the `probe` Deployment, a `shuttle` client Pod in `starfleet` and a `drifter` client Pod in `outpost`. Graded exercises use their own separate environments and appear right after the reading they practise.

## Reading Order

The first part follows a Deployment, its ReplicaSet and its Pods through a failure, and explains spec, status and generation. The second part explains startup, readiness and liveness probes, how the kubelet counts results, and how to size thresholds. Two graded tasks, one on a readiness probe and one on a liveness probe, follow. A guided practice then repairs the readiness probe step by step, and the summary closes the module.

<!-- astrona:playground -->
