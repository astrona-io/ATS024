---
draft: true
exam_objectives:
- Configure Pod admission and scheduling (limits, node affinity, etc.)
---
# Pod Affinity, Anti-Affinity And Topology Spread

This module teaches how to place Pods relative to other Pods. Pod affinity keeps related Pods together, Pod anti-affinity keeps them apart, and topology spread constraints spread the replicas of one workload evenly over failure domains such as nodes and zones. You will learn what each rule counts, which field controls the size of a domain, and what a rule does when the cluster cannot satisfy it.

## Learning Goals

- Write Pod affinity and anti-affinity with `labelSelector` and `topologyKey`, required and preferred.
- Explain what a topology domain is and how the `topologyKey` label defines it.
- Write `topologySpreadConstraints` with `maxSkew`, `topologyKey`, `whenUnsatisfiable` and `labelSelector`.
- Compute the skew of a placement and predict whether the next Pod can be scheduled.
- Use `matchLabelKeys` so that a rolling update counts only the Pods of one revision.

## Before You Start

You need `kubectl` and a cluster with two worker nodes. The module playground has two workers labelled with different values of `topology.kubernetes.io/zone`. A topology domain is the set of nodes that share one value of a label.

## Reading Order

1. Pod affinity and anti-affinity with topologyKey
2. Topology spread constraints
3. Rolling updates, matchLabelKeys and domain selection
4. Summary

<!-- astrona:playground -->
