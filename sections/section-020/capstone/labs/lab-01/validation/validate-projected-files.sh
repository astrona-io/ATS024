#!/usr/bin/env bash
# Check: one projected volume at /etc/beacon with banner.txt, secrets/db-password (0400) and pod/labels.
set -uo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-024-lab-020-cap" ]]; then
  echo "FAIL: wrong Kubernetes context"
  exit 1
fi
fail=0
kubectl -n outpost rollout status deployment/beacon --timeout=90s >/dev/null 2>&1 || { echo "FAIL: beacon rollout is not complete"; exit 1; }
pods="$(kubectl -n outpost get pods -l app=beacon -o go-template='{{range .items}}{{if and (not .metadata.deletionTimestamp) (eq .status.phase "Running")}}{{.metadata.name}} {{end}}{{end}}')"
if [ -z "$pods" ]; then
  echo "FAIL: no running beacon pod"
  exit 1
fi
count="$(kubectl -n outpost get deployment beacon -o jsonpath='{range .spec.template.spec.volumes[*]}{.name}{"\n"}{end}' | grep -c .)"
[ "$count" = "1" ] || { echo "FAIL: expected exactly one volume, found $count"; exit 1; }
src="$(kubectl -n outpost get deployment beacon -o jsonpath='{.spec.template.spec.volumes[0].projected.sources[*]}' 2>/dev/null || true)"
[ -n "$src" ] || { echo "FAIL: the volume is not a projected volume"; exit 1; }
vol="$(kubectl -n outpost get deployment beacon -o jsonpath='{.spec.template.spec.volumes[0].name}')"
path="$(kubectl -n outpost get deployment beacon -o jsonpath="{.spec.template.spec.containers[0].volumeMounts[?(@.name==\"$vol\")].mountPath}")"
ro="$(kubectl -n outpost get deployment beacon -o jsonpath="{.spec.template.spec.containers[0].volumeMounts[?(@.name==\"$vol\")].readOnly}")"
[ "$path" = "/etc/beacon" ] || { echo "FAIL: the projected volume is not mounted at /etc/beacon"; fail=1; }
[ "$ro" = "true" ] || { echo "FAIL: the mount is not read-only"; fail=1; }
banner="$(kubectl -n outpost get configmap beacon-settings -o jsonpath='{.data.banner}')"
password="$(kubectl -n outpost get secret beacon-db -o jsonpath='{.data.password}' | base64 -d)"
for pod in $pods; do
  [ "$(kubectl -n outpost exec "$pod" -- cat /etc/beacon/banner.txt 2>/dev/null || true)" = "$banner" ] || { echo "FAIL: $pod has no matching /etc/beacon/banner.txt"; fail=1; }
  [ "$(kubectl -n outpost exec "$pod" -- cat /etc/beacon/secrets/db-password 2>/dev/null || true)" = "$password" ] || { echo "FAIL: $pod has no matching /etc/beacon/secrets/db-password"; fail=1; }
  [ "$(kubectl -n outpost exec "$pod" -- stat -L -c '%a' /etc/beacon/secrets/db-password 2>/dev/null || true)" = "400" ] || { echo "FAIL: $pod password file does not have mode 400"; fail=1; }
  kubectl -n outpost exec "$pod" -- cat /etc/beacon/pod/labels 2>/dev/null | grep -qx 'app="beacon"' || { echo "FAIL: $pod has no /etc/beacon/pod/labels with the Pod labels"; fail=1; }
done
[ "$fail" -eq 0 ] && echo "PASS: the projected volume delivers the three files"
exit "$fail"
