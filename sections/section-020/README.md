---
draft: true
exam_objectives:
- Use ConfigMaps and Secrets to configure applications
---
# Use ConfigMaps and Secrets to configure applications

A ConfigMap changes, but the running process keeps its startup environment value. The object was updated successfully, and the container still uses the old value, because the delivery method decides when a change is seen. This section teaches how configuration and confidential input reach a container, which delivery methods update while a Pod runs, which Secret types exist and who reads them, and how to combine several sources.

The explanations identify the responsible components, compare intended and observed state, and work through the decisions needed to preserve the requirement. Every module has a playground, a fresh single-node `kind` cluster for practice without grading. Graded labs and the capstone run in independent environments. All labs and playgrounds of this section are UNTESTED: they were written statically and never run.

## Modules

| Module | Topic | Practice |
| --- | --- | --- |
| Configuration And Confidential Input Delivery | ConfigMaps and Secrets as files and variables, storage, rotation | Playground, two labs, guided practice |
| Create ConfigMaps And Secrets And Inject Environment Variables | `kubectl create`, `valueFrom`, `envFrom`, `optional`, `items`, `defaultMode`, `immutable` | Playground, one lab |
| Secret Types And Special Uses | `Opaque`, TLS, registry, ServiceAccount token Secrets, `imagePullSecrets`, RBAC, encryption at rest | Playground, one lab |
| Projected Volumes, The Downward API And Configuration Patterns | `projected` volumes, `fieldRef`, `resourceFieldRef`, `$(VAR)` in `args`, rollout of changes | Playground, one lab |

A capstone lab closes the section. It asks you to fix a Deployment that mixes literal settings, a registry Secret of the wrong type, a missing configuration directory and a mutable ConfigMap. A knowledge check of twelve questions follows the capstone.

## Learning Outcomes

- Choose file or environment delivery for configuration.
- Explain namespace and key references.
- Distinguish input updates from application reload.
- Evaluate confidentiality, indirect access and rotation.
- Create ConfigMaps and Secrets from literals, files and environment files, and inject them with `valueFrom` and `envFrom`.
- Choose the Secret type that matches the consumer, and attach registry credentials through a ServiceAccount.
- Combine a ConfigMap, a Secret and the downward API in one projected volume.
