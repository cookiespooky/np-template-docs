# NP Template Docs

Template repository for documentation websites powered by Notepub.

Recent changes are tracked in [CHANGELOG.md](./CHANGELOG.md).

## Repository structure

- `content/` - user content (Markdown)
- `media/` - optional media files
- `.np/` - technical workspace (`config`, `rules`, `theme`, `scripts`, output dirs)
- `.github/workflows/` - CI/CD deploy to GitHub Pages

This layout is Obsidian-friendly: users mostly edit `content/` and `media/`.

## What changed (engine-aligned)

- no source markdown rewrite step in build pipeline
- Obsidian syntax handled directly by engine (`[[...]]`, `![[...]]`, callouts, footnotes, math)
- markdown diagnostics integrated into local and CI builds (`validate --markdown`)
- URL mode handled by runtime resolver (`runtime.mode: auto|dev|prod`)
- `preview.sh` removed; local preview uses standard `notepub serve`

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

You do not need to edit `.np/config.yaml` after creating a repository from this template.
During GitHub Actions builds, `.np/scripts/build.sh` infers the GitHub Pages URL from `GITHUB_REPOSITORY`:

- `owner.github.io` -> `https://owner.github.io/`
- any other repository -> `https://owner.github.io/repository/`

The inferred URL is passed to Notepub through environment overrides:

- `NOTEPUB_BASE_URL`
- `NOTEPUB_MEDIA_BASE_URL`

For a custom domain, set repository variables with the same names.

## Config points

- site/runtime config: `.np/config.yaml`
- routing/model rules: `.np/rules.yaml`
- templates/assets: `.np/theme/`
- footer content page: `content/footer.md`

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
