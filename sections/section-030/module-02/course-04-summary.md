---
draft: true
exam_objectives:
- Configure workload autoscaling
---
# Summary

An `autoscaling/v2` HPA takes a list of metrics. A `Resource` metric reads CPU or memory of the whole Pod, and a `ContainerResource` metric reads one container. `Pods`, `Object` and `External` metrics read custom and external metrics APIs, which a metrics adapter must serve, because the metrics server serves only `metrics.k8s.io`. For several metrics the controller computes one proposal for each and uses the largest, and it does not scale down while any metric is unreadable.

The `behavior` field controls the speed of change. Each direction has its own stabilization window, policies and `selectPolicy`. The defaults scale up at once and wait 300 seconds before scaling down. A policy of type `Pods` or `Percent` limits the change in one period, `Max` picks the largest allowed change, `Min` the smallest, and `Disabled` stops that direction.

A `ScalingActive` condition of `False` means the controller cannot calculate. The causes, in order, are the metrics API, the kubelet data, a missing CPU request, and a wrong target reference. The repair belongs to the broken part, so the Deployment gets its request and the HPA stays. `ScalingLimited` only reports that a bound or a policy cut the result.

- Utilization targets need requests on every container; average value targets do not.
- The HPA does not install a metrics adapter.
- A stabilization window picks the highest recent recommendation for scale-down.

<!-- astrona:playground:destroy -->
