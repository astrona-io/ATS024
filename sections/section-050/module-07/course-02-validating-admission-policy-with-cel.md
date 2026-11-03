---
draft: true
exam_objectives:
- Configure Pod admission and scheduling (limits, node affinity, etc.)
---
# ValidatingAdmissionPolicy With CEL

A platform team wants one rule: no Deployment in `starfleet` may run more than three replicas. Running a webhook service for one line of logic is a lot of work. A ValidatingAdmissionPolicy lets the API server evaluate the rule itself. It is stable since Kubernetes 1.30 and is on by default, so it works on the 1.35 playground without any setting.

## Two objects, one rule

A **ValidatingAdmissionPolicy** says what is checked. It has `matchConstraints`, which list the resources and operations it applies to, and `validations`, a list of expressions in the Common Expression Language (CEL). CEL is a small expression language. In an expression, `object` is the new object, `oldObject` is the stored one (empty on create), and `request` holds data about the request such as the user.

A **ValidatingAdmissionPolicyBinding** says where the policy applies and what happens when an expression is false. It names the policy in `policyName`, selects namespaces or objects with `matchResources`, and lists `validationActions`:

- `Deny`: reject the request.
- `Warn`: accept the request and return a warning to the client.
- `Audit`: accept the request and record the failure in the audit log.

A policy without a binding does nothing. This is the most common mistake: the policy exists, `kubectl get` shows it, and requests still pass.

## Write a policy

Save this as `policy-replica-limit.yaml`:

```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingAdmissionPolicy
metadata:
  name: replica-limit
spec:
  failurePolicy: Fail
  matchConstraints:
    resourceRules:
      - apiGroups: ["apps"]
        apiVersions: ["v1"]
        operations: ["CREATE", "UPDATE"]
        resources: ["deployments"]
  validations:
    - expression: "object.spec.replicas <= 3"
      message: "Deployments may run at most 3 replicas"
```

<!-- astrona:playground:renew -->

Apply it:

```sh
kubectl apply -f policy-replica-limit.yaml
```

The API server checks the expression against the Deployment type when it saves the policy. A misspelled field makes the policy report a type-checking warning in its `status`. `failurePolicy: Fail` means that when the expression cannot be evaluated, the request is handled as a failure, which then follows the binding's actions. With `Ignore`, an evaluation error lets the request through.

Test the policy before it has a binding. The playground `scout` Deployment can be scaled to five replicas, because nothing is bound yet:

```sh
kubectl -n starfleet scale deployment scout --replicas=5
kubectl -n starfleet scale deployment scout --replicas=2
```

Both commands succeed. The second one puts the Deployment back.

## Bind the policy

Save this as `binding-replica-limit.yaml`. The namespace selector uses the label `kubernetes.io/metadata.name`, which Kubernetes puts on every namespace:

```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingAdmissionPolicyBinding
metadata:
  name: replica-limit-starfleet
spec:
  policyName: replica-limit
  validationActions: ["Deny"]
  matchResources:
    namespaceSelector:
      matchLabels:
        kubernetes.io/metadata.name: starfleet
```

Apply it:

```sh
kubectl apply -f binding-replica-limit.yaml
```

The policy becomes active after the API server has read the new objects. If the next command is accepted, wait a few seconds and run it again:

```sh
kubectl -n starfleet scale deployment scout --replicas=5
```

The request is rejected. The message has the form `ValidatingAdmissionPolicy 'replica-limit' with binding 'replica-limit-starfleet' denied request:` followed by the text from `message`. When a validation has no `message`, the failed expression is shown instead. The same scale in `outpost` is not rejected, because the binding selects only `starfleet`.

## Choose the actions with care

Use `Warn` and `Audit` together to introduce a new rule. Clients such as `kubectl` print the warning, and the audit log records the failure, but nothing breaks. After teams fix their objects, change the binding to `Deny`. Do not combine `Deny` with `Warn`, because the same failure is then reported twice.

A policy matches `CREATE` and `UPDATE`, so it also blocks harmless updates to old objects that already break the rule, for example a label change on a Deployment with four replicas. The expression sees the new object only. A rule that should apply only to new objects needs a check on `oldObject` or a narrower `operations` list.

## Parameters and mutating policies

A policy can read parameters from another object through `paramKind` in the policy and `paramRef` in the binding, so that one policy serves several limits, for example a ConfigMap per namespace. In expressions the values are in `params`.

A **MutatingAdmissionPolicy** is the matching object for rules that change a request. In Kubernetes 1.35 it is beta, and it is off by default: it needs the `MutatingAdmissionPolicy` feature gate and the `admissionregistration.k8s.io/v1beta1` API enabled on the API server. It becomes stable and enabled by default in Kubernetes 1.36. Until then, mutation in a 1.35 cluster is done with the built-in plugins or with a mutating webhook.

You now know how to write a rule, bind it to a namespace and read its rejection. The playground policy affects only Deployments in `starfleet`. The open question is how to prove that a rule is active, which the rejection message does for you.

## Common pitfalls

> [!WARNING]
> - **Creating a policy and no binding.** Nothing is enforced until a binding names the policy and has at least one validation action.
> - **Testing too early.** The policy needs a few seconds to become active. A request accepted right after the apply does not prove the rule is wrong.
> - **Forgetting `UPDATE`.** A rule that matches only `CREATE` is bypassed by editing an object that already exists.
> - **Binding to every namespace by accident.** A binding with no `namespaceSelector` applies cluster-wide, including `kube-system`.
