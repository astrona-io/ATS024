---
estimated_duration: 25m
---

# Lab: Repair And Tune A Broken Autoscaler

The `scout` Deployment has an HPA that never works. Repair it and then slow its scale-down.

**Status: UNTESTED - never run against a live cluster.** Built with static checks only. The task is in `question.md`, the walk-through is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS024.git -c sections/section-030/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS024.git -c sections/section-030/module-02/labs/lab-01
astrona destroy ats-024-lab-030-02-01
```

Authors run the local copy with `astrona run -c <lab>` and check the reference solution with `astrona test -c <lab>`.

## Checks

The grader is one script, `validate.sh`. It prints a `PASS` or `FAIL` line for each check.

| Check | What it proves |
| --- | --- |
| `scout container requests CPU` | The Deployment fix. A repair in the HPA cannot pass it. |
| `HPA scout reports ScalingActive` | The controller reads measurements again. |
| `HPA scout reports a current utilization` | A real value in the status, not only the condition. |
| `scaleDown` and `scaleUp` fields | Window 600, Pods policy 1 per 120 seconds for scale-down, Pods policy 2 per 60 seconds for scale-up. |
| `HPA maxReplicas` and `minReplicas` | Maximum 6, minimum 2. |
| `HPA was edited, not recreated` and `Deployment scout was kept` | Object identifiers match the starting state. |
