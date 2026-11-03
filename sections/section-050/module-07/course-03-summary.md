---
draft: true
exam_objectives:
- Configure Pod admission and scheduling (limits, node affinity, etc.)
---
# Summary

Admission is the last check an API server makes on a create, update or delete request. It runs after authentication and authorization and before the object is stored in etcd. Mutating plugins run first and may change the object. The API server then validates the object against its schema. Validating plugins run last and may only accept or reject.

Built-in admission plugins do much of the daily work. `LimitRanger` and `ResourceQuota` enforce resource rules, `Priority` turns a priority class name into a number, `PodSecurity` enforces the Pod Security Standards, `ServiceAccount` adds a service account to pods and `NodeRestriction` limits what a kubelet may change. The plugins that are enabled are set with API server flags.

Dynamic admission webhooks let a cluster call an external HTTPS service for matching requests. Their `failurePolicy` decides what happens when the service is unreachable: `Fail` rejects the request, and `Ignore` lets it through. A webhook that fails closed and runs on the cluster it guards can block its own recovery.

A ValidatingAdmissionPolicy is a rule written in CEL and evaluated inside the API server. It has a policy object that says which requests it matches and which expressions must be true, and a binding object that says where the policy applies and what happens on failure: `Deny`, `Warn` or `Audit`. A policy without a binding does nothing. In Kubernetes 1.35 the MutatingAdmissionPolicy is beta and off by default, and it becomes stable in 1.36.

A rejection message names the plugin or the policy and binding, and for a policy it repeats the message or the failed expression. Reading that text first shows which rule to change.

<!-- astrona:playground:destroy -->
