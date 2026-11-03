---
estimated_duration: 25m
---

# Lab: Release Pending Pods

Graded lab for Pending Pods. Three separate causes keep Pods from starting. The task is in `question.md` and the walkthrough in `solution.md`.

**Status: UNTESTED - never run against a live cluster.** Static checks only: `bash -n`, YAML parsing and `astrona validate`.

## Run it

```sh
astrona run -c .
astrona submit -c .
astrona destroy ats-024-lab-050-05-01
```

Authors can run `testing/smoke.sh` against the private cluster: it proves that the starting state fails grading and that the reference solution in `solution/` passes.
