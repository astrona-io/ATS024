---
draft: true
exam_objectives:
- Understand application deployments and how to perform rolling update and rollbacks
---
# Understand application deployments and how to perform rolling update and rollbacks

A new `probe` version starts but cannot answer its readiness check. Kubernetes keeps the process running while the Deployment waits for usable replacement capacity. Reading this situation correctly prevents a failed rollout from being mistaken for a missing update.

The explanations identify the responsible components, compare intended and observed state, and work through the decisions needed to preserve the requirement. Read the worked examples as reasoning about a proposed system; no environment is started by this section.

Each module begins with its goals and ends with a summary. Reusable YAML knowledge checks follow the section summary and are registered separately for future presentation.

## Learning Outcomes

- Identify Deployment template changes and revisions.
- Calculate rolling-update limits.
- Explain health and capacity effects on progress.
- Evaluate rollback compatibility and external state.
