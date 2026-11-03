#!/usr/bin/env bash
# Check: registry-creds is a dockerconfigjson Secret and the ServiceAccount beacon passes it to new Pods.
set -uo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-024-lab-020-cap" ]]; then
  echo "FAIL: wrong Kubernetes context"
  exit 1
fi
fail=0
type="$(kubectl -n outpost get secret registry-creds -o jsonpath='{.type}' 2>/dev/null || true)"
[ "$type" = "kubernetes.io/dockerconfigjson" ] || { echo "FAIL: registry-creds has type '$type'"; exit 1; }
config="$(kubectl -n outpost get secret registry-creds -o jsonpath='{.data.\.dockerconfigjson}' | base64 -d)"
echo "$config" | grep -q '"registry.starfleet.example"' || { echo "FAIL: no entry for registry.starfleet.example"; fail=1; }
list="$(kubectl -n outpost get serviceaccount beacon -o jsonpath='{.imagePullSecrets[*].name}' 2>/dev/null || true)"
case " $list " in
  *" registry-creds "*) ;;
  *) echo "FAIL: ServiceAccount beacon does not list registry-creds"; fail=1 ;;
esac
injected="$(kubectl -n outpost run grader-check --image=docker.io/library/busybox:1.37.0 --overrides='{"spec":{"serviceAccountName":"beacon"}}' --dry-run=server -o jsonpath='{.spec.imagePullSecrets[*].name}' 2>/dev/null || true)"
[ "$injected" = "registry-creds" ] || { echo "FAIL: a new Pod running as beacon does not receive registry-creds"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: registry credentials are valid and attached to the ServiceAccount"
exit "$fail"
