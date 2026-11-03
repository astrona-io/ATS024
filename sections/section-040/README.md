---
draft: true
exam_objectives:
- Understand the primitives used to create robust, self-healing, application deployments
---
# Understand the primitives used to create robust, self-healing, application deployments

A controller replaces a lost application Pod, but the replacement cannot mount its storage. Reconciliation created the requested object, while a later dependency prevented readiness. A robust deployment combines several Kubernetes primitives: controllers that restore the desired number of Pods, probes that decide when a container is ready or must restart, restart and lifecycle rules for each Pod, and budgets that limit how many Pods maintenance may remove at once.

This section has four modules. Each module starts with its goals, explains the mechanism in a few parts, offers a playground for free exploration and a graded lab, and ends with a summary. A capstone lab at the end of the section combines the four modules in one task.

The first module explains desired state, reconciliation and the three probe types. The second module covers the workload controllers: Deployments and ReplicaSets, ownership and garbage collection, DaemonSets, StatefulSets, Jobs and CronJobs. The third module follows a single Pod through its life: restart policy, crash loops, init containers, native sidecar containers, lifecycle hooks and graceful termination. The fourth module covers disruption: PodDisruptionBudgets, cordon, drain and eviction, node failure and topology spread constraints.

## Learning Outcomes

- Explain owner-driven replacement and desired state.
- Distinguish process startup from useful service.
- Choose health checks with appropriate recovery actions.
- Identify dependencies that replacement cannot repair.
- Choose the workload controller that fits a requirement and explain how ownership and garbage collection work.
- Repair a Job or CronJob by setting completions, retry, concurrency and clean-up fields.
- Predict Pod restart behavior from the restart policy, container states and probes.
- Use init containers, native sidecar containers and lifecycle hooks, and size the termination grace period.
- Protect an application during voluntary disruption with a PodDisruptionBudget, and explain why a drain is blocked.
- Explain how node failure leads to Pod eviction, and spread replicas over nodes to survive it.
