---
draft: true
exam_objectives:
- Use ConfigMaps and Secrets to configure applications
---
# Summary

ConfigMaps and Secrets connect declared input objects to application consumers. The kubelet delivers the data, and it does so in two ways: as files in a mounted volume and as environment variables set at container start. The two ways have different update behavior.

A mounted volume changes after the kubelet sync, through an atomic link swap, but the application must read the file again. An environment variable and a `subPath` mount keep the value they received at start, so a rollout is needed to change them.

Secret encoding is not encryption. Read permission, encryption at rest and application behavior protect different exposure paths, and a rotation needs the issuer, the stored value and every consumer to change in a planned order. Verification must prove that access works without printing the value.

<!-- astrona:playground:destroy -->
