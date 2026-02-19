---
name: mdx-validator
description: >
  MDX 语法预检查工具。**推荐**：先使用 eslint-mdx 和 prettier 进行基础检查，
  再使用本 skill 进行 Fumadocs 特定问题的专项检查（图片文件名、翻译完整性）。
  在 article-translator 翻译后、pnpm build 前使用。
version: 1.2.0
---

# MDX Validator

MDX 语法预检查工具，**补充**现有工具（eslint-mdx, prettier）。

## 🎯 设计理念

### 与现有工具的关系

```
eslint-mdx (基础 MDX 检查)
    +
prettier (格式化)
    +
mdx-validator (Fumadocs 专项检查) ← 你在这里
    ↓
完整的 MDX 质量保证
```

**为什么需要本 skill**:
- eslint-mdx 不检查图片文件名规范
- prettier 不检查翻译完整性
- 现有工具没有 Fumadocs 特定问题的检查

## 📦 前置条件

### 推荐安装（可选）

```bash
# 1. 安装 eslint-mdx（官方 MDX 检查工具）
npm install -D eslint-plugin-mdx

# 2. 安装 prettier（MDX 格式化）
npm install -D prettier

# 3. 创建配置
echo '{"extends":["plugin:mdx/recommended"]}' > .eslintrc.json
```

## 🔍 检查项

### Step 0: 使用现有工具（如果有）

```bash
# 检查是否有 eslint-mdx
if [ -f "node_modules/eslint-plugin-mdx" ]; then
  echo "✅ 发现 eslint-mdx，运行检查..."
  npx eslint "**/*.mdx" --fix
else
  echo "⚠️  未安装 eslint-mdx，跳过基础检查"
  echo "   推荐: npm install -D eslint-plugin-mdx"
fi

# 检查是否有 prettier
if [ -f "node_modules/prettier" ]; then
  echo "✅ 发现 prettier，格式化..."
  npx prettier --write "**/*.mdx"
fi
```

### Step 1: 特殊字符检查（MDX 语法）

**问题字符**:
- `<` - 被解析为 JSX 标签
- `>` - 被解析为 JSX 标签
- `{` `}` - 被解析为 JSX 表达式

**检查命令**:

```bash
# 检查危险的 < 符号（不在代码块和 HTML 标签中）
grep -n '<[^a-zA-Z/!]' *.mdx | grep -v '```' | grep -v '^.*:.*<\(a\|img\|div\|span\|p\|h[1-6]\|ul\|ol\|li\|code\|pre\|strong\|em\|br\|hr\)\'

# 检查危险的 > 符号（不在代码块中）
grep -n '>[^a-zA-Z/]' *.mdx | grep -v '```' | grep -v '^.*:.*</\(a\|img\|div\|span\|p\|h[1-6\|ul\|ol\|li\|code\|pre\|strong\|em\)\>'
```

### 2. 图片路径检查

**问题模式**: `img-1.png`, `screenshot-10.png`

**检查命令**:

```bash
# 检查连字符+数字的文件名
grep -nE '(img|image|screenshot|fig|figure)-[0-9]+\.(png|jpg|webp|gif)' *.mdx
```

### 3. Frontmatter 检查

**必需字段**: `title`, `description`

**检查命令**:

```bash
# 检查缺失 title 的文件
grep -L '^title:' *.mdx

# 检查缺失 description 的文件
grep -L '^description:' *.mdx

