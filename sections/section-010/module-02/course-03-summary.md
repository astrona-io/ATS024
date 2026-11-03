---
draft: true
exam_objectives:
- Understand application deployments and how to perform rolling update and rollbacks
---
# Summary

A Deployment stores each revision as a ReplicaSet that it owns. The ReplicaSet name carries a hash of the Pod template, and the annotation `deployment.kubernetes.io/revision` holds the revision number. Only the current ReplicaSet has Pods. The others have zero replicas and are kept as rollback targets.

The history lists revisions with the text of the `kubernetes.io/change-cause` annotation, and a single revision can be read to see its template. The field `revisionHistoryLimit` bounds how many old ReplicaSets remain, and a value of 0 removes every rollback target.

A rollback writes an earlier template back into the Deployment, and the Deployment controller then performs an ordinary rolling update. The target ReplicaSet receives the next revision number, so revision numbers only grow. A rollback does not restore the replica count, the strategy, mounted configuration, Secrets or data.

Pausing a Deployment stops new rollouts so several edits can be released as one revision. A paused Deployment cannot be rolled back until it is resumed.

<!-- astrona:playground:destroy -->
