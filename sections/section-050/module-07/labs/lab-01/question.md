# Question

Solve this question on: `terminal`

UNTESTED: not yet run against a live environment.

The platform team wrote the ValidatingAdmissionPolicy `replica-limit` (Deployments may run at most 3 replicas), but a Deployment with five replicas is still accepted in `starfleet`. Do not edit or delete `replica-limit`. Do not delete any Deployment.

1. Make `replica-limit` reject Deployments with more than 3 replicas in the `starfleet` namespace. Use the action `Deny`. The rule must not apply in `outpost`.
2. Write a new ValidatingAdmissionPolicy named `require-team-label` that rejects a Deployment without the label `team` in its own metadata, on create and on update. Enforce it with `Deny` in `starfleet` only.
3. The Deployment `shuttle` in `starfleet` has no `team` label and was created before the rule. It must keep working: make it comply with the rule. Do not remove the rule.

`kubectl` already points at the cluster as the cluster administrator. A new policy needs a few seconds to become active.
