---
name: skill-article-writer
description: Generate comprehensive analysis articles from Claude skills. Use when analyzing a skill from the Anthropic repository and creating a detailed tutorial explaining its structure, design patterns, and usage.
---

# Skill Article Writer

Analyze Claude skills and generate detailed tutorial articles.

## What This Skill Does

**Meta-skill** that transforms any skill into a detailed tutorial:
- Analyzes skill structure and resources
- Generates article outlines
- Creates comprehensive tutorials with examples
- Produces multi-language versions (en, zh, fr)

**Use cases**:
- Documentation for internal skills
- Tutorials for skill development
- Best practices analysis
- Educational content

## Prerequisites

- Local clone of target skill
- Python 3.x (for analysis scripts)
- Write access to create article files

## Workflow

### Step 1: Understand the Source Skill

1. Read the skill's SKILL.md
2. Examine bundled resources (scripts/, references/, assets/)
3. Identify key workflows
4. Note target audience

**Output**: Understanding of skill's value proposition

### Step 2: Analyze Structure

```bash
scripts/analyze_skill.py /path/to/skill-name > /tmp/skill-metadata.json
```

**Extracts**:
- Directory structure
- YAML frontmatter
- Section headings
- Bundled resources
- Workflow steps

### Step 3: Generate Article Outline

```bash
scripts/generate_article_outline.py /tmp/skill-metadata.json > /tmp/article-outline.md
```

**Outline structure**:
1. Introduction (what is this skill?)
2. Skill Anatomy (directory structure)
3. Technical Deep Dive (how it works)
4. Usage Examples (practical demonstrations)
5. Best Practices (design principles)
6. Integration Patterns (with other skills)
7. Conclusion

### Step 4: Fill In Content

For each section in the outline:
1. Expand bullet points into full paragraphs
2. Add code examples where appropriate
3. Include MDX components (Callout, Cards, Steps)
4. Add source attribution

### Step 5: Add Frontmatter

```yaml
---
title: Analyzing {Skill Name}
description: Deep dive into {skill name} - structure, patterns, and usage
author: Your Name
date: YYYY-MM-DD
lang: en
category: development
---
```

### Step 6: Create Multi-Language Versions

Use **article-translator skill** to create:
- `content/docs/zh/development/{slug}.mdx`
- `content/docs/fr/development/{slug}.mdx`

### Step 7: Validate and Publish

1. Run MDX validation
2. Run build check
3. Use **skill-article-publisher** to commit and push

## Article Structure Template

```mdx
---
title: Analyzing {Skill Name}
description: {Brief description}
---

# Analyzing {Skill Name}

## Introduction

{What problem does this skill solve?}

<Callout type="info">
Key insight about the skill
</Callout>

## Skill Anatomy

### Directory Structure

```
skill-name/
├── SKILL.md          # Main skill definition
├── scripts/          # Helper scripts
├── references/       # Reference documents
└── assets/           # Templates, images
```

### Key Components

- **SKILL.md**: {description}
- **scripts/**: {description}

## How It Works

{Step-by-step explanation of the workflow}

## Usage Examples

### Example 1: {Use Case}

```bash
# Command or code
```

## Best Practices

1. {Practice 1}
2. {Practice 2}

## Integration

{How this skill works with others}

## Conclusion

{Summary and next steps}
```

## Example Output

See `examples/skill-creator-output.md` for a complete example analyzing the skill-creator skill.

## Best Practices

### Content Quality

1. **Be specific**: Use actual code examples, not placeholders
2. **Be practical**: Focus on what readers need to know
3. **Be accurate**: Verify all technical details

### Structure

1. **Lead with value**: Start with what problem the skill solves
2. **Progressive disclosure**: Simple → complex
3. **Scannable**: Use headings, lists, callouts

### MDX Components

```mdx
<Callout type="info">Key information</Callout>

<Steps>
  <Step>First step</Step>
  <Step>Second step</Step>
</Steps>

<CardGroup>
  <Card title="Card 1">Content</Card>
  <Card title="Card 2">Content</Card>
</CardGroup>
```

## Integration with Other Skills

```
skill-article-writer (this skill)
        ↓
article-translator (translate to zh/fr)
        ↓
mdx-article-publisher (commit & push)
```

## Scripts

- `scripts/analyze_skill.py` - Extract skill metadata
- `scripts/generate_article_outline.py` - Generate article template

## References

- `references/article-templates.md` - Templates for different skill types
