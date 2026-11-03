---
draft: true
exam_objectives:
- Understand application deployments and how to perform rolling update and rollbacks
---
# Update Strategies For Deployments, StatefulSets And DaemonSets

A rolling update is not the right choice for every release. Some applications cannot run two versions at once, some releases need a trial on a small share of traffic, and some workloads, such as StatefulSets and DaemonSets, replace Pods by their own rules. This module compares the strategies and shows how each one is configured and observed.

## Learning Goals

- Choose between RollingUpdate and Recreate for a Deployment.
- Build a blue-green switch with a Service selector and a canary with two Deployments.
- Tune `progressDeadlineSeconds` and `minReadySeconds`.
- Update a StatefulSet in stages with `partition`.
- Explain the DaemonSet update strategies and use `rollout status` and `rollout undo` on them.

## Before You Start

You need to know what a Deployment and a Service are, and that a Service sends requests to Pods chosen by labels. The module playground has the `probe` Deployment and Service, a StatefulSet named `crew` and a DaemonSet named `scanner` in `starfleet`.

## Reading Order

1. Deployment Strategies: Recreate, Blue-Green And Canary
2. Updating StatefulSets And DaemonSets
3. Summary

<!-- astrona:playground -->
