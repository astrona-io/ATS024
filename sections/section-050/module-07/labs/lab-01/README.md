---
estimated_duration: 25m
---

# Lab: Enforce Rules With ValidatingAdmissionPolicy

**Status: UNTESTED - never run against a live cluster.**

A policy without a binding does nothing, and a second rule must be written. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run -c .
astrona submit -c .
astrona destroy ats-024-lab-050-07-01
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-replica-limit.sh` | Server dry runs: 5 replicas rejected in `starfleet` by `replica-limit`, accepted in `outpost` |
| `validate-team-label.sh` | A Deployment without a team label is rejected in `starfleet` by `require-team-label` |
| `validate-shuttle.sh` | `shuttle` exists, has the label and can be updated |
| `validate-policy-unchanged.sh` | The seeded policy keeps its expression and has a `Deny` binding |
