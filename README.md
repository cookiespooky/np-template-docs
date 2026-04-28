# NP Template Docs

Template repository for documentation websites powered by Notepub.

Recent changes are tracked in [CHANGELOG.md](./CHANGELOG.md).

## Repository structure

- `content/` - user content (Markdown)
- `media/` - optional media files
- `Site.md` - basic site settings editable in Obsidian
- `Interface.md` - basic interface labels editable in Obsidian
- `.np/` - technical workspace (`config`, `rules`, `theme`, `scripts`, output dirs)
- `.github/workflows/` - CI/CD deploy to GitHub Pages

This layout is Obsidian-friendly: users mostly edit `content/`, `media/`, `Site.md`, and `Interface.md`.

## Quick user flow (Obsidian-first)

1. Click **Use this template** on GitHub and create a repository.
2. Clone your repository locally.
3. Open the repository folder as an Obsidian vault.
4. In Obsidian, disable hidden files so `.np/` and `.notepub/` stay out of the editor workflow.
5. Edit only `content/`, `media/`, `Site.md`, and `Interface.md`.
6. Commit and push with your preferred Git workflow (for example Obsidian Git plugin).
7. GitHub Actions builds and publishes the site to GitHub Pages.

## What changed (engine-aligned)

- no source markdown rewrite step in build pipeline
- Obsidian syntax handled directly by engine (`[[...]]`, `![[...]]`, callouts, footnotes, math)
- markdown diagnostics integrated into local and CI builds (`validate --markdown`)
- URL mode handled by runtime resolver (`runtime.mode: auto|dev|prod`)
- canonical route handling is now tolerant to trailing slash variants in `serve` (`/slug` and `/slug/` resolve consistently with canonical redirect)
- basic site/UI settings are read from root Obsidian notes and override `.np/config.yaml`
- logo and default OG image are referenced from `media/`, so they are visible in Obsidian
- `Site.md` and `Interface.md` are optional; build generates safe effective settings from notes, `.np/config.yaml`, and template defaults
- `preview.sh` removed; local preview uses standard `notepub serve`
- search modal/page thumbnail fallback now uses `/assets/notepub.jpg` to avoid dependency on media allowlist for default placeholder image
- SEO meta tags include both `og:image` and `twitter:image` based on resolved page image metadata.

## Local build

```bash
./.np/scripts/build.sh
```

If `.np/bin/notepub` is missing:

```bash
NOTEPUB_BIN=/path/to/notepub ./.np/scripts/build.sh
```

The build script runs:

1. runtime config generation (optional analytics JS config)
2. `notepub index`
3. `notepub validate --links`
4. `notepub validate --markdown`
5. `notepub build`

Output:

- primary: `.np/dist/`
- mirror: `dist/`

## Local serve (preview)

```bash
NOTEPUB_BIN=/path/to/notepub /path/to/notepub serve --config ./.np/config.yaml --rules ./.np/rules.yaml
```

With `runtime.mode: auto`, local serve resolves to dev URLs automatically.

## Deploy

Workflow `.github/workflows/deploy.yml` builds and deploys automatically.
CI uses pinned Notepub release binaries (`v0.1.6`) from GitHub Releases.

Additional quality gate workflow `.github/workflows/quality-gate.yml` runs matrix checks before release-sensitive merges:

- `compat_mode`: `auto`, `modern`, `legacy`
- notes mode: `present`, `absent`
- source mode: `local`, `s3` (config-compat validation)

Release criteria are documented in `content/release-gate.md`.

You do not need to edit `.np/config.yaml` after creating a repository from this template.
During GitHub Actions builds, `.np/scripts/build.sh` first checks for a root `CNAME` file.
If `CNAME` exists, that custom domain becomes the production base URL and is copied into the Pages artifact.

The workflow also passes the official `actions/configure-pages` `base_url` output into the build. This is the preferred source for GitHub Pages project sites and custom domains.

Without a Pages-provided URL or `CNAME`, the script infers the GitHub Pages URL from `GITHUB_REPOSITORY`:

- `owner.github.io` -> `https://owner.github.io/`
- any other repository -> `https://owner.github.io/repository/`

The inferred URL is passed to Notepub through environment overrides:

- `NOTEPUB_BASE_URL`
- `NOTEPUB_MEDIA_BASE_URL`

When a production URL is available, the build script also writes `.np/config.resolved.yaml` with `site.base_url` and `site.media_base_url` already set. This keeps production asset URLs correct even with older Notepub binaries.

Repository variables with the same names can still override both modes.

## Config points

- user-facing site settings: `Site.md`
- user-facing interface labels: `Interface.md`
- technical site/runtime fallback config: `.np/config.yaml`
- routing/model rules: `.np/rules.yaml`
- templates/assets: `.np/theme/`
- footer content page: `content/footer.md`

Footer content is managed only in `content/footer.md`. It is not configured through `Interface.md` or `.np/config.yaml`.

`Site.md` and `Interface.md` are optional. If they are removed or contain invalid media/icon paths, `.np/scripts/build.sh` falls back to the `settings:` block in `.np/config.yaml` and then to theme defaults. The build writes temporary effective notes under `.np/generated/`, generates `.np/config.generated.yaml`, and passes that generated config to Notepub.

In `CONTENT_SOURCE=s3` mode, CI writes `.np/config.effective.yaml` with `content.source: "s3"` and a top-level `s3:` block compatible with Notepub config loading.

Fonts can use the simple presets `system`, `inter`, `serif`, or `mono`. Advanced users can override them with CSS font stacks:

```yaml
theme_font_stack: IBM Plex Sans, Arial, sans-serif
theme_heading_font_stack: IBM Plex Serif, Georgia, serif
theme_font_url: https://fonts.googleapis.com/css2?family=IBM+Plex+Sans:wght@400;600&display=swap
```

Invalid font stacks or non-HTTPS font URLs fall back to the configured preset.

Icons are intentionally simple for regular users:

```yaml
site_icon: /media/notepub.png
```

The build uses `site_icon` for favicon, Apple touch icon, and manifest icons. Developers who need exact control can edit `.np/theme/assets/site.webmanifest` or add advanced icon fields in `.np/config.yaml settings:`.

Optional LLM files:

- `LLMS.md` -> `llms.txt`
- `LLMS.full.md` -> `llms-full.txt`

If these files are missing or empty, the default files from `.np/theme/assets/` are used.

## Optional analytics flag

In `.np/config.yaml`:

```yaml
site:
  analytics:
    enabled: false
    provider: "yandex_metrika"
    yandex_counter_id: ""
```

When enabled, runtime config JS is generated during build and injected by frontend code.
