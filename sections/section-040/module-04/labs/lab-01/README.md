---
estimated_duration: 25m
---

# Lab: Repair Pod Disruption Budgets And Node-Loss Tolerance

Graded lab for the disruption module. The cluster starts with a budget that allows no disruption, a budget that selects no Pod, and a Deployment without node-loss tolerations or a spread constraint. The task is in `question.md`; the walkthrough is in `solution.md`.

**Status: UNTESTED - never run against a live cluster.**

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS024.git -c sections/section-040/module-04/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS024.git -c sections/section-040/module-04/labs/lab-01
astrona destroy ats-024-lab-040-04-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-scout-pdb-allows-one-disruption.sh` | `scout-pdb` selects 3 Pods, requires 2 healthy and allows 1 disruption |
| `validate-probe-pdb-selects-probe-pods.sh` | `probe-pdb` selects the 2 `probe` Pods and allows 1 disruption |
| `validate-scout-tolerates-node-loss-for-30-seconds.sh` | Both `NoExecute` tolerations have `tolerationSeconds: 30` |
| `validate-scout-spreads-across-nodes.sh` | A `ScheduleAnyway` constraint on `kubernetes.io/hostname` with `maxSkew: 1` exists |
| `validate-workloads-kept-and-available.sh` | Seeded objects were not recreated; 3 `scout` and 2 `probe` Pods are ready |

The last check passes before any change. No script drains a node.
