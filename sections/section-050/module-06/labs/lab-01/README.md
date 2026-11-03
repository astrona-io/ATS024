---
estimated_duration: 20m
---

# Lab: Enforce Defaults And Quotas In A Namespace

**Status: UNTESTED - never run against a live cluster.**

The `drifter` Deployment cannot create pods because the namespace quota needs requests and limits. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run -c .
astrona submit -c .
astrona destroy ats-024-lab-050-06-01
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-drifter-running.sh` | Two pods are available, have the default requests, and the Deployment template has no resources |
| `validate-limitrange.sh` | A Container LimitRange has the required defaults and maximum |
| `validate-max-enforced.sh` | A server-side dry run rejects cpu limit 1 and accepts a valid pod |
| `validate-quota.sh` | The quota keeps its values and caps Deployments at 3 |
