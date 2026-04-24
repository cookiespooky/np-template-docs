---
type: article
slug: deployment-rollback
title: Deployment Rollback
description: How to rollback quickly when a deployment introduces regressions.
hub:
  - "ci-cd"
order: 30
related:
  - "release-checklist"
  - "troubleshooting"
---

# Deployment Rollback

Rollback strategy should be documented before incidents happen.

Basic rollback flow:

1. identify the last known good commit
2. redeploy that commit
3. verify critical routes and assets
4. create a follow-up fix for the failed change
