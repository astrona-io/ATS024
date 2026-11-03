---
draft: true
exam_objectives:
- Configure Pod admission and scheduling (limits, node affinity, etc.)
---
# Starting Environment

The `starfleet` namespace has a Deployment `probe` with two replicas and a Pod `shuttle`, and none of them runs. The worker node is cordoned, the Deployment names a scheduler that does not exist and the Pod carries a scheduling gate.
