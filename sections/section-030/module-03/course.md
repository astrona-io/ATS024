---
draft: true
exam_objectives:
- Configure workload autoscaling
---
# Scale Workloads Manually And Vertically

Horizontal autoscaling changes how many Pods run. Two other controls change the capacity of a workload: a person or a script that sets the replica count, and a change to the size of each Pod. This module covers manual scaling through the scale subresource, in-place Pod resize, and the Vertical Pod Autoscaler.

## Learning goals

- Scale workloads with `kubectl scale` and explain the scale subresource.
- Predict what happens when manual scaling and an HPA write the same replica count.
- Resize the CPU of a running Pod with `kubectl patch --subresource resize` and read the result.
- Name the components and update modes of the Vertical Pod Autoscaler.

## Before you start

You need to know what a Deployment, a Pod, a request and a limit are. The playground is a private kind cluster with one worker node. It runs the `scout` Deployment with two replicas and the Pod `bridge` whose CPU can be resized in place.

## What the parts cover

The first part explains the scale subresource, the `kubectl scale` command and its preconditions, and the conflict with an HPA. The second part resizes a running Pod in place and reads the resize conditions. A graded task on both follows the second part. The third part explains the Vertical Pod Autoscaler as reading. A summary closes the module.

<!-- astrona:playground -->
