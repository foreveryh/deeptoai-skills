# deeptoai-skills 🦞

Skills crafted by DeepToAI team for enhancing productivity with OpenClaw/Claude Code.

English | [中文](README.zh.md)

## Prerequisites

- Node.js environment installed
- Ability to run npx/pnpm commands

## Installation

### Quick Install

```bash
npx skills add foreveryh/deeptoai-skills
```

### Or via ClawdHub

```bash
clawdhub install <skill-name>
```

## Available Skills

| Skill | Description |
|-------|-------------|
| [fumadocs-writing](skills/fumadocs-writing) | MDX documentation writing for Fumadocs-powered sites |
| [web-search-zai](skills/web-search-zai) | Zhipu AI Web Search API integration |

### fumadocs-writing

Create well-structured, Fumadocs-compliant MDX documentation with proper frontmatter, markdown extensions, and interactive components.

**Features:**
- Frontmatter validation (title, description, author, date)
- MDX syntax support
- Callouts, Cards, Tabs components
- Code highlighting with Shiki

### web-search-zai

Search the web using Zhipu AI's web_search API.

**Features:**
- Real-time web search
- Chinese language optimized
- API key auto-detection

## Installation via ClawdHub

```bash
# Install fumadocs-writing
clawdhub install fumadocs-writing

# Install web-search-zai
clawdhub install web-search-zai
```

## License

MIT
