#!/usr/bin/env bash
set -uo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-024-lab-030-03-01" ]]; then
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
for kind in requests limits; do
  check_equal "bridge spec $kind cpu" "$(field pod bridge -o jsonpath="{.spec.containers[0].resources.$kind.cpu}")" "300m"
done
check_equal "bridge applied cpu request" "$(field pod bridge -o jsonpath='{.status.containerStatuses[0].resources.requests.cpu}')" "300m"
check_equal "bridge applied cpu limit" "$(field pod bridge -o jsonpath='{.status.containerStatuses[0].resources.limits.cpu}')" "300m"
check_equal "no resize is pending" "$(field pod bridge -o jsonpath='{.status.conditions[?(@.type=="PodResizePending")].status}')" ""

check_equal "bridge is the original Pod" "$(field pod bridge -o jsonpath='{.metadata.uid}')" "$(baseline bridge-uid)"
check_equal "bridge container was not restarted" "$(field pod bridge -o jsonpath='{.status.containerStatuses[0].restartCount}')" "0"
check_equal "bridge keeps the Guaranteed QoS class" "$(field pod bridge -o jsonpath='{.status.qosClass}')" "Guaranteed"
check_equal "bridge memory request is unchanged" "$(field pod bridge -o jsonpath='{.spec.containers[0].resources.requests.memory}')" "64Mi"
check_equal "bridge memory limit is unchanged" "$(field pod bridge -o jsonpath='{.spec.containers[0].resources.limits.memory}')" "64Mi"

check_equal "scout desired replicas" "$(field deployment scout -o jsonpath='{.spec.replicas}')" "3"
ready="$(wait_for_value "field deployment scout -o jsonpath='{.status.readyReplicas}'" 3 20)"
check_equal "scout ready replicas" "$ready" "3"
check_equal "Deployment scout was kept" "$(field deployment scout -o jsonpath='{.metadata.uid}')" "$(baseline deployment-uid)"
[[ "$failures" -eq 0 ]]
