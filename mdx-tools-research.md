# MDX 工具调研报告

## 📚 现有的 MDX 工具

### 1. **eslint-mdx / eslint-plugin-mdx** ⭐⭐⭐⭐⭐

**官网**: https://github.com/mdx-js/eslint-mdx

**功能**:
- ✅ MDX 语法解析和检查
- ✅ 集成 remark-lint 规则
- ✅ 支持 Prettier 集成
- ✅ 支持代码块 linting
- ✅ VSCode 扩展支持

**安装**:
```bash
npm install -D eslint-plugin-mdx
```

**配置示例**:
```javascript
// eslint.config.js
import * as mdx from 'eslint-plugin-mdx'

export default [
  {
    ...mdx.flat,
    processor: mdx.createRemarkProcessor({
      lintCodeBlocks: true,
    }),
  },
]
```

**支持的规则**:
- `mdx/remark` - 集成所有 remark-lint 规则
- 自动读取 `.remarkrc` 配置

**优势**:
- 官方维护，质量高
- 与 ESLint 生态集成
- 支持自定义规则
- 有 VSCode 扩展

---

### 2. **remark-mdx** ⭐⭐⭐⭐

**官网**: https://mdxjs.com/packages/remark-mdx/

**功能**:
- ✅ MDX 语法解析
- ✅ AST 生成
- ✅ 支持自定义插件

**安装**:
```bash
npm install remark-mdx
```

**使用示例**:
```javascript
import {remark} from 'remark'
import remarkMdx from 'remark-mdx'

const file = await remark()
  .use(remarkMdx)
  .process('import a from "b"\n\na <b /> c {1 + 1} d')
```

**优势**:
- 底层解析器
- 可以构建自定义工具
- 支持所有 MDX 语法

**劣势**:
- 需要自己编写检查逻辑
- 不是开箱即用的 linter

---

### 3. **remark-lint** ⭐⭐⭐⭐⭐

**官网**: https://github.com/remarkjs/remark-lint

**功能**:
- ✅ 70+ Markdown lint 规则
- ✅ 3 个预设配置
- ✅ 支持自定义规则
- ✅ CLI 和 API 两种使用方式

**预设**:
1. `remark-preset-lint-consistent` - 一致性规则
2. `remark-preset-lint-recommended` - 推荐规则
3. `remark-preset-lint-markdown-style-guide` - Markdown 风格指南

**安装**:
```bash
npm install -D remark-cli remark-preset-lint-recommended
```

**使用**:
```bash
npx remark . --use remark-preset-lint-recommended
```

**优势**:
- 成熟的规则集
- 社区活跃
- 可扩展性强

---

### 4. **Prettier** ⭐⭐⭐⭐

**官网**: https://prettier.io/

**功能**:
- ✅ MDX 格式化
- ✅ 统一代码风格
- ✅ 自动修复格式问题

**安装**:
```bash
npm install -D prettier
```

**使用**:
```bash
prettier --write "**/*.mdx"
```

**优势**:
- 开箱即用
- 无需配置
- 自动修复

**劣势**:
- 只处理格式，不检查语义
- 不检查特殊字符问题

---

## 🆚 与我们的 mdx-validator 对比

### 功能对比表

| 功能 | eslint-mdx | remark-lint | prettier | **我们的 mdx-validator** |
|------|-----------|-------------|----------|------------------------|
| **MDX 语法检查** | ✅ 完整 | ✅ 完整 | ⚠️ 部分 | ⚠️ 基本 |
| **特殊字符检查** | ❌ 无 | ❌ 无 | ❌ 无 | ✅ **专门针对** |
| **图片路径检查** | ❌ 无 | ❌ 无 | ❌ 无 | ✅ **专门针对** |
| **翻译完整性检查** | ❌ 无 | ❌ 无 | ❌ 无 | ✅ **专门针对** |
| **自动修复** | ✅ 部分 | ❌ 无 | ✅ 完整 | ✅ **专门针对** |
| **开箱即用** | ⚠️ 需配置 | ⚠️ 需配置 | ✅ 是 | ✅ **是** |
| **与 Fumadocs 集成** | ❌ 无 | ❌ 无 | ❌ 无 | ✅ **专门设计** |

---

## 💡 关键发现

### 我们的优势

1. **针对性更强**
   - ✅ 专门解决 Fumadocs 项目的常见问题
   - ✅ 图片文件名规范检查（现有工具都没有）
   - ✅ 翻译完整性检查（现有工具都没有）
   - ✅ 特殊字符处理指南（现有工具没有明确说明）

