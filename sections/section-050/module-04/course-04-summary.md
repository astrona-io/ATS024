---
draft: true
exam_objectives:
- Configure Pod admission and scheduling (limits, node affinity, etc.)
---
# Summary

Pod affinity and anti-affinity relate a Pod to other Pods that a label selector picks. The topology key names a node label, and all nodes that share its value form one domain. Affinity places a Pod in a domain that holds a matching Pod. Anti-affinity keeps it out of such a domain.

A required anti-affinity rule needs as many eligible domains as replicas. When the cluster has fewer, the extra Pods stay Pending, and the event names the rule that failed. A preferred rule never blocks scheduling and only changes the score.

Topology spread constraints allow an uneven spread within a limit. Skew is the count in a domain minus the lowest count in any eligible domain, and `maxSkew` is the largest allowed value. `DoNotSchedule` filters nodes out. `ScheduleAnyway` only lowers the score.

Which nodes count as domains decides the result. Nodes without the topology label are not domains. Tainted or excluded nodes can still count unless the node inclusion policies say otherwise. The field `matchLabelKeys` keeps the Pods of different revisions apart during a rolling update. The proof of a spread is the real placement of the Pods.

<!-- astrona:playground:destroy -->
