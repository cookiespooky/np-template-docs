# Changelog

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
