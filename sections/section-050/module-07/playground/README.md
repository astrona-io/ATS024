# Resource Quotas And Limit Ranges Playground

- **Slug:** ats-024-playground-050-07
- **Type:** Astrona playground, ungraded. No task and no `astrona submit`.

A Kubernetes 1.35 kind cluster with one control plane node and one worker node. It runs `scout` (2 replicas), `probe` and `shuttle` in `starfleet` and `drifter` in `outpost`. Static checks only so far: **Status: UNTESTED, never run against a live cluster.**

## Run it

```sh
astrona run -c .
astrona destroy ats-024-playground-050-07
```

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition |
| `manifests/starfleet.yaml` | Namespaces and example workloads |
| `docs/overview.md` | What runs and what to try |
