#!/usr/bin/env bash
# Starting state for the Job and CronJob lab. It creates the faulty Job and
# CronJob and records the CronJob uid so the grader can tell a repair from a
# delete-and-recreate shortcut.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"

# Bounded wait: the Job fails on its first attempt because it has no retry.
kubectl -n starfleet wait --for=condition=failed job/scan-report --timeout=120s || true

cron_uid="$(kubectl -n starfleet get cronjob fleet-report -o jsonpath='{.metadata.uid}')"
kubectl -n starfleet create configmap lab-baseline --from-literal=cronjob-uid="$cron_uid"
echo "[lab] Ready."
