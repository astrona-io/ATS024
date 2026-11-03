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
jq -e '[.spec.template.spec.tolerations[]? | select(.key=="dedicated" and .effect=="NoSchedule" and ((.operator=="Equal" and .value=="scout") or .operator=="Exists"))] | length >= 1' <<<"$deployment" >/dev/null && r=ok || r=bad
check "$r" "scout tolerates dedicated=scout:NoSchedule"
jq -e '[.spec.template.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[]?.matchExpressions[]? | select(.key=="pool" and .operator=="In" and (.values | index("dedicated")))] | length >= 1' <<<"$deployment" >/dev/null && r=ok || r=bad
check "$r" "scout requires pool In [dedicated] with node affinity"
[ "$(jq -r '.spec.template.spec.nodeName // ""' <<<"$deployment")" = "" ] && r=ok || r=bad
check "$r" "scout does not pin a node with nodeName"
[ "$(jq -r '.spec.replicas' <<<"$deployment")" = "4" ] && r=ok || r=bad
check "$r" "scout keeps 4 replicas"
exit "$fail"
