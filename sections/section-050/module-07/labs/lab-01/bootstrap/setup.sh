#!/usr/bin/env bash
# Starting state: workloads, one shuttle Deployment without a team label, and a policy without a binding.
set -euo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-024-lab-050-07-01" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi
dep() { # namespace name replicas labels-yaml
cat <<YAML
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $2
  namespace: $1
spec:
  replicas: $3
  selector:
    matchLabels:
      app: $2
  template:
    metadata:
      labels:
        app: $2
    spec:
      containers:
        - name: $2
          image: docker.io/library/busybox:1.37.0
          command: ["sleep", "86400"]
YAML
}
{
  printf 'apiVersion: v1\nkind: Namespace\nmetadata:\n  name: starfleet\n---\napiVersion: v1\nkind: Namespace\nmetadata:\n  name: outpost\n'
  dep starfleet scout 2; dep starfleet probe 1; dep starfleet shuttle 1; dep outpost drifter 1
} | kubectl apply -f -
kubectl -n starfleet label deployment scout probe team=starfleet
kubectl -n outpost label deployment drifter team=outpost
kubectl apply -f - <<'YAML'
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
YAML
echo "[lab] Ready."
