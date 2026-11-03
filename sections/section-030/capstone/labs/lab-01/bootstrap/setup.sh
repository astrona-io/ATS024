#!/usr/bin/env bash
set -euo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-024-lab-030-cap" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi
lab_directory="$(cd "$(dirname "$0")/.." && pwd)"
kubectl apply -f "$lab_directory/bootstrap/manifests/start.yaml"
kubectl -n starfleet rollout status deployment/scout --timeout=180s
kubectl -n starfleet wait --for=condition=Ready pod/shuttle --timeout=120s
kubectl -n outpost wait --for=condition=Ready pod/drifter --timeout=120s
kubectl wait --for=condition=Available apiservice/v1beta1.metrics.k8s.io --timeout=180s
kubectl -n starfleet wait --for=condition=Ready pod/bridge --timeout=120s
kubectl -n starfleet create configmap lab-baseline \
  --from-literal=hpa-uid="$(kubectl -n starfleet get hpa scout -o jsonpath='{.metadata.uid}')" \
  --from-literal=pdb-uid="$(kubectl -n starfleet get pdb scout -o jsonpath='{.metadata.uid}')" \
  --from-literal=bridge-uid="$(kubectl -n starfleet get pod bridge -o jsonpath='{.metadata.uid}')" \
  --from-literal=deployment-uid="$(kubectl -n starfleet get deployment scout -o jsonpath='{.metadata.uid}')"
