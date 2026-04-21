---
type: article
slug: troubleshooting
title: Troubleshooting
description: Common issues and practical fixes.
hub:
  - "[[operations]]"
order: 20
related:
  - "[[build-and-deploy]]"
---
If styles are missing on GitHub Pages:

- verify `base_url` is patched in workflow
- ensure template uses `.AssetsBase` for static assets

If links break under project pages:

- use base-aware URLs and avoid hardcoded root paths.
