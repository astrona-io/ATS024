# Workloads & Scheduling (ATS024)

Certified Kubernetes Administrator (CKA): Workloads & Scheduling, worth 15% of the official curriculum. This course belongs to ATP005.

Reading lessons, module playgrounds, graded labs, capstones and quizzes cover the full CKA Workloads & Scheduling domain. Technical content remains draft.

## Course Outline

| Section / module | Module | Teaching lessons |
| --- | --- | --- |
| 010 / 01 | Rolling Replacement And Recovery | Rolling Updates And Health Gates; Calculating Rollout Capacity And Diagnosing Progress |
| 010 / 02 | Revision History And Rollbacks | Revision History And ReplicaSet Ownership; Rolling Back, Pausing And Resuming |
| 010 / 03 | Update Strategies For Deployments, StatefulSets And DaemonSets | Deployment Strategies: Recreate, Blue-Green And Canary; Updating StatefulSets And DaemonSets |
| 010 / 04 | Managing Deployments With Kustomize And Helm | Kustomize Bases, Overlays And Patches; Helm Releases: Upgrade, History And Rollback |
| 020 / 01 | Configuration And Confidential Input Delivery | ConfigMaps, Secrets And Configuration Delivery; Secret Storage, Delivery And Rotation |
| 020 / 02 | Create ConfigMaps And Secrets And Inject Environment Variables | Creating ConfigMaps And Secrets With kubectl; Environment Variables From ConfigMaps And Secrets; Volume Selection, Immutability And Update Rules |
| 020 / 03 | Secret Types And Special Uses | Secret Types And Required Keys; TLS And Registry Credential Secrets; Image Pull Secrets On Pods And ServiceAccounts; Protecting Secrets With RBAC And Encryption At Rest |
| 020 / 04 | Projected Volumes, The Downward API And Configuration Patterns | Projected Volumes: Combining Configuration Sources; The Downward API: Pod And Container Facts; Command Arguments And Configuration Patterns |
| 030 / 01 | Workload Autoscaling And Useful Capacity | Metric-Driven Replica Decisions And Their Boundaries; Replica Autoscaling And Availability |
| 030 / 02 | Tune HPA Metrics And Scaling Behavior | Metric Types And Multiple Metrics; Scaling Behavior And Stabilization; Missing Requests And HPA Conditions |
| 030 / 03 | Scale Workloads Manually And Vertically | Manual Scaling And The Scale Subresource; In-Place Pod Resize; Vertical Pod Autoscaler |
| 030 / 04 | Plan Event-Driven And Node-Level Autoscaling | Event-Driven Autoscaling And Scale To Zero; Node-Level Autoscaling; HPA, Disruption Budgets And Rollouts |
| 040 / 01 | Reconciliation And Application Health | Desired State And Reconciliation; Designing Startup, Readiness And Liveness Checks |
| 040 / 02 | Workload Controllers For Self-Healing | ReplicaSet Ownership And Garbage Collection; DaemonSet And StatefulSet; Jobs And CronJobs |
| 040 / 03 | Pod Lifecycle And Restart Behavior | Restart Policy, Crash Loops And Pod Status; Init Containers And Native Sidecar Containers; Lifecycle Hooks And Graceful Termination |
| 040 / 04 | Voluntary And Involuntary Disruption | Voluntary And Involuntary Disruption And PodDisruptionBudgets; Drain, Cordon And Eviction; Node Failure And Topology Spread |
| 050 / 01 | Placement Rules And Node Eligibility | Filtering, Scoring And Placement Rules; Taints, Tolerations And Eligibility |
| 050 / 02 | Admission And Resource Constraints | Expressing Resource Needs For Every Container; Applying Pod Security Requirements At Admission |
| 050 / 03 | Node Affinity | Node Labels And nodeSelector; Required Node Affinity And Operators; Preferred Node Affinity And Weights |
| 050 / 04 | Pod Affinity, Anti-Affinity And Topology Spread | Pod Affinity And Anti-Affinity With topologyKey; Topology Spread Constraints; Rolling Updates, matchLabelKeys And Domain Selection |
| 050 / 05 | Manual Scheduling, Static Pods And Scheduler Controls | Manual Scheduling With nodeName; Static Pods; Multiple Schedulers And Scheduler Profiles; Scheduling Gates, Cordon And Uncordon; Debugging Pending Pods |
| 050 / 06 | Resource Quotas And Limit Ranges | Requests, Limits, Throttling And OOM Kills; Limit Ranges And Resource Quotas At Admission |
| 050 / 07 | Admission Controllers And ValidatingAdmissionPolicy | The Admission Chain And Built-In Controllers; ValidatingAdmissionPolicy With CEL |
| 050 / 08 | Priority, Preemption And Quality Of Service | Priority Classes And Preemption; Quality Of Service, Eviction And Pod Overhead |

