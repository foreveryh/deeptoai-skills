# 通用工具 Skills

不限于特定平台的通用工具。

## 📦 包含的 Skills

| Skill | 用途 | 适用范围 |
|-------|------|---------|
| **philosophical-illustrator** | 生成 SVG 插图 | 任何技术博客 |
| **skill-article-writer** | 分析 Skill 并创作教程 | Claude Skills 文档化 |

## 🎨 philosophical-illustrator

**用途：** 为技术博客生成现代、多彩的 SVG 插图

**特点：**
- 800x450px 封面图
- 主题相关配色
- 几何图形 + 技术图标

**使用场景：**
```
用户: 为我的 AI 文章生成封面图
AI: [使用 philosophical-illustrator]
    ↓ 分析文章主题
    ↓ 选择配色方案
    ↓ 生成 SVG
```

## 📝 skill-article-writer

**用途：** 分析 Claude Skill 并生成详细教程

**输入：** 本地 skill 目录
**输出：** 完整的教程文章

**使用场景：**
```
用户: 帮我为我的 skill 写篇文档
AI: [使用 skill-article-writer]
    ↓ 分析 SKILL.md 结构
    ↓ 提取工作流程
    ↓ 生成教程大纲
    ↓ 创作完整文章
```

## 🔄 与 Fumadocs Skills 配合

这些通用 skills 可以与 `skills/fumadocs/` 中的 skills 配合使用：

```
skill-article-writer (创作文章)
         ↓
article-translator (fumadocs/) (翻译)
         ↓
philosophical-illustrator (添加插图)
         ↓
mdx-article-publisher (fumadocs/) (发布)
```
