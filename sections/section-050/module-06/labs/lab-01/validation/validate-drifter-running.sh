#!/usr/bin/env bash
# Check: drifter runs two pods, the pods have the defaults, and the Deployment template was not edited.
set -uo pipefail
fail=0
if ! kubectl -n outpost rollout status deployment/drifter --timeout=60s >/dev/null 2>&1; then
  echo "FAIL: deployment drifter is not available in outpost"; exit 1
fi
ready="$(kubectl -n outpost get deployment drifter -o jsonpath='{.status.availableReplicas}' 2>/dev/null)"
[ "$ready" = "2" ] || { echo "FAIL: drifter has ${ready:-0} available replicas, expected 2"; fail=1; }
template="$(kubectl -n outpost get deployment drifter -o jsonpath='{.spec.template.spec.containers[0].resources}' 2>/dev/null)"
if [ -n "$template" ] && [ "$template" != "{}" ]; then
  echo "FAIL: the Deployment template sets resources; the defaults must come from a LimitRange"; fail=1
fi
pod_cpu="$(kubectl -n outpost get pods -l app=drifter -o jsonpath='{.items[*].spec.containers[0].resources.requests.cpu}' 2>/dev/null)"
case "$pod_cpu" in
  *100m*) ;;
  *) echo "FAIL: drifter pods do not have the default cpu request 100m (found: ${pod_cpu:-none})"; fail=1;;
esac
[ "$fail" -eq 0 ] && echo "PASS: drifter runs with the default requests and limits"
exit "$fail"
