# Solution

UNTESTED: not yet run against a live environment.

Solve this lab on `terminal`. Each step ends with `astrona submit`.

Start the lab and point `kubectl` at it:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-024-lab-050-07-01)"
```

## Step 1: Bind the existing policy

A policy does nothing without a binding. Check that none exists:

```sh
kubectl get validatingadmissionpolicy,validatingadmissionpolicybinding
```

Save this as `binding-replica-limit.yaml`:

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

Apply it and run `astrona submit`. The check `replica-limit-denies-in-starfleet` passes.

```sh
kubectl apply -f binding-replica-limit.yaml
```

## Step 2: Require the team label

Save this as `policy-require-team-label.yaml`:

```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingAdmissionPolicy
metadata:
  name: require-team-label
spec:
  failurePolicy: Fail
  matchConstraints:
    resourceRules:
      - apiGroups: ["apps"]
        apiVersions: ["v1"]
        operations: ["CREATE", "UPDATE"]
        resources: ["deployments"]
  validations:
    - expression: "has(object.metadata.labels) && 'team' in object.metadata.labels"
      message: "Deployments must have a team label"
---
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingAdmissionPolicyBinding
metadata:
  name: require-team-label-starfleet
spec:
  policyName: require-team-label
  validationActions: ["Deny"]
  matchResources:
    namespaceSelector:
      matchLabels:
        kubernetes.io/metadata.name: starfleet
```

Apply it:

```sh
kubectl apply -f policy-require-team-label.yaml
```

Try to create a Deployment without the label with `kubectl create deployment test --image=docker.io/library/busybox:1.37.0 -n starfleet --dry-run=server`. The rejection names `require-team-label`. Wait a few seconds if it is accepted at first.

## Step 3: Fix shuttle

The policy matches updates, so any change to `shuttle` without the label is rejected. Add the label:

```sh
kubectl -n starfleet label deployment shuttle team=starfleet
```

Run `astrona submit`. All four checks pass.
