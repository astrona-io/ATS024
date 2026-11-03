---
draft: true
exam_objectives:
- Configure Pod admission and scheduling (limits, node affinity, etc.)
---
# Priority, Preemption And Quality Of Service

When a node is full, Kubernetes must decide which pod waits, which pod is removed and which pod is killed first. Three settings decide this: the priority of the pod, its quality of service class and the pressure on the node. This module teaches how each one works, and how they combine when the cluster runs short of resources.

## Learning goals

- Create a PriorityClass and use it in a workload, including `globalDefault` and `preemptionPolicy`.
- Describe the preemption flow of the scheduler step by step.
- Name the three quality of service classes and the rule that assigns each.
- Explain the order in which the kubelet evicts pods under node pressure.
- Explain `oom_score_adj` and how it relates to the quality of service class.
- Explain pod overhead and a RuntimeClass.

## Before you start

You need to know what requests and limits are and what the scheduler does. The playground is a Kubernetes 1.35 `kind` cluster with one worker node. It has the workloads `scout`, `probe` and `shuttle` in `starfleet` and `drifter` in `outpost`.

## Reading order

The first part covers priority classes and the preemption flow of the scheduler. The second part covers quality of service classes, node-pressure eviction, the kernel out-of-memory score and pod overhead. The summary closes the module.

<!-- astrona:playground -->
