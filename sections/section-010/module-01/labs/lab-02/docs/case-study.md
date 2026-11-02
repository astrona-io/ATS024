---
draft: true
exam_objectives:
- Understand application deployments and how to perform rolling update and rollbacks
---
# Starting Environment

The application first becomes healthy. Bootstrap then changes its image to a nonexistent tag. Existing replicas may still serve requests while the new template cannot start. A working response alone does not prove that the update completed.

Keep the `probe` Deployment in `starfleet`, its two replicas, labels, command, configuration and Service. Restore container `probe` to image `docker.io/library/python:3.13-alpine`. The current generation must finish rolling out with exactly two updated, ready and available replicas. The `shuttle` client must receive `version=v1` through `http://probe/`.
