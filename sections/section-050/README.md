---
draft: true
exam_objectives:
- Configure Pod admission and scheduling (limits, node affinity, etc.)
---
# Configure Pod admission and scheduling (limits, node affinity, etc.)

A Pod needs an accelerator, but the only idle node lacks its required label. Free CPU does not make that node eligible. Scheduling first satisfies mandatory requirements, then evaluates preferences.

The explanations identify the responsible components, compare intended and observed state, and work through the decisions needed to preserve the requirement. Read the worked examples as reasoning about a proposed system; no environment is started by this section.

Each module begins with its goals and ends with a summary. Reusable YAML knowledge checks follow the section summary and are registered separately for future presentation.

## Learning Outcomes

- Explain scheduling filters and preferences.
- Compare required and preferred affinity.
- Interpret taints and tolerations.
- Diagnose eligibility separately from available capacity.
- Explain defaults, quota and resource requirement admission.
- Distinguish policy rejection from scheduler placement.
- Evaluate complete container resource needs.
- Interpret security profile enforcement and exceptions.
