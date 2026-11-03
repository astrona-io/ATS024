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
[ "$(jq -r '.status.availableReplicas // 0' <<<"$deployment")" = "4" ] && [ "$(jq -r '.status.updatedReplicas // 0' <<<"$deployment")" = "4" ] && r=ok || r=bad
check "$r" "four updated replicas are available"
pods="$(kubectl -n starfleet get pods -l app=scout -o json)"
counts="$(jq -r '[.items[] | select(.metadata.deletionTimestamp==null and .status.phase=="Running") | .spec.nodeName] | group_by(.) | map(length) | sort | join(",")' <<<"$pods")"
[ "$counts" = "2,2" ] && r=ok || r=bad
check "$r" "Running Pods are spread two and two over the workers (found: ${counts:-none})"
control="$(jq -r '[.items[] | select(.metadata.deletionTimestamp==null) | .spec.nodeName] | map(select(test("control-plane"))) | length' <<<"$pods")"
[ "$control" = "0" ] && r=ok || r=bad
check "$r" "no scout Pod runs on the control plane node"
problems="$(jq -r '
  .items[] | select(.metadata.deletionTimestamp==null) | . as $pod
  | ($pod.spec.securityContext // {}) as $psc
  | $pod.spec.containers[] | (.securityContext // {}) as $csc
  | [
      (if ($csc.allowPrivilegeEscalation == false) then empty else "allowPrivilegeEscalation is not false" end),
      (if (($csc.capabilities.drop // []) | index("ALL")) then empty else "capabilities do not drop ALL" end),
      (if (($csc.runAsNonRoot // $psc.runAsNonRoot) == true) then empty else "runAsNonRoot is not true" end),
      (if ((($csc.seccompProfile.type // $psc.seccompProfile.type) // "") | IN("RuntimeDefault","Localhost")) then empty else "seccompProfile is not RuntimeDefault" end)
    ] | select(length > 0) | $pod.metadata.name + ": " + join(", ")' <<<"$pods")"
if [ -z "$problems" ]; then r=ok; else r=bad; echo "$problems" | sed 's/^/  /'; fi
check "$r" "every scout Pod meets the restricted settings"
exit "$fail"
