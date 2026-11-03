#!/usr/bin/env bash
# Reference solution. Run only by `astrona test`.
set -euo pipefail
scout_cpu="$(kubectl -n outpost get configmap seed -o jsonpath='{.data.scout_cpu}')"
kubectl apply -f - <<'YAML'
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: critical-service
value: 100000
globalDefault: false
description: "Services that must keep running when the cluster is full."
YAML
kubectl -n starfleet patch deployment scout --type=strategic -p "{\"spec\":{\"template\":{\"spec\":{\"priorityClassName\":\"critical-service\",\"containers\":[{\"name\":\"scout\",\"resources\":{\"requests\":{\"cpu\":\"$scout_cpu\",\"memory\":\"64Mi\"},\"limits\":{\"cpu\":\"$scout_cpu\",\"memory\":\"64Mi\"}}}]}}}}"
kubectl -n starfleet rollout status deployment/scout --timeout=180s
