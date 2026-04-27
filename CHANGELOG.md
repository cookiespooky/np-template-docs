# Changelog

## 2026-04-27

### Fixed

- Fixed build pipeline path handling for generated note overrides:
  - `.np/scripts/prepare-settings.py` now writes `.np/config.generated.yaml` (instead of placing generated config under `.np/generated/`).
  - generated config keeps valid relative paths to `content/` and `.np/generated/*.md`.
- Fixed GitHub Actions S3 override generation:
  - CI now writes `content.source: "s3"` plus a top-level `s3:` block expected by Notepub config loader.
- Fixed local build regressions caused by generated config path mismatch.
- Fixed search thumbnail fallback in theme JS:
  - fallback image now uses `/assets/notepub.jpg` instead of `/media/notepub.jpg`, so thumbnails work even when `/media` allowlist does not include the default image.
- Fixed `serve` URL behavior with latest Notepub route canonicalization:
  - `/slug/` now redirects to canonical `/slug` (and legacy slash-style routes are also resolved).
- Fixed search page behavior for query navigation:
  - removed duplicated results on `/search?q=...` (server list + JS list overlap),
  - `/search` now shows body content from `content/search.md` when served by updated Notepub.
- Fixed search page card presentation regression:
  - server-rendered `/search` results now use the same card structure/classes as modal results (`np-search-item-card`), preserving thumbnail/title/snippet visual style before JS enhancement.
- Changed `/search` UX: removed visible `Query: ...` summary text under the search input.
- Improved technical SEO meta generation in theme layout:
  - `twitter:image` now mirrors resolved OpenGraph image.
  - `og:image` now consistently uses engine-resolved `og:image` when present (not only for `article` pages).
- Fixed CI notepub binary pinning:
  - switched GitHub Actions workflows from non-existent `v0.1.5` to existing `v0.1.4`,
  - hardened binary download with `curl -fL` so invalid release URLs fail fast.

### Changed

- Improved Obsidian-first onboarding in `README.md`, `README.ru.md`, and `content/getting-started.md`.
- Documented explicit user flow (`Use this template -> clone -> Obsidian vault -> edit content -> push -> Pages deploy`).
- Documented that `.np/` and `.notepub/` should stay outside the regular authoring workflow.
- Added release-quality workflow `.github/workflows/quality-gate.yml` with matrix checks:
  - `compat_mode`: `auto|modern|legacy`
  - notes mode: `present|absent`
  - source mode: `local|s3` (S3 config compatibility gate)
- Updated release checklist and deploy docs with the new matrix gate requirement.
- Added `content/release-gate.md` as a single source of truth for release readiness criteria.

## 2026-04-24

### Changed

- GitHub Pages base URL is now inferred during CI builds, so template users do not need to edit `.np/config.yaml` after creating a repository.
- GitHub Pages builds now prefer the official `actions/configure-pages` `base_url` output before falling back to `CNAME` or repository-name inference.
- Production builds now generate `.np/config.resolved.yaml` with resolved site/media URLs so asset links stay correct across older and newer Notepub binaries.
- Root `CNAME` files are now used to infer custom-domain production URLs and are copied into the Pages artifact.
- Added responsive video styling so embedded videos fill the content width.
- Added root `Site.md` and `Interface.md` notes for Obsidian-editable basic site settings, theme accent/font/radius, and interface labels.
- Moved default site images referenced by `Site.md` into `media/` and added separate `theme_link` color customization.
- Removed legacy local/preview/runtime config files in favor of the single `.np/config.yaml`.
- Added generated effective settings during build, so `Site.md` and `Interface.md` are optional and `.np/config.yaml` can be used directly.
- Added build-time fallback handling for favicon, PWA manifest icons, `site.webmanifest`, `llms.txt`, and `llms-full.txt`.
- Moved footer ownership fully to `content/footer.md`; footer text is no longer configured through `Interface.md` or generated settings.
- Moved remaining visible template labels and section headings into `Interface.md` and generated settings.
- Added optional custom CSS font stacks and HTTPS web font stylesheet URL support in `Site.md`.
- Simplified user-facing icon settings to a single `site_icon` field, deriving favicon and manifest icons from it by default.
- Updated CI to use Notepub `v0.1.5`, which is required for note-based settings.

## 2026-04-23

### Changed

- Build pipeline migrated to engine-native Obsidian support:
  - removed markdown normalization step from local build and CI workflow
  - removed dependency on `normalize-obsidian-embeds.sh`
- Added markdown diagnostics to template build flow:
  - `notepub validate --links`
  - `notepub validate --markdown`
- Switched URL handling to runtime mode strategy:
  - local preview uses `runtime.mode=dev`
  - GitHub Pages publish config uses `runtime.mode=prod` with computed base/media URLs
- Updated documentation (`README.md`, `README.ru.md`) to match the new workflow and engine behavior.
- Updated content docs to reflect current Obsidian capabilities and deployment flow.
