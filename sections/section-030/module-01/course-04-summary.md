---
draft: true
exam_objectives:
- Configure workload autoscaling
---
# Summary

A HorizontalPodAutoscaler (HPA) is a control loop in `kube-controller-manager`. About every 15 seconds it reads Pod measurements from the metrics API, which the metrics server serves from kubelet data, calculates a desired replica count and writes it to the target's scale subresource. The calculation multiplies the current replicas by the ratio of the current value to the target and rounds up. A tolerance of 10 percent suppresses tiny changes, and `minReplicas` and `maxReplicas` cap the result.

CPU utilization is usage divided by the request. A container without a CPU request gives the HPA no denominator, so `ScalingActive` becomes `False`. A metric helps only when it rises with the real bottleneck, and a saturated dependency can leave the CPU low while users wait.

The HPA changes replica counts and nothing else. New Pods still need free node resources, image pulls and readiness, and a node autoscaler or a person must supply nodes. A PodDisruptionBudget limits voluntary disruption and must agree with the HPA minimum. The HPA owns the replica count of its target, so manifests for autoscaled workloads leave `replicas` out.

- `kubectl describe hpa` shows `AbleToScale`, `ScalingActive` and `ScalingLimited` with reasons.
- `kubectl autoscale` creates a CPU target only; behavior and extra metrics need an `autoscaling/v2` manifest.
- Scale-down waits for a 300 second stabilization window by default.

<!-- astrona:playground:destroy -->
