---
draft: true
exam_objectives:
- Understand the primitives used to create robust, self-healing, application deployments
---
# Summary

A disruption is an event that removes a running Pod. Voluntary disruptions are actions that a person or a tool chooses, such as draining a node or changing a Pod template. Involuntary disruptions are failures nobody chose, such as a lost machine or an out-of-memory node. Kubernetes can limit the first kind and can only react to the second.

A PodDisruptionBudget limits how many Pods of one application may be down at the same time because of voluntary disruption. It states either a minimum number of available Pods or a maximum number of unavailable Pods, and it selects the Pods with a label selector. The disruption controller turns that rule into a status that shows how many disruptions are allowed right now. A budget that requires every replica, or whose selector matches nothing, protects nothing useful.

The Eviction API is the part that enforces a budget. A drain cordons the node and then asks the API server to evict each Pod. When an eviction would break a budget, the API server refuses and the drain retries. Direct deletion, rolling updates and node failure do not go through that check.

When a node stops reporting, the node lifecycle controller adds the not-ready or unreachable taint with the NoExecute effect. Pods that tolerate the taint stay until their tolerationSeconds run out, and the API server adds a default of 300 seconds to every Pod that does not set its own. A shorter value moves replicas sooner, and a longer value avoids moving them during short network problems.

Topology spread constraints and anti-affinity decide where replicas run in the first place. If all replicas share one node, no budget or toleration can keep the application available when that node fails. Replicas on different nodes, a budget that allows one disruption at a time and a deliberate toleration time work together.

<!-- astrona:playground:destroy -->
