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
- URL-режим переведен на `runtime.mode: dev|prod` вместо патчинга `site.base_url`

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
2. `notepub validate --links`
3. `notepub validate --markdown`
4. `notepub index`
5. `notepub build`

Результат:

- основной: `.np/dist/`
- зеркальный: `dist/`

## Локальный предпросмотр

```bash
./.np/scripts/preview.sh
```

Свой порт:

```bash
./.np/scripts/preview.sh 8080
```

`preview.sh` генерирует временный конфиг с `runtime.mode=dev` и локальным `runtime.dev.base_url`.

## Деплой

Workflow `.github/workflows/deploy.yml` собирает и деплоит сайт автоматически.

URL для GitHub Pages вычисляется в workflow и подставляется в временный publish-конфиг через `runtime.prod.*`.

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
