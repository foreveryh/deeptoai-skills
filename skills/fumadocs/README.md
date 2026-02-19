# Fumadocs 文档自动化发布

完整的内容导入 → 翻译 → 发布工作流。

## 📦 包含的 Skills

| Skill | 用途 | 使用频率 |
|-------|------|---------|
| **fumadocs-article-importer** | 导入外部文章 + 图片 | 每次导入 |
| **article-translator** | MDX 文档翻译 | 每次翻译 |
| **mdx-article-publisher** | 验证 + 提交 + 推送 | 每次发布 |
| **fumadocs-i18n-setup** | i18n 配置 | 仅一次 |

## 🔄 完整工作流

```
场景 1：导入外部文章

外部 URL
    ↓
fumadocs-article-importer  ──→  下载文章 + 图片
    ↓                            转换为 MDX
article-translator  ──────────→  翻译到 en/zh/fr
    ↓
mdx-article-publisher  ───────→  验证 + 推送


场景 2：为自己的 skill 写文档

你的 Skill
    ↓
skill-article-writer  ────────→  分析 + 创作教程
    ↓                            (在 general/ 目录)
article-translator  ──────────→  翻译
    ↓
mdx-article-publisher  ───────→  发布
```

## 📋 前置配置

### 1. Jina MCP（必需）

编辑 `~/.clawdbot/moltbot.json`：

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

获取 API Key: https://jina.ai/reader

### 2. Git 配置（必需）

```bash
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
```

## 🎯 快速开始

### 导入一篇文章

```
用户: 帮我导入这篇文章 https://example.com/article
AI: [使用 fumadocs-article-importer]
    ↓ 下载文章内容
    ↓ 下载图片
    ↓ 自动分类
    ↓ [使用 article-translator] 翻译
    ↓ [使用 mdx-article-publisher] 发布
```

### 首次配置 i18n

```
用户: 帮我配置 Fumadocs 多语言支持
AI: [使用 fumadocs-i18n-setup]
    ↓ 创建语言配置
    ↓ 配置路由
    ↓ 添加语言切换器
```

## 📁 输出目录结构

```
content/docs/
├── en/
│   └── ai-ml/
│       └── article-slug.mdx
├── zh/
│   └── ai-ml/
│       └── article-slug.mdx
└── fr/
    └── ai-ml/
        └── article-slug.mdx

public/images/docs/article-slug/
├── image1.png
└── image2.png
```

## ⚠️ 注意事项

- `fumadocs-i18n-setup` 是**一次性配置**，项目已有 i18n 则不需要
- `article-translator` 会保留代码块和技术术语
- `mdx-article-publisher` 支持多种项目（Fumadocs、Next.js、Docusaurus）

## 🔗 相关 Skills

- **philosophical-illustrator** (general/) - 为文章生成 SVG 插图
- **skill-article-writer** (general/) - 分析 skill 并创作教程
