---
name: fumadocs-deploy
description: >
  Fumadocs 构建和部署验证。清理缓存、构建项目、检查 Caddy 配置、
  验证资源可访问性。在 pnpm build 后使用，确保部署成功。
version: 1.0.0
---

# Fumadocs Deploy

Fumadocs 构建和部署验证工具，确保所有资源正确部署。

## 前置条件

- Fumadocs 项目已初始化
- Caddy 已安装并配置
- 构建输出目录：`apps/docs-app/out/`

## 完整流程

### Step 0: 配置检查（重要！）

**检查 Next.js 配置**:

```bash
# 静态导出必须禁用图片优化
if ! grep -q "unoptimized: true" next.config.mjs; then
  echo "❌ 缺少 images.unoptimized: true"
  echo ""
  echo "请在 next.config.mjs 中添加："
  echo ""
  echo "export default {"
  echo "  output: 'export',"
  echo "  images: {"
  echo "    unoptimized: true,"
  echo "  },"
  echo "}"
  exit 1
fi

echo "✅ Next.js 配置正确"
```

**检查 i18n 配置（如果使用多语言）**:

```bash
# 检查 UI 翻译文件是否完整
for lang in en zh-CN fr; do
  if [ ! -f "libs/i18n/locales/$lang.ts" ]; then
    echo "⚠️  缺少 $lang.ts 翻译文件"
  else
    lines=$(wc -l < "libs/i18n/locales/$lang.ts")
    echo "✅ $lang.ts: $lines 行"
  fi
done
```

### Step 1: 清理缓存

**清理构建缓存**:

```bash
# 清理所有缓存
rm -rf .turbo
rm -rf apps/docs-app/.next
rm -rf apps/docs-app/out

echo "✅ 缓存已清理"
```

### Step 2: 构建

**运行构建命令**:

```bash
# 构建 Fumadocs
pnpm build:docs

# 检查构建结果
if [ -d "apps/docs-app/out" ]; then
  echo "✅ 构建成功"
  ls -lh apps/docs-app/out/ | head -10
else
  echo "❌ 构建失败"
  exit 1
fi
```

**验证构建输出**:

```bash
# 检查 HTML 文件
find apps/docs-app/out -name "*.html" | wc -l

# 检查图片
find apps/docs-app/out/images -type f 2>/dev/null | wc -l

# 检查静态资源
find apps/docs-app/out/_next -type f 2>/dev/null | wc -l
```

### Step 3: Caddy 配置检查

**必需的路径配置**:

```caddyfile
# /etc/caddy/Caddyfile

yourdomain.com {
    # 必须包含的路径
    @docs_static path /_next* /docs* /zh-CN/docs* /en/docs* /fr/docs* /images*

    root * /path/to/fumadocs/apps/docs-app/out

    # 静态文件服务
    file_server @docs_static

    # SPA fallback（如果使用）
    @docs_not_static not path /_next* /images*
    try_files @docs_not_static {path} /index.html
}
```

**检查 Caddy 配置**:

```bash
# 验证 Caddyfile 语法
caddy validate --config /etc/caddy/Caddyfile

# 检查必需路径
grep -E "/_next\*|/docs\*|/images\*" /etc/caddy/Caddyfile || echo "⚠️  缺少路径配置"
```

**常见配置问题**:

| 问题 | 原因 | 解决方案 |
|------|------|----------|
| 图片 404 | Caddy 未配置 `/images*` | 添加 `@docs_static path /images*` |
| 页面 404 | 语言路径未包含 | 添加 `/en/docs*` `/zh-CN/docs*` |
| 样式丢失 | `/_next*` 路径未配置 | 添加 `@docs_static path /_next*` |

### Step 4: 重载 Caddy

```bash
# 优雅重载（不中断服务）
sudo systemctl reload caddy

# 或使用 Caddy 命令
caddy reload --config /etc/caddy/Caddyfile

# 检查 Caddy 状态
sudo systemctl status caddy
```

### Step 5: 部署验证

**验证清单**:

```bash
DOMAIN="yourdomain.com"
SLUG="your-article"

echo "=== 部署验证 ==="

# 1. 测试主页
curl -s -o /dev/null -w "主页: %{http_code}\n" "https://$DOMAIN/"

# 2. 测试文章页面（各语言）
curl -s -o /dev/null -w "英文页面: %{http_code}\n" "https://$DOMAIN/en/docs/$SLUG"
curl -s -o /dev/null -w "中文页面: %{http_code}\n" "https://$DOMAIN/zh-CN/docs/$SLUG"

# 3. 测试图片
curl -s -o /dev/null -w "图片1: %{http_code}\n" "https://$DOMAIN/images/docs/$SLUG/img01.png"

# 4. 测试静态资源
curl -s -o /dev/null -w "CSS: %{http_code}\n" "https://$DOMAIN/_next/static/css/$(ls apps/docs-app/out/_next/static/css/ | head -1)"

echo "=== 验证完成 ==="
```

**期望结果**:

```
主页: 200
英文页面: 200
中文页面: 200
图片1: 200
CSS: 200
```

