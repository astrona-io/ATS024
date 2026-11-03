---
draft: true
exam_objectives:
- Use ConfigMaps and Secrets to configure applications
---
# Question

Solve this question on: `terminal`

UNTESTED: not yet run against a live environment.

The `starfleet` namespace needs credentials for the private registry `registry.starfleet.example` and a certificate for the `probe` Deployment. The Secret `registry-creds` already exists, but it was created with the wrong type. The ServiceAccount `builder` does not use it. Keep the Deployment `probe` as the same object and edit it in place.

1. Make `registry-creds` a Secret of the type `kubernetes.io/dockerconfigjson` for the server `registry.starfleet.example`, with the user `scout` and the password `disposable-pass`.
2. Make every new Pod that runs as the ServiceAccount `builder` pull images with `registry-creds`. Set it on the ServiceAccount, not on single Pods.
3. Create the Secret `probe-tls` of the type `kubernetes.io/tls` in `starfleet`. Use a self-signed certificate with the subject `/CN=probe.starfleet.svc` and its matching private key. Do not keep the files in the cluster.
4. Mount `probe-tls` into the `probe` container at `/tls` as a read-only volume. The files must have the mode `0400`.

Use the kubeconfig of the lab:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-024-lab-020-03-01)"
```

Do not print the password or the private key. The task is graded when the running `probe` Pod has the files in `/tls`.
