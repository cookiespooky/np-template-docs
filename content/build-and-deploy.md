---
type: article
slug: build-and-deploy
title: Build and Deploy
description: How the template builds and deploys with GitHub Actions.
hub:
  - "operations"
order: 10
related:
  - "getting-started"
  - "configuration"
---

# Build and Deploy

Default workflow:

1. Downloads a pinned Notepub binary release.
2. Resolves content source (`local`, `content_repo`, or `s3`).
3. Runs local template build pipeline (`validate -> index -> build`).
4. Uploads `.np/dist` to GitHub Pages.

URL handling:

- CI computes the final GitHub Pages URL.
- Workflow creates temporary publish config with `runtime.mode: prod`.
- `runtime.prod.base_url` and `runtime.prod.media_base_url` are injected into that temporary config.

The content markdown is not rewritten in CI.
Obsidian syntax is processed by the engine at render/index time.
