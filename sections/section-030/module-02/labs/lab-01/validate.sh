#!/usr/bin/env bash
set -uo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-024-lab-030-02-01" ]]; then
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
if [[ -n "$cpu_request" ]]; then pass "scout container requests CPU ($cpu_request)"; else fail "scout container has no CPU request"; fi

active="$(wait_for_value "field hpa scout -o jsonpath='{.status.conditions[?(@.type==\"ScalingActive\")].status}'" True 30)"
check_equal "HPA scout reports ScalingActive" "$active" "True"
metric="$(field hpa scout -o jsonpath='{.status.currentMetrics[0].resource.current.averageUtilization}')"
if [[ -n "$metric" ]]; then pass "HPA scout reports a current utilization"; else fail "HPA scout has no current utilization"; fi

check_equal "scaleDown stabilization window" "$(field hpa scout -o jsonpath='{.spec.behavior.scaleDown.stabilizationWindowSeconds}')" "600"
check_equal "scaleDown Pods policy value" "$(field hpa scout -o jsonpath='{.spec.behavior.scaleDown.policies[?(@.type=="Pods")].value}')" "1"
check_equal "scaleDown Pods policy period" "$(field hpa scout -o jsonpath='{.spec.behavior.scaleDown.policies[?(@.type=="Pods")].periodSeconds}')" "120"

check_equal "scaleUp Pods policy value" "$(field hpa scout -o jsonpath='{.spec.behavior.scaleUp.policies[?(@.type=="Pods")].value}')" "2"
check_equal "scaleUp Pods policy period" "$(field hpa scout -o jsonpath='{.spec.behavior.scaleUp.policies[?(@.type=="Pods")].periodSeconds}')" "60"
check_equal "HPA maxReplicas" "$(field hpa scout -o jsonpath='{.spec.maxReplicas}')" "6"
check_equal "HPA minReplicas" "$(field hpa scout -o jsonpath='{.spec.minReplicas}')" "2"

check_equal "HPA was edited, not recreated" "$(field hpa scout -o jsonpath='{.metadata.uid}')" "$(baseline hpa-uid)"
check_equal "Deployment scout was kept" "$(field deployment scout -o jsonpath='{.metadata.uid}')" "$(baseline deployment-uid)"
[[ "$failures" -eq 0 ]]
