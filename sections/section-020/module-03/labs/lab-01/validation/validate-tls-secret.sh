#!/usr/bin/env bash
# Check: probe-tls is a kubernetes.io/tls Secret with a matching certificate and key for probe.starfleet.svc.
set -uo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-024-lab-020-03-01" ]]; then
  echo "FAIL: wrong Kubernetes context"
  exit 1
fi
fail=0
command -v openssl >/dev/null || { echo "FAIL: openssl is not installed on the grading host"; exit 1; }
type="$(kubectl -n starfleet get secret probe-tls -o jsonpath='{.type}' 2>/dev/null || true)"
if [ "$type" != "kubernetes.io/tls" ]; then
  echo "FAIL: probe-tls has type '$type', expected kubernetes.io/tls"
  exit 1
fi
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
kubectl -n starfleet get secret probe-tls -o jsonpath='{.data.tls\.crt}' | base64 -d > "$work/tls.crt"
kubectl -n starfleet get secret probe-tls -o jsonpath='{.data.tls\.key}' | base64 -d > "$work/tls.key"
subject="$(openssl x509 -in "$work/tls.crt" -noout -subject 2>/dev/null || true)"
case "$subject" in
  *probe.starfleet.svc*) ;;
  *) echo "FAIL: certificate subject does not contain probe.starfleet.svc"; fail=1 ;;
esac
openssl x509 -in "$work/tls.crt" -noout -checkend 0 >/dev/null 2>&1 || { echo "FAIL: certificate is expired or unreadable"; fail=1; }
cert_key="$(openssl x509 -in "$work/tls.crt" -noout -pubkey 2>/dev/null | openssl md5 2>/dev/null || true)"
private_key="$(openssl pkey -in "$work/tls.key" -pubout 2>/dev/null | openssl md5 2>/dev/null || true)"
if [ -z "$cert_key" ] || [ "$cert_key" != "$private_key" ]; then
  echo "FAIL: the private key does not match the certificate"
  fail=1
fi
[ "$fail" -eq 0 ] && echo "PASS: probe-tls is a valid TLS Secret for probe.starfleet.svc"
exit "$fail"
