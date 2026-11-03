#!/usr/bin/env bash
# Check: running Pods hold flags.conf, secrets/token with mode 0400 and pod/labels.
set -uo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-024-lab-020-04-01" ]]; then
  echo "FAIL: wrong Kubernetes context"
  exit 1
fi
fail=0
kubectl -n starfleet rollout status deployment/shuttle --timeout=90s >/dev/null 2>&1 || { echo "FAIL: shuttle rollout is not complete"; exit 1; }
pods="$(kubectl -n starfleet get pods -l app=shuttle -o go-template='{{range .items}}{{if and (not .metadata.deletionTimestamp) (eq .status.phase "Running")}}{{.metadata.name}} {{end}}{{end}}')"
if [ -z "$pods" ]; then
  echo "FAIL: no running shuttle pod"
  exit 1
fi
expected_flags="$(kubectl -n starfleet get configmap shuttle-config -o jsonpath='{.data.flags}')"
expected_token="$(kubectl -n starfleet get secret shuttle-token -o jsonpath='{.data.token}' | base64 -d)"
for pod in $pods; do
  flags="$(kubectl -n starfleet exec "$pod" -- cat /etc/shuttle/flags.conf 2>/dev/null || true)"
  [ "$flags" = "$expected_flags" ] || { echo "FAIL: $pod has no matching /etc/shuttle/flags.conf"; fail=1; }
  token="$(kubectl -n starfleet exec "$pod" -- cat /etc/shuttle/secrets/token 2>/dev/null || true)"
  [ "$token" = "$expected_token" ] || { echo "FAIL: $pod has no matching /etc/shuttle/secrets/token"; fail=1; }
  mode="$(kubectl -n starfleet exec "$pod" -- stat -L -c '%a' /etc/shuttle/secrets/token 2>/dev/null || true)"
  [ "$mode" = "400" ] || { echo "FAIL: $pod token has mode '$mode', expected 400"; fail=1; }
  labels="$(kubectl -n starfleet exec "$pod" -- cat /etc/shuttle/pod/labels 2>/dev/null || true)"
  echo "$labels" | grep -qx 'app="shuttle"' || { echo "FAIL: $pod has no /etc/shuttle/pod/labels with the Pod labels"; fail=1; }
done
[ "$fail" -eq 0 ] && echo "PASS: every running shuttle Pod has the three delivered files"
exit "$fail"