2. **开箱即用**
   - ✅ 无需安装 npm 包
   - ✅ 直接使用 bash/grep
   - ✅ 适合快速检查

3. **自动修复**
   - ✅ 针对我们发现的问题提供自动修复
   - ✅ 修复逻辑简单明了

### 我们的劣势

1. **覆盖面不足**
   - ❌ 只检查了我们遇到的几个问题
   - ❌ 不检查 Markdown 语法错误
   - ❌ 不检查 MDX JSX 语法

2. **准确性可能不够**
   - ❌ 翻译检测可能误报（英文术语）
   - ❌ grep 方式不够精确

3. **维护成本**
   - ❌ 需要自己维护规则
   - ❌ 不跟随 MDX 规范更新

---

## 🎯 改进建议

### 方案 1：集成现有工具（推荐）⭐⭐⭐⭐⭐

**优势**:
- ✅ 利用成熟的工具
- ✅ 减少维护成本
- ✅ 更全面的检查

**实现**:

```bash
# 1. 安装 eslint-mdx
npm install -D eslint-plugin-mdx eslint-config-prettier

# 2. 创建 .eslintrc.json
{
  "extends": ["plugin:mdx/recommended"],
  "rules": {
    "mdx/remark": "error"
  }
}

# 3. 运行检查
npx eslint "**/*.mdx"
```

**我们的 skill 可以**:
1. 检测项目是否有 eslint-mdx
2. 如果有，运行 eslint
3. 如果没有，使用我们的 bash 检查
4. 补充 eslint 没有的检查（翻译完整性）

---

### 方案 2：创建 remark 插件（中级）⭐⭐⭐⭐

**优势**:
- ✅ 更专业的实现
- ✅ 可复用
- ✅ 精确的 AST 分析

**实现**:

```javascript
// remark-lint-fumadocs-images.js
import {visit} from 'unist-util-visit'

export default function remarkLintFumadocsImages() {
  return (tree, file) => {
    visit(tree, 'image', (node) => {
      // 检查图片文件名
      if (/-\d+\.(png|jpg|webp)$/.test(node.url)) {
        file.message(
          '图片文件名包含连字符+数字，MDX 会解析错误',
          node,
          'fumadocs:image-filename'
        )
      }
    })
  }
}
```

---

### 方案 3：保留并优化现有 skill（基础）⭐⭐⭐

**优化点**:

1. **改进翻译检测**
   ```bash
   # 排除常见英文术语
   grep -E '\b(is|the|and)\b' zh-CN/article.mdx | \
     grep -v -E '\b(React|TypeScript|API|SDK|CDN|CSS|HTML)\b'
   ```

2. **使用 AST 解析而非 grep**
   ```bash
   # 使用 remark 解析 MDX
   npx remark article.mdx --use remark-mdx --tree > ast.json
   # 然后分析 AST
   ```

3. **添加更多检查项**
   - 未闭合的 JSX 标签
   - 无效的 import/export 语句
   - Markdown 语法错误

---

## 📋 推荐的混合方案

### 最佳实践

```bash
# 1. 使用 eslint-mdx 进行基础检查
npx eslint "**/*.mdx"

# 2. 使用我们的 skill 进行专项检查
mdx-validator --check-translation --check-images

# 3. 使用 prettier 格式化
prettier --write "**/*.mdx"
```

### 更新后的 mdx-validator skill

```markdown
## 检查策略

### 优先使用现有工具

1. **如果项目有 eslint-mdx**:
   ```bash
   npx eslint "**/*.mdx"
   ```

2. **如果项目有 prettier**:
   ```bash
   prettier --check "**/*.mdx"
   ```

### 补充我们的专项检查

3. **图片文件名检查**（eslint 没有）
4. **翻译完整性检查**（eslint 没有）
5. **Fumadocs 特定问题**（eslint 没有）

## 自动修复

1. **先尝试 prettier**:
   ```bash
   prettier --write "**/*.mdx"
   ```

2. **再运行我们的修复**:
   ```bash
   mdx-validator --fix
   ```
```

---

## 🎓 学习资源

- **eslint-mdx 文档**: https://github.com/mdx-js/eslint-mdx
- **remark-lint 规则**: https://github.com/remarkjs/remark-lint#rules
- **MDX 官方文档**: https://mdxjs.com/
- **unified 生态**: https://github.com/unifiedjs/unified

---

**结论**: 我们的 mdx-validator 应该 **补充** 现有工具，而不是 **替代** 它们。
