---
type: article
slug: troubleshooting
title: Устранение проблем
description: Частые проблемы и практические решения.
hub:
  - "operations"
order: 20
related:
  - "build-and-deploy"
---

# Устранение проблем

Если стили не загружаются в GitHub Pages:

- проверьте, что workflow сформировал publish-конфиг с `runtime.mode: prod`
- проверьте, что вычисленный `runtime.prod.base_url` совпадает с вашим Pages URL
- убедитесь, что шаблоны используют `.AssetsBase` для статических ассетов

Если ссылки ломаются в project pages:

- избегайте жёстко заданных root-путей
- проверьте, что canonical/OG URL используют одинаковый runtime base URL

Если сборка падает на markdown-валидации:

- запустите `./.np/scripts/build.sh` локально
- посмотрите diagnostics от `validate --markdown`
- исправьте нерезолвленные wikilinks/embeds или неподдерживаемый синтаксис
