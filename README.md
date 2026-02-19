# deeptoai-skills 🦞

DeepToAI 团队制作的 Skills，用于 Fumadocs 文档自动化发布和通用内容创作。

English | [中文](README.zh.md)

## 📁 目录结构

```
skills/
├── fumadocs/                  # Fumadocs 文档自动化发布
│   ├── fumadocs-article-importer/  # ① 文章导入
│   ├── article-translator/         # ② 文章翻译
│   ├── mdx-article-publisher/      # ③ 发布验证
│   └── fumadocs-i18n-setup/        # i18n 配置（一次性）
│
└── general/                   # 通用工具
    ├── philosophical-illustrator/  # SVG 插图生成
    └── skill-article-writer/       # Skill 分析文章生成
```

## 🚀 Fumadocs 完整工作流

```
导入外部文章：
URL → fumadocs-article-importer → article-translator → mdx-article-publisher

创作 skill 文档：
Skill → skill-article-writer → article-translator → mdx-article-publisher
```

## 📦 安装

### 前置要求

- Node.js 环境
- OpenClaw 或 Claude Code 已安装

---

### 方式 1：快速安装（推荐）

安装所有 skills：

```bash
npx skills add foreveryh/deeptoai-skills
```

---

### 方式 2：注册为插件市场

在 Claude Code / OpenClaw 中运行：

```
/plugin marketplace add foreveryh/deeptoai-skills
```

然后浏览并安装：
1. 选择 **Browse and install plugins**
2. 选择 **deeptoai-skills**
3. 选择要安装的 **plugin**（fumadocs-skills 或 general-skills）
4. 点击 **Install now**

---

### 方式 3：单独安装特定 Plugin

```bash
# 安装 Fumadocs 自动化发布（4 个 skills）
/plugin install fumadocs-skills@deeptoai-skills

# 安装通用工具（2 个 skills）
/plugin install general-skills@deeptoai-skills
```

**Plugin 内容：**

| Plugin | 包含的 Skills |
|--------|--------------|
| **fumadocs-skills** | fumadocs-article-importer, article-translator, mdx-article-publisher, fumadocs-i18n-setup |
| **general-skills** | philosophical-illustrator, skill-article-writer |

---

### 方式 4：让 AI 安装

直接对 Claude Code / OpenClaw 说：

```
请安装 github.com/foreveryh/deeptoai-skills 的 Fumadocs skills
```

---

### 更新 Skills

```
/plugin
```
然后：
1. 切换到 **Marketplaces** 标签
2. 选择 **deeptoai-skills**
3. 选择 **Update marketplace**

或开启 **auto-update** 自动更新。

## 📋 Skills 说明

### Fumadocs 自动化发布

| Skill | 用途 | 使用频率 |
|-------|------|---------|
| **fumadocs-article-importer** | 导入外部文章 + 下载图片 | 每次导入 |
| **article-translator** | MDX 文档翻译 (en/zh/fr/ko) | 每次翻译 |
| **mdx-article-publisher** | 验证语法 + 提交 + 推送 | 每次发布 |
| **fumadocs-i18n-setup** | 配置多语言支持 | 仅一次 |

### 通用工具

| Skill | 用途 |
|-------|------|
| **philosophical-illustrator** | 为技术博客生成 SVG 插图 |
| **skill-article-writer** | 分析 Claude Skill 并创作教程 |

## ⚙️ 前置配置

### Jina MCP（文章导入必需）

编辑 `~/.clawdbot/moltbot.json`（OpenClaw）或 Claude Code 配置文件：

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

## 🎯 快速开始

### 导入一篇文章

```
用户: 帮我导入这篇文章 https://example.com/article
AI: [自动使用 fumadocs-article-importer → article-translator → mdx-article-publisher]
```

### 首次配置 i18n

```
用户: 帮我配置 Fumadocs 多语言支持
AI: [使用 fumadocs-i18n-setup]
```

## 📄 许可证

MIT
