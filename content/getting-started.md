---
type: article
slug: getting-started
title: Быстрый старт (legacy)
description: Путь от Use this template до деплоя в GitHub Pages.
draft: true
order: 10
related:
  - "configuration"
  - "build-and-deploy"
  - "content-model"
  - "notepub-engine"
---

# Быстрый старт

Ниже минимальный путь запуска шаблона с нуля:

1. Нажмите **Use this template** на GitHub.
2. Создайте новый репозиторий из шаблона.
3. Клонируйте репозиторий на компьютер.
4. Откройте папку репозитория как vault в Obsidian.
5. В Obsidian отключите показ скрытых файлов, чтобы `.np/` и `.notepub/` не мешали авторингу.
6. Редактируйте контент в `content/`, `media/`, `Site.md`, `Interface.md`.
7. Делайте commit/push в `main` через любой Git-клиент, в том числе через Obsidian Git plugin.
8. GitHub Actions автоматически соберёт и опубликует сайт в GitHub Pages.

Технические файлы трогаются только при необходимости:

- `.np/config.yaml` для расширенных настроек
- `.np/rules.yaml` для правил модели и роутинга
- `.np/theme/` для кастомизации шаблона

## Что дальше

- [[content-model|Модель контента и frontmatter]]
- [[obsidian-markdown-syntax|Поддержка markdown и синтаксис Obsidian]]
- [[build-and-deploy|Сборка и деплой]]
- [[notepub-engine|Движок Notepub]]
