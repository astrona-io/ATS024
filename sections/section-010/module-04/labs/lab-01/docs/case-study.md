---
draft: true
exam_objectives:
- Understand application deployments and how to perform rolling update and rollbacks
---
# Starting Environment

The `outpost` namespace exists and is empty. The task gives you a base Deployment named `beacon` that you must create as files in your shell. It has one replica, the label `app: beacon`, one container named `beacon` with the image `docker.io/library/busybox:1.36.1` and the command `sh -c "sleep 3600"`. It names no namespace.
