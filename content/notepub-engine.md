---
type: article
slug: notepub-engine
title: Движок Notepub
description: Что делает движок, где его документация и с чего начать.
hub:
  - "concepts"
order: 30
related:
  - "getting-started"
  - "content-model"
  - "build-and-deploy"
---

# Движок Notepub

Этот шаблон собирается на движке **Notepub**.

Notepub отвечает за:

- индексацию markdown-контента (`notepub index`)
- валидацию ссылок и markdown-диагностику (`notepub validate`)
- статическую сборку сайта (`notepub build`)
- локальный сервер предпросмотра (`notepub serve`)

Официальные ссылки:

- сайт движка: [Notepub](https://cookiespooky.github.io/np/ru)
- раздел быстрого старта в документации движка: [Getting Started](https://cookiespooky.github.io/np/ru/docs/getting-started/)

## Что важно для пользователя шаблона

- в повседневной работе достаточно редактировать `content/`, `media/`, `Site.md`, `Interface.md`
- сборка и деплой уже настроены в GitHub Actions
- для расширений на уровне движка используйте `.np/config.yaml`, `.np/rules.yaml`, `.np/theme/`
