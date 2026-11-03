#!/usr/bin/env bash
# Starting state: a quota that needs requests and limits, and a Deployment that sets none.
set -euo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-024-lab-050-06-01" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi
kubectl apply -f - <<'YAML'
apiVersion: v1
kind: Namespace
metadata:
  name: outpost
---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute
  namespace: outpost
spec:
  hard:
    requests.cpu: "1"
    requests.memory: 1Gi
    limits.cpu: "2"
    limits.memory: 2Gi
    pods: "6"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: drifter
  namespace: outpost
spec:
  replicas: 2
  selector:
    matchLabels:
      app: drifter
  template:
    metadata:
      labels:
        app: drifter
    spec:
      containers:
        - name: drifter
          image: docker.io/library/busybox:1.37.0
          command: ["sleep", "86400"]
YAML
echo "[lab] Ready: the drifter Deployment cannot create pods."
