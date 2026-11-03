---
estimated_duration: 30m
---

# Capstone: Self-Healing Deployments

Graded integration lab for the whole section. The `starfleet` namespace starts with a `scout` Deployment whose readiness probe points at the wrong port, a PodDisruptionBudget that blocks every eviction, a `bridge` Deployment that crash-loops for a missing file, and a `sweep` CronJob that allows overlap. The task is in `question.md`; the walkthrough is in `solution.md`.

**Status: UNTESTED - never run against a live cluster.**

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS024.git -c sections/section-040/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS024.git -c sections/section-040/capstone/labs/lab-01
astrona destroy ats-024-lab-040-cap
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-scout-ready.sh` | `scout` was not recreated, has 3 replicas in its spec, keeps a readiness probe and has 3 available replicas |
| `validate-scout-pdb-allows-one-eviction.sh` | The budget keeps its identity, allows at least 1 disruption, keeps at least 2 pods healthy and selects 3 pods |
| `validate-scout-topology-spread.sh` | The pod template has a hostname spread with maxSkew 1 and ScheduleAnyway |
| `validate-bridge-init-container.sh` | `bridge` has an init container, still checks `config.ready` in its own container and has 1 ready replica |
| `validate-sweep-concurrency-and-history.sh` | `sweep` forbids overlap, keeps one successful and one failed Job, and is not suspended |
| `validate-sweep-job-ttl.sh` | The Job template removes finished Jobs after 120 seconds and the schedule is unchanged |

The PodDisruptionBudget check passes only after `scout` is ready, because the budget counts healthy pods.
