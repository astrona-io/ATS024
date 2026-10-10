---
draft: true
exam_objectives:
- Configure Pod admission and scheduling (limits, node affinity, etc.)
---
# Summary

Scheduling considers feasibility before choosing among eligible nodes. Required placement rules and taint effects can exclude capacity that otherwise appears available.

A toleration permits consideration rather than forcing placement or guaranteeing health. Combine declared requests, node eligibility and supported topology rules when explaining why a workload remains unassigned.
