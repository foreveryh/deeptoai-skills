# Fumadocs Skills 改进总结

## ✅ 已完成的改进

### 1. 修复 fumadocs-article-importer

**问题**: 依赖 Jina MCP 配置，但 OpenClaw 不支持 `mcpServers`

**解决方案**:
- ❌ 移除 MCP 依赖
- ✅ 改用 curl 直接调用 Jina Reader API
- ✅ 使用环境变量 `JINA_API_KEY`

**关键代码**:
```bash
# 获取文章内容
curl -s "https://r.jina.ai/{url}" \
  -H "Authorization: Bearer ${JINA_API_KEY}"

# 下载图片（安全文件名）
curl -o "public/images/docs/{slug}/img01.png" "{image_url}"
```

---

### 2. 增强 article-translator

**问题**: 缺少 MDX 语法安全规则

**解决方案**: 添加 MDX 安全检查清单

**关键规则**:

| 字符 | 问题 | 解决方案 |
|------|------|----------|
| `<` | 被解析为 JSX | `&lt;` 或 "under" |
| `>` | 被解析为 JSX | `&gt;` 或 "over" |
| `{` `}` | JSX 表达式 | `&#123;` `&#125;` |

**图片文件名规则**:
```
❌ img-1.png, screenshot-10.png
✅ img01.png, screenshot10.png
```

---

### 3. 新增 mdx-validator

**用途**: MDX 语法预检查，在构建前发现问题

**检查项**:
- ✅ 特殊字符（`<` `>` `{` `}`）
- ✅ 图片路径（避免连字符+数字）
- ✅ Frontmatter 格式
- ✅ 代码块完整性

**自动修复**:
```bash
mdx-validator --fix content/docs/**/*.mdx
```

---

### 4. 新增 fumadocs-deploy

**用途**: 构建和部署验证

**步骤**:
1. 清理缓存（`.turbo`, `.next`, `out`）
2. 构建项目（`pnpm build:docs`）
3. 检查 Caddy 配置
4. 重载 Caddy
5. 验证所有资源（200 状态）

**Caddy 必需配置**:
```caddyfile
@docs_static path /_next* /docs* /zh-CN/docs* /en/docs* /fr/docs* /images*
```

---

## 🔄 新的工作流

### 改进前（有问题）

```
importer → translator → [手动构建] → [发现错误] → [修复] → [重新构建]
```

### 改进后（顺畅）

```
importer → translator → validator → [自动修复] → build → deploy → verify
```

---

## 📊 Skills 清单（更新后）

| Skill | 状态 | 主要改进 |
|-------|------|----------|
| **fumadocs-article-importer** | ✅ 已修复 | 移除 MCP 依赖，改用 curl |
| **article-translator** | ✅ 已增强 | 添加 MDX 安全规则 |
| **mdx-validator** | ✅ 新增 | MDX 语法预检查 |
| **fumadocs-deploy** | ✅ 新增 | 构建部署验证 |
| **fumadocs-i18n-setup** | ✅ 无需修改 | 一次性配置 |
| **mdx-article-publisher** | ⚠️ 可选 | Git 提交推送（保留） |

---

## 🎯 最佳实践

### 1. 图片文件名规范

```bash
# ❌ 错误（MDX 会解析为表达式）
img-1.png
screenshot-10.png
figure-2.png

# ✅ 正确（无连字符+数字）
img01.png
screenshot10.png
figure02.png
openclaw01.png
```

### 2. 特殊字符处理

```markdown
<!-- ❌ 错误 -->
Accuracy: >80%
Memory: <5MB

<!-- ✅ 正确 -->
Accuracy: over 80%
Memory: under 5MB

<!-- ✅ 或使用 HTML 实体 -->
Accuracy: &gt;80%
Memory: &lt;5MB
```

### 3. Caddy 配置模板

```caddyfile
docs.yourdomain.com {
    # 必需路径
    @docs_static path /_next* /docs* /zh-CN/docs* /en/docs* /fr/docs* /images*

    root * /var/www/fumadocs/apps/docs-app/out

    file_server @docs_static

    # 压缩
    encode gzip zstd

    # 缓存静态资源
    @cacheable path /_next/static/*
    header @cacheable Cache-Control "public, max-age=31536000, immutable"
}
```

### 4. 部署检查清单

- [ ] 清理缓存：`rm -rf .turbo .next out`
- [ ] 构建：`pnpm build:docs`
- [ ] Caddy 配置包含所有路径
- [ ] 重载 Caddy：`systemctl reload caddy`
- [ ] 验证主页：200
- [ ] 验证文章页面：200
- [ ] 验证图片：200
- [ ] 验证静态资源：200

---

## 🚀 快速开始

### 导入一篇新文章

```bash
# 1. 导入文章
fumadocs-article-importer https://example.com/article

# 2. 翻译
article-translator --to zh,fr

# 3. 预检查
mdx-validator --fix

# 4. 构建部署
fumadocs-deploy

# 完成！
```

---

## 📝 配置要求

### Jina API Key

```json
// ~/.clawdbot/moltbot.json
{
  "env": {
    "JINA_API_KEY": "jina_xxxxxxxxxxxx"
  }
}
```

获取：https://jina.ai/reader

---

## 🔗 相关链接

- **deeptoai-skills 仓库**: https://github.com/foreveryh/deeptoai-skills
- **Jina Reader API**: https://jina.ai/reader
- **Fumadocs 文档**: https://fumadocs.vercel.app
- **Caddy 文档**: https://caddyserver.com/docs

---

**最后更新**: 2026-02-19
**维护者**: DeepToAI Team
