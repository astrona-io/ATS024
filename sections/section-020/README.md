---
draft: true
exam_objectives:
- Use ConfigMaps and Secrets to configure applications
---
# Use ConfigMaps and Secrets to configure applications

A ConfigMap changes, but the running process keeps its startup environment value. The object was updated successfully; adoption did not occur through that delivery method. Configuration maintenance needs both delivery and consumption to be explained.

The explanations identify the responsible components, compare intended and observed state, and work through the decisions needed to preserve the requirement. Read the worked examples as reasoning about a proposed system; no environment is started by this section.

Each module begins with its goals and ends with a summary. Reusable YAML knowledge checks follow the section summary and are registered separately for future presentation.

## Learning Outcomes

- Choose file or environment delivery for configuration.
- Explain namespace and key references.
- Distinguish input updates from application reload.
- Evaluate confidentiality, indirect access and rotation.
