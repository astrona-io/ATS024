---
draft: true
exam_objectives:
- Understand application deployments and how to perform rolling update and rollbacks
---
# Starting Environment

The `probe` Deployment in `starfleet` has four revisions. Revision 1 serves `v1`. Revision 2 serves `v2` and was the last release that users verified. Revision 3 serves `v3` and returns wrong data although it passes readiness. Revision 4 also points at an image tag that does not exist, so its new Pods cannot start. The `shuttle` Pod is a client in the same namespace.
