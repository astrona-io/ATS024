---
draft: true
exam_objectives:
- Understand the primitives used to create robust, self-healing, application deployments
---
# Starting Environment

The application starts with an intentional readiness port error in its probe. Inspect the Pod events and the configured listener before changing the probe.

Repair the readiness probe on `probe` to HTTP path `/ready` and named port `http`. Keep the application command, image, two replicas and original Service. Both replicas must become ready and available. The original client must receive version one. Do not remove the readiness check.
