---
estimated_duration: 25m
---

# Lab: Repair A Failed Job And A CronJob

Graded lab for the workload controller module. The cluster starts with a Job that failed on its first attempt and has no retry, and with a suspended CronJob that may overlap and keeps too many finished Jobs. The task is in `question.md`; the walkthrough is in `solution.md`.

**Status: UNTESTED - never run against a live cluster.**

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS024.git -c sections/section-040/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS024.git -c sections/section-040/module-02/labs/lab-01
astrona destroy ats-024-lab-040-02-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-scan-report-complete.sh` | The Job `scan-report` has the condition Complete |
| `validate-scan-report-retries.sh` | `restartPolicy` is `OnFailure` and `backoffLimit` is at least 1 |
| `validate-scan-report-cleanup.sh` | `ttlSecondsAfterFinished` is between 900 and 86400 |
| `validate-scan-report-task-kept.sh` | The image is busybox 1.37.0 and the command still uses `/data/attempt` |
| `validate-fleet-report-no-overlap.sh` | `concurrencyPolicy` is `Forbid` |
| `validate-fleet-report-schedulable.sh` | `suspend` is not true and `startingDeadlineSeconds` is 30 to 300 |
| `validate-fleet-report-history-and-identity.sh` | Both history limits are 3 or less and the CronJob uid matches the one recorded at the start |

Six checks fail on the starting state; `validate-scan-report-task-kept.sh` passes and guards against a shortcut. The Job is deleted and created again by design, so no check uses the Job uid.
