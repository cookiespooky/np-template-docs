(function () {
  var navPanel = document.querySelector('[data-nav-panel]');
  var navOpen = document.querySelector('[data-nav-open]');
  var navCloseBtns = document.querySelectorAll('[data-nav-close]');
  var header = document.querySelector('.site-header');
  var root = document.documentElement;
  var body = document.body;
  var lockedScrollY = 0;

  function label(key, fallback) {
    var labels = window.__notepubLabels || {};
    return labels[key] || fallback;
  }

  function lockBodyScroll() {
    if (!body || body.classList.contains('nav-locked')) return;
    lockedScrollY = window.scrollY || window.pageYOffset || 0;
    if (root) root.classList.add('nav-locked');
    body.style.top = '-' + lockedScrollY + 'px';
    body.style.position = 'fixed';
    body.style.left = '0';
    body.style.right = '0';
    body.style.width = '100%';
    body.classList.add('nav-locked');
  }

  function unlockBodyScroll() {
    if (!body || !body.classList.contains('nav-locked')) return;
    if (root) root.classList.remove('nav-locked');
    body.classList.remove('nav-locked');
    body.style.position = '';
    body.style.top = '';
    body.style.left = '';
    body.style.right = '';
    body.style.width = '';
    window.scrollTo(0, lockedScrollY);
  }

  function openNav() {
    if (!navPanel) return;
    navPanel.classList.add('is-open');
    navPanel.setAttribute('aria-hidden', 'false');
    lockBodyScroll();
    if (navOpen) {
      navOpen.classList.add('is-open');
      navOpen.setAttribute('aria-label', label('closeNavigation', navOpen.getAttribute('data-close-label') || ''));
    }
  }

  function closeNav() {
    if (!navPanel) return;
    navPanel.classList.remove('is-open');
    navPanel.setAttribute('aria-hidden', 'true');
    unlockBodyScroll();
    if (navOpen) {
      navOpen.classList.remove('is-open');
      navOpen.setAttribute('aria-label', label('openNavigation', navOpen.getAttribute('data-open-label') || ''));
    }
  }

  function toggleNav() {
    if (!navPanel) return;
    if (navPanel.classList.contains('is-open')) {
      closeNav();
    } else {
      openNav();
    }
  }

  function getBasePath() {
    try {
      var raw = window.__notepubBaseURL || '/';
      var path = new URL(raw, window.location.origin).pathname || '/';
      return path.replace(/\/+$/, '');
    } catch (_err) {
      return '';
    }
  }

  function withBasePath(path) {
    if (!path || path.charAt(0) !== '/') return path;
    if (path.indexOf('//') === 0 || path.charAt(1) === '#') return path;
    var basePath = getBasePath();
    if (!basePath) return path;
    if (path === basePath || path.indexOf(basePath + '/') === 0) return path;
    return basePath + path;
  }

  function normalizeRootLinks(scope) {
    var rootNode = scope || document;
    var links = rootNode.querySelectorAll('a[href^="/"]');
    links.forEach(function (link) {
      var href = link.getAttribute('href');
      var next = withBasePath(href);
      if (next && next !== href) {
        link.setAttribute('href', next);
      }
    });
  }

  function loadFooterFromNote() {
    var container = document.querySelector('[data-site-footer-content]');
    if (!container || typeof window.fetch !== 'function') return;

    var footerURL = withBasePath('/footer/');
    if (!footerURL) return;

    fetch(footerURL, { credentials: 'same-origin' })
      .then(function (response) {
        if (!response || !response.ok) return null;
        return response.text();
      })
      .then(function (html) {
        if (!html) return;
        var parser = new DOMParser();
        var doc = parser.parseFromString(html, 'text/html');
        if (!doc) return;

        var content = doc.querySelector('.content');
        if (!content) return;

        // Footer page uses the regular page template, which includes page hero
        // with H1/lead. Strip that block so footer renders body content only.
        var hero = content.querySelector('.page-hero');
        if (hero) hero.remove();

        container.innerHTML = content.innerHTML;
        normalizeRootLinks(container);
        markExternalLinks(container);
      })
      .catch(function () {
        // Keep fallback footer text when the footer page is unavailable.
      });
  }

  function atDocumentTop() {
    return (window.scrollY || window.pageYOffset || 0) <= 0;
  }

  function atDocumentBottom() {
    var doc = document.documentElement;
    if (!doc) return false;
    var scrollTop = window.scrollY || window.pageYOffset || 0;
    return scrollTop + window.innerHeight >= doc.scrollHeight - 1;
  }

  function canSidebarScroll(sidebar, deltaY) {
    if (!sidebar) return false;
    if (sidebar.scrollHeight <= sidebar.clientHeight) return false;
    if (deltaY > 0) return sidebar.scrollTop + sidebar.clientHeight < sidebar.scrollHeight - 1;
    if (deltaY < 0) return sidebar.scrollTop > 0;
    return false;
  }

  function enableSidebarScrollChaining() {
    window.addEventListener('wheel', function (event) {
      if (!event || typeof event.deltaY !== 'number') return;
      if (window.matchMedia && window.matchMedia('(max-width: 820px)').matches) return;

      var deltaY = event.deltaY;
      if (deltaY === 0) return;

      var sidebar = document.querySelector('.sidebar');
      if (!sidebar) return;

      var shouldChainDown = deltaY > 0 && atDocumentBottom();
      var shouldChainUp = deltaY < 0 && atDocumentTop();
      if (!shouldChainDown && !shouldChainUp) return;
      if (!canSidebarScroll(sidebar, deltaY)) return;

      sidebar.scrollTop += deltaY;
      event.preventDefault();
    }, { passive: false });
  }

  function markExternalLinks(scope) {
    var rootNode = scope || document;
    var links = rootNode.querySelectorAll('a[href]');
    if (!links.length) return;
    links.forEach(function (link) {
      if (link.dataset.externalMarked === '1') return;
      link.dataset.externalMarked = '1';
      var href = link.getAttribute('href') || '';
      if (!href || href.indexOf('#') === 0 || href.indexOf('mailto:') === 0 || href.indexOf('tel:') === 0) return;
      var url;
      try {
        url = new URL(href, window.location.href);
      } catch (_err) {
        return;
      }
      if (url.origin !== window.location.origin) {
        link.target = '_blank';
        link.rel = 'noopener noreferrer';
        if (link.closest('.content')) {
          link.classList.add('is-external');
        }
      }
    });
  }

  function initHeadingAnchors(scope) {
    var rootNode = scope || document;
    var headings = rootNode.querySelectorAll('.content h1, .content h2, .content h3, .content h4, .content h5, .content h6');
    if (!headings.length) return;

    function slugify(text) {
      return (text || '')
        .toLowerCase()
        .trim()
        .replace(/&/g, ' and ')
        .replace(/[^a-z0-9\s-]/g, ' ')
        .replace(/\s+/g, '-')
        .replace(/-+/g, '-')
        .replace(/^-|-$/g, '');
    }

    var used = Object.create(null);
    headings.forEach(function (h) {
      if (h.id) {
        used[h.id] = true;
        return;
      }
      var base = slugify(h.textContent || '');
      if (!base) return;
      var id = base;
      var n = 2;
      while (used[id] || document.getElementById(id)) {
        id = base + '-' + n;
        n += 1;
      }
      h.id = id;
      used[id] = true;
    });
  }

  function parseNpEmbedConfig(raw) {
    var config = {};
    if (!raw) return config;
    raw.split(/\r?\n/).forEach(function (line) {
      var trimmed = line.trim();
      if (!trimmed) return;
      var idx = trimmed.indexOf(':');
      if (idx <= 0) return;
      var key = trimmed.slice(0, idx).trim().toLowerCase();
      var value = trimmed.slice(idx + 1).trim();
      if (!value) return;
      config[key] = value;
    });
    return config;
  }

  function initMarkdownEmbeds(scope) {
    var rootNode = scope || document;
    var blocks = rootNode.querySelectorAll('pre > code.language-np-embed');
    if (!blocks.length) return;

    blocks.forEach(function (code) {
      var pre = code.parentElement;
      if (!pre || pre.dataset.embedInited === '1') return;
      pre.dataset.embedInited = '1';

      var cfg = parseNpEmbedConfig(code.textContent || '');
      var id = (cfg.id || '').toLowerCase();
      if (!/^[a-z0-9-]+$/.test(id)) return;

      var title = cfg.title || ('Embed: ' + id);
      var src = withBasePath('/assets/animations/' + id + '/index.html?motion=on');

      var wrapper = document.createElement('div');
      wrapper.className = 'np-embed';

      var iframe = document.createElement('iframe');
      iframe.className = 'np-embed-frame';
      iframe.src = src;
      iframe.title = title;
      iframe.loading = 'lazy';
      iframe.referrerPolicy = 'no-referrer';
      iframe.sandbox = 'allow-scripts allow-same-origin';
      iframe.style.width = '100%';
      iframe.style.aspectRatio = '1 / 1';
      iframe.style.border = 'none';
      iframe.style.display = 'block';
      iframe.style.background = '#fff';

      wrapper.appendChild(iframe);
      pre.replaceWith(wrapper);
    });
  }

  function initMathRendering(scope) {
    if (!window.katex) return;
    var rootNode = scope || document;
    var nodes = rootNode.querySelectorAll('.math-inline, .math-block');
    if (!nodes.length) return;

    nodes.forEach(function (node) {
      if (!node || node.dataset.mathRendered === '1') return;
      var source = (node.textContent || '').trim();
      if (!source) return;
      try {
        window.katex.render(source, node, {
          throwOnError: false,
          strict: 'ignore',
          displayMode: node.classList.contains('math-block')
        });
        node.dataset.mathRendered = '1';
      } catch (_err) {
        // Keep original text fallback when rendering fails.
      }
    });
  }

  function scheduleMathRendering(scope) {
    var rootNode = scope || document;

    if (window.katex) {
      initMathRendering(rootNode);
      return;
    }

    var attempts = 0;
    var maxAttempts = 40;
    var pollDelayMs = 100;
    var timerId = window.setInterval(function () {
      attempts += 1;
      if (window.katex) {
        window.clearInterval(timerId);
        initMathRendering(rootNode);
        return;
      }
      if (attempts >= maxAttempts) {
        window.clearInterval(timerId);
      }
    }, pollDelayMs);

    window.addEventListener('load', function () {
      initMathRendering(rootNode);
    }, { once: true });
  }

  function normalizeCodeLanguage(raw) {
    var lang = (raw || '').toLowerCase().trim();
    if (!lang) return '';

    var aliases = {
      js: 'javascript',
      jsx: 'javascript',
      ts: 'typescript',
      tsx: 'typescript',
      sh: 'bash',
      shell: 'bash',
      zsh: 'bash',
      yml: 'yaml',
      md: 'markdown',
      py: 'python',
      rb: 'ruby',
      rs: 'rust',
      cs: 'csharp',
      'c#': 'csharp',
      html: 'xml'
    };

    return aliases[lang] || lang;
  }

  function detectCodeLanguage(codeNode) {
    if (!codeNode || !codeNode.classList) return '';
    var classes = Array.prototype.slice.call(codeNode.classList);
    var rawLang = '';

    classes.some(function (className) {
      if (className.indexOf('language-') === 0) {
        rawLang = className.slice('language-'.length);
        return true;
      }
      if (className.indexOf('lang-') === 0) {
        rawLang = className.slice('lang-'.length);
        return true;
      }
      return false;
    });

    return normalizeCodeLanguage(rawLang);
  }

  function initCodeHighlighting(scope) {
    var rootNode = scope || document;
    var blocks = rootNode.querySelectorAll('.content pre > code');
    if (!blocks.length) return;

    blocks.forEach(function (code) {
      var pre = code.parentElement;
      if (!pre) return;
      pre.classList.add('code-block');

      var lang = detectCodeLanguage(code);
      pre.setAttribute('data-code-lang', lang || 'text');

      if (pre.dataset.codeHighlighted === '1') {
        return;
      }

      if (!window.hljs || !lang || !window.hljs.getLanguage(lang)) {
        return;
      }

      try {
        window.hljs.highlightElement(code);
        pre.dataset.codeHighlighted = '1';
      } catch (_err) {
        // Keep source code as-is when highlighting fails.
      }
    });
  }

  function scheduleCodeHighlighting(scope) {
    var rootNode = scope || document;

    if (window.hljs) {
      initCodeHighlighting(rootNode);
      return;
    }

    var attempts = 0;
    var maxAttempts = 40;
    var pollDelayMs = 100;
    var timerId = window.setInterval(function () {
      attempts += 1;
      if (window.hljs) {
        window.clearInterval(timerId);
        initCodeHighlighting(rootNode);
        return;
      }
      if (attempts >= maxAttempts) {
        window.clearInterval(timerId);
        initCodeHighlighting(rootNode);
      }
    }, pollDelayMs);

    window.addEventListener('load', function () {
      initCodeHighlighting(rootNode);
    }, { once: true });
  }

  function initAnalytics() {
    var cfg = window.__npRuntimeConfig && window.__npRuntimeConfig.analytics;
    if (!cfg || !cfg.enabled) return;

    if (cfg.provider === 'yandex_metrika' && cfg.yandexCounterId) {
      var id = String(cfg.yandexCounterId).trim();
      if (!id) return;
      if (window.ym) return;

      (function (m, e, t, r, i, k, a) {
        m[i] = m[i] || function () {
          (m[i].a = m[i].a || []).push(arguments);
        };
        m[i].l = 1 * new Date();
        k = e.createElement(t);
        a = e.getElementsByTagName(t)[0];
        k.async = 1;
        k.src = r;
        a.parentNode.insertBefore(k, a);
      })(window, document, 'script', 'https://mc.yandex.ru/metrika/tag.js', 'ym');

      window.ym(id, 'init', {
        clickmap: true,
        trackLinks: true,
        accurateTrackBounce: true,
        webvisor: true
      });
    }
  }

  function initRecursiveSidebarTree() {
    var groupsRoot = document.getElementById('np-nav-groups');
    if (!groupsRoot) return;

    var groupsByParent = Object.create(null);
    var groupNodes = groupsRoot.querySelectorAll('[data-group]');
    groupNodes.forEach(function (groupNode) {
      var key = groupNode.getAttribute('data-group') || '';
      if (!key) return;
      var items = [];
      var rawItems = groupNode.querySelectorAll('span[data-slug]');
      rawItems.forEach(function (node) {
        items.push({
          slug: node.getAttribute('data-slug') || '',
          title: node.getAttribute('data-title') || '',
          path: node.getAttribute('data-path') || '',
          type: node.getAttribute('data-type') || ''
        });
      });
      groupsByParent[key] = items;
    });

    var currentPath = window.location.pathname.replace(/\/+$/, '') || '/';

    function normalizePath(path) {
      return (path || '').replace(/\/+$/, '') || '/';
    }

    function makeInternalHref(path) {
      var clean = (path || '').replace(/^\/+/, '');
      return withBasePath('/' + clean);
    }

    function isActivePath(path) {
      return normalizePath(path) === normalizePath(currentPath);
    }

    function renderChildren(containerEl, parentSlug, seen) {
      var children = groupsByParent[parentSlug] || [];
      if (!children.length) return;
      if (seen[parentSlug]) return;
      seen[parentSlug] = true;

      var ul = document.createElement('ul');
      ul.className = 'sidebar-sublist';

      children.forEach(function (item) {
        if (!item || !item.slug || item.slug === 'footer') return;

        var li = document.createElement('li');
        var a = document.createElement('a');
        var href = makeInternalHref(item.path);
        a.href = href;
        a.textContent = item.title || item.slug;
        if (isActivePath(new URL(href, window.location.origin).pathname)) {
          a.classList.add('is-active');
        }

        li.appendChild(a);

        if (item.type === 'hub') {
          var nextSeen = Object.create(null);
          Object.keys(seen).forEach(function (k) { nextSeen[k] = seen[k]; });
          renderChildren(li, item.slug, nextSeen);
        }

        ul.appendChild(li);
      });

      if (ul.children.length > 0) {
        containerEl.appendChild(ul);
      }
    }

    var hubNodes = document.querySelectorAll('[data-nav-hub-node][data-slug]');
    hubNodes.forEach(function (hubNode) {
      var slug = hubNode.getAttribute('data-slug') || '';
      if (!slug) return;
      renderChildren(hubNode, slug, Object.create(null));
    });
  }

  if (navOpen) navOpen.addEventListener('click', toggleNav);
  navCloseBtns.forEach(function (btn) { btn.addEventListener('click', closeNav); });

  if (navPanel) {
    navPanel.addEventListener('click', function (event) {
      var target = event.target;
      if (!target) return;
      var link = target.closest('a');
      if (!link) return;
      closeNav();
    });
  }

  if (header) {
    header.addEventListener('click', function (event) {
      var target = event.target;
      if (!target) return;
      var button = target.closest('a, button');
      if (!button) return;
      if (button.hasAttribute('data-nav-open')) return;
      closeNav();
    });
  }

  normalizeRootLinks(document);
  loadFooterFromNote();
  initRecursiveSidebarTree();
  enableSidebarScrollChaining();
  initMarkdownEmbeds(document.querySelector('main') || document);
  scheduleCodeHighlighting(document.querySelector('main') || document);
  scheduleMathRendering(document.querySelector('main') || document);
  initHeadingAnchors(document.querySelector('main') || document);
  markExternalLinks(document);
  initAnalytics();

  function setHeaderHeight() {
    if (!header) return;
    document.documentElement.style.setProperty('--header-height', header.offsetHeight + 'px');
  }

  setHeaderHeight();
  window.addEventListener('resize', setHeaderHeight);
  window.addEventListener('keydown', function (event) {
    if (event.key === 'Escape') closeNav();
  });
})();
