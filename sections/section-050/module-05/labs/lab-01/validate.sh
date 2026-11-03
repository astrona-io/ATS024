#!/usr/bin/env bash
set -uo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-024-lab-050-05-01" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi
fail=0
check() { if [ "$1" = "ok" ]; then echo "PASS: $2"; else echo "FAIL: $2"; fail=1; fi; }

worker_json="$(kubectl get nodes -l '!node-role.kubernetes.io/control-plane' -o json | jq '.items[0]')"
[ "$(jq -r '.spec.unschedulable // false' <<<"$worker_json")" = "false" ] && r=ok || r=bad
check "$r" "the worker is not cordoned"

jq -e '[.spec.taints[]? | select(.key=="node.kubernetes.io/unschedulable")] | length == 0' <<<"$worker_json" >/dev/null && r=ok || r=bad
check "$r" "the worker has no unschedulable taint"

deployment="$(kubectl -n starfleet get deployment probe -o json 2>/dev/null)"
if [ -z "$deployment" ]; then
  echo "FAIL: the probe Deployment is missing"
  exit 1
fi
scheduler="$(jq -r '.spec.template.spec.schedulerName // "default-scheduler"' <<<"$deployment")"
[ "$scheduler" = "default-scheduler" ] && r=ok || r=bad
check "$r" "probe uses the default scheduler (found: $scheduler)"

[ "$(jq -r '.spec.replicas' <<<"$deployment")" = "2" ] && [ "$(jq -r '.status.availableReplicas // 0' <<<"$deployment")" = "2" ] && [ "$(jq -r '.status.updatedReplicas // 0' <<<"$deployment")" = "2" ] && r=ok || r=bad
check "$r" "probe has 2 replicas, all updated and available"

[ "$(jq -r '.spec.template.spec.nodeName // ""' <<<"$deployment")" = "" ] && r=ok || r=bad
check "$r" "the probe template does not pin a node"

shuttle="$(kubectl -n starfleet get pod shuttle -o json 2>/dev/null)"
if [ -z "$shuttle" ]; then
  echo "FAIL: the shuttle Pod is missing"
  exit 1
fi
[ "$(jq -r '.spec.schedulingGates // [] | length' <<<"$shuttle")" = "0" ] && r=ok || r=bad
check "$r" "the shuttle scheduling gate is released"

[ "$(jq -r '.status.phase' <<<"$shuttle")" = "Running" ] && r=ok || r=bad
check "$r" "the shuttle Pod is Running"

seed_uid="$(kubectl -n starfleet get configmap lab-seed -o jsonpath='{.data.shuttle-uid}' 2>/dev/null)"
[ -n "$seed_uid" ] && [ "$(jq -r '.metadata.uid' <<<"$shuttle")" = "$seed_uid" ] && r=ok || r=bad
check "$r" "the original shuttle Pod was kept, not recreated"

exit "$fail"
