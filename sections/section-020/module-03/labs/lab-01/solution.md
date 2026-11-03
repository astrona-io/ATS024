---
draft: true
exam_objectives:
- Use ConfigMaps and Secrets to configure applications
---
# Solution

UNTESTED: not yet run against a live environment.

Solve this lab on `terminal`. Each step ends with `astrona submit`, which shows which checks pass. Start the lab if it is not running, and select its kubeconfig:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-024-lab-020-03-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-024-lab-020-03-01" || exit 1
```

## Step 1: Look at the starting state

```sh
kubectl -n starfleet get secret registry-creds
kubectl -n starfleet get serviceaccount builder -o yaml
kubectl -n starfleet get deployment probe -o yaml
```

The Secret has the type `Opaque`. The ServiceAccount has no `imagePullSecrets`. The Deployment has no volumes. All checks fail now.

## Step 2: Create the registry Secret again

The type of a Secret cannot change after creation, so the Secret must be deleted and created again. The command `kubectl create secret docker-registry` builds the `.dockerconfigjson` key for you:

```sh
kubectl -n starfleet delete secret registry-creds
kubectl -n starfleet create secret docker-registry registry-creds \
  --docker-server=registry.starfleet.example \
  --docker-username=scout \
  --docker-password=disposable-pass
```

Run `astrona submit`. The check `registry-secret-type` should pass.

## Step 3: Add the pull secret to the ServiceAccount

The ServiceAccount admission controller copies `imagePullSecrets` of the ServiceAccount into each new Pod at creation. Patch the ServiceAccount:

```sh
kubectl -n starfleet patch serviceaccount builder -p '{"imagePullSecrets":[{"name":"registry-creds"}]}'
```

Run `astrona submit`. The check `serviceaccount-pull-secret` should pass. It asks the API server to admit a Pod as `builder` without storing it, and looks for the copied secret.

## Step 4: Create the TLS Secret

Make a self-signed certificate in a temporary directory, and create the Secret from it:

```sh
work="$(mktemp -d)"
openssl req -x509 -newkey rsa:2048 -nodes -keyout "$work/probe.key" -out "$work/probe.crt" -days 30 -subj "/CN=probe.starfleet.svc"
kubectl -n starfleet create secret tls probe-tls --cert="$work/probe.crt" --key="$work/probe.key"
rm -r "$work"
```

The command checks that the key and the certificate match. Run `astrona submit`. The check `tls-secret` should pass.

## Step 5: Mount the Secret

The Deployment must keep its identity, so apply a changed manifest to the same object. Save this as `deployment-probe.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: probe
  namespace: starfleet
spec:
  replicas: 1
  selector:
    matchLabels:
      app: probe
  template:
    metadata:
      labels:
        app: probe
    spec:
      containers:
      - name: probe
        image: docker.io/library/busybox:1.37.0
        command:
        - sh
        - -c
        - sleep 3600
        volumeMounts:
        - name: tls
          mountPath: /tls
          readOnly: true
      volumes:
      - name: tls
        secret:
          secretName: probe-tls
          defaultMode: 0400
```

Apply it:

```sh
kubectl apply -f deployment-probe.yaml
```

Then check the result:

```sh
kubectl -n starfleet rollout status deployment/probe --timeout=120s
```

The mode is written as octal in YAML, and the API shows it as the decimal number 256. Run `astrona submit`. All four checks should pass.