## 部署后检查

### 检查 Next.js 配置（重要！）

**静态导出必须禁用图片优化**:

```javascript
// next.config.mjs 或 next.config.js
export default {
  output: 'export',
  images: {
    unoptimized: true, // ← 必须！静态导出时图片优化 API 不可用
  },
  trailingSlash: true,
}
```

**如果未禁用，会出现**:
- `/_next/image?url=...` 返回 404
- 图片无法加载

**验证配置**:

```bash
# 检查配置文件
grep "unoptimized: true" next.config.mjs || echo "⚠️  需要添加 images.unoptimized: true"
```

### 检查图片可访问性

```bash
# 检查所有图片
for img in apps/docs-app/out/images/docs/**/*.png; do
  url="https://$DOMAIN${img#apps/docs-app/out}"
  status=$(curl -s -o /dev/null -w "%{http_code}" "$url")
  if [ "$status" != "200" ]; then
    echo "❌ $url: $status"
  fi
done
```

### 检查页面渲染

```bash
# 检查 HTML 包含正确内容
curl -s "https://$DOMAIN/en/docs/$SLUG" | grep -q "<title>" && echo "✅ 标题存在"
curl -s "https://$DOMAIN/en/docs/$SLUG" | grep -q "<meta name=\"description\"" && echo "✅ 描述存在"
```

## 常见问题排查

### 问题 1: 图片 404

**诊断**:

```bash
# 检查图片是否存在
ls -l apps/docs-app/out/images/docs/$SLUG/

# 检查 Caddy 配置
grep "/images\*" /etc/caddy/Caddyfile

# 检查文件权限
stat apps/docs-app/out/images/docs/$SLUG/*.png
```

**解决**:

1. 确认图片已下载到正确位置
2. 确认 Caddy 配置包含 `/images*` 路径
3. 确认文件权限可读（644）

### 问题 2: 页面 404

**诊断**:

```bash
# 检查 HTML 文件是否存在
ls -l apps/docs-app/out/en/docs/$SLUG.html

# 检查 Caddy 配置
grep "/en/docs\*" /etc/caddy/Caddyfile
```

**解决**:

1. 确认构建成功
2. 确认语言路径已配置
3. 重载 Caddy

### 问题 3: 样式丢失

**诊断**:

```bash
# 检查静态资源
ls -l apps/docs-app/out/_next/static/css/

# 检查 Caddy 配置
grep "/_next\*" /etc/caddy/Caddyfile
```

**解决**:

1. 确认 `/_next*` 路径已配置
2. 清理浏览器缓存
3. 重新构建

## 与其他 Skills 配合

```
fumadocs-article-importer (导入文章)
         ↓
article-translator (翻译内容)
         ↓
mdx-validator (预检查)
         ↓
pnpm build:docs (构建)
         ↓
fumadocs-deploy ← 你在这里（部署验证）
```

## 自动化部署脚本

```bash
#!/bin/bash
# deploy-fumadocs.sh

set -e

echo "=== 开始部署 ==="

# 1. 清理
echo "清理缓存..."
rm -rf .turbo apps/docs-app/.next apps/docs-app/out

# 2. 构建
echo "构建项目..."
pnpm build:docs

# 3. 验证构建
if [ ! -d "apps/docs-app/out" ]; then
  echo "❌ 构建失败"
  exit 1
fi

# 4. 重载 Caddy
echo "重载 Caddy..."
sudo systemctl reload caddy

# 5. 验证部署
echo "验证部署..."
sleep 2

DOMAIN="yourdomain.com"
STATUS=$(curl -s -o /dev/null -w "%{http_code}" "https://$DOMAIN/")

if [ "$STATUS" = "200" ]; then
  echo "✅ 部署成功！"
else
  echo "❌ 部署失败: HTTP $STATUS"
  exit 1
fi
```

## 配置示例

### next.config.js

```javascript
module.exports = {
  output: 'export',
  images: {
    unoptimized: true, // 静态导出必须禁用图片优化
  },
  trailingSlash: true,
}
```

### Caddyfile（完整示例）

```caddyfile
docs.example.com {
    # 日志
    log {
        output file /var/log/caddy/docs-access.log
    }

    # 静态文件路径
    @static path /_next* /docs* /en/docs* /zh-CN/docs* /fr/docs* /images*

    root * /var/www/fumadocs/apps/docs-app/out

    # 静态文件服务
    file_server @static

    # 压缩
    encode gzip zstd

    # 缓存
    @cacheable path /_next/static/*
    header @cacheable Cache-Control "public, max-age=31536000, immutable"

    # 安全头
    header {
        X-Frame-Options "SAMEORIGIN"
        X-Content-Type-Options "nosniff"
        Referrer-Policy "strict-origin-when-cross-origin"
    }
}
```

## 监控和日志

```bash
# 查看 Caddy 日志
sudo journalctl -u caddy -f

# 查看访问日志
tail -f /var/log/caddy/docs-access.log

# 检查错误
grep "ERROR" /var/log/caddy/docs-access.log
```
