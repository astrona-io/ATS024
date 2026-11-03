#!/usr/bin/env bash
# Starting state for the section capstone. It creates the faulty workloads and
# records the unique identifier of each object, so the grader can tell a repair
# from a delete and recreate.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"

for name in scout bridge; do
  until kubectl -n starfleet get deployment "$name" >/dev/null 2>&1; do sleep 1; done
done

kubectl -n starfleet create configmap capstone-uids \
  --from-literal=scout="$(kubectl -n starfleet get deployment scout -o jsonpath='{.metadata.uid}')" \
  --from-literal=bridge="$(kubectl -n starfleet get deployment bridge -o jsonpath='{.metadata.uid}')" \
  --from-literal=sweep="$(kubectl -n starfleet get cronjob sweep -o jsonpath='{.metadata.uid}')" \
  --from-literal=pdb="$(kubectl -n starfleet get pdb scout -o jsonpath='{.metadata.uid}')"
echo "[lab] Ready."
