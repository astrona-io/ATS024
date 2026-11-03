---
draft: true
exam_objectives:
- Understand application deployments and how to perform rolling update and rollbacks
---
# Revision History And Rollbacks

A release of `probe` passes its readiness check but returns wrong answers, and the team must return to the previous version quickly. Kubernetes keeps earlier Pod templates so that a Deployment can go back to them. This module explains where that history is stored, how to read it, and how to roll back to a chosen revision.

## Learning Goals

- Explain how a Deployment stores each revision as a ReplicaSet.
- Read the rollout history and the template of a single revision.
- Control how many revisions are kept and record why each one exists.
- Roll back to the previous or to a specific revision.
- Pause and resume a rollout to batch several changes.
- State what a rollback does not restore.

## Before You Start

You need basic `kubectl` use and the idea of a Pod template. The module playground contains a `probe` Deployment in the `starfleet` namespace that already has three revisions.

## Reading Order

1. Revision History And ReplicaSet Ownership
2. Rolling Back, Pausing And Resuming
3. Summary

<!-- astrona:playground -->
