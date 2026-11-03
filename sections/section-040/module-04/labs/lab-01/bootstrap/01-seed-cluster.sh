#!/usr/bin/env bash
# Starting state for the disruption lab. Environment only: it creates the
# workloads and the faulty disruption settings. It does not fix anything.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
for name in scout probe; do
  kubectl -n starfleet rollout status "deployment/$name" --timeout=180s
done
echo "[lab] Ready."
