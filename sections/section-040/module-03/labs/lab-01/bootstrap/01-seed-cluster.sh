#!/usr/bin/env bash
# Starting state for the pod lifecycle lab. Environment only: it creates the
# two faulty workloads and does not fix them.
set -euo pipefail

if [[ "$(kubectl config current-context)" != "kind-astro-ats-024-lab-040-03-01" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
kubectl apply -f "$DIR/manifests/lab-start.yaml"
kubectl -n starfleet wait --for=create pod -l app=bridge --timeout=60s
echo "[lab] Ready."
