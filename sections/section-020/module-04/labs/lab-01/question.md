---
draft: true
exam_objectives:
- Use ConfigMaps and Secrets to configure applications
---
# Question

Solve this question on: `terminal`

UNTESTED: not yet run against a live environment.

The `shuttle` Deployment in `starfleet` needs its configuration in one directory, and two variables that describe the Pod itself. The ConfigMap `shuttle-config` (key `flags`) and the Secret `shuttle-token` (key `token`) already exist. Edit the Deployment in place. Do not delete and create it again, and keep two available replicas.

1. Define exactly one volume on the Pod template, a projected volume, and mount it read-only at `/etc/shuttle`.
2. The volume must place the key `flags` of `shuttle-config` at `flags.conf`, the key `token` of `shuttle-token` at `secrets/token` with the mode `0400`, and the labels of the Pod at `pod/labels`.
3. The variable `POD_NAME` must hold the name of the Pod. It is a literal value now, which is wrong. Take it from the downward API.
4. The variable `CPU_MILLI` must hold the CPU limit of the container in millicores. It is a literal value now, which is wrong. Take it from the downward API with a divisor.
5. No `env` entry may keep a `value` field.

Use the kubeconfig of the lab:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-024-lab-020-04-01)"
```

Do not print the token. The task is graded when every running `shuttle` Pod has the files and the variables.
