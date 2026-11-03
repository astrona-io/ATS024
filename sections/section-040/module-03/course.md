---
draft: true
exam_objectives:
- Understand the primitives used to create robust, self-healing, application deployments
---
# Pod Lifecycle And Restart Behavior

A Pod can fail in many small ways, and each failure has its own recovery rule. A container that exits is restarted by the kubelet. A Pod that cannot finish its setup is retried or marked failed. A Pod that is deleted gets a bounded time to stop. This module explains those rules, so that you can predict what a Pod will do and fix it when it does not do that.

## Learning Goals

- Explain how `restartPolicy` decides whether the kubelet restarts a container, and why `CrashLoopBackOff` is a waiting reason and not a phase.
- Read Pod phases, Pod conditions and container states as three separate levels of status.
- Use a startup probe so that a slow application is not killed by its liveness probe.
- Use init containers and native sidecar containers, and predict their start order and failure behavior.
- Use `postStart` and `preStop` hooks and `terminationGracePeriodSeconds` for a graceful stop.

## Before You Start

You need a basic idea of what a Pod, a container and the kubelet (the agent on each node that runs containers) are. The module playground has four example Pods. Graded exercises use a separate environment and follow the reading they practise.

## Reading Order

The first part covers `restartPolicy`, the restart delay, the three status levels and the startup probe. The second part covers init containers and native sidecar containers. The third part covers lifecycle hooks and the termination sequence. The module ends with a summary.

<!-- astrona:playground -->
