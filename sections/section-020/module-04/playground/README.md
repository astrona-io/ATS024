# Projected Volumes, The Downward API And Configuration Patterns - Playground

- **Slug:** ats-024-playground-020-04
- **Type:** Astrona playground, ungraded, no submit
- **Status:** UNTESTED - never run against a live cluster.

A single-node kind cluster (Kubernetes 1.35) with the namespaces `starfleet` and `outpost` and one Deployment in each.

```sh
astrona run -c .
astrona destroy ats-024-playground-020-04
```

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition |
| `manifests/starfleet.yaml` | Namespaces and Deployments |
| `docs/overview.md` | What is running and what to try |
