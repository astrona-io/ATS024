---
draft: true
exam_objectives:
- Configure Pod admission and scheduling (limits, node affinity, etc.)
---
# Starting Environment

Starting state: the namespace `starfleet` has no Pod Security label. Two worker nodes carry the label `pool=dedicated`, a zone label (`zone-a` and `zone-b`) and the taint `dedicated=scout:NoSchedule`, and the second worker is cordoned. The Deployment `scout` has four replicas, requests 16 CPUs per Pod, and has no toleration, affinity, spread constraint or security settings. All four Pods are Pending.
