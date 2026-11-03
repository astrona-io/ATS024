#!/usr/bin/env bash
# Check: registry-creds is a dockerconfigjson Secret with the login for registry.starfleet.example.
set -uo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-024-lab-020-03-01" ]]; then
  echo "FAIL: wrong Kubernetes context"
  exit 1
fi
fail=0
type="$(kubectl -n starfleet get secret registry-creds -o jsonpath='{.type}' 2>/dev/null || true)"
if [ "$type" != "kubernetes.io/dockerconfigjson" ]; then
  echo "FAIL: registry-creds has type '$type', expected kubernetes.io/dockerconfigjson"
  exit 1
fi
config="$(kubectl -n starfleet get secret registry-creds -o jsonpath='{.data.\.dockerconfigjson}' | base64 -d)"
echo "$config" | grep -q '"registry.starfleet.example"' || { echo "FAIL: no entry for registry.starfleet.example"; fail=1; }
echo "$config" | grep -Eq '"username" *: *"scout"' || { echo "FAIL: user name is not scout"; fail=1; }
echo "$config" | grep -Eq '"password" *: *"disposable-pass"' || { echo "FAIL: password is not the required value"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: registry-creds is a valid registry Secret"
exit "$fail"