Each section ends with a capstone lab and a knowledge-check quiz (`quiz.yaml`). The domain closes with `sections/final-domain-quiz.yaml`.

## Author Review

The [curriculum map](CURRICULUM.md) records objective coverage. [Sources](SOURCES.md) support author review, and [assessment documentation](ASSESSMENTS.md) describes the reusable YAML contract. Guided practice and independent graded labs use private environments. Live verification remains pending.

## Hands-On Coverage

Every module has an ungraded playground and at least one graded lab; every section has a capstone lab. Labs and playgrounds were built with static checks only (`astrona validate -c`, `bash -n`, YAML parsing). Nothing has been run against a live environment, so new labs are marked UNTESTED.

| Module | Lab (all new labs UNTESTED) |
| --- | --- |
| 010/01 | Perform A Rolling Template Update |
| 010/01 | Recover A Failed Deployment Update |
| 010/02 | Roll Back To A Specific Revision |
| 010/03 | Stage A StatefulSet Update With A Partition |
| 010/04 | Build A Kustomize Production Overlay |
| 010/capstone | Capstone: Recover From A Faulty Update And Ship A Safe Release |
| 020/01 | Consume A Mounted ConfigMap |
| 020/01 | Consume A Secret Without Printing It |
| 020/02 | Inject Configuration Through Environment Variables |
| 020/03 | Attach Registry Credentials And Serve A TLS Secret |
| 020/04 | Merge Configuration Into One Projected Volume |
| 020/capstone | Configure An Application With ConfigMaps And Secrets |
| 030/01 | Configure A Metrics-Backed Autoscaler |
| 030/02 | Repair And Tune A Broken Autoscaler |
| 030/03 | Resize A Running Pod And Scale A Deployment |
| 030/04 | Make The Budget And The Autoscaler Agree |
| 030/capstone | Capstone: Autoscale, Resize And Protect A Workload |
| 040/01 | Repair Readiness Without Removing It |
| 040/01 | Repair A Liveness Probe Port |
| 040/02 | Repair A Failed Job And A CronJob |
| 040/03 | Repair A Crash-Looping Deployment And A Restarting Task Pod |
| 040/04 | Repair Pod Disruption Budgets And Node-Loss Tolerance |
| 040/capstone | Self-Healing Deployments Capstone |
| 050/01 | Repair An Impossible Node Selector |
| 050/01 | Tolerate A Dedicated Worker Taint |
| 050/02 | Enforce Restricted Pod Admission |
| 050/03 | Repair Required Node Affinity |
| 050/04 | Replace Anti-Affinity With A Spread Constraint |
| 050/05 | Release Pending Pods |
| 050/06 | Enforce Defaults And Quotas In A Namespace |
| 050/07 | Enforce Rules With ValidatingAdmissionPolicy |
| 050/08 | Protect A Critical Workload With Priority And QoS |
| 050/capstone | Place A Restricted Workload On A Dedicated Pool |
