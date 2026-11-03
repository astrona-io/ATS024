---
draft: true
exam_objectives:
- Understand the primitives used to create robust, self-healing, application deployments
---
# Voluntary And Involuntary Disruption

This module explains what happens to application Pods when a node is taken out of service on purpose and when a node fails without warning. A Pod is the smallest unit Kubernetes runs, and a node is a machine that runs Pods. Replicas of an application only help if the cluster removes them one at a time during maintenance and replaces them quickly after a failure.

## Learning Goals

- Tell voluntary disruption from involuntary disruption and name the Kubernetes mechanism for each.
- Write a PodDisruptionBudget with `minAvailable` or `maxUnavailable` and read its status fields.
- Cordon and drain a node, and explain why the Eviction API refuses an eviction.
- Explain taint-based eviction, `tolerationSeconds` and the default of 300 seconds.
- Spread replicas across nodes with topology spread constraints.

## Before You Start

You need to know what a Deployment, a ReplicaSet and a Pod are, and how to read `kubectl get` and `kubectl describe` output. Use the module playground for the hands-on steps. Graded exercises use independent environments and follow the readings they practise.

## Reading Order

1. Voluntary And Involuntary Disruption And PodDisruptionBudgets: the two kinds of disruption and how a budget limits the voluntary kind.
2. Drain, Cordon And Eviction: how an administrator empties a node and how the Eviction API enforces the budget.
3. Node Failure And Topology Spread: how the control plane reacts to a lost node and how to keep replicas on different nodes.
4. Summary.

<!-- astrona:playground -->
