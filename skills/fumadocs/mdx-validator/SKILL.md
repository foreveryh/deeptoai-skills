---
name: mdx-validator
description: >
  MDX 语法预检查，在构建前发现并修复常见问题。检查特殊字符、图片路径、
  Frontmatter 格式等。在 article-translator 翻译后、pnpm build 前使用。
version: 1.0.0
---

# MDX Validator

MDX 语法预检查工具，在构建前发现并自动修复常见问题。

## 检查项

### 1. 特殊字符检查

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

**检测未翻译内容**:

```bash
# 检查中文文件中的英文单词
for f in content/docs/zh-CN/*.mdx; do
  english=$(grep -oE '\b(is|the|and|to|for|with|from)\b' "$f" | wc -l)
  if [ $english -gt 10 ]; then
    echo "⚠️  $f: 可能未翻译（发现 $english 个英文单词）"
  fi
done

# 检查文件内容是否与英文版相同
for f in content/docs/zh-CN/*.mdx; do
  en_file="${f/zh-CN/en}"
  if [ -f "$en_file" ]; then
    if diff -q "$f" "$en_file" > /dev/null 2>&1; then
      echo "❌ $f: 内容与英文版相同，未翻译！"
    fi
  fi
done
```

**检查 frontmatter 翻译**:

```bash
# 确保 title 和 description 已翻译
for f in *.mdx; do
  title=$(grep '^title:' "$f" | head -1)
  desc=$(grep '^description:' "$f" | head -1)

  # 如果是中文文件但 title 包含英文
  if [[ "$f" == *"zh-CN"* ]] && echo "$title" | grep -qE '[A-Za-z]{5,}'; then
    echo "⚠️  $f: title 可能未翻译"
  fi
done
```

## 自动修复

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

### 方式 1: 完整检查

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
mdx-validator ← 你在这里（预检查）
         ↓
pnpm build:docs (构建)
         ↓
fumadocs-deploy (部署验证)
```

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
