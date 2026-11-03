#!/usr/bin/env bash
# Check: the seeded policy keeps its expression and a binding with Deny exists for it.
set -uo pipefail
fail=0
expr="$(kubectl get validatingadmissionpolicy replica-limit -o jsonpath='{.spec.validations[0].expression}' 2>/dev/null)"
[ "$expr" = "object.spec.replicas <= 3" ] || { echo "FAIL: the replica-limit expression was changed or the policy was deleted"; fail=1; }
actions="$(kubectl get validatingadmissionpolicybinding -o jsonpath='{range .items[?(@.spec.policyName=="replica-limit")]}{.spec.validationActions}{"\n"}{end}' 2>/dev/null)"
grep -q "Deny" <<<"$actions" || { echo "FAIL: no binding of replica-limit uses the action Deny"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: the seeded policy is unchanged and bound with Deny"
exit "$fail"
