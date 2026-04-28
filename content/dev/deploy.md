---
type: article
slug: dev-deploy
title: Деплой и автоматизация
description: Как работает GitHub Pages, Actions и quality gate.
hub: ["dev"]
order: 30
related: ["dev-rules", "dev-config", "dev"]
---

# Деплой и автоматизация

В шаблоне используются:

- `.github/workflows/deploy.yml` для публикации в GitHub Pages
- `.github/workflows/quality-gate.yml` для матричных проверок

Поток обновления:

1. commit/push в `main`
2. автоматическая сборка
3. публикация артефакта в Pages

Если нужно менять механику деплоя, начинайте с workflow-файлов в `.github/workflows/`.