# 检查 description 长度（建议 50-160 字符）
for f in *.mdx; do
  desc=$(grep '^description:' "$f" | cut -d':' -f2-)
  len=${#desc}
  if [ $len -lt 50 ] || [ $len -gt 160 ]; then
    echo "⚠️  $f: description 长度 $len（建议 50-160）"
  fi
done
```

### 4. 代码块完整性检查

**检查命令**:

```bash
# 检查未闭合的代码块
awk '/^```/{flag=1-flag} END{if(flag)print "❌ 未闭合的代码块"}' *.mdx

# 检查代码块语言标识
grep -n '^```[^a-z]*$' *.mdx | grep -v '^.*:.*````*$'
```

### 5. 翻译完整性检查

**改进后的检测逻辑**:

```bash
# 1. 定义常见的英文技术术语（不应被检测为未翻译）
TECH_TERMS=(
  "React|TypeScript|JavaScript|Node\.js|npm|yarn|pnpm"
  "API|SDK|CLI|GUI|IDE|JSON|YAML|XML|HTTP|HTTPS"
  "CSS|HTML|SQL|NoSQL|REST|GraphQL"
  "Git|GitHub|GitLab|Bitbucket"
  "Docker|Kubernetes|AWS|GCP|Azure"
  "MacOS|Windows|Linux|Ubuntu|Debian"
  "CDN|DNS|SSL|TLS|OAuth|JWT"
)

# 合并为正则表达式
TECH_REGEX=$(IFS="|"; echo "${TECH_TERMS[*]}")

# 2. 检查中文文件中的英文单词（排除技术术语）
for f in content/docs/zh-CN/*.mdx; do
  # 统计英文单词数量（排除技术术语）
  english=$(grep -oE '\b[A-Za-z]+\b' "$f" | \
    grep -v -E "^($TECH_REGEX)$" | \
    wc -l)

  # 统计总词数
  total=$(wc -w < "$f")

  # 计算英文占比
  if [ $total -gt 0 ]; then
    ratio=$((english * 100 / total))
    if [ $ratio -gt 20 ]; then
      echo "⚠️  $f: 英文占比 ${ratio}%，可能未翻译"
    fi
  fi
done

# 3. 检查正文内容是否与英文版相同（排除 frontmatter）
for f in content/docs/zh-CN/*.mdx; do
  en_file="${f/zh-CN/en}"
  if [ -f "$en_file" ]; then
    # 提取正文（跳过前 10 行 frontmatter）
    zh_body=$(tail -n +10 "$f")
    en_body=$(tail -n +10 "$en_file")

    if [ "$zh_body" = "$en_body" ]; then
      echo "❌ $f: 正文内容与英文版相同，未翻译！"
    fi
  fi
done

# 4. 智能检测（基于句子级别）
for f in content/docs/zh-CN/*.mdx; do
  # 提取包含大量英文的句子
  grep -nE '^[^#]*[A-Za-z]{20,}[^#]*$' "$f" | \
    grep -v '```' | \
    grep -v '<!--' | \
    head -5
done
```

**更智能的检测**:

```bash
# 使用 MDX AST 解析（更准确）
# 需要安装: npm install -D remark remark-mdx

npx remark content/docs/zh-CN/article.mdx \
  --use remark-mdx \
  --tree | \
  jq '.. | .value? | select(. != null) | select(test("[A-Za-z]{10,}"))'
```

## 自动修复

### 优先使用 prettier

```bash
# 如果有 prettier，优先使用
if command -v prettier &> /dev/null; then
  echo "✅ 使用 prettier 格式化..."
  prettier --write "**/*.mdx"
fi
```

### 修复特殊字符

```bash
# 修复 < 符号（数字前）
sed -i 's|<\([0-9]\)|under \1|g' *.mdx
sed -i 's|<\([0-9]\)|&lt;\1|g' *.mdx  # 或使用 HTML 实体

# 修复 > 符号（数字前）
sed -i 's|>\([0-9]\)|over \1|g' *.mdx
sed -i 's|>\([0-9]\)|&gt;\1|g' *.mdx  # 或使用 HTML 实体
```

### 修复图片路径

```bash
# 修复连字符+数字的文件名
# img-1.png → img01.png
# screenshot-10.png → screenshot10.png
sed -i -E 's|(img|image|screenshot|fig|figure)-([0-9]+)\.|\1\2.|g' *.mdx
```

### 修复 Frontmatter

```bash
# 添加缺失的 title（如果文件名有意义）
for f in *.mdx; do
  if ! grep -q '^title:' "$f"; then
    title=$(basename "$f" .mdx | sed 's/-/ /g' | sed 's/\b\(.\)/\u\1/')
    sed -i "1i---\ntitle: $title\n---" "$f"
  fi
done
```

## 使用方式

### 方式 1: 完整检查（推荐）

```bash
# 1. 基础检查（如果有 eslint-mdx）
if [ -f "node_modules/eslint-plugin-mdx" ]; then
  npx eslint "**/*.mdx" --fix
fi

# 2. 格式化（如果有 prettier）
if [ -f "node_modules/prettier" ]; then
  npx prettier --write "**/*.mdx"
fi

# 3. Fumadocs 专项检查
mdx-validator --check-images --check-translation

# 4. 自动修复剩余问题
mdx-validator --fix
```

### 方式 2: 仅使用 mdx-validator

```bash
# 检查单个文件
mdx-validator article.mdx

# 检查目录下所有文件
mdx-validator content/docs/en/**/*.mdx

# 检查并修复
mdx-validator --fix content/docs/en/**/*.mdx
```

### 方式 2: 集成到工作流

```bash
# 在翻译后运行
article-translator article.mdx --to zh
mdx-validator --fix content/docs/zh/article.mdx

# 在构建前运行
mdx-validator content/docs/**/*.mdx && pnpm build:docs
```

## 输出示例

```
=== MDX Validation Report ===

File: content/docs/en/ai-ml/jina-vlm.mdx

✅ Special characters: OK
⚠️  Image paths: 2 issues found
  Line 45: img-10.png → img10.png
  Line 78: screenshot-1.png → screenshot01.png
✅ Frontmatter: OK
✅ Code blocks: OK

Auto-fix available: mdx-validator --fix jina-vlm.mdx
```

## 配置

可在项目根目录创建 `.mdx-validator.json`:

```json
{
  "rules": {
    "specialChars": true,
    "imagePaths": true,
    "frontmatter": true,
    "codeBlocks": true
  },
  "autoFix": false,
  "ignore": ["node_modules", ".next"]
}
```

## 与其他 Skills 配合

```
fumadocs-article-importer (导入文章)
         ↓
article-translator (翻译内容)
         ↓
┌────────┴────────┐
│  eslint-mdx     │ ← 基础 MDX 检查（推荐）
│  prettier       │ ← 格式化（推荐）
└────────┬────────┘
         ↓
mdx-validator ← 你在这里（Fumadocs 专项检查）
         ↓
pnpm build:docs (构建)
         ↓
fumadocs-deploy (部署验证)
```

## 🆚 与现有工具对比

| 检查项 | eslint-mdx | prettier | **mdx-validator** |
|--------|-----------|----------|-------------------|
| MDX JSX 语法 | ✅ | - | - |
| Markdown 语法 | ✅ | - | - |
| 代码风格 | - | ✅ | - |
| **特殊字符（MDX）** | - | - | ✅ |
| **图片文件名** | - | - | ✅ |
| **翻译完整性** | - | - | ✅ |
| **Fumadocs 特定** | - | - | ✅ |

**结论**:
- 使用 eslint-mdx + prettier 进行**基础检查**
- 使用 mdx-validator 进行**专项检查**
- 三者**互补**，不冲突

## 常见问题

### Q: 为什么要预检查？

A: MDX 语法错误在构建时才会发现，预检查可以：
- 提前发现问题，节省构建时间
- 自动修复常见问题
- 避免 CI/CD 失败

### Q: 哪些字符是安全的？

A:
- **安全**: 字母、数字、基本标点（`. , ! ? ; : ' " ( )`）
- **不安全**: `<` `>` `{` `}` `&`（需要特殊处理）
- **代码块中**: 所有字符都安全

### Q: 图片路径为什么不能用连字符？

A: MDX 会将 `img-1.png` 解析为 `img` 减去 `1.png`，导致路径错误。
使用 `img01.png` 或 `openclaw01.png` 可避免此问题。
