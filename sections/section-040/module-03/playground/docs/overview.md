# Overview: Pod Lifecycle And Restart Behavior (Playground)

This is a playground, not a lab. It starts a fresh cluster with four example Pods and then waits. There is no task, no `astrona submit` and no pass or fail. Break things, run `astrona destroy`, start over. `kubectl` already points at the cluster.

## What is running

| Namespace | Pod | What it shows |
| --- | --- | --- |
| `starfleet` | `shuttle` | `restartPolicy: Always`, exits with code 1 after about 3 seconds, so it ends in `CrashLoopBackOff` |
| `outpost` | `drifter` | The same command with `restartPolicy: Never`: it fails once and stays in the `Error` state |
| `starfleet` | `scout` | Two init containers (`write-config`, `check-config`) run in order before the main container |
| `starfleet` | `probe` | A native sidecar (`log-shipper`, an init container with `restartPolicy: Always`) and a main container that writes to the same volume |
| `starfleet` | `bridge` | `postStart` and `preStop` hooks, a SIGTERM handler and `terminationGracePeriodSeconds: 45` |

## Things to try

- Watch `shuttle` with `kubectl -n starfleet get pod shuttle -w` and note the time between restarts. Read the last exit code with `kubectl -n starfleet get pod shuttle -o jsonpath='{.status.containerStatuses[0].lastState.terminated.exitCode}'`.
- Compare `kubectl -n outpost get pod drifter` with `shuttle`. Which phase does each Pod have?
- Print the conditions of `scout` and `probe` and compare the `Initialized` and `Ready` values.
- Run `kubectl -n starfleet logs probe -c log-shipper`. Then delete `probe` and watch which container stops first.
- Delete `bridge` with `--wait=false` and read its logs while it is `Terminating`. How long does the whole stop take?
- Write a Pod whose init container fails and compare the status under `restartPolicy: Always` and `restartPolicy: Never`.
- Add a `startupProbe` to a slow Pod and see that the liveness probe stays quiet until it succeeds.
