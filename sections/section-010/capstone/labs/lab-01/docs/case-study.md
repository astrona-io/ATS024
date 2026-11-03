---
draft: true
exam_objectives:
- Understand application deployments and how to perform rolling update and rollbacks
---
# Starting Environment

The `probe` Deployment in `starfleet` serves `v1` and was updated to an image tag that does not exist. Its strategy is `Recreate`, so the update removed every working Pod first, and the `probe` Service now has no backends. The `shuttle` Pod is a client in the same namespace. The Deployment is revision 2, and revision 1 is the last working template.
