#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

kubectl -n starfleet patch deployment bridge --type=strategic --patch-file "$DIR/bridge-init-patch.yaml"
kubectl -n starfleet rollout status deployment/bridge --timeout=120s

kubectl -n outpost delete pod drifter-survey --wait=true
kubectl apply -f "$DIR/drifter-survey.yaml"
kubectl -n outpost wait --for=jsonpath='{.status.phase}'=Succeeded pod/drifter-survey --timeout=60s
echo "[solution] Applied."
