# Scale Workloads Manually And Vertically Playground

Ungraded kind environment (`ats-024-playground-030-03`) with the `scout` Deployment and the resizable Pod `bridge`. Manifests are in `manifests/starfleet.yaml`. **Status: UNTESTED - never run against a live cluster.** Static checks only (`astrona validate -c config.yaml`).

```sh
astrona run -c .
astrona destroy ats-024-playground-030-03
```
