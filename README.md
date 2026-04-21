# Notepub Documentation Template

Template repository for building and deploying documentation websites with Notepub and GitHub Pages.

## Features

- Docs-first structure (`/` is the documentation home page)
- Hub-based sidebar navigation
- Markdown + frontmatter content model
- Search page and search modal
- SEO/metadata defaults (sitemap, robots, OpenGraph, JSON-LD)
- Branding from content/config:
  `content/home.md` frontmatter `title` is used as the header brand name,
  `site.default_og_image` in `config.yaml` is used as the header brand logo
- `llms.txt` and `llms-full.txt` for LLM indexing
- GitHub Actions workflow for automatic deploy

## Use This Template

1. Click **Use this template** in GitHub.
2. Create a new repository.
3. Push changes to `main`.
4. Open **Settings -> Pages** and ensure source is **GitHub Actions**.
5. Wait for the `Deploy Docs Template to GitHub Pages` workflow to finish.

The workflow computes `base_url` from your repository URL and deploys `dist/` automatically.

## Content Structure

- `content/home.md` - documentation home page (route `/`)
- `content/*.md` - pages, hubs, and articles
- non-markdown files in `content/` are treated as media and exported to `/media/*`

Minimal frontmatter example:

```yaml
type: article
slug: configuration
title: Configuration
description: Key settings in config.yaml and rules.yaml.
hub: [reference]
order: 10
```

## Local Development

Recommended local setup uses the same pinned release version as CI:

`NOTEPUB_VERSION=v0.1.3`

Download `notepub` binary from GitHub Releases:

macOS (Apple Silicon):

```bash
curl -L -o ./notepub "https://github.com/cookiespooky/notepub/releases/download/v0.1.3/notepub_darwin_arm64"
chmod +x ./notepub
```

macOS (Intel):

```bash
curl -L -o ./notepub "https://github.com/cookiespooky/notepub/releases/download/v0.1.3/notepub_darwin_amd64"
chmod +x ./notepub
```

Linux (amd64):

```bash
curl -L -o ./notepub "https://github.com/cookiespooky/notepub/releases/download/v0.1.3/notepub_linux_amd64"
chmod +x ./notepub
```

Windows (PowerShell):

```powershell
Invoke-WebRequest -Uri "https://github.com/cookiespooky/notepub/releases/download/v0.1.3/notepub_windows_amd64.exe" -OutFile ".\\notepub.exe"
```

Release artifacts also include:

- `notepub_linux_arm64`
- `notepub_darwin_amd64`
- `checksums.txt`

Build with helper script (macOS/Linux, or Windows with Git Bash/WSL):

```bash
NOTEPUB_BIN=./notepub ./scripts/build.sh
```

Obsidian-style image embeds are supported in CI and local scripts:

- input: `![[cover.webp]]`
- normalized: `![](/media/cover.webp)`
- static export: `dist/media/cover.webp`

Build on Windows without `bash`:

```powershell
.\notepub.exe index --config .\config.yaml --rules .\rules.yaml
.\notepub.exe build --config .\config.yaml --rules .\rules.yaml --artifacts .\.notepub\artifacts --dist .\dist
```

Serve static output:

```bash
python3 -m http.server 9000 -d dist
```

Open: `http://127.0.0.1:9000/`

Versioning rule:

- Keep README commands and `.github/workflows/deploy.yml` `NOTEPUB_VERSION` on the same release tag.

## Template Notes

After creating your own repo from this template, update these values:

- `site.title` and `site.description` in `config.yaml`
- `site.media_base_url` in `config.yaml` (local default: `http://127.0.0.1:8080/media/`)
- `content/home.md` -> `title` (shown as brand name in header)
- `site.default_og_image` in `config.yaml` (used as brand logo in header and default OG image)
- `theme/assets/llms.txt` and `theme/assets/llms-full.txt` placeholders (`<username>`, `<repo>`)
