---
estimated_duration: 35m
---

# Lab: Place A Restricted Workload On A Dedicated Pool

Combine taints, required node affinity, resource requests, a topology spread constraint and Pod Security admission to place four Pods on a dedicated pool.

**Status: UNTESTED - never run against a live cluster.** Static checks only: `bash -n`, YAML parsing and `astrona validate`.

## Run it

```sh
astrona run -c .
astrona submit -c .
astrona destroy ats-024-lab-050-cap
```

Authors can run `testing/smoke.sh` against the private cluster: it proves that the starting state fails grading and that the reference solution in `solution/` passes.
