---
draft: true
exam_objectives:
- Use ConfigMaps and Secrets to configure applications
---
# Question

Solve this question on: `terminal`

UNTESTED: not yet run against a live environment.

The `beacon` Deployment in the namespace `outpost` was built in a hurry. Its settings are literal values, it has no configuration directory, its registry Secret has the wrong type, and the ConfigMap that holds its settings can still be edited by accident. Fix all of it. Edit the Deployment in place. Do not delete and create it again, and keep two available replicas. The objects `beacon-settings` (keys `LOG_LEVEL`, `REGION`, `mode`, `banner`), `beacon-db` (key `password`) and the ServiceAccount `beacon` already exist.

1. Import every key of `beacon-settings` into the `beacon` container as environment variables with the prefix `BEACON_`. Fill `DB_PASSWORD` from the key `password` of `beacon-db`. No `env` entry may keep a `value` field.
2. Add the variable `POD_NAMESPACE`, filled from the namespace of the Pod by the downward API.
3. Define exactly one volume on the Pod template, a projected volume, and mount it read-only at `/etc/beacon`. It must contain the key `banner` of `beacon-settings` as `banner.txt`, the key `password` of `beacon-db` as `secrets/db-password` with the mode `0400`, and the labels of the Pod as `pod/labels`.
4. The Secret `registry-creds` must be of the type `kubernetes.io/dockerconfigjson` for the server `registry.starfleet.example`, with the user `beacon` and the password `disposable-pass`. Every new Pod of the ServiceAccount `beacon` must receive it as an image pull secret, without a change to the Pod template.
5. Make the ConfigMap `beacon-settings` immutable, and keep its four keys.

Use the kubeconfig of the lab:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-024-lab-020-cap)"
```

Do not print the password. The task is graded when every running `beacon` Pod has the new environment and files.
