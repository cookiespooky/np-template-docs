---
type: article
slug: release-checklist
title: Release Checklist
description: Pre-release checks before deploying documentation updates.
hub:
  - "ci-cd"
order: 20
related:
  - "workflow-structure"
  - "troubleshooting"
  - "release-gate"
---

# Release Checklist

Use a release checklist to avoid avoidable production issues.

Minimum checks:

- build passes without warnings
- search index is generated
- sitemap/robots are valid
- key pages render correctly
- external links are not broken
- quality gate matrix is green:
  - `compat_mode`: `auto`, `modern`, `legacy`
  - notes mode: `present`, `absent`
  - source mode: `local`, `s3` (config compatibility)

Use [[release-gate|Release Gate]] as the source of truth for required merge and smoke conditions.
