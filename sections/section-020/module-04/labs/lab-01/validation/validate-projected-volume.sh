#!/usr/bin/env bash
# Check: one projected volume with configMap, secret and downwardAPI sources, mounted read-only at /etc/shuttle.
set -uo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-024-lab-020-04-01" ]]; then
  echo "FAIL: wrong Kubernetes context"
  exit 1
fi
fail=0
count="$(kubectl -n starfleet get deployment shuttle -o jsonpath='{range .spec.template.spec.volumes[*]}{.name}{"\n"}{end}' 2>/dev/null | grep -c .)"
[ "$count" = "1" ] || { echo "FAIL: expected exactly one volume, found $count"; exit 1; }
cm="$(kubectl -n starfleet get deployment shuttle -o jsonpath='{.spec.template.spec.volumes[0].projected.sources[*].configMap.name}')"
sec="$(kubectl -n starfleet get deployment shuttle -o jsonpath='{.spec.template.spec.volumes[0].projected.sources[*].secret.name}')"
dapi="$(kubectl -n starfleet get deployment shuttle -o jsonpath='{.spec.template.spec.volumes[0].projected.sources[*].downwardAPI.items[*].path}')"
[ "$cm" = "shuttle-config" ] || { echo "FAIL: projected volume has no configMap source shuttle-config"; fail=1; }
[ "$sec" = "shuttle-token" ] || { echo "FAIL: projected volume has no secret source shuttle-token"; fail=1; }
[ -n "$dapi" ] || { echo "FAIL: projected volume has no downwardAPI source"; fail=1; }
vol="$(kubectl -n starfleet get deployment shuttle -o jsonpath='{.spec.template.spec.volumes[0].name}')"
mount_ro="$(kubectl -n starfleet get deployment shuttle -o jsonpath="{.spec.template.spec.containers[0].volumeMounts[?(@.name==\"$vol\")].readOnly}")"
mount_path="$(kubectl -n starfleet get deployment shuttle -o jsonpath="{.spec.template.spec.containers[0].volumeMounts[?(@.name==\"$vol\")].mountPath}")"
[ "$mount_path" = "/etc/shuttle" ] || { echo "FAIL: the projected volume is not mounted at /etc/shuttle"; fail=1; }
[ "$mount_ro" = "true" ] || { echo "FAIL: the mount is not read-only"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: one projected volume with three sources at /etc/shuttle"
exit "$fail"
