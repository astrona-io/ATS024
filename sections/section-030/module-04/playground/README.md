# Plan Event-Driven And Node-Level Autoscaling Playground

Ungraded kind environment (`ats-024-playground-030-04`) with the metrics server, the `scout` Deployment, an HPA and a PodDisruptionBudget. Manifests are in `manifests/starfleet.yaml`. **Status: UNTESTED - never run against a live cluster.** Static checks only (`astrona validate -c config.yaml`).

```sh
astrona run -c .
astrona destroy ats-024-playground-030-04
```
