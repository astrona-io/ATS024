#!/usr/bin/env bash
set -uo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-024-lab-030-04-01" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi
failures=0
pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1"; failures=$((failures + 1)); }
field() { kubectl -n starfleet get "$@" 2>/dev/null; }
baseline() { field configmap lab-baseline -o jsonpath="{.data.$1}"; }
check_equal() { # description actual expected
  if [[ "$2" == "$3" ]]; then pass "$1"; else fail "$1 (found '$2', expected '$3')"; fi
}
wait_for_value() { # command expected attempts
  local value=""
  for attempt in $(seq 1 "$3"); do
    value="$(eval "$1")"
    [[ "$value" == "$2" ]] && break
    if [[ "$value" =~ ^[0-9]+$ && "$2" =~ ^[0-9]+$ && "$value" -ge "$2" ]]; then break; fi
    sleep 3
  done
  echo "$value"
}
check_equal "PDB scout was kept" "$(field pdb scout -o jsonpath='{.metadata.uid}')" "$(baseline pdb-uid)"
check_equal "PDB still requires two available Pods" "$(field pdb scout -o jsonpath='{.spec.minAvailable}')" "2"
check_equal "HPA scout was kept" "$(field hpa scout -o jsonpath='{.metadata.uid}')" "$(baseline hpa-uid)"
check_equal "Deployment scout was kept" "$(field deployment scout -o jsonpath='{.metadata.uid}')" "$(baseline deployment-uid)"

min="$(field hpa scout -o jsonpath='{.spec.minReplicas}')"
max="$(field hpa scout -o jsonpath='{.spec.maxReplicas}')"
if [[ "${min:-0}" -ge 3 && "${max:-0}" -ge "${min:-0}" ]]; then pass "HPA minimum is $min and maximum is $max"; else fail "HPA minimum must be at least 3 (found '$min', maximum '$max')"; fi

ready="$(wait_for_value "field deployment scout -o jsonpath='{.status.readyReplicas}'" 3 30)"
if [[ "${ready:-0}" -ge 3 ]]; then pass "scout has $ready ready replicas"; else fail "scout has '$ready' ready replicas, expected at least 3"; fi

allowed="$(wait_for_value "field pdb scout -o jsonpath='{.status.disruptionsAllowed}'" 1 30)"
if [[ "${allowed:-0}" -ge 1 ]]; then pass "PDB allows $allowed disruption"; else fail "PDB allows '$allowed' disruptions, expected at least 1"; fi
[[ "$failures" -eq 0 ]]
