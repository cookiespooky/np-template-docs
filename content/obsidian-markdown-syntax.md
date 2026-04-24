---
type: article
slug: obsidian-markdown-syntax
title: Obsidian Markdown Syntax Reference
description: Syntax test page with explicit support status for this Notepub template.
hub:
  - "authoring"
order: 99
related:
  - "links-and-wikilinks"
  - "content-model"
image: /media/notepub_cover.png
---
# Obsidian Markdown Syntax Reference

This page is a practical test for markdown generation in this template.

## Support status in this template

- `Rendered correctly`: CommonMark + GFM + Obsidian wikilinks/embeds + callouts + footnotes + math wrappers.
- `Partially supported`: some Obsidian-specific extensions (see section below).

## Rendered correctly

### Headings

# H1 Heading
## H2 Heading
### H3 Heading
#### H4 Heading
##### H5 Heading
###### H6 Heading

### Paragraphs and line breaks

This is a paragraph with standard spacing.
This line stays in the same paragraph.

This is a new paragraph.  
Hard break line.

### Emphasis and inline styles

**Bold**, *italic*, and ***bold italic***.

~~Strikethrough~~ and `inline code`.

Escaped characters: \*not italic\*, \[not a link\], \#not-a-tag.

---

### Links

External link: [Notepub](https://cookiespooky.github.io/np/)

Auto-link: https://example.com/docs

Relative markdown link: [Getting Started](/getting-started)

Wikilink: [[Getting Started|Getting Started]]

Wikilink with alias: [[Build and Deploy|Build & Deploy Guide]]

Heading link: [[Getting Started#Next steps|Jump to Next steps section]]

### Images and embeds

Markdown image:

![Template cover](/media/notepub_cover.png)

Image embed result:

![](/media/notepub_cover.png)

Obsidian non-image embed (rendered as linked embed block):

![[Getting Started|Embedded Getting Started]]

### Lists

- Unordered list item
- Another item
  - Nested item
  - Nested item 2
    - Third level

1. Ordered item
2. Ordered item
   1. Nested ordered
   2. Nested ordered

- [ ] Open task
- [x] Done task
- [ ] Another open task

### Blockquotes and callouts

> Basic blockquote
>
> Multi-line quote.

> [!note] Callout title
> Callout content

> [!tip]+ Foldable callout (open)
> This block should be rendered as an expandable callout.

### Code blocks

```bash
./.np/scripts/preview.sh 9000
```

```js
function greet(name) {
  return `Hello, ${name}`;
}
```

```json
{
  "site": "np-template-docs",
  "mode": "test"
}
```

```yaml
runtime:
  mode: dev
```

### Footnotes and math wrappers

Footnote reference[^1]

[^1]: Footnote text

Inline math wrapper: $E = mc^2$

$$
\int_a^b f(x)\,dx = F(b) - F(a)
$$

### Tables

| Syntax | Example | Rendered |
|---|---|---|
| Bold | `**text**` | Yes |
| Wikilink | `[[Getting Started\|Getting Started]]` | Yes |
| Task list | `- [x]` | Yes |

| Left | Center | Right |
|:--|:--:|--:|
| a | b | c |
| 1 | 2 | 3 |

### Tags

Inline tags: #docs #obsidian #markdown #docs/markdown

## Partially supported / unsupported

The following syntax is Obsidian-specific and not fully supported:

```markdown
%% Obsidian comment %%

[[Getting Started#^block-id]]
![[Getting Started#^block-id]]
```

Block references (`#^...`) are detected by markdown diagnostics as unsupported.

## Mixed formatting paragraph

You can combine **bold**, *italic*, `code`, [links](https://example.com), and [[Getting Started|Wikilinks]] in one sentence.
