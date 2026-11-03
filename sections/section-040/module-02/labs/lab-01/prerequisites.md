# Prerequisites

- The `astrona` command-line tool, installed and working (`astrona check` passes).
- A container engine that kind can use (Podman or Docker) with about 2 GiB of free memory.
- `kubectl`.
- You know the Job fields `completions`, `backoffLimit`, `restartPolicy` and `ttlSecondsAfterFinished`, and the CronJob fields `concurrencyPolicy`, `suspend`, `startingDeadlineSeconds` and the history limits.

The lab starts a single-node kind cluster (Kubernetes 1.35) with a failed Job and a faulty CronJob in the `starfleet` namespace. The commands to run the lab are in the README of this folder.
