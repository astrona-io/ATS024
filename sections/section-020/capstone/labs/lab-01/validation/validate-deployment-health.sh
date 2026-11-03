#!/usr/bin/env bash
# Check: original Deployment, 2 available replicas and POD_NAMESPACE from the downward API.
set -uo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-024-lab-020-cap" ]]; then
  echo "FAIL: wrong Kubernetes context"
  exit 1
fi
fail=0
current="$(kubectl -n outpost get deployment beacon -o jsonpath='{.metadata.uid}' 2>/dev/null || true)"
baseline="$(kubectl -n kube-system get configmap lab-baseline -o jsonpath='{.data.beacon-uid}' 2>/dev/null || true)"
if [ -z "$current" ] || [ -z "$baseline" ] || [ "$current" != "$baseline" ]; then
  echo "FAIL: Deployment beacon was deleted and created again"
  exit 1
fi
kubectl -n outpost rollout status deployment/beacon --timeout=90s >/dev/null 2>&1 || { echo "FAIL: beacon rollout is not complete"; exit 1; }
available="$(kubectl -n outpost get deployment beacon -o jsonpath='{.status.availableReplicas}')"
[ "$available" = "2" ] || { echo "FAIL: expected 2 available replicas, found '${available:-0}'"; fail=1; }
field="$(kubectl -n outpost get deployment beacon -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name=="POD_NAMESPACE")].valueFrom.fieldRef.fieldPath}')"
[ "$field" = "metadata.namespace" ] || { echo "FAIL: POD_NAMESPACE is not a fieldRef to metadata.namespace"; fail=1; }
pods="$(kubectl -n outpost get pods -l app=beacon -o go-template='{{range .items}}{{if and (not .metadata.deletionTimestamp) (eq .status.phase "Running")}}{{.metadata.name}} {{end}}{{end}}')"
for pod in $pods; do
  [ "$(kubectl -n outpost exec "$pod" -- printenv POD_NAMESPACE 2>/dev/null || true)" = "outpost" ] || { echo "FAIL: $pod has no POD_NAMESPACE with the value outpost"; fail=1; }
done
[ "$fail" -eq 0 ] && echo "PASS: original Deployment, healthy, with POD_NAMESPACE from the downward API"
exit "$fail"
