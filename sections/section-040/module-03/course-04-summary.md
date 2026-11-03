---
draft: true
exam_objectives:
- Understand the primitives used to create robust, self-healing, application deployments
---
# Summary

The kubelet restarts containers inside a Pod according to the Pod restart policy. `Always` restarts after every exit, `OnFailure` only after a failure, and `Never` not at all. Controllers limit the choice: services use `Always` and tasks use `OnFailure` or `Never`. The delay between restarts doubles up to five minutes, and the reason `CrashLoopBackOff` describes that wait. It does not name the cause, which is found in the exit code and the log of the previous run.

A Pod reports its health on three levels. The phase is a short summary of the lifecycle, the conditions are true or false facts that decide traffic eligibility, and the container state says whether each container is waiting, running or terminated. A startup probe holds back the liveness and readiness probes until a slow application has started, which prevents a restart loop that the probes themselves would cause.

Init containers run one after another to completion before the main containers. A failed init container blocks the Pod and is retried or failed according to the restart policy. A native sidecar is an init container with its own restart policy of `Always`. It starts before the application, restarts by itself and stops after the application.

A stop follows a fixed order: the `preStop` hook, the signal SIGTERM, a wait, and SIGKILL when the grace period ends. All of it shares the period set by `terminationGracePeriodSeconds`. A process that handles SIGTERM stops quickly. A process that ignores it takes the full period. A short `preStop` hook gives the Service endpoints time to drop the Pod before the application closes its listener.

<!-- astrona:playground:destroy -->
