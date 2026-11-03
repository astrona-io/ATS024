---
draft: true
exam_objectives:
- Configure workload autoscaling
---
# Tune HPA Metrics And Scaling Behavior

A HorizontalPodAutoscaler (HPA) with a single CPU target is only the starting point. Real workloads need more than one metric, a controlled speed of change, and a way to find out why the HPA does nothing. This module covers the `autoscaling/v2` API, the `behavior` field and the diagnosis of the HPA status.

## Learning goals

- Name the five metric types and combine several metrics in one HPA.
- Control the speed of scaling with stabilization windows, policies and `selectPolicy`.
- Diagnose `ScalingActive` and `ScalingLimited` and repair a missing CPU request.

## Before you start

You need to know how a Deployment, a Pod and a CPU request work, and what the HPA controller does with a CPU utilization target. The playground is a private kind cluster with the metrics server installed. It runs the `probe` Deployment with CPU and memory requests, the `scout` Deployment without any requests, and the client Pods `shuttle` and `drifter`.

## What the parts cover

The first part lists the metric types and the APIs behind them, and writes an HPA with two metrics. The second part controls the speed of scale-up and scale-down with `behavior`. The third part reproduces an HPA that cannot calculate, reads its conditions and repairs it. A graded task on a broken HPA follows the third part, and a summary closes the module.

<!-- astrona:playground -->
