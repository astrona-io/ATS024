---
draft: true
exam_objectives:
- Configure workload autoscaling
---
# Configure workload autoscaling

Two replicas average one hundred percent CPU utilization against a fifty percent target. The simplified calculation suggests four replicas, but useful capacity still needs metrics, scheduling and readiness.

The explanations identify the responsible components, compare intended and observed state, and work through the decisions needed to preserve the requirement. Each module has a playground, a private kind cluster for free practice, and a graded lab. A capstone lab combines the modules, and a knowledge check closes the section. The labs and playgrounds are marked as untested until they have been run against a live cluster.

Each module begins with its goals and ends with a summary.

## Learning Outcomes

- Identify autoscaling target and metric requirements.
- Interpret utilization relative to requests.
- Explain stabilization and minimum or maximum bounds.
- Distinguish replica scaling from node capacity and bottleneck recovery.
- Combine several metrics in one HPA and control the speed of scaling with `behavior`.
- Diagnose an HPA that cannot calculate from its conditions and repair the cause.
- Scale a workload manually through the scale subresource and resize a running Pod in place.
- Describe the Vertical Pod Autoscaler, event-driven autoscaling with KEDA, and node-level autoscaling.
- Choose a PodDisruptionBudget and an HPA minimum that leave room for one eviction.

## Learning Path

| Step | Module | What you do |
| --- | --- | --- |
| 1 | Workload Autoscaling And Useful Capacity | Read how the HPA decides, then create a metrics-backed HPA in the playground and in the graded lab `ats-024-lab-030-01-01` |
| 2 | Tune HPA Metrics And Scaling Behavior | Read the metric types and `behavior`, practise in playground `ats-024-playground-030-02`, then repair and tune an HPA in lab `ats-024-lab-030-02-01` |
| 3 | Scale Workloads Manually And Vertically | Read the scale subresource and in-place resize, practise in playground `ats-024-playground-030-03`, then resize a Pod in lab `ats-024-lab-030-03-01`, and read about the Vertical Pod Autoscaler |
| 4 | Plan Event-Driven And Node-Level Autoscaling | Read KEDA, node autoscalers and disruption budgets, practise in playground `ats-024-playground-030-04`, then fix a budget in lab `ats-024-lab-030-04-01` |
| 5 | Capstone | Combine all four in lab `ats-024-lab-030-cap` |
| 6 | Knowledge check | Twelve questions across the four modules |

Run a playground or a lab from the repository root, for example:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS024.git -c sections/section-030/module-02/playground
astrona run --git ssh://git@github.com/astrona-io/ATS024.git -c sections/section-030/module-02/labs/lab-01
```
