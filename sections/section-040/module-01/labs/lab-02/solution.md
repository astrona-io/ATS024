---
draft: true
exam_objectives:
- Understand the primitives used to create robust, self-healing, application deployments
---
# Repair A Liveness Probe Port Solution

Use a host shell with this lab's private kubeconfig. A kubeconfig identifies the cluster and credentials used by kubectl, the Kubernetes command-line tool. This environment is separate from the ungraded playground.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-024-lab-040-01-02)"
test "$(kubectl config current-context)" = "kind-astro-ats-024-lab-040-01-02" || exit 1
```

Keep this connection selected throughout the task. Every script supplied by the lab refuses a different context.

## Inspect And Explain

The application starts with an intentional liveness port error in its probe. Inspect the Pod events and the configured listener before changing the probe.

Inspect the relevant evidence:

```sh
kubectl -n starfleet describe pods -l app=probe
kubectl -n starfleet get deployment probe -o yaml
```

A failing liveness probe can cause the kubelet to restart a healthy process if it checks the wrong listener. Correct the check rather than removing it. Readiness still controls backend eligibility independently. Current-generation availability and a successful health request verify the repaired configuration.


Save this as `deployment-probe.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: probe
  namespace: starfleet
spec:
  replicas: 2
  selector:
    matchLabels:
      app: probe
      release: probe
  template:
    metadata:
      labels:
        app: probe
        release: probe
    spec:
      containers:
      - name: probe
        image: docker.io/library/python:3.13-alpine
        command:
        - python
        - /app/server.py
        env:
        - name: VERSION
          value: v1
        ports:
        - name: http
          containerPort: 8080
        readinessProbe:
          httpGet:
            path: /ready
            port: http
          periodSeconds: 2
        resources:
          requests:
            cpu: 10m
            memory: 32Mi
          limits:
            memory: 128Mi
        volumeMounts:
        - name: app
          mountPath: /app
          readOnly: true
        livenessProbe:
          httpGet:
            path: /health
            port: http
          periodSeconds: 2
          failureThreshold: 3
      volumes:
      - name: app
        configMap:
          name: probe-code
```

Apply the required change:

```sh
kubectl apply -f deployment-probe.yaml
```

## Verify The Result

Observe the actual result. A denied-request command returns a nonzero status when the denial works. Run denial checks separately from a shell sequence that stops on the first nonzero status.

```sh
kubectl -n starfleet rollout status deployment/probe --timeout=180s
kubectl -n starfleet exec shuttle -- wget -q -T 3 -O- http://probe/
kubectl -n starfleet exec deployment/probe -- python -c 'import urllib.request; print(urllib.request.urlopen('"'"'http://127.0.0.1:8080/health'"'"',timeout=3).status)'
```

Repair the liveness probe on `probe` to HTTP path `/health`, named port `http`, period two seconds and failure threshold three. Keep the readiness probe on `/ready`, both replicas, the application and its Service. The healthy application must finish rolling out, then pass its health request. Do not remove the liveness probe to stop restarts.

After recording the result, remove this independent lab with `astrona destroy ats-024-lab-040-01-02`.

## Common pitfalls

> [!WARNING]
> Do not remove liveness to stop the observed restarts. Fix its listener relationship. Readiness still controls Service eligibility independently of the restart check.
