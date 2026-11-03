---
draft: true
exam_objectives:
- Use ConfigMaps and Secrets to configure applications
---
# Question

Solve this question on: `terminal`

UNTESTED: not yet run against a live environment.

The `scout` Deployment in `starfleet` still has its settings written into the Pod template as literal values. Move them to the ConfigMap and the Secret that already exist. Edit the Deployment in place. Do not delete and create it again, and keep two available replicas.

1. The ConfigMap `scout-settings` has the keys `LOG_LEVEL`, `REGION` and `mode`. Import every key of the ConfigMap into the `scout` container as environment variables with the prefix `SCOUT_`.
2. The application expects the variable `APP_MODE`. Fill it from the key `mode` of `scout-settings`.
3. The variable `DB_PASSWORD` holds a literal password. Fill it from the key `password` of the Secret `scout-db` instead.
4. Remove the literal `LOG_LEVEL` and `DB_PASSWORD` values from the Pod template. No `env` entry may keep a `value` field.

Use the kubeconfig of the lab:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-024-lab-020-02-01)"
```

Do not print the password. The task is graded when every running `scout` Pod has the new environment.
