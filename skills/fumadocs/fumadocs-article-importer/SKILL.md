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
- **Jina API Key** configured (必需)
- `curl` installed for article fetch and image downloads
- Write access to `content/docs/` and `public/images/`

## Configuration

### Jina API Key 配置（必需）

**Step 1: 获取 API Key**

1. 访问 https://jina.ai/reader
2. 注册/登录账号
3. 在 Dashboard 生成 API Key（格式：`jina_xxxxxxxxxxxx`）

**Step 2: 配置到环境变量**

编辑 `~/.clawdbot/moltbot.json`：

```json
{
  "env": {
    "JINA_API_KEY": "jina_你的API_KEY"
  }
}
```

或添加到 `~/.openclaw/.env`：

```bash
JINA_API_KEY=jina_你的API_KEY
```

**Step 3: 验证配置**

```bash
# 测试 API 可用性
curl -s "https://r.jina.ai/https://example.com" \
  -H "Authorization: Bearer $JINA_API_KEY" | head -20
```

## Workflow

### Step 1: Get Article Info

Ask user:
1. Article URL
2. Target languages (default: en, zh, fr)
3. Image strategy (default: auto)

### Step 2: Fetch Article Content

**使用 Jina Reader API（curl 方式）**:

```bash
# 获取文章内容（Markdown 格式）
curl -s "https://r.jina.ai/{article_url}" \
  -H "Authorization: Bearer ${JINA_API_KEY}" \
  -o /tmp/article.md

# 检查获取结果
if [ ! -s /tmp/article.md ]; then
  echo "❌ 文章获取失败"
  exit 1
fi

echo "✅ 文章内容已获取"
head -20 /tmp/article.md
```

**提取图片 URL**:

```bash
# 从 Markdown 中提取所有图片 URL
grep -oE 'https://[^)]+\.(png|jpg|jpeg|webp|gif)' /tmp/article.md > /tmp/images.txt

# 统计图片数量
IMAGE_COUNT=$(wc -l < /tmp/images.txt)
echo "📊 发现 ${IMAGE_COUNT} 张图片"
```

**尝试提取发布日期（可选）**:

```bash
# 使用 Jina 的日期检测 API
curl -s "https://r.jina.ai/{article_url}" \
  -H "Authorization: Bearer ${JINA_API_KEY}" \
  -H "X-With-Generated-Summary: true" \
  | grep -oE 'Published:.*|Updated:.*' || echo "日期未找到"
```

### Step 3: Generate Slug

Create URL-friendly slug from title:
- Lowercase, hyphens for spaces
- Remove special characters
- Example: "Building Agents with Skills" → `building-agents-with-skills`

### Step 4: Process Images

**图片下载和重命名（重要！）**:

```bash
# 创建图片目录
mkdir -p public/images/docs/{slug}

# 下载图片（使用安全的文件名）
i=1
while IFS= read -r img_url; do
  # 使用 img01.png, img02.png 格式（避免连字符+数字）
  printf -v filename "img%02d.png" $i

  echo "下载: $img_url → $filename"
  curl -s -o "public/images/docs/{slug}/$filename" "$img_url"

  # 更新 Markdown 中的图片引用
  sed -i "s|$img_url|/images/docs/{slug}/$filename|g" /tmp/article.md

  ((i++))
done < /tmp/images.txt

echo "✅ 已下载 $((i-1)) 张图片"
```

**图片文件名规则（重要！）**:

```
❌ 错误：img-1.png, img-10.png（MDX 会解析 -1, -10 为表达式）
✅ 正确：img01.png, img10.png, openclaw01.png（无连字符）
```

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
