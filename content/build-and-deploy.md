---
type: article
slug: build-and-deploy
title: Сборка и деплой
description: Как шаблон собирается и деплоится через GitHub Actions.
draft: true
hub:
  - "operations"
order: 10
related:
  - "getting-started"
  - "configuration"
---

# Сборка и деплой

Базовый workflow:

1. Скачивает зафиксированный релиз бинарника Notepub.
2. Определяет источник контента (`local`, `content_repo`, или `s3`).
3. Запускает локальный конвейер шаблона (`validate -> index -> build`).
4. Публикует `.np/dist` в GitHub Pages.

Как обрабатываются URL:

- CI вычисляет итоговый URL GitHub Pages.
- Пайплайн формирует временный publish-конфиг с `runtime.mode: prod`.
- `runtime.prod.base_url` и `runtime.prod.media_base_url` подставляются в этот временный конфиг.

Markdown-контент в CI не переписывается.
Синтаксис Obsidian обрабатывается самим движком на этапе индексации и рендера.
