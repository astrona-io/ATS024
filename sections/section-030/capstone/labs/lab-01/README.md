---
estimated_duration: 30m
---

# Lab: Capstone: Autoscale, Resize And Protect A Workload

The `scout` workload needs a working, bounded autoscaler that leaves room for a node drain, and the `bridge` Pod needs more CPU.

**Status: UNTESTED - never run against a live cluster.** Built with static checks only. The task is in `question.md`, the walk-through is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS024.git -c sections/section-030/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS024.git -c sections/section-030/capstone/labs/lab-01
astrona destroy ats-024-lab-030-cap
```

Authors run the local copy with `astrona run -c <lab>` and check the reference solution with `astrona test -c <lab>`.

## Checks

The grader is one script, `validate.sh`. It prints a `PASS` or `FAIL` line for each check.

| Check | What it proves |
| --- | --- |
| `scout requests CPU` and `ScalingActive` | The Deployment has a request and the controller calculates. |
| `scaleDown` window, policy and `minReplicas` | Window at least 300, one Pod per 120 seconds, minimum at least 3. |
| `PDB` fields and `disruptionsAllowed` | `minAvailable` is still 2 and at least one disruption is allowed. |
| `bridge` applied CPU 400m, same Pod, no restart, `Guaranteed` | Resized in place with request and limit together. |
| Kept objects | HPA, budget and Deployment identifiers match the starting state. |
