---
draft: true
exam_objectives:
- Configure Pod admission and scheduling (limits, node affinity, etc.)
---
# Configure Pod admission and scheduling (limits, node affinity, etc.)

A Pod needs an accelerator, but the only idle node lacks its required label. Free CPU does not make that node eligible. Scheduling first removes every node that breaks a mandatory rule, then ranks the nodes that remain by preference. Before the scheduler sees a Pod, the API server has already checked it against admission rules such as Pod Security levels.

This section follows that path. You read the events and the objects to find which component decided what, you write the rules as files, and you apply them in a playground cluster that starts fresh for each part. Each module has a playground, a graded lab, and a summary. A capstone lab at the end combines the skills of the earlier modules in one cluster.

## Learning Outcomes

- Explain scheduling filters and preferences.
- Compare required and preferred affinity.
- Interpret taints and tolerations.
- Diagnose eligibility separately from available capacity.
- Explain resource requests and how requests drive placement.
- Distinguish policy rejection at admission from scheduler placement.
- Apply Pod Security levels to a namespace and read the effect.
- Write node selectors and required or preferred node affinity with the right operators.
- Spread or separate Pods with pod affinity, anti-affinity and topology spread constraints.
- Place Pods by hand with nodeName and static Pods, and explain which checks that skips.
- Hold, release and redirect Pods with scheduling gates, cordon and scheduler names.
- Debug a Pending Pod from its status, events and the nodes.
