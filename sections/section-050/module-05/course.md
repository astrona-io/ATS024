---
draft: true
exam_objectives:
- Configure Pod admission and scheduling (limits, node affinity, etc.)
---
# Manual Scheduling, Static Pods And Scheduler Controls

This module teaches the ways a Pod gets a node without the normal scheduling path, and the controls that change when and by whom a Pod is scheduled. You will assign a node by hand with `nodeName`, run static Pods from the kubelet's manifest directory, direct a Pod to another scheduler or scheduler profile, hold a Pod back with a scheduling gate, take a node out of rotation with cordon, and debug Pending Pods from events.

## Learning Goals

- Explain what `spec.nodeName` does and which checks it skips.
- Place a static Pod file in `/etc/kubernetes/manifests` and explain the mirror Pod.
- Use `schedulerName`, and describe how a scheduler profile in `KubeSchedulerConfiguration` differs from a second scheduler process.
- Use scheduling gates, `kubectl cordon` and `kubectl uncordon`.
- Debug a Pending Pod with `kubectl describe`, events and node data, and tell a scheduler failure from a Pod nobody is scheduling.

## Before You Start

You need `kubectl` and a cluster with one worker node. For the static Pod and kube-scheduler chapters you also need to run commands inside a node container with `podman exec` or `docker exec`, because kind nodes are containers. The module playground provides this cluster.

## Reading Order

1. Manual scheduling with nodeName
2. Static Pods
3. Multiple schedulers and scheduler profiles
4. Scheduling gates, cordon and uncordon
5. Debugging Pending Pods
6. Summary

<!-- astrona:playground -->
