---
draft: true
exam_objectives:
- Configure workload autoscaling
---
# Replica Autoscaling And Availability

An autoscaler requests ten replicas, but only six fit on the current nodes. Application scaling succeeded as a decision while physical capacity remains a separate constraint.

## Learning objectives

- Identify autoscaling target and metric requirements.
- Interpret utilization relative to requests.
- Explain stabilization and minimum or maximum bounds.

## Before you start

This chapter is standalone reading material; no running cluster or installed tools are required. A Pod is the Kubernetes unit for running one or more containers, and a namespace groups namespaced objects. Treat the worked configurations as teaching examples rather than recorded observations from a provisioned environment.

## Responsible components and behavior

Traffic to `scout` increases. Adding more application replicas can share requests if the application and its dependencies support parallel work. The Horizontal Pod Autoscaler (HPA) adjusts the replica count of a supported target according to configured metrics and a control loop.

For CPU utilization targets, utilization is measured relative to resource requests. A metrics provider supplies observations; the autoscaler compares them with its target and calculates a desired replica count within configured bounds. Missing metrics or requests can prevent the expected calculation. Scaling decisions also use timing and stabilization behavior rather than responding instantly to every fluctuation.

```mermaid
flowchart TB
    W["Workload replicas"] -->|"measured use"| M["Metrics provider"]
    M -->|"metrics"| H["Horizontal Pod Autoscaler"]
    H -->|"desired replicas"| D["Deployment"]
    D -->|"reconcile"| W
```
The feedback loop changes application replicas; it does not directly add worker nodes.

More replicas need somewhere to run. An HPA can request ten replicas while only six fit on existing nodes. Node autoscaling may then provide additional capacity, but these are separate mechanisms. Vertical sizing changes resource requests or limits for a workload rather than simply adding copies.

Availability also needs ready backends, suitable spreading and resilient dependencies. A PodDisruptionBudget limits certain voluntary disruptions according to availability requirements. It does not prevent hardware failure, guarantee capacity or replace a sound application design. A budget that cannot be satisfied may block maintenance rather than solve the missing redundancy.

For a scenario, identify whether demand exceeds application concurrency, node capacity or a dependency's capacity. Adding request handlers cannot repair a database bottleneck by itself. Scaling is effective only when the component receiving more capacity is the limiting part of the system.

## Interpreting A CPU Utilization Target

Suppose four `scout` replicas each request 200 millicores and use about 100 millicores. Their CPU utilization relative to requests is about 50%. An HPA target expressed as CPU utilization compares against that request-relative measure, not the node's total CPU percentage. Changing requests can change the calculated utilization even when measured process usage stays similar.

When observed demand rises above the target, the autoscaler can request more replicas within its configured minimum and maximum. Its decisions depend on available metrics, valid target configuration and timing rules. A momentary spike need not cause an immediate matching replica increase, and missing metrics can prevent straightforward interpretation.

Replica scaling assumes the workload can distribute useful work across more instances. A serial task, a fixed external bottleneck or a limited connection pool can undermine that assumption. More instances can even increase load on a struggling dependency. Inspect whether added capacity addresses the actual limiting component.

## Three Different Capacity Controls

Horizontal scaling changes the number of instances. Vertical sizing changes the resources assigned to each instance. Node scaling changes the pool of machines that can host them. A healthy operating model may use all three, but they have different inputs, delays and compatibility requirements.

A replica increase can encounter Pending Pods because the node pool is full. A node increase can create unused capacity if the application is still capped at a low maximum replica count. Enlarging a container request can improve its resource allocation while reducing how many replicas fit on each node.

Availability requires these controls to agree with readiness and placement. Disruption budgets can limit supported maintenance removals, but they cannot replace capacity after involuntary loss. A clear scaling explanation identifies the metric or requirement, the value being changed and the stage where the additional capacity becomes useful.

## Work through the decision

Horizontal scaling changes replica population. Node scaling changes where that population can run. Vertical sizing changes per-workload resource declarations. These mechanisms can complement each other, but none should be inferred from the existence of another.

Suppose the real bottleneck is one database lock. More request handlers can increase pressure without increasing completed operations. Measure the constrained operation, then choose a scaling action that supplies useful capacity. A PodDisruptionBudget constrains supported voluntary disruptions rather than supplying spare nodes or protecting against every failure. Maintenance must be evaluated against actual available replicas and their dependencies.

```mermaid
flowchart TB
    N0["Demand measurement"]
    N1["Replica scaling decision"]
    N2["Node capacity"]
    N3["Ready backend population"]
    N4["Completed application work"]
    N0 --> N1
    N1 --> N2
    N2 --> N3
    N3 --> N4
```

Availability depends on useful replicas and resilient dependencies, not on desired replica count alone.

Availability depends on useful replicas and resilient dependencies, not on desired replica count alone.

## Common pitfalls

> [!WARNING]
> The HPA changes replicas, not node count. Additional replicas can remain Pending, and a disruption budget does not prevent involuntary failures.
