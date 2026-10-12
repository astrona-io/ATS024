---
draft: true
exam_objectives:
- Configure workload autoscaling
---
# Metric-Driven Replica Decisions And Their Boundaries

Two replicas average one hundred percent CPU utilization against a fifty percent target. The simplified calculation suggests four replicas, but useful capacity still needs metrics, scheduling and readiness.

## Learning objectives

- Identify autoscaling target and metric requirements.
- Interpret utilization relative to requests.
- Explain stabilization and minimum or maximum bounds.

## Before you start

This chapter is standalone reading material; no running cluster or installed tools are required. A Pod is the Kubernetes unit for running one or more containers, and a namespace groups namespaced objects. Treat the worked configurations as teaching examples rather than recorded observations from a provisioned environment.

## Responsible components and behavior

The HorizontalPodAutoscaler, or HPA, adjusts a supported workload's desired replica count from configured metrics. It does not directly create more nodes or rewrite every container's resource limit. Scaling decisions depend on metric availability, target interpretation and the workload's ability to provide useful capacity after replicas are added.

## Identify The Scaling Target

The HPA references a workload with a supported scale interface. Its minimum and maximum replicas constrain the desired range. A Deployment can therefore have its replica count influenced by the HPA, while a separate process continually forcing another count can create conflicting desired-state updates.

Resource metrics can express utilization relative to requests or an absolute usage value according to the configured target type. Custom and external metrics need appropriate metric APIs and adapters. An HPA definition does not automatically install those data sources.

For a CPU utilization target, CPU means central processing unit. Applicable container CPU requests supply the utilization denominator. Missing required requests can prevent meaningful utilization calculation for the target. A measured consumption number without that denominator does not establish the desired percentage.

## Work Through A Simplified Decision

Under a simplified average utilization model, desired replicas are based on current replicas multiplied by observed utilization divided by target utilization, rounded upward. With two replicas, one hundred percent observed utilization and a fifty percent target, that simple calculation suggests four replicas.

Real controller behavior includes tolerance, missing metrics, not-yet-ready Pods and stabilization or scaling policies. The simplified calculation teaches the relationship, not a promise that every observation instantly produces that exact count. A maximum of three would also constrain the final requested range.

The metric must fit the application. CPU can represent useful demand for some workloads but fail to represent a queue or external bottleneck for others. An application waiting on a saturated database may have low CPU while requests are slow. Increasing frontend replicas then may increase backend pressure without fixing the limiting dependency.

## From Desired Replicas To Useful Capacity

Adding desired replicas causes the workload controller to create or manage more Pods. Those Pods still need scheduling capacity, image access, startup and readiness. An HPA can request more capacity while all new Pods remain Pending. It does not guarantee the cluster has suitable nodes or storage for them.

A node autoscaler, when installed and configured, performs a different responsibility concerning infrastructure capacity. It has provider constraints, timing and placement limits. The presence of an HPA does not imply that node autoscaling is available or that every unschedulable Pod can be solved by adding a node.

Scaling down can remove replicas that hold temporary local state or active requests. The application should handle termination and shared state appropriately. A larger count is not universally safer, and a lower count needs an availability and disruption design that fits the workload.

## Stability And Diagnosis

Stabilization windows and scaling policies can reduce oscillation or constrain rate of change. A fluctuating metric can otherwise repeatedly increase and decrease capacity. Interpret configured behavior and current conditions before treating a delayed decrease as proof that the controller is broken.

If an HPA has no usable metrics, inspect the metric service, target and required requests. If it asks for additional replicas but none become ready, follow placement and preparation. If new ready replicas do not improve latency, investigate the application bottleneck and metric choice.

Successful autoscaling is a chain from meaningful measurement to appropriate desired replicas and usable application capacity. Each step has a separate responsible component and limit. That chain explains both a configuration choice and a realistic diagnosis.

## Dependency Flow

```mermaid
flowchart TB
    metric["Usable metric and configured target"] --> hpa["HPA applies bounds and behavior"]
    hpa --> replicas["Desired workload replicas"]
    replicas --> controller["Workload controller manages Pods"]
    controller --> capacity["Placement, preparation and readiness"]
    capacity --> service["Useful application capacity"]
```

## Work through the decision

The HorizontalPodAutoscaler (HPA) uses an observed-to-target relationship to adjust the target workload's scale. Central processing unit (CPU) utilization uses the relevant resource requests as a denominator. Missing metrics or required requests can prevent a meaningful percentage calculation.

Under the simplified model, multiply current replicas by observed utilization divided by target utilization and round upward. Real behavior also considers tolerance, missing observations, readiness and configured stabilization. The resulting desired replicas are intent: the workload controller must create Pods, nodes must fit them, and the application must serve useful work. The HPA does not directly add nodes or repair a saturated database.

```mermaid
flowchart TB
    N0["Metrics and request denominator"]
    N1["HPA decision and bounds"]
    N2["Desired workload scale"]
    N3["Schedulable ready replicas"]
    N4["Useful application capacity"]
    N0 --> N1
    N1 --> N2
    N2 --> N3
    N3 --> N4
```

A scale decision becomes useful only when the resulting replicas can run and relieve the actual bottleneck.

A scale decision becomes useful only when the resulting replicas can run and relieve the actual bottleneck.

## Common pitfalls

> [!WARNING]
> HPA changes workload replica intent, not node capacity or every resource limit. Metrics, requests, stabilization, placement and application bottlenecks determine whether a replica change provides useful service.
