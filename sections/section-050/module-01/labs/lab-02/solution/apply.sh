#!/usr/bin/env bash
set -euo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-024-lab-050-01-02" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi
lab_directory="$(cd "$(dirname "$0")/.." && pwd)"
solution_directory="$lab_directory/solution"
node_name="astro-ats-024-lab-050-01-02-control-plane"
worker_name="astro-ats-024-lab-050-01-02-worker"

kubectl apply -f "$solution_directory/pod-taint-reader.yaml"
kubectl -n starfleet wait --for=condition=Ready pod/taint-reader --timeout=180s
