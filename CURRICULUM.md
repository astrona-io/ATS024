# Curriculum Coverage

Exam: Certified Kubernetes Administrator (CKA). Domain: Workloads & Scheduling (15%).

The [official objectives](https://training.linuxfoundation.org/certification/certified-kubernetes-application-developer-ckad/) were verified on 2026-10-11. Teaching structure is original; it does not add official exam requirements.

| Section | Official objective | Modules |
| --- | --- | --- |
| 010 | Understand application deployments and how to perform rolling update and rollbacks | 1 |
| 020 | Use ConfigMaps and Secrets to configure applications | 1 |
| 030 | Configure workload autoscaling | 1 |
| 040 | Understand the primitives used to create robust, self-healing, application deployments | 1 |
| 050 | Configure Pod admission and scheduling (limits, node affinity, etc.) | 2 |

| Section / module | Module | Teaching lessons |
| --- | --- | --- |
| 010 / 01 | Rolling Replacement And Recovery | Rolling Updates And Health Gates; Calculating Rollout Capacity And Diagnosing Progress |
| 020 / 01 | Configuration And Confidential Input Delivery | ConfigMaps, Secrets And Configuration Delivery; Secret Storage, Delivery And Rotation |
| 030 / 01 | Workload Autoscaling And Useful Capacity | Metric-Driven Replica Decisions And Their Boundaries; Replica Autoscaling And Availability |
| 040 / 01 | Reconciliation And Application Health | Desired State And Reconciliation; Designing Startup, Readiness And Liveness Checks |
| 050 / 01 | Placement Rules And Node Eligibility | Filtering, Scoring And Placement Rules; Taints, Tolerations And Eligibility |
| 050 / 02 | Admission And Resource Constraints | Expressing Resource Needs For Every Container; Applying Pod Security Requirements At Admission |

The module goals and adaptation sources are recorded in AUTHORING.yaml. Every official objective is covered. Each section starts with an introduction, and each module ends with a summary. YAML banks follow the relevant summary and remain separate from the Markdown manifest.

This is a reading-only draft. No new labs, playgrounds, command output or runtime verification are included. ATP005 publication remains draft.
