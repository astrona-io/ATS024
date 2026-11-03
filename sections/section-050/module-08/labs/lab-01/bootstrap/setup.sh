#!/usr/bin/env bash
# Starting state: two drifter pods request most of the free CPU of the worker node, and scout stays Pending.
set -euo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-024-lab-050-08-01" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi
worker="$(kubectl get nodes -l '!node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].metadata.name}')"
free="$(kubectl get nodes "$worker" -o jsonpath='{.status.allocatable.cpu}' >/tmp/ats024-alloc-$$ ; kubectl get pods -A --field-selector "spec.nodeName=$worker" -o json | python3 -c '
import json, sys
def milli(v):
    return int(v[:-1]) if v.endswith("m") else int(float(v) * 1000)
alloc = milli(open(sys.argv[1]).read().strip())
used = 0
for pod in json.load(sys.stdin)["items"]:
    if pod["status"].get("phase") in ("Succeeded", "Failed"):
        continue
    for c in pod["spec"]["containers"]:
        used += milli(c.get("resources", {}).get("requests", {}).get("cpu", "0"))
print(alloc - used)
' /tmp/ats024-alloc-$$)"
rm -f /tmp/ats024-alloc-$$
drifter_cpu="$(( free * 45 / 100 / 10 * 10 ))m"
scout_cpu="$(( free * 30 / 100 / 10 * 10 ))m"
kubectl apply -f - <<YAML
apiVersion: v1
kind: Namespace
metadata:
  name: starfleet
---
apiVersion: v1
kind: Namespace
metadata:
  name: outpost
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: seed
  namespace: outpost
data:
  drifter_cpu: "$drifter_cpu"
  scout_cpu: "$scout_cpu"
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
          resources:
            requests:
              cpu: $drifter_cpu
              memory: 32Mi
YAML
kubectl -n outpost rollout status deployment/drifter --timeout=180s
kubectl apply -f - <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: scout
  namespace: starfleet
spec:
  replicas: 1
  selector:
    matchLabels:
      app: scout
  template:
    metadata:
      labels:
        app: scout
    spec:
      containers:
        - name: scout
          image: docker.io/library/busybox:1.37.0
          command: ["sleep", "86400"]
          resources:
            requests:
              cpu: $scout_cpu
              memory: 64Mi
YAML
echo "[lab] Ready: scout is Pending because the worker node is full."
