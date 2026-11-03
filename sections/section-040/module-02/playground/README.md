# Workload Controllers For Self-Healing - Playground

- **Slug:** ats-024-playground-040-02
- **Type:** Astrona playground - clean environment, no task, no grading

A kind cluster (Kubernetes 1.35, one control-plane node and one worker) with
the Deployment `scout`, the DaemonSet `shuttle`, the StatefulSet `probe` with
its headless Service, the Job `bridge-report` and the CronJob `drifter-sweep`,
all in `starfleet`. Nothing to submit.

## Run it

```sh
astrona run -c .
astrona destroy ats-024-playground-040-02
```

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition |
| `manifests/starfleet.yaml` | Namespaces and the `scout` Deployment |
| `manifests/controllers.yaml` | DaemonSet `shuttle`, headless Service and StatefulSet `probe` |
| `manifests/batch.yaml` | Job `bridge-report` and CronJob `drifter-sweep` |
| `docs/overview.md` | What runs and what to try |

**Status: UNTESTED - never run against a live cluster.**
