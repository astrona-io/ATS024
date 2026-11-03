# Curriculum Coverage

Exam: Certified Kubernetes Administrator (CKA). Domain: Workloads & Scheduling (15%).

The [official objectives](https://training.linuxfoundation.org/certification/certified-kubernetes-administrator-cka/) were verified on 2026-10-11. Teaching structure is original; it does not add official exam requirements.

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

This draft includes developed readings, private playgrounds and independent graded labs. Static and offline checks pass; live execution remains pending. ATP005 publication remains draft.

## Hands-On Coverage

This course has 6 ungraded module playgrounds and 10 draft independent labs. Tasks and solutions are registered around each lab immediately after its teaching reading. Static configuration, shell/Python/YAML, parser, lifecycle and offline grader checks pass. Live execution remains pending because the session cannot access Podman; installed CLI configuration validation is separately blocked by its maintenance lock.

| Module | Labs in teaching order |
| --- | --- |
| 010/01 | Perform A Rolling Template Update |
| 010/01 | Recover A Failed Deployment Update |
| 020/01 | Consume A Mounted ConfigMap |
| 020/01 | Consume A Secret Without Printing It |
| 030/01 | Configure A Metrics-Backed Autoscaler |
| 040/01 | Repair Readiness Without Removing It |
| 040/01 | Repair A Liveness Probe Port |
| 050/01 | Repair An Impossible Node Selector |
| 050/01 | Tolerate A Dedicated Worker Taint |
| 050/02 | Enforce Restricted Pod Admission |


## Coverage By Module (updated)

Every objective is covered by one or more modules, each with a playground and a graded lab, plus a section capstone and quiz. Labs are UNTESTED.

### Understand application deployments and how to perform rolling update and rollbacks

- Rolling Replacement And Recovery
- Revision History And Rollbacks
- Update Strategies For Deployments, StatefulSets And DaemonSets
- Managing Deployments With Kustomize And Helm

### Use ConfigMaps and Secrets to configure applications

- Configuration And Confidential Input Delivery
- Create ConfigMaps And Secrets And Inject Environment Variables
- Secret Types And Special Uses
- Projected Volumes, The Downward API And Configuration Patterns

### Configure workload autoscaling

- Workload Autoscaling And Useful Capacity
- Tune HPA Metrics And Scaling Behavior
- Scale Workloads Manually And Vertically
- Plan Event-Driven And Node-Level Autoscaling

### Understand the primitives used to create robust, self-healing, application deployments

- Reconciliation And Application Health
- Workload Controllers For Self-Healing
- Pod Lifecycle And Restart Behavior
- Voluntary And Involuntary Disruption

### Configure Pod admission and scheduling (limits, node affinity, etc.)

- Placement Rules And Node Eligibility
- Admission And Resource Constraints
- Node Affinity
- Pod Affinity, Anti-Affinity And Topology Spread
- Manual Scheduling, Static Pods And Scheduler Controls
- Resource Quotas And Limit Ranges
- Admission Controllers And ValidatingAdmissionPolicy
- Priority, Preemption And Quality Of Service

