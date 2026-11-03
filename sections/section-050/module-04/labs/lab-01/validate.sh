#!/usr/bin/env bash
set -uo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-024-lab-050-04-01" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi
fail=0
check() { if [ "$1" = "ok" ]; then echo "PASS: $2"; else echo "FAIL: $2"; fail=1; fi; }

deployment="$(kubectl -n starfleet get deployment probe -o json 2>/dev/null)"
if [ -z "$deployment" ]; then
  echo "FAIL: the probe Deployment is missing"
  exit 1
fi

[ "$(jq -r '.spec.replicas' <<<"$deployment")" = "3" ] && [ "$(jq -r '.status.availableReplicas // 0' <<<"$deployment")" = "3" ] && [ "$(jq -r '.status.updatedReplicas // 0' <<<"$deployment")" = "3" ] && r=ok || r=bad
check "$r" "probe keeps 3 replicas, all updated and available"

[ "$(jq -r '.spec.template.spec.affinity.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution // [] | length' <<<"$deployment")" = "0" ] && r=ok || r=bad
check "$r" "the required Pod anti-affinity rule is gone"

jq -e '[.spec.template.spec.topologySpreadConstraints[]?
  | select(.topologyKey=="topology.kubernetes.io/zone" and .maxSkew==1 and .whenUnsatisfiable=="DoNotSchedule")] | length >= 1' <<<"$deployment" >/dev/null && r=ok || r=bad
check "$r" "a topology spread constraint uses the zone key, maxSkew 1 and DoNotSchedule"

jq -e '[.spec.template.spec.topologySpreadConstraints[]?
  | select(.matchLabelKeys // [] | index("pod-template-hash"))] | length >= 1' <<<"$deployment" >/dev/null && r=ok || r=bad
check "$r" "the constraint lists pod-template-hash in matchLabelKeys"

pods="$(kubectl -n starfleet get pods -l app=probe -o json)"
jq -r '.items[] | select(.metadata.deletionTimestamp==null and .status.phase=="Running") | .spec.nodeName' <<<"$pods" | sort -u | wc -l | grep -qx 2 && r=ok || r=bad
check "$r" "the running Pods use both worker nodes"

counts="$(jq -r '[.items[] | select(.metadata.deletionTimestamp==null and .status.phase=="Running") | .spec.nodeName] | group_by(.) | map(length) | sort | join(",")' <<<"$pods")"
[ "$counts" = "1,2" ] && r=ok || r=bad
check "$r" "three Pods run as a 2 and 1 split (found: ${counts:-none})"

exit "$fail"
