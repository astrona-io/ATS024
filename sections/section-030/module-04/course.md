---
draft: true
exam_objectives:
- Configure workload autoscaling
---
# Plan Event-Driven And Node-Level Autoscaling

The HorizontalPodAutoscaler (HPA) reacts to CPU, memory and metrics that an adapter serves. Some workloads need a different signal, and every replica decision depends on nodes that have room. This module covers event-driven autoscaling and scale to zero, node-level autoscaling, and the way a PodDisruptionBudget works with the HPA minimum.

## Learning goals

- Explain why the HPA cannot scale to zero by default and what KEDA adds.
- Follow an unschedulable Pod to the node autoscaler that reacts to it.
- Compare Cluster Autoscaler and Karpenter at the level of concepts.
- Choose a PodDisruptionBudget and an HPA minimum that leave room for one eviction.

## Before you start

You need to know how an HPA, a Deployment and a request work. The playground is a private kind cluster with one worker node and the metrics server. It runs the `scout` Deployment with three replicas, an HPA with a minimum of 2 and a maximum of 5, and a PodDisruptionBudget that requires two available Pods. Neither KEDA nor a node autoscaler is installed, because both need components or a cloud provider that the playground does not have.

## What the parts cover

The first part explains event-driven autoscaling, the ScaledObject of KEDA and the state of scale to zero in Kubernetes 1.35. The second part follows an unschedulable Pod and explains Cluster Autoscaler and Karpenter. The third part explains which disruptions a PodDisruptionBudget limits and how the budget and the HPA bounds must agree. A graded task on the budget follows the third part, and a summary closes the module.

<!-- astrona:playground -->
