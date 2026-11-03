---
draft: true
exam_objectives:
- Understand application deployments and how to perform rolling update and rollbacks
---
# Starting Environment

The StatefulSet `crew` in `starfleet` has four Pods, `crew-0` to `crew-3`, that all run `docker.io/library/busybox:1.36.1`. All four are Ready. The update strategy is the default `RollingUpdate` with no partition.
