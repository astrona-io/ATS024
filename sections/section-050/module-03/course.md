---
draft: true
exam_objectives:
- Configure Pod admission and scheduling (limits, node affinity, etc.)
---
# Node Affinity

This module teaches how a Pod asks the scheduler to run on nodes that have certain labels. It starts with the simple `nodeSelector` field and then moves to node affinity, which adds operators, alternatives and weighted preferences. The goal is that you can write a rule, predict which nodes it matches, and prove the result from the Pod and the node.

## Learning Goals

- Read node labels and add a label to a node.
- Choose between `nodeSelector` and node affinity for a given requirement.
- Write `requiredDuringSchedulingIgnoredDuringExecution` rules with `matchExpressions` and the operators `In`, `NotIn`, `Exists`, `DoesNotExist`, `Gt` and `Lt`.
- Predict how several `nodeSelectorTerms` and several expressions combine.
- Use `preferredDuringSchedulingIgnoredDuringExecution` with weights, and explain what the weights change.

## Before You Start

You need `kubectl` and a Kubernetes cluster that has at least one worker node. The module playground provides a cluster with one worker node that already carries the labels `disk=ssd`, `tier=compute` and `gpu-count=2`. A Pod is the smallest unit Kubernetes runs, and a label is a key and value pair attached to an object.

## Reading Order

1. Node labels and nodeSelector
2. Required node affinity and operators
3. Preferred node affinity and weights
4. Summary

<!-- astrona:playground -->
