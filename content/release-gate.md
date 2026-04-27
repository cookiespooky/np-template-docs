---
type: article
slug: release-gate
title: Release Gate
description: CI matrix and smoke checks required before documentation releases.
hub:
  - "ci-cd"
order: 15
related:
  - "release-checklist"
  - "build-and-deploy"
  - "workflow-structure"
---

# Release Gate

Use this page as the single release-readiness contract for this template.

## Required CI gate

Workflow: `.github/workflows/quality-gate.yml`

Matrix dimensions:

- `compat_mode`: `auto`, `modern`, `legacy`
- notes mode: `present`, `absent`
- source mode: `local`, `s3`

What each axis verifies:

- `compat_mode` validates compatibility behavior between modern and legacy contracts.
- notes mode validates fallback behavior when `Site.md` and `Interface.md` are missing.
- source mode validates both local build flow and S3 effective-config compatibility.

## Required merge conditions

A release candidate is considered ready only when all are true:

- all matrix jobs in `quality-gate.yml` are green
- deploy workflow can build from current `main`
- no blocking markdown diagnostics for release content
- no unresolved manual release blockers in PR discussion

## Recommended smoke checks

After CI is green and before tagging/release announcement:

- open home page and at least one page per main hub
- verify search results for 2-3 representative queries
- verify sitemap/robots availability
- verify one image and one video embed rendering
- verify canonical URLs on a couple of pages

## Commands for local dry run

```bash
./.np/scripts/build.sh
```

```bash
NOTEPUB_BIN=/path/to/notepub /path/to/notepub validate --config ./.np/config.yaml --rules ./.np/rules.yaml --markdown --markdown-format text
```

## Related docs

- [[Release Checklist|Release Checklist]]
- [[Build and Deploy|Build and Deploy]]
- [[Deployment Rollback|Deployment Rollback]]
