#!/usr/bin/env bash
# Reference solution. Run only by `astrona test`.
set -euo pipefail
kubectl apply -f - <<'YAML'
apiVersion: v1
kind: LimitRange
metadata:
  name: container-defaults
  namespace: outpost
spec:
  limits:
    - type: Container
      defaultRequest:
        cpu: 100m
        memory: 64Mi
      default:
        cpu: 200m
        memory: 128Mi
      max:
        cpu: 500m
        memory: 256Mi
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
    count/deployments.apps: "3"
YAML
kubectl -n outpost rollout restart deployment/drifter
kubectl -n outpost rollout status deployment/drifter --timeout=120s
