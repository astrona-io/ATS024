#!/usr/bin/env bash
set -uo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-024-lab-050-cap" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi
fail=0
check() { if [ "$1" = "ok" ]; then echo "PASS: $2"; else echo "FAIL: $2"; fail=1; fi; }
deployment="$(kubectl -n starfleet get deployment scout -o json 2>/dev/null)"
if [ -z "$deployment" ]; then
  echo "FAIL: the scout Deployment is missing"
  exit 1
fi
jq -e '[.spec.template.spec.containers[] | select(.resources.requests.cpu != null and .resources.requests.memory != null)] | length == (.spec.template.spec.containers | length)' <<<"$deployment" >/dev/null && r=ok || r=bad
check "$r" "every container has a CPU and a memory request"
cpu="$(jq -r '[.spec.template.spec.containers[].resources.requests.cpu // "0"] | .[0]' <<<"$deployment")"
case "$cpu" in
  *m) millicores="${cpu%m}" ;;
  *) millicores="$(awk -v v="$cpu" 'BEGIN { printf "%d", v * 1000 }')" ;;
esac
[ "$millicores" -ge 1 ] && [ "$millicores" -le 250 ] && r=ok || r=bad
check "$r" "the CPU request is between 1m and 250m (found: $cpu)"
jq -e '[.spec.template.spec.topologySpreadConstraints[]? | select(.topologyKey=="topology.kubernetes.io/zone" and .maxSkew==1 and .whenUnsatisfiable=="DoNotSchedule")] | length >= 1' <<<"$deployment" >/dev/null && r=ok || r=bad
check "$r" "a spread constraint uses the zone key, maxSkew 1 and DoNotSchedule"
exit "$fail"
