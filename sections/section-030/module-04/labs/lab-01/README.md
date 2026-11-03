---
estimated_duration: 20m
---

# Lab: Make The Budget And The Autoscaler Agree

A node drain would hang on the `scout` workload. Change the autoscaler so that one Pod can be evicted.

**Status: UNTESTED - never run against a live cluster.** Built with static checks only. The task is in `question.md`, the walk-through is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS024.git -c sections/section-030/module-04/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS024.git -c sections/section-030/module-04/labs/lab-01
astrona destroy ats-024-lab-030-04-01
```

Authors run the local copy with `astrona run -c <lab>` and check the reference solution with `astrona test -c <lab>`.

## Checks

The grader is one script, `validate.sh`. It prints a `PASS` or `FAIL` line for each check.

| Check | What it proves |
| --- | --- |
| `PDB scout was kept` and `still requires two` | The budget is the original object with `minAvailable` 2. |
| `HPA minimum is 3 or more` | The minimum is at least 3 and the maximum is not lower. |
| `scout has 3 ready replicas` | The Deployment reached the new minimum. |
| `PDB allows 1 disruption` | The status field `disruptionsAllowed` is at least 1. |
| `HPA scout was kept` and `Deployment scout was kept` | Object identifiers match the starting state. |
