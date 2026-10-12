---
draft: true
exam_objectives:
- Understand the primitives used to create robust, self-healing, application deployments
---
# Understand the primitives used to create robust, self-healing, application deployments

A controller replaces a lost application Pod, but the replacement cannot mount its storage. Reconciliation created the requested object while a later dependency prevented readiness.

The explanations identify the responsible components, compare intended and observed state, and work through the decisions needed to preserve the requirement. Read the worked examples as reasoning about a proposed system; no environment is started by this section.

Each module begins with its goals and ends with a summary. Reusable YAML knowledge checks follow the section summary and are registered separately for future presentation.

## Learning Outcomes

- Explain owner-driven replacement and desired state.
- Distinguish process startup from useful service.
- Choose health checks with appropriate recovery actions.
- Identify dependencies that replacement cannot repair.
