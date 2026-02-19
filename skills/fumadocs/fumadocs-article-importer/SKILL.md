---
name: fumadocs-article-importer
description: >
  Import external articles into a Fumadocs project with automatic multi-language
  translation (en, zh, fr), AI-powered classification into 8 categories,
  image processing, and MDX conversion. Use this skill when the user wants to
  import an article from a URL into their Fumadocs documentation site.
---

# Fumadocs Article Importer

Import external articles into a Fumadocs project with tri-language support (en, zh, fr), auto-classification, and proper MDX formatting.

## Prerequisites

- Fumadocs project initialized
- **Jina MCP** configured (recommended) - see `references/jina-mcp-setup.md`
- **Translator Skill** available for professional translation
- `curl` installed for image downloads
- Write access to `content/docs/` and `public/images/`

## Critical Requirements

### 0. Jina MCP Configuration (必需)

**需要 Jina API Key** - 在 skill 执行前必须配置！

#### 获取 API Key

1. 访问 https://jina.ai/reader
2. 注册/登录账号
3. 在 Dashboard 生成 API Key（格式：`jina_xxxxxxxxxxxx`）

#### 配置到 Moltbot

编辑 `~/.clawdbot/moltbot.json`，添加 MCP Server：

```json
{
  "mcpServers": {
    "jina": {
      "url": "https://mcp.jina.ai/sse",
      "headers": {
        "Authorization": "Bearer jina_你的API_KEY"
      }
    }
  }
}
```

#### 验证配置

重启 Gateway 后，Jina MCP 的 `read_url` 工具应该可用：

```
moltbot gateway restart
```

#### 可用工具

- `read_url` - 网页 → Markdown (主工具)
- `guess_datetime_url` - 提取发布日期
- `search_web` - 网页搜索
- `parallel_read_url` - 批量读取

### 1. Image Extraction

**MUST use `withAllImages: true`** when fetching articles:

```typescript
Tool: read_url
Parameters:
  url: {article_url}
  withAllImages: true  // ← MANDATORY
```

### 2. Image Storage Strategy

**Option A (Default): Download to Local**
- Path: `public/images/docs/{slug}/`
- Use when: Source doesn't support CORS, need offline availability

**Option B: Use External URLs**
- Keep original URLs in article
- Use when: Source supports CORS (test with `curl -I`)

### 3. Always Validate Images

After fetching, verify `response.images` exists before proceeding.

## Workflow

### Step 1: Get Article Info

Ask user:
1. Article URL
2. Target languages (default: en, zh, fr)
3. Image strategy (default: auto)

### Step 2: Fetch Article Content

Use Jina MCP `read_url` tool:

```
Tool: read_url
Parameters:
  url: {article_url}
  withAllImages: true
```

**Validate**: Check `response.images` array exists.

### Step 3: Generate Slug

Create URL-friendly slug from title:
- Lowercase, hyphens for spaces
- Remove special characters
- Example: "Building Agents with Skills" → `building-agents-with-skills`

### Step 4: Process Images

For each image in `response.images`:

**If downloading (Option A)**:
```bash
curl -o "public/images/docs/{slug}/{image-filename}" "{image-url}"
```

**Update MDX image references**:
```mdx
![Alt text](/images/docs/{slug}/image.png)
```

**If using external URLs (Option B)**:
- Keep original URLs
- Verify CORS support first

### Step 5: Classify Article

Classify into one of 8 categories (see `references/classification-rules.md`):

| Category | Description |
|----------|-------------|
| `development` | Coding, APIs, frameworks |
| `ai-ml` | AI/ML topics, LLMs |
| `tools` | Developer tools, CLIs |
| `best-practices` | Patterns, methodologies |
| `architecture` | System design, infrastructure |
| `testing` | Testing, QA |
| `security` | Security practices |
| `general` | Everything else |

### Step 6: Create MDX Files

For each language, create MDX file:

**English**: `content/docs/en/{category}/{slug}.mdx`
**Chinese**: `content/docs/zh/{category}/{slug}.mdx`
**French**: `content/docs/fr/{category}/{slug}.mdx`

**Frontmatter template** (see `assets/frontmatter-template.yaml`):

```yaml
---
title: {translated_title}
description: {translated_description}
author: {original_author}
date: {publication_date}
lang: {en|zh|fr}
category: {category}
---
```

### Step 7: Translate Content

Use **article-translator skill** to translate:
1. Title and description
2. Article body (preserving code blocks, MDX syntax)
3. Image alt text

**Key rules**:
- Keep code blocks unchanged
- Preserve MDX component syntax
- Add space after `**bold**` in Chinese/Korean

### Step 8: Update Navigation

Update `content/docs/{lang}/meta.json`:

```json
{
  "title": "{Category Title}",
  "pages": ["existing-page", "{new-slug}"]
}
```

See `references/meta-json-best-practices.md` for details.

### Step 9: Generate Illustration (Optional)

Use **philosophical-illustrator skill** to create cover image:

```
Generate an 800x450px SVG illustration for: {article_title}
Theme: {category}
```

Save to: `public/images/docs/{slug}/cover.svg`

### Step 10: Validate and Report

1. Verify all files created correctly
2. Check MDX syntax compiles
3. Verify image paths resolve
4. Report summary to user

## Output Structure

```
content/docs/
├── en/{category}/{slug}.mdx
├── zh/{category}/{slug}.mdx
└── fr/{category}/{slug}.mdx

public/images/docs/{slug}/
├── image1.png
├── image2.png
└── cover.svg (optional)
```

## Error Handling

| Error | Solution |
|-------|----------|
| No images extracted | Verify `withAllImages: true` was used |
| CORS failure | Switch to download strategy |
| Translation failed | Check article-translator skill is available |
| Slug conflict | Append date suffix: `{slug}-2024-01-15` |

## References

- `references/classification-rules.md` - Category classification rules
- `references/fumadocs-components.md` - Available MDX components
- `references/meta-json-best-practices.md` - Navigation configuration
- `references/jina-mcp-setup.md` - Jina MCP configuration
- `assets/frontmatter-template.yaml` - Frontmatter template
