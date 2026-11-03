---
estimated_duration: 30m
---

# Lab: Merge Configuration Into One Projected Volume

**Status: UNTESTED - never run against a live cluster.**

Graded lab for the projected volume module. The Deployment `shuttle` has no volume and two wrong literal variables. The task is in `question.md` and the walkthrough is in `solution.md`.

## Run it

```sh
astrona run -c .
astrona submit -c .
astrona destroy ats-024-lab-020-04-01
```

Authors prove the reference solution with `astrona test -c .` once a live run is allowed.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-projected-volume.sh` | One volume, projected, with ConfigMap, Secret and downward API sources, mounted read-only at `/etc/shuttle` |
| `validate-delivered-files.sh` | Running Pods have `flags.conf`, `secrets/token` with mode 400 and `pod/labels` |
| `validate-downward-variables.sh` | `POD_NAME` and `CPU_MILLI` are downward API references and show the right values |
| `validate-same-deployment.sh` | Same Deployment uid, 2 available replicas, no literal env value |

All checks fail on the starting state.
