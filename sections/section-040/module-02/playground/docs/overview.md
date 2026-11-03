# Overview: Workload Controllers For Self-Healing (Playground)

This is a playground, not a lab. It starts a Kubernetes cluster with one control-plane node and one worker node, and with one workload of each controller kind. There is no task and nothing to submit. Break things, destroy the playground and start again.

## What is running

| Namespace | Object | Kind | What to look at |
| --- | --- | --- | --- |
| `starfleet` | `scout` | Deployment, three replicas | The ReplicaSet it creates and the `ownerReferences` on each pod |
| `starfleet` | `shuttle` | DaemonSet | One pod on each node, including the control-plane node |
| `starfleet` | `probe` | StatefulSet, three replicas | Pods `probe-0` to `probe-2`, claims `data-probe-0` to `data-probe-2`, the headless Service `probe` |
| `starfleet` | `bridge-report` | Job | Three completions, two at a time, two retries |
| `starfleet` | `drifter-sweep` | CronJob | Runs every two minutes and forbids overlapping runs |

`kubectl` already points at this cluster as the cluster administrator.

## Things to try

- Delete one `scout` pod and watch the ReplicaSet create another. Then delete the ReplicaSet with `--cascade=orphan` and check which pods survive and who owns them.
- Delete the pod `probe-1` and confirm that a pod with the same name and the same claim returns.
- Taint the worker node with `kubectl taint nodes <worker> team=test:NoSchedule` and check that the `shuttle` pod on it keeps running, then change the taint effect to `NoExecute` and watch what happens.
- Create a Job from the CronJob with `kubectl -n starfleet create job manual-sweep --from=cronjob/drifter-sweep`.
- Suspend the CronJob with a patch and confirm that no new Job starts.
- Write a Job whose first attempt fails and compare `restartPolicy: Never` with `restartPolicy: OnFailure`.
