# Tune HPA Metrics And Scaling Behavior Playground

Ungraded kind environment (`ats-024-playground-030-02`) with the metrics server, the `probe` Deployment (with requests) and the `scout` Deployment (without requests). Manifests are in `manifests/starfleet.yaml`. **Status: UNTESTED - never run against a live cluster.** Static checks only (`astrona validate -c config.yaml`).

```sh
astrona run -c .
astrona destroy ats-024-playground-030-02
```
