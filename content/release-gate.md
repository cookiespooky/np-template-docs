---
type: article
slug: release-gate
title: Релизный гейт
description: CI-матрица и smoke-проверки, обязательные перед релизом документации.
draft: true
hub:
  - "ci-cd"
order: 15
related:
  - "release-checklist"
  - "build-and-deploy"
  - "workflow-structure"
---

# Релизный гейт

Используйте эту страницу как единый контракт релизной готовности шаблона.

## Обязательный CI-гейт

Файл workflow: `.github/workflows/quality-gate.yml`

Измерения матрицы:

- `compat_mode`: `auto`, `modern`, `legacy`
- режим заметок: `present`, `absent`
- режим источника: `local`, `s3`

Что проверяет каждая ось:

- `compat_mode` проверяет совместимость между modern и legacy-контрактами.
- режим заметок проверяет fallback-поведение при отсутствии `Site.md` и `Interface.md`.
- режим источника проверяет локальную сборку и совместимость S3 effective-config.

## Обязательные условия слияния

Релизный кандидат считается готовым только если выполнено всё:

- все задания матрицы в `quality-gate.yml` зелёные
- deploy-workflow умеет собрать текущий `main`
- нет блокирующих markdown-диагностик релизного контента
- в обсуждении PR нет нерешённых ручных релиз-блокеров

## Рекомендуемые smoke-проверки

После зелёного CI и до тега/анонса релиза:

- открыть главную и минимум по одной странице на каждый основной хаб
- проверить выдачу поиска для 2-3 типовых запросов
- проверить доступность sitemap/robots
- проверить рендер минимум одного изображения и одного видео-встраивания
- проверить canonical URL на нескольких страницах

## Команды для локального прогона

```bash
./.np/scripts/build.sh
```

```bash
NOTEPUB_BIN=/path/to/notepub /path/to/notepub validate --config ./.np/config.yaml --rules ./.np/rules.yaml --markdown --markdown-format text
```

## Связанные документы

- [[release-checklist|Чеклист релиза]]
- [[build-and-deploy|Сборка и деплой]]
- [[deployment-rollback|Откат деплоя]]
