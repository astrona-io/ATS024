---
draft: true
exam_objectives:
- Understand the primitives used to create robust, self-healing, application deployments
---
# Starting Environment

The application starts with an intentional liveness port error in its probe. Inspect the Pod events and the configured listener before changing the probe.

Repair the liveness probe on `probe` to HTTP path `/health`, named port `http`, period two seconds and failure threshold three. Keep the readiness probe on `/ready`, both replicas, the application and its Service. The healthy application must finish rolling out, then pass its health request. Do not remove the liveness probe to stop restarts.
