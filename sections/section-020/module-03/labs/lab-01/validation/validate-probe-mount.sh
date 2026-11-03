#!/usr/bin/env bash
# Check: Deployment probe mounts probe-tls read-only at /tls with mode 0400 and is the original object.
set -uo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-024-lab-020-03-01" ]]; then
  echo "FAIL: wrong Kubernetes context"
  exit 1
fi
fail=0
kubectl -n starfleet rollout status deployment/probe --timeout=90s >/dev/null 2>&1 || { echo "FAIL: probe rollout is not complete"; exit 1; }
mode="$(kubectl -n starfleet get deployment probe -o jsonpath='{.spec.template.spec.volumes[?(@.secret.secretName=="probe-tls")].secret.defaultMode}')"
[ "$mode" = "256" ] || { echo "FAIL: the probe-tls volume does not have defaultMode 0400"; fail=1; }
readonly_mount="$(kubectl -n starfleet get deployment probe -o jsonpath='{.spec.template.spec.containers[0].volumeMounts[?(@.mountPath=="/tls")].readOnly}')"
[ "$readonly_mount" = "true" ] || { echo "FAIL: /tls is not a read-only mount"; fail=1; }
pod="$(kubectl -n starfleet get pods -l app=probe -o go-template='{{range .items}}{{if and (not .metadata.deletionTimestamp) (eq .status.phase "Running")}}{{.metadata.name}} {{end}}{{end}}' | cut -d' ' -f1)"
if [ -z "$pod" ]; then
  echo "FAIL: no running probe pod"
  exit 1
fi
files="$(kubectl -n starfleet exec "$pod" -- ls /tls 2>/dev/null || true)"
echo "$files" | grep -qx 'tls.crt' && echo "$files" | grep -qx 'tls.key' || { echo "FAIL: /tls does not hold tls.crt and tls.key"; fail=1; }
perm="$(kubectl -n starfleet exec "$pod" -- stat -L -c '%a' /tls/tls.key 2>/dev/null || true)"
[ "$perm" = "400" ] || { echo "FAIL: tls.key has mode '$perm', expected 400"; fail=1; }
current="$(kubectl -n starfleet get deployment probe -o jsonpath='{.metadata.uid}')"
baseline="$(kubectl -n kube-system get configmap lab-baseline -o jsonpath='{.data.probe-uid}' 2>/dev/null || true)"
if [ -z "$baseline" ] || [ "$current" != "$baseline" ]; then
  echo "FAIL: Deployment probe was deleted and created again"
  fail=1
fi
[ "$fail" -eq 0 ] && echo "PASS: probe mounts probe-tls read-only with mode 0400"
exit "$fail"
