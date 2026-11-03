#!/usr/bin/env bash
# Reference solution. Run only by `astrona test`.
set -euo pipefail
kubectl apply -f - <<'YAML'
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
---
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
YAML
kubectl -n starfleet label deployment shuttle team=starfleet --overwrite
for i in $(seq 1 15); do
  if ! kubectl -n starfleet scale deployment scout --replicas=5 --dry-run=server >/dev/null 2>&1; then break; fi
  sleep 2
done
echo "[solution] Applied."
