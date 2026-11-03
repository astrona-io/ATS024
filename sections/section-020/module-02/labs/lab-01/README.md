---
estimated_duration: 25m
---

# Lab: Inject Configuration Through Environment Variables

**Status: UNTESTED - never run against a live cluster.**

Graded lab for the environment variable module. The Deployment `scout` has literal settings in its Pod template. The task is in `question.md` and the walkthrough is in `solution.md`.

## Run it

```sh
astrona run -c .
astrona submit -c .
astrona destroy ats-024-lab-020-02-01
```

Authors prove the reference solution with `astrona test -c .` once a live run is allowed.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-prefixed-import.sh` | `envFrom` imports `scout-settings` with prefix `SCOUT_`, and running Pods have the variables |
| `validate-renamed-key.sh` | `APP_MODE` is a `configMapKeyRef` to the key `mode`, and Pods have `standby` |
| `validate-secret-reference.sh` | `DB_PASSWORD` is a `secretKeyRef` and equals the Secret value |
| `validate-no-literals.sh` | No `env` entry has a literal value, the Deployment is the original object and has 2 available replicas |

All checks fail on the starting state.
