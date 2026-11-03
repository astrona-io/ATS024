---
estimated_duration: 20m
---

# Lab: Resize A Running Pod And Scale A Deployment

The `bridge` Pod needs more CPU now, and `scout` needs one more replica. Make both changes without a restart or a new Pod.

**Status: UNTESTED - never run against a live cluster.** Built with static checks only. The task is in `question.md`, the walk-through is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS024.git -c sections/section-030/module-03/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS024.git -c sections/section-030/module-03/labs/lab-01
astrona destroy ats-024-lab-030-03-01
```

Authors run the local copy with `astrona run -c <lab>` and check the reference solution with `astrona test -c <lab>`.

## Checks

The grader is one script, `validate.sh`. It prints a `PASS` or `FAIL` line for each check.

| Check | What it proves |
| --- | --- |
| `bridge spec requests/limits cpu` | Both values are 300m in the Pod spec. |
| `bridge applied cpu request` and `limit` | The kubelet reports 300m in the container status. |
| `no resize is pending` | The `PodResizePending` condition is absent. |
| `bridge is the original Pod` and `not restarted` | The Pod identifier and a restart count of 0 match the starting state. |
| `Guaranteed` QoS and memory unchanged | Request and limit changed together, and memory stayed 64Mi. |
| `scout` replicas and identifier | Desired and ready replicas are 3, and the Deployment is the original object. |
