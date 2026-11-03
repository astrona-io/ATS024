---
draft: true
exam_objectives:
- Configure Pod admission and scheduling (limits, node affinity, etc.)
---
# Starting Environment

The `starfleet` namespace has a Deployment `probe` with three replicas and a required Pod anti-affinity rule on the zone key. The two worker nodes are in two zones, so the third replica is Pending.
