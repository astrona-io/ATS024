#!/usr/bin/env bash
set -euo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-024-lab-010-01-02" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi
bootstrap_directory="$(cd "$(dirname "$0")" && pwd)"
kubectl apply -f "$bootstrap_directory/manifests/start.yaml"
kubectl -n starfleet rollout status deployment/probe --timeout=180s
kubectl -n starfleet wait --for=condition=Ready pod/shuttle --timeout=120s
kubectl -n starfleet set image deployment/probe probe=docker.io/library/python:ckad-missing-image
kubectl -n starfleet get deployment probe -o json | python3 -c 'import json,sys; d=json.load(sys.stdin); assert d["spec"]["template"]["spec"]["containers"][0]["image"].endswith(":ckad-missing-image")'
