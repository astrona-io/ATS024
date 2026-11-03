#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

kubectl -n starfleet delete job scan-report --ignore-not-found
kubectl apply -f "$DIR/solution.yaml"

kubectl -n starfleet patch cronjob fleet-report --type merge -p \
  '{"spec":{"suspend":false,"concurrencyPolicy":"Forbid","startingDeadlineSeconds":120,"successfulJobsHistoryLimit":2,"failedJobsHistoryLimit":2}}'

kubectl -n starfleet wait --for=condition=complete job/scan-report --timeout=120s
echo "[solution] Applied."
