#!/usr/bin/env bash
# Applies the reference solution. Run only by astrona test.
set -euo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-024-lab-020-03-01" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi
directory="$(cd "$(dirname "$0")" && pwd)"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

kubectl -n starfleet delete secret registry-creds
kubectl -n starfleet create secret docker-registry registry-creds \
  --docker-server=registry.starfleet.example \
  --docker-username=scout \
  --docker-password=disposable-pass \
  --docker-email=scout@starfleet.example
kubectl -n starfleet patch serviceaccount builder -p '{"imagePullSecrets":[{"name":"registry-creds"}]}'

openssl req -x509 -newkey rsa:2048 -nodes -keyout "$work/probe.key" -out "$work/probe.crt" -days 30 -subj "/CN=probe.starfleet.svc"
kubectl -n starfleet create secret tls probe-tls --cert="$work/probe.crt" --key="$work/probe.key"

kubectl apply -f "$directory/deployment-probe.yaml"
kubectl -n starfleet rollout status deployment/probe --timeout=180s
