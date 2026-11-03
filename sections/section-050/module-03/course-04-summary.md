---
draft: true
exam_objectives:
- Configure Pod admission and scheduling (limits, node affinity, etc.)
---
# Summary

Node labels are data on node objects. The kubelet sets the well-known labels, and administrators add the rest. The scheduler reads those labels when it places a Pod, and it retries a Pending Pod when a node label changes.

A `nodeSelector` is an exact match on every listed pair. Node affinity is the richer form: it supports the operators `In`, `NotIn`, `Exists`, `DoesNotExist`, `Gt` and `Lt`. Several terms are alternatives, and several expressions inside one term must all hold.

A required rule filters nodes out, and a Pod with no matching node stays Pending. A preferred rule only adds its weight to the score of matching nodes among the nodes that already passed the filters. Both rules are ignored once the Pod runs, so a later label change does not evict it.

When a Pod does not schedule, the `FailedScheduling` event names the check that failed. Compare the rule with the real node labels before changing anything else.

<!-- astrona:playground:destroy -->
