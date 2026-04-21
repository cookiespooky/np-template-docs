# Шаблон документации Notepub

Шаблон репозитория для создания и деплоя сайтов документации на Notepub + GitHub Pages.

## Возможности

- Документация в корне (`/` — главная страница docs)
- Навигация через хабы (sidebar)
- Контент в Markdown + frontmatter
- Страница поиска и модальный поиск
- Базовое SEO: sitemap, robots, OpenGraph, JSON-LD
- Брендинг из контента и конфига:
  - имя бренда в header берется из `content/home.md` (`title`)
  - логотип бренда берется из `site.default_og_image` в `config.yaml`
- `llms.txt` и `llms-full.txt` для LLM-индексации
- GitHub Actions workflow для автодеплоя

## Как использовать шаблон

1. Нажмите **Use this template** в GitHub.
2. Создайте новый репозиторий.
3. Пушьте изменения в `main`.
4. В **Settings -> Pages** выберите источник **GitHub Actions**.
5. Дождитесь завершения workflow `Deploy Docs Template to GitHub Pages`.

Workflow сам вычисляет `base_url` из URL репозитория и публикует `dist/`.

## Структура контента

- `content/home.md` — главная страница документации (`/`)
- `content/*.md` — страницы, хабы и статьи
- немаркдаун-файлы в `content/` считаются медиа и экспортируются в `/media/*`

Минимальный frontmatter:

```yaml
type: article
slug: configuration
title: Configuration
description: Key settings in config.yaml and rules.yaml.
hub: [reference]
order: 10
```

## Локальная разработка

Рекомендуемая версия движка (как в CI):

`NOTEPUB_VERSION=v0.1.3`

Скачайте бинарник `notepub` из GitHub Releases:

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

Сборка через helper-скрипт (macOS/Linux или Windows через Git Bash/WSL):

```bash
NOTEPUB_BIN=./notepub ./scripts/build.sh
```

Поддерживаются Obsidian image-embed:

- вход: `![[cover.webp]]`
- нормализация: `![](/media/cover.webp)`
- экспорт: `dist/media/cover.webp`

Сборка на Windows без `bash`:

```powershell
.\notepub.exe index --config .\config.yaml --rules .\rules.yaml
.\notepub.exe build --config .\config.yaml --rules .\rules.yaml --artifacts .\.notepub\artifacts --dist .\dist
```

Локальный запуск статики:

```bash
python3 -m http.server 9000 -d dist
```

Откройте: `http://127.0.0.1:9000/`

## Что поменять после создания репозитория из шаблона

- `site.title` и `site.description` в `config.yaml`
- `site.media_base_url` в `config.yaml` (локально по умолчанию: `http://127.0.0.1:8080/media/`)
- `content/home.md` -> `title` (имя бренда в header)
- `site.default_og_image` в `config.yaml` (логотип бренда и дефолт OG image)
- плейсхолдеры в `theme/assets/llms.txt` и `theme/assets/llms-full.txt` (`<username>`, `<repo>`)
