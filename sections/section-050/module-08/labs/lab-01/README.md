---
estimated_duration: 25m
---

# Lab: Protect A Critical Workload With Priority And QoS

**Status: UNTESTED - never run against a live cluster.**

The start script sizes two `drifter` pods to use 90 percent of the free CPU of the worker node and leaves `scout` Pending. The task is in `question.md`; the walkthrough is in `solution.md`. The start script needs `python3` on the machine that runs it.

## Run it

```sh
astrona run -c .
astrona submit -c .
astrona destroy ats-024-lab-050-08-01
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-priorityclass.sh` | `critical-service` has value 100000 and is not the global default |
| `validate-scout-priority.sh` | The template names the class and a running `scout` pod has priority 100000 |
| `validate-scout-qos.sh` | The running `scout` pod is `Guaranteed` and keeps its original CPU request |
| `validate-no-shortcut.sh` | `drifter` keeps 2 replicas, its CPU request and no priority class |
