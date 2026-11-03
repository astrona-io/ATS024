---
draft: true
exam_objectives:
- Configure Pod admission and scheduling (limits, node affinity, etc.)
---
# Pod Affinity And Topology Spread Playground

This ungraded environment is a kind cluster with one control plane node and two worker nodes. The first worker has the label `topology.kubernetes.io/zone=zone-a` and the second has `topology.kubernetes.io/zone=zone-b`. The control plane node is tainted and has no zone label. The namespaces `starfleet` and `outpost` exist and are empty. There is no task and nothing to submit.

## What to try

- Run three replicas with required anti-affinity on `kubernetes.io/hostname` and read the event of the Pending Pod.
- Change the topology key to `topology.kubernetes.io/zone` and count how many replicas can run.
- Run four replicas with a spread constraint on the zone key and `maxSkew: 1`, then on the hostname key. Compare the results, then add `nodeTaintsPolicy: Honor` to the hostname version.
- Compare `DoNotSchedule` with `ScheduleAnyway` after you cordon one worker with `kubectl cordon`.
- Add `matchLabelKeys` with `pod-template-hash` and change the image to watch a rolling update.
- Start a client Pod with required Pod affinity to the `probe` Pods on the zone key and check which zone it uses.

Use `astrona destroy ats-024-playground-050-04` when you are done.
