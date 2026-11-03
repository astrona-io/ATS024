---
draft: true
exam_objectives:
- Configure Pod admission and scheduling (limits, node affinity, etc.)
---
# Admission Controllers And ValidatingAdmissionPolicy

A request that is authenticated and authorized can still be refused. The refusal comes from admission, the last check before the API server stores an object. This module explains the admission chain, the built-in admission plugins, how webhooks extend them, and how a ValidatingAdmissionPolicy lets an administrator write a rule in the Common Expression Language (CEL) without running any server.

## Learning goals

- Describe the order of the admission chain: mutating plugins, object validation, validating plugins.
- Name the built-in admission plugins that matter for pods and say what each does.
- Explain how dynamic admission webhooks work and what `failurePolicy` controls.
- Write a ValidatingAdmissionPolicy and a ValidatingAdmissionPolicyBinding that deny a request.
- State the status of MutatingAdmissionPolicy in Kubernetes 1.35.
- Read a rejection message and name the policy, binding and rule behind it.

## Before you start

You need to know how a request reaches the API server and what a Deployment is. The playground is a Kubernetes 1.35 `kind` cluster with a worker node. It has the namespaces `starfleet` and `outpost` with the workloads `scout`, `probe`, `shuttle` and `drifter`. It has no policy objects yet.

## Reading order

The first part follows a request through the admission chain and shows which plugins run and how to read their rejections. The second part writes a ValidatingAdmissionPolicy with a binding and tests it. The summary closes the module.

<!-- astrona:playground -->
