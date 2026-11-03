---
draft: true
exam_objectives:
- Configure Pod admission and scheduling (limits, node affinity, etc.)
---
# Resource Quotas And Limit Ranges

A team deploys a workload without resource settings into a namespace that has a quota, and no pod appears. Nothing is wrong with the image or the scheduler. The API server refused to create the pods, and the reason is in the events of the ReplicaSet. This module teaches how container resource settings work, and how a LimitRange and a ResourceQuota enforce rules on them at admission.

## Learning goals

- Explain the difference between a resource request and a resource limit, and which component uses each.
- Predict what happens when a container exceeds its CPU limit and when it exceeds its memory limit.
- Write a LimitRange with `default`, `defaultRequest`, `min`, `max` and `maxLimitRequestRatio`.
- Write a ResourceQuota for compute resources and for object counts, and use a scope.
- Read a quota or limit range rejection and name the rule that caused it.

## Before you start

You need to know what a pod, a Deployment and a namespace are, and the commands `kubectl get`, `kubectl apply` and `kubectl describe`. The playground is a Kubernetes 1.35 `kind` cluster with one control plane node and one worker node. It has a `starfleet` namespace with the workloads `scout`, `probe` and `shuttle`, and an `outpost` namespace with the workload `drifter`. No quota or limit range exists yet.

## Reading order

The first part covers requests and limits and what the kernel and the kubelet do when a container reaches them. The second part covers the LimitRange and ResourceQuota objects, which the API server checks when a pod is created, and the errors they return. The summary closes the module.

<!-- astrona:playground -->
