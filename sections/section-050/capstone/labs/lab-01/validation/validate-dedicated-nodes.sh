#!/usr/bin/env bash
set -uo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-024-lab-050-cap" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi
fail=0
check() { if [ "$1" = "ok" ]; then echo "PASS: $2"; else echo "FAIL: $2"; fail=1; fi; }
workers="$(kubectl get nodes -l '!node-role.kubernetes.io/control-plane' -o json)"
[ "$(jq '.items | length' <<<"$workers")" = "2" ] && r=ok || r=bad
check "$r" "two worker nodes exist"
[ "$(jq '[.items[] | select(.metadata.labels.pool=="dedicated")] | length' <<<"$workers")" = "2" ] && r=ok || r=bad
check "$r" "both workers keep the label pool=dedicated"
[ "$(jq '[.items[] | select([.spec.taints[]? | select(.key=="dedicated" and .value=="scout" and .effect=="NoSchedule")] | length == 1)] | length' <<<"$workers")" = "2" ] && r=ok || r=bad
check "$r" "both workers keep the taint dedicated=scout:NoSchedule"
[ "$(jq '[.items[] | select(.spec.unschedulable==true)] | length' <<<"$workers")" = "0" ] && r=ok || r=bad
check "$r" "no worker is cordoned"
[ "$(jq '[.items[] | select(.metadata.labels["topology.kubernetes.io/zone"]=="zone-a" or .metadata.labels["topology.kubernetes.io/zone"]=="zone-b")] | length' <<<"$workers")" = "2" ] && r=ok || r=bad
check "$r" "both workers keep their zone label"
exit "$fail"
