---
draft: true
exam_objectives:
- Understand application deployments and how to perform rolling update and rollbacks
---
# Starting Environment

The application and client fixtures are healthy. Complete the required change without replacing unrelated resources.

Update `probe` to version `v2` through its `VERSION` environment value. Keep two replicas, a RollingUpdate strategy with `maxSurge: 1` and `maxUnavailable: 0`, and the readiness probe. The current generation must have two updated, ready and available replicas. The client must receive version two.
