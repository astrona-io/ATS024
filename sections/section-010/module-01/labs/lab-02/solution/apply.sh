#!/usr/bin/env bash
set -euo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-024-lab-010-01-02" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi
solution_directory="$(cd "$(dirname "$0")" && pwd)"
kubectl -n starfleet set image deployment/probe probe=docker.io/library/python:3.13-alpine
kubectl -n starfleet rollout status deployment/probe --timeout=180s
