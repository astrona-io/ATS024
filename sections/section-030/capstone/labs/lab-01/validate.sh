#!/usr/bin/env bash
set -uo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-024-lab-030-cap" ]]; then
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
cpu_request="$(field deployment scout -o jsonpath='{.spec.template.spec.containers[0].resources.requests.cpu}')"
if [[ -n "$cpu_request" ]]; then pass "scout requests CPU ($cpu_request)"; else fail "scout has no CPU request"; fi
active="$(wait_for_value "field hpa scout -o jsonpath='{.status.conditions[?(@.type==\"ScalingActive\")].status}'" True 30)"
check_equal "HPA scout reports ScalingActive" "$active" "True"

window="$(field hpa scout -o jsonpath='{.spec.behavior.scaleDown.stabilizationWindowSeconds}')"
if [[ "${window:-0}" -ge 300 ]]; then pass "scaleDown stabilization window is $window"; else fail "scaleDown stabilization window must be at least 300 (found '$window')"; fi
check_equal "scaleDown Pods policy value" "$(field hpa scout -o jsonpath='{.spec.behavior.scaleDown.policies[?(@.type=="Pods")].value}')" "1"
check_equal "scaleDown Pods policy period" "$(field hpa scout -o jsonpath='{.spec.behavior.scaleDown.policies[?(@.type=="Pods")].periodSeconds}')" "120"

min="$(field hpa scout -o jsonpath='{.spec.minReplicas}')"
if [[ "${min:-0}" -ge 3 ]]; then pass "HPA minimum is $min"; else fail "HPA minimum must be at least 3 (found '$min')"; fi
check_equal "PDB still requires two available Pods" "$(field pdb scout -o jsonpath='{.spec.minAvailable}')" "2"
allowed="$(wait_for_value "field pdb scout -o jsonpath='{.status.disruptionsAllowed}'" 1 30)"
if [[ "${allowed:-0}" -ge 1 ]]; then pass "PDB allows $allowed disruption"; else fail "PDB allows '$allowed' disruptions, expected at least 1"; fi

check_equal "bridge applied cpu request" "$(field pod bridge -o jsonpath='{.status.containerStatuses[0].resources.requests.cpu}')" "400m"
check_equal "bridge applied cpu limit" "$(field pod bridge -o jsonpath='{.status.containerStatuses[0].resources.limits.cpu}')" "400m"
check_equal "bridge was resized in place" "$(field pod bridge -o jsonpath='{.metadata.uid}')-$(field pod bridge -o jsonpath='{.status.containerStatuses[0].restartCount}')" "$(baseline bridge-uid)-0"
check_equal "bridge keeps the Guaranteed QoS class" "$(field pod bridge -o jsonpath='{.status.qosClass}')" "Guaranteed"

check_equal "HPA was kept" "$(field hpa scout -o jsonpath='{.metadata.uid}')" "$(baseline hpa-uid)"
check_equal "PDB was kept" "$(field pdb scout -o jsonpath='{.metadata.uid}')" "$(baseline pdb-uid)"
check_equal "Deployment scout was kept" "$(field deployment scout -o jsonpath='{.metadata.uid}')" "$(baseline deployment-uid)"
[[ "$failures" -eq 0 ]]
