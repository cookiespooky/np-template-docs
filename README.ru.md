# NP Template Docs

Шаблон репозитория документации на Notepub.

Последние изменения фиксируются в [CHANGELOG.md](./CHANGELOG.md).

## Структура

- `content/` - пользовательский контент (Markdown)
- `media/` - опциональные медиа
- `.np/` - техническая часть (`config`, `rules`, `theme`, `scripts`, output dirs)
- `.github/workflows/` - CI/CD деплой в GitHub Pages

Формат удобен для Obsidian: основная работа идет в `content/` и `media/`.

## Что обновлено под новый движок

- из пайплайна убрана перезапись markdown-файлов
- Obsidian-синтаксис обрабатывается в движке напрямую (`[[...]]`, `![[...]]`, callouts, footnotes, math)
- markdown-диагностика встроена в локальную сборку и CI (`validate --markdown`)
- URL-режим переведен на `runtime.mode: auto|dev|prod`, production URL вычисляется в CI

## Локальная сборка

```bash
./.np/scripts/build.sh
```

Если нет `.np/bin/notepub`:

```bash
NOTEPUB_BIN=/path/to/notepub ./.np/scripts/build.sh
```

Скрипт сборки выполняет:

1. генерацию runtime-конфига (опционально, для аналитики)
2. `notepub index`
3. `notepub validate --links`
4. `notepub validate --markdown`
5. `notepub build`

Результат:

- основной: `.np/dist/`
- зеркальный: `dist/`

## Локальный предпросмотр

```bash
NOTEPUB_BIN=/path/to/notepub /path/to/notepub serve --config ./.np/config.yaml --rules ./.np/rules.yaml
```

С `runtime.mode: auto` локальный запуск автоматически использует dev URL.

## Деплой

Workflow `.github/workflows/deploy.yml` собирает и деплоит сайт автоматически.

После создания репозитория из шаблона `.np/config.yaml` править не нужно.
Во время GitHub Actions сборки `.np/scripts/build.sh` вычисляет GitHub Pages URL из `GITHUB_REPOSITORY`:

- `owner.github.io` -> `https://owner.github.io/`
- любой другой репозиторий -> `https://owner.github.io/repository/`

URL передается в Notepub через environment override:

- `NOTEPUB_BASE_URL`
- `NOTEPUB_MEDIA_BASE_URL`

Для кастомного домена задайте repository variables с теми же именами.

## Где настраивать

- конфиг сайта/runtime: `.np/config.yaml`
- правила роутинга/модели: `.np/rules.yaml`
- шаблоны/ассеты: `.np/theme/`
- контент футера: `content/footer.md`

## Опциональная аналитика

В `.np/config.yaml`:

```yaml
site:
  analytics:
    enabled: false
    provider: "yandex_metrika"
    yandex_counter_id: ""
```

При `enabled: true` runtime JS-конфиг генерируется на сборке и подключается на фронтенде.
