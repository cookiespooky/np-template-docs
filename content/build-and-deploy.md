---
type: article
slug: build-and-deploy
title: Build and Deploy
description: How the template builds and deploys with GitHub Actions.
hub:
  - "[[operations]]"
order: 10
related:
  - "[[getting-started]]"
  - "[[configuration]]"
---
The default workflow:

1. Downloads a pinned Notepub binary release.
2. Runs `notepub index` and `notepub build`.
3. Uploads `dist` to GitHub Pages.

The `base_url` is patched in CI based on your repository URL.
