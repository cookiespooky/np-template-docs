# NP Template Docs

Шаблон репозитория документации на Notepub.

Последние изменения фиксируются в [CHANGELOG.md](./CHANGELOG.md).

## Структура

- `content/` - пользовательский контент (Markdown)
- `media/` - опциональные медиа
- `Site.md` - базовые настройки сайта, редактируемые в Obsidian
- `Interface.md` - базовые тексты интерфейса, редактируемые в Obsidian
- `.np/` - техническая часть (`config`, `rules`, `theme`, `scripts`, output dirs)
- `.github/workflows/` - CI/CD деплой в GitHub Pages

Формат удобен для Obsidian: основная работа идет в `content/`, `media/`, `Site.md` и `Interface.md`.

## Быстрый пользовательский путь (Obsidian-first)

1. Нажмите **Use this template** на GitHub и создайте репозиторий.
2. Клонируйте репозиторий на компьютер.
3. Откройте папку репозитория как vault в Obsidian.
4. В Obsidian отключите показ скрытых файлов, чтобы `.np/` и `.notepub/` не мешали редактору.
5. Редактируйте только `content/`, `media/`, `Site.md` и `Interface.md`.
6. Коммитьте и пушьте любым удобным Git-потоком (например через Obsidian Git plugin).
7. GitHub Actions собирает и публикует сайт в GitHub Pages.

## Что обновлено под новый движок

- из пайплайна убрана перезапись markdown-файлов
- Obsidian-синтаксис обрабатывается в движке напрямую (`[[...]]`, `![[...]]`, callouts, footnotes, math)
- markdown-диагностика встроена в локальную сборку и CI (`validate --markdown`)
- URL-режим переведен на `runtime.mode: auto|dev|prod`, production URL вычисляется в CI
- канонизация маршрутов в `serve` устойчиво обрабатывает варианты со слешем на конце (`/slug` и `/slug/`) с редиректом на канонический путь
- базовые настройки сайта и интерфейса читаются из корневых Obsidian-заметок и переопределяют `.np/config.yaml`
- логотип и дефолтная OG-картинка берутся из `media/`, поэтому видны в Obsidian
- `Site.md` и `Interface.md` опциональны; сборка генерирует безопасные effective settings из заметок, `.np/config.yaml` и дефолтов шаблона
- fallback-превью в поиске теперь использует `/assets/notepub.jpg`, чтобы не зависеть от allowlist `/media` для дефолтной картинки
- SEO-мета теперь включает и `og:image`, и `twitter:image` на основе резолвленного изображения страницы.

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

Дополнительный workflow качества `.github/workflows/quality-gate.yml` запускает матричные проверки перед merge в релизный поток:

- `compat_mode`: `auto`, `modern`, `legacy`
- режим заметок: `present`, `absent`
- режим источника: `local`, `s3` (проверка совместимости конфига)

Критерии релизной готовности описаны в `content/release-gate.md`.

После создания репозитория из шаблона `.np/config.yaml` править не нужно.
Во время GitHub Actions сборки `.np/scripts/build.sh` сначала проверяет корневой файл `CNAME`.
Если `CNAME` есть, кастомный домен становится production base URL и копируется в Pages artifact.

Workflow также передает в сборку официальный `base_url` из `actions/configure-pages`. Это основной источник URL для GitHub Pages project sites и кастомных доменов.

Без Pages URL и без `CNAME` скрипт вычисляет GitHub Pages URL из `GITHUB_REPOSITORY`:

- `owner.github.io` -> `https://owner.github.io/`
- любой другой репозиторий -> `https://owner.github.io/repository/`

URL передается в Notepub через environment override:

- `NOTEPUB_BASE_URL`
- `NOTEPUB_MEDIA_BASE_URL`

Когда production URL известен, скрипт сборки также пишет `.np/config.resolved.yaml` с уже заданными `site.base_url` и `site.media_base_url`. Это сохраняет корректные URL ассетов даже со старыми бинарями Notepub.

Repository variables с теми же именами остаются ручным override для обоих режимов.

## Где настраивать

- пользовательские настройки сайта: `Site.md`
- пользовательские тексты интерфейса: `Interface.md`
- технический fallback-конфиг сайта/runtime: `.np/config.yaml`
- правила роутинга/модели: `.np/rules.yaml`
- шаблоны/ассеты: `.np/theme/`
- контент футера: `content/footer.md`

Контент футера настраивается только в `content/footer.md`. Он не задаётся через `Interface.md` или `.np/config.yaml`.

`Site.md` и `Interface.md` можно удалить. Если заметок нет или в них указаны несуществующие картинки/иконки, `.np/scripts/build.sh` берёт значения из блока `settings:` в `.np/config.yaml`, а затем из дефолтов темы. На сборке временные effective notes создаются в `.np/generated/`, затем формируется `.np/config.generated.yaml`, и именно этот конфиг передаётся в Notepub.

В режиме `CONTENT_SOURCE=s3` CI формирует `.np/config.effective.yaml` с `content.source: "s3"` и top-level блоком `s3:`, совместимым с загрузкой конфига Notepub.

Для шрифтов доступны простые пресеты `system`, `inter`, `serif`, `mono`. Продвинутый режим позволяет указать CSS font stack:

```yaml
theme_font_stack: IBM Plex Sans, Arial, sans-serif
theme_heading_font_stack: IBM Plex Serif, Georgia, serif
theme_font_url: https://fonts.googleapis.com/css2?family=IBM+Plex+Sans:wght@400;600&display=swap
```

Невалидный font stack или не-HTTPS URL откатывается к выбранному пресету.

Иконки намеренно упрощены для обычного пользователя:

```yaml
site_icon: /media/notepub.png
```

Сборка использует `site_icon` для favicon, Apple touch icon и manifest icons. Если нужен точный контроль, dev-пользователь может править `.np/theme/assets/site.webmanifest` или добавить advanced icon fields в `.np/config.yaml settings:`.

Опциональные LLM-файлы:

- `LLMS.md` -> `llms.txt`
- `LLMS.full.md` -> `llms-full.txt`

Если файлов нет или они пустые, используются дефолты из `.np/theme/assets/`.

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
