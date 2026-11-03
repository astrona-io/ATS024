#!/usr/bin/env bash
set -uo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-024-lab-050-03-01" ]]; then
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

replicas="$(jq -r '.spec.replicas' <<<"$deployment")"
available="$(jq -r '.status.availableReplicas // 0' <<<"$deployment")"
updated="$(jq -r '.status.updatedReplicas // 0' <<<"$deployment")"
[ "$replicas" = "2" ] && [ "$available" = "2" ] && [ "$updated" = "2" ] && r=ok || r=bad
check "$r" "scout keeps 2 replicas, all updated and available"

jq -e '[.spec.template.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[]?.matchExpressions[]?
  | select(.key=="disk" and .operator=="In" and (.values | index("ssd")) and (.values | index("nvme")))] | length >= 1' <<<"$deployment" >/dev/null && r=ok || r=bad
check "$r" "required affinity allows disk In [ssd, nvme]"

jq -e '[.spec.template.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[]?.matchExpressions[]?
  | select(.key=="tier" and .operator=="NotIn" and (.values | index("spot")))] | length >= 1' <<<"$deployment" >/dev/null && r=ok || r=bad
check "$r" "required affinity excludes tier NotIn [spot]"

jq -e '[.spec.template.spec.affinity.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution[]?
  | select(.weight >= 1 and ([.preference.matchExpressions[]? | select(.key=="gpu-count" and .operator=="Gt")] | length >= 1))] | length >= 1' <<<"$deployment" >/dev/null && r=ok || r=bad
check "$r" "a preferred rule uses gpu-count with the Gt operator"

[ "$(jq -r '.spec.template.spec.nodeSelector // {} | length' <<<"$deployment")" = "0" ] && r=ok || r=bad
check "$r" "no nodeSelector shortcut"
[ "$(jq -r '.spec.template.spec.nodeName // ""' <<<"$deployment")" = "" ] && r=ok || r=bad
check "$r" "no nodeName shortcut"

labels="$(kubectl get nodes -l '!node-role.kubernetes.io/control-plane' -o json | jq -r '.items[0].metadata.labels')"
[ "$(jq -r '.disk' <<<"$labels")" = "ssd" ] && [ "$(jq -r '.tier' <<<"$labels")" = "compute" ] && [ "$(jq -r 'has("accelerator") or (.disk=="nvme")' <<<"$labels")" = "false" ] && r=ok || r=bad
check "$r" "the worker labels were not changed to hide the fault"

running="$(kubectl -n starfleet get pods -l app=scout -o json | jq '[.items[] | select(.metadata.deletionTimestamp==null and .status.phase=="Running" and .spec.nodeName != null)] | length')"
[ "$running" = "2" ] && r=ok || r=bad
check "$r" "two scout Pods are Running on a node"

exit "$fail"
