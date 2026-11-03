---
draft: true
exam_objectives:
- Configure workload autoscaling
---
# Workload Autoscaling And Useful Capacity

The HorizontalPodAutoscaler (HPA) is the Kubernetes object that changes the replica count of a workload from measurements. This module follows one HPA decision from the container measurement to the number of ready Pods, and shows where that chain breaks.

## Learning goals

- Identify the autoscaling target and the metric requirements.
- Interpret CPU utilization relative to requests.
- Explain tolerance, stabilization and the minimum and maximum bounds.
- Distinguish replica scaling from node capacity and vertical sizing.

## Before you start

You need to know what a Deployment, a Pod and a Service are, and how to run `kubectl get` and `kubectl apply`. The playground is a private kind cluster with the metrics server installed. It runs the `probe` Deployment in `starfleet` and the client Pods `shuttle` and `drifter`.

## What the parts cover

The first part follows the measurement from the kubelet through the metrics server to the controller, and works through the replica calculation with its tolerance and bounds. The second part writes the HPA with `kubectl autoscale` and with an `autoscaling/v2` manifest, reads its status conditions, and separates horizontal, vertical and node scaling. A graded task follows, then a guided practice in the playground, and a summary closes the module.

<!-- astrona:playground -->
