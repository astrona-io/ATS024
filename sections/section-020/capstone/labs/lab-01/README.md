---
estimated_duration: 30m
---

# Capstone: Configure An Application With ConfigMaps And Secrets

**Status: UNTESTED - never run against a live cluster.**

Graded capstone for the section. The Deployment `beacon` has literal settings, no configuration directory, a registry Secret of the wrong type and a mutable ConfigMap. The task is in `question.md` and the walkthrough is in `solution.md`.

## Skills

- Inject ConfigMap and Secret values as environment variables with `envFrom`, a prefix and `secretKeyRef`.
- Combine a ConfigMap, a Secret and the downward API in one projected volume with paths and file modes.
- Create a registry Secret of the right type and attach it through a ServiceAccount.
- Pass Pod facts to a container with `fieldRef`.
- Protect a ConfigMap from edits with `immutable`.

## Run it

```sh
astrona run -c .
astrona submit -c .
astrona destroy ats-024-lab-020-cap
```

Authors prove the reference solution with `astrona test -c .` once a live run is allowed.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-environment.sh` | Prefixed import, `secretKeyRef`, no literal values, correct values in running Pods |
| `validate-registry-credentials.sh` | Secret type and server, ServiceAccount list, a server-side dry run Pod receives the secret |
| `validate-projected-files.sh` | One projected volume at `/etc/beacon` with the three files and the mode 400 |
| `validate-settings-immutable.sh` | `beacon-settings` is immutable and keeps its four keys |
| `validate-deployment-health.sh` | Same Deployment uid, 2 available replicas, `POD_NAMESPACE` from the downward API |

All checks fail on the starting state.
