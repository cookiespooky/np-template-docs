---
type: article
slug: content-model
title: Модель контента и frontmatter
description: Какие поля обязательны, какие опциональны и какие типы страниц есть в шаблоне.
draft: true
hub:
  - "concepts"
order: 10
related:
  - "configuration"
  - "getting-started"
  - "notepub-engine"
---

# Модель контента и frontmatter

Каждый markdown-файл — это страница с frontmatter и body.

Минимально обязательные поля frontmatter:

- `type`
- `slug`
- `title`

Опциональные поля, которые уже поддерживает шаблон:

- `description`
- `draft`
- `noindex`
- `hub`
- `related`
- `order`
- `tags`
- `jsonld`

Пример минимального frontmatter:

```yaml
---
type: article
slug: primer-stranicy
title: Пример страницы
---
```

Пример с расширенными полями:

```yaml
---
type: article
slug: primer-stranicy
title: Пример страницы
description: Короткое описание страницы для превью и SEO.
draft: false
noindex: false
hub: ["concepts"]
related: ["getting-started"]
order: 20
tags: ["docs", "template"]
---
```

## Типы страниц в этом шаблоне

- `home` — главная страница (`/`)
- `hub` — хаб-раздел, контейнер для материалов
- `article` — контентная страница внутри хаба
- `page` — обычная страница документации
- `search` — системная страница поиска (`/search/`)
- `footer` — системная страница футера (`/footer/`)

## Как это связано с шаблоном

- типы, permalink и правила включения в sitemap/search задаются в `.np/rules.yaml`
- связи между страницами строятся через `hub`, `related` и wikilinks `[[...]]`
- `draft: true` исключает страницу из публикации и из поиска
- `noindex: true` помечает страницу как неиндексируемую
