---
type: article
slug: troubleshooting
title: Troubleshooting
description: Common issues and practical fixes.
hub:
  - "operations"
order: 20
related:
  - "build-and-deploy"
---

# Troubleshooting

If styles are missing on GitHub Pages:

- verify workflow generated publish config with `runtime.mode: prod`
- verify computed `runtime.prod.base_url` matches your Pages URL
- ensure templates use `.AssetsBase` for static assets

If links break under project pages:

- avoid hardcoded root paths
- verify canonical/OG URLs use the same resolved runtime base URL

If build fails on markdown validation:

- run `./.np/scripts/build.sh` locally
- inspect diagnostics output from `validate --markdown`
- fix unresolved wikilinks/embeds or unsupported syntax
