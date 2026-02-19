# Fumadocs Skills 改进总结

## ✅ 已完成的改进（v1.1）

基于 **龙虾 2** 实际工作中的问题反馈，进一步完善了 Skills。

---

## 🔧 第一轮改进（初始修复）

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

## 🔧 第二轮改进（基于实战问题）

### 5. 补充翻译完整性检查

**问题**: 中文版本显示英文内容（未翻译）

**原因**: 直接复制英文文件，没有使用 article-translator

**解决方案**: 在 article-translator 中添加 **Step 4: Translation Integrity Check**

**检查项**:
```bash
# 1. 对比中英文文件内容
diff <(head -c 100 en/article.mdx) <(head -c 100 zh-CN/article.mdx)

# 2. 检测中文文件中的英文单词
grep -E '\b(is|the|and|to|for)\b' zh-CN/article.mdx

# 3. 验证 frontmatter 翻译
grep '^title:' zh-CN/article.mdx
```

---

### 6. 补充 Next.js 配置检查

**问题**: 图片 `/_next/image?url=...` 返回 404

**原因**: 静态导出模式下图片优化 API 不可用

**解决方案**: 在 fumadocs-deploy 中添加 **Step 0: 配置检查**

**必须配置**:
```javascript
// next.config.mjs
export default {
  output: 'export',
  images: {
    unoptimized: true, // ← 必须！
  },
}
```

**自动检查**:
```bash
grep "unoptimized: true" next.config.mjs || echo "❌ 需要添加配置"
```

---

### 7. 增强 mdx-validator

**新增检查项 5: 翻译完整性检查**

**检测未翻译内容**:
```bash
# 检查中文文件中的英文单词
for f in content/docs/zh-CN/*.mdx; do
  english=$(grep -oE '\b(is|the|and)\b' "$f" | wc -l)
  if [ $english -gt 10 ]; then
    echo "⚠️  $f: 可能未翻译"
  fi
done

# 检查文件是否与英文版相同
diff zh-CN/article.mdx en/article.mdx
```

---

## 📊 问题对照表

基于 **龙虾 2** 实际工作问题，对照 Skills 改进：

| 问题 | 原因 | 相关 Skill | 改进措施 | 状态 |
|------|------|-----------|----------|------|
| 1. 中文显示英文 | 跳过翻译步骤 | article-translator | 添加翻译完整性检查（Step 4） | ✅ v1.1 |
| 2. 图片缺失 | 跳过导入步骤 | article-importer | 改用 curl + 图片提取 | ✅ v1.0 |
| 3. 文件名连字符+数字 | 未处理特殊文件名 | article-translator<br>mdx-validator | 添加文件名规范检查 | ✅ v1.0 |
| 4. MDX `<` 符号 | 特殊字符未转义 | article-translator<br>mdx-validator | 添加特殊字符处理 | ✅ v1.0 |
| 5. 法语 UI 翻译缺失 | i18n 配置问题 | - | 不在 content skill 范围 | ⚠️ 手动处理 |
| 6. 图片 404 | Caddy 配置缺失 | fumadocs-deploy | 添加 Caddy 配置检查 | ✅ v1.0 |
| 7. Next.js 图片优化 | 静态导出配置 | fumadocs-deploy | 添加 Next.js 配置检查（Step 0） | ✅ v1.1 |

**改进覆盖率**: 6/7 (86%)

---

## 🔄 新的工作流

### 改进前（有问题）

```
importer → translator → [手动构建] → [发现错误] → [修复] → [重新构建]
```

### 改进后（顺畅）

```
Step 0: 配置检查（fumadocs-deploy）
    ↓
Step 1: 导入文章（fumadocs-article-importer）
    ↓
Step 2: 翻译（article-translator + 翻译完整性检查）
    ↓
Step 3: MDX 预检查（mdx-validator + 翻译检测）
    ↓
Step 4: 构建部署（fumadocs-deploy + 配置验证）
    ↓
完成！✅
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
