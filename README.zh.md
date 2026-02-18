# deeptoai-skills 🦞

DeepToAI 团队制作的 Skills，用于提升 OpenClaw/Claude Code 的工作效率。

## 前置要求

- 已安装 Node.js 环境
- 能运行 npx/pnpm 命令

## 安装

### 快速安装

```bash
npx skills add foreveryh/deeptoai-skills
```

### 或通过 ClawdHub

```bash
clawdhub install <skill-name>
```

## 可用 Skills

| Skill | 描述 |
|-------|------|
| [fumadocs-writing](skills/fumadocs-writing) | Fumadocs 站点的 MDX 文档写作 |
| [web-search-zai](skills/web-search-zai) | 智谱 AI Web Search API 集成 |

### fumadocs-writing

创建结构良好的 Fumadocs MDX 文档，包含正确的 frontmatter、markdown 扩展和交互组件。

**特性：**
- Frontmatter 验证 (title, description, author, date)
- MDX 语法支持
- Callouts, Cards, Tabs 组件
- Shiki 代码高亮

### web-search-zai

使用智谱 AI 的 web_search API 进行网络搜索。

**特性：**
- 实时网络搜索
- 中文优化
- API Key 自动检测

## 通过 ClawdHub 安装

```bash
# 安装 fumadocs-writing
clawdhub install fumadocs-writing

# 安装 web-search-zai
clawdhub install web-search-zai
```

## 许可证

MIT
