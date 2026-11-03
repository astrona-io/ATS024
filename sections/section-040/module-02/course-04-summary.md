---
draft: true
exam_objectives:
- Understand the primitives used to create robust, self-healing, application deployments
---
# Summary

A workload controller turns a declaration into running Pods and keeps the two equal. The link between a controller and its Pods is a label selector plus an owner reference. The selector tells the controller which Pods to count, and the owner reference tells the garbage collector who owns a Pod. A Deployment owns ReplicaSets, and a ReplicaSet owns Pods. Deleting an owner removes its dependents unless you ask for orphaning, and a Pod without a controller owner is never replaced.

Each controller kind keeps a different promise. A Deployment keeps a number of interchangeable Pods. A DaemonSet keeps one Pod on every eligible node and relies on tolerations to reach tainted nodes. A StatefulSet keeps stable names, stable claims and a start order, and it needs a headless Service for the per-Pod DNS names. A Job keeps retrying until the required number of Pods has finished, and a CronJob creates Jobs on a schedule.

The fields of batch workloads decide how they fail and how they clean up. The restart policy and the retry limit decide whether a failed attempt can recover. The concurrency policy, the start deadline and the suspend flag decide whether a scheduled run happens. The time to live and the history limits decide how much finished work stays in the cluster. A good diagnosis names the controller, reads its fields and compares them with the behavior you see.

<!-- astrona:playground:destroy -->
