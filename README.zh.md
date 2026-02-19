# deeptoai-skills 🦞

DeepToAI 团队制作的 Skills，用于 Fumadocs 文档自动化发布和通用内容创作。

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

然后浏览并安装。

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
切换到 **Marketplaces** 标签 → 选择 **deeptoai-skills** → **Update marketplace**

## 📋 Skills 说明

### Fumadocs 自动化发布

| Skill | 用途 |
|-------|------|
| **fumadocs-article-importer** | 导入外部文章 + 下载图片 |
| **article-translator** | MDX 文档翻译 (en/zh/fr/ko) |
| **mdx-article-publisher** | 验证语法 + 提交 + 推送 |
| **fumadocs-i18n-setup** | 配置多语言支持（一次性） |

### 通用工具

| Skill | 用途 |
|-------|------|
| **philosophical-illustrator** | 生成 SVG 插图 |
| **skill-article-writer** | 分析 Skill 并创作教程 |

## ⚙️ 前置配置

### Jina MCP（文章导入必需）

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

## 📄 许可证

MIT
