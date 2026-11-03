# Voluntary And Involuntary Disruption - Playground

- **Slug:** ats-024-playground-040-04
- **Type:** Astrona playground - clean environment, no task, no grading
- **Status:** UNTESTED - never run against a live cluster.

A kind cluster (Kubernetes 1.35) with one control-plane node and one worker
node. `starfleet` runs the `scout` Deployment (3 replicas, PodDisruptionBudget
`scout-pdb` with `minAvailable: 2`), the `probe` Deployment (2 replicas with a
topology spread constraint and PodDisruptionBudget `probe-pdb`) and a bare Pod
named `shuttle`. `outpost` runs the `drifter` Deployment.

## Run it

```sh
astrona run -c .
astrona destroy ats-024-playground-040-04
```

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition |
| `manifests/starfleet.yaml` | Namespaces, workloads and PodDisruptionBudgets |
| `docs/overview.md` | What is running and what to try |
