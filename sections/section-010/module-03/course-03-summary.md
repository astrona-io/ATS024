---
draft: true
exam_objectives:
- Understand application deployments and how to perform rolling update and rollbacks
---
# Summary

A Deployment has two built-in strategies. RollingUpdate replaces Pods gradually and lets two versions run together. Recreate stops all old Pods before it starts new ones, so it causes downtime but never runs two versions at once.

Blue-green and canary are patterns built from ordinary objects. Blue-green keeps two Deployments and switches a Service selector. A canary lets one Service select the Pods of two Deployments, and the Pod counts set the approximate traffic share. The fields `minReadySeconds` and `progressDeadlineSeconds` make any strategy safer, and a passed deadline reports a failure without rolling back.

A StatefulSet updates Pods one at a time from the highest ordinal down and waits for each to be Ready. The `partition` field restricts the update to ordinals at or above its value, which allows a staged update that is finished by lowering the partition to zero. A broken Pod can block the update and may need manual deletion.

A DaemonSet uses `RollingUpdate` with `maxUnavailable` or `maxSurge`, or `OnDelete`, where Pods change only when deleted. The commands `rollout status`, `rollout history` and `rollout undo` work on Deployments, StatefulSets and DaemonSets.

<!-- astrona:playground:destroy -->
