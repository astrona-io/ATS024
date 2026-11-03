# Overview: Voluntary And Involuntary Disruption (Playground)

This is a playground, not a lab. It starts a cluster and waits. There is no task, no `astrona submit` and no pass or fail. Change things, break them, run `astrona destroy` and start again.

## What is running

- A kind cluster running Kubernetes 1.35 with one control-plane node and one worker node. `kubectl` points at it as the cluster administrator. The control-plane node carries a `NoSchedule` taint, so application Pods run on the worker node.
- In `starfleet`:

  | Object | What it is |
  | --- | --- |
  | Deployment `scout` | 3 replicas |
  | PodDisruptionBudget `scout-pdb` | `minAvailable: 2` for the `scout` Pods |
  | Deployment `probe` | 2 replicas with a topology spread constraint on `kubernetes.io/hostname` |
  | PodDisruptionBudget `probe-pdb` | `maxUnavailable: 1` and `unhealthyPodEvictionPolicy: AlwaysAllow` |
  | Pod `shuttle` | A bare Pod with no controller |

- In `outpost`: Deployment `drifter` with 1 replica.

## Things to try

- Run `kubectl -n starfleet get pdb` and read `ALLOWED DISRUPTIONS`. Scale `scout` to 2 and read it again, then back to 3.
- Cordon the worker node, delete one `scout` Pod and see where the replacement stays. Then uncordon the node.
- Drain the worker node with `kubectl drain` and the flag `--ignore-daemonsets`. Read why it refuses, then add the flags it asks for. Predict which Pod needs which flag before you run it.
- Change `scout-pdb` to `minAvailable: 3` and try to evict one `scout` Pod with `kubectl drain` and a short `--timeout`. Read the retry messages.
- Read the tolerations that the API server added to a `scout` Pod, and write a Deployment that uses `tolerationSeconds: 30` for the `node.kubernetes.io/not-ready` taint.
