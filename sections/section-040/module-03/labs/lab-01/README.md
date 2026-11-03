---
estimated_duration: 25m
---

# Lab: Repair A Crash-Looping Deployment And A Restarting Task Pod

**Status: UNTESTED - never run against a live cluster.**

Graded lab for the Pod lifecycle module. The Deployment `bridge` crash-loops because nothing creates a required file, and the Pod `drifter-survey` restarts a task that already succeeded. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS024.git -c sections/section-040/module-03/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS024.git -c sections/section-040/module-03/labs/lab-01
astrona destroy ats-024-lab-040-03-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-bridge-has-init-container.sh` | `bridge` has an init container without `restartPolicy: Always` that mounts `work`, and its Pods show exit code 0 for it |
| `validate-bridge-available.sh` | `bridge` has at least 2 replicas, all ready, and no container waits in `CrashLoopBackOff` |
| `validate-bridge-main-container-kept.sh` | The main container keeps its name, image, the `/work/config.txt` test and the `emptyDir` volume |
| `validate-survey-restart-policy.sh` | `drifter-survey` has `OnFailure` or `Never` and keeps its task command |
| `validate-survey-completed.sh` | `drifter-survey` ends in phase `Succeeded` with no restart |

The first four fail on the starting state; `validate-survey-completed.sh` fails until the Pod is recreated.
