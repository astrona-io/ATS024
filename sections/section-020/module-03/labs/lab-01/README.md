---
estimated_duration: 30m
---

# Lab: Attach Registry Credentials And Serve A TLS Secret

**Status: UNTESTED - never run against a live cluster.**

Graded lab for the Secret types module. The Secret `registry-creds` has the wrong type, the ServiceAccount `builder` has no pull secret, and the Deployment `probe` has no certificate. The task is in `question.md` and the walkthrough is in `solution.md`. The host needs `openssl`.

## Run it

```sh
astrona run -c .
astrona submit -c .
astrona destroy ats-024-lab-020-03-01
```

Authors prove the reference solution with `astrona test -c .` once a live run is allowed.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-registry-secret.sh` | `registry-creds` has type dockerconfigjson with the expected server, user and password |
| `validate-serviceaccount.sh` | `builder` lists `registry-creds`, and a server-side dry run Pod receives it |
| `validate-tls-secret.sh` | `probe-tls` has type tls, subject `probe.starfleet.svc`, a valid date and a matching key |
| `validate-probe-mount.sh` | `probe` mounts the Secret read-only at `/tls`, mode 0400 in the running Pod, same Deployment uid |

All checks fail on the starting state.
