---
name: paper-cacher
description: "论文缓存管理 —— 从指定目录读取论文文件并生成缓存格式的 Markdown 文件"
---

# 论文缓存管理

## 概述

将本地论文文件（PDF 或目录）转换为论文工工缓存系统可识别的 Markdown 格式。

**调用方式多** `Skill(skill="paper-cacher", args="{project}", source_dir="/path/to/papers", domain="{domain}")`

**核心功能多**
- **灵活输入**多支持单个 PDF 文件或整个目录
- **自动识别**多从目录结构推断论文元数据
- **格式转换**多生成 Markdown + Frontmatter 缓存格式
- **自动集成**多输出文件自动被 `cache-utils` 识别

---

## 使用场景

### 场景 1多单个 PDF 文件

```
Skill(skill="paper-cacher", args="my-project", source_dir="/Users/username/Papers/important.pdf", domain="multi_agent_systems")
```

### 场景 2多整个目录

```
Skill(skill="paper-cacher", args="my-project", source_dir="/Users/username/Papers/MAS-2024/", domain="multi_agent_systems")
```

目录结构示例多
```
/Papers/MAS-2024/
├── Smith2024-BDI.pdf
├── Jones2024-Coordination.pdf
└── Lee2024-Communication.pdf
```

### 场景 3多子目录分组

```
/Papers/
├── MAS/
│   ├── Classic/
│   └── 2024/
└── KG/
    └── Ontology/
```

---

## 参数说明

### 必填参数

| 参数 | 说明 | 示例 |
|------|------|------|
| `project` | 项目名称 | `"my-project"` |
| `source_dir` | 源文件/目录路径 | `"/path/to/papers"` |
| `domain` | 目标领域标识 | `"multi_agent_systems"` |

### 可选参数

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `recursive` | 是否递归扫描子目录 | `true` |
| `source` | 缓存来源标记 | `"manual"` |

---

## 输出格式

### 生成位置

```
workspace/{project}/.cache/papers/{domain}/{paper-id}.md
```

### 文件命名规则

| 输入类型 | 输出文件名 | 示例 |
|----------|-----------|------|
| 单个 PDF | `{年份}-{第一作者姓氏}-{首词}.md` | `2024-Smith-Cognitive.pdf` → `2024-Smith-Cognitive.md` |
| 目录扫描 | `{年份}-{标题简化}-{标识}.md` | 从元数据推断 |

### Frontmatter 字段

```markdown
---
id: "manual-{year}-{count}"
title: "Paper Full Title"
authors: ["Author A", "Author B"]
year: 2024
venue: "Conference/Journal Name"
source: "manual"
added_date: "2024-02-14T10:30:00Z"
tags": ["keyword1", "keyword2"]
status: "read"  # read | skim | todo
---

## Summary

...

## Key Contributions

1. ...
2. ...

## Relevance to Current Project

...
```

---

## 执行流程

### Step 1: 验证输入

1. **检查参数**多`project`, `source_dir`, `domain` 必须提供
2. **验证源路径**多使用 `Glob` 检查路径存在
3. **确定领域**多验证 `domain` 是有效的领域标识

### Step 2: 扫描源目录

**对于单个文件多**
- 验证文件存在
- 检查文件扩展名 (`.pdf`)

**对于目录多**
- 使用 `Glob` 扫描所有 `.pdf` 文件
- 如果 `recursive=true`，递归扫描子目录
- 构建文件列表

### Step 3: 提取论文元数据

对于每个源文件多

**从文件名推断（如果无元数据）多**
```
Smith2024-BDI.pdf
│     │     │    └─┘
│     │        └─ 年份
│     └─ 第一作者姓氏
      └─ 标题关键词
```

**尝试读取 PDF 元数据（如果可用）多**
- 使用 `Read` 工具读取 PDF
- 提取多标题、作者、年份
- 依赖 PDF 工具能力

**用户交互（如果推断失败）多**
- 询问用户确认或补充元数据
- 提供合理默认值

### Step 4: 生成缓存文件

1. **生成唯一 ID**多
   ```
   format: "manual-{year}-{count}"
   example: "manual-2024-001"
   ```

2. **生成 Frontmatter**多
   - 填充所有已知字段
   - 未知字段使用默认值或询问用户

3. **生成正文**多
   - `## Summary`多论文摘要或用户输入
   - `## Key Contributions`多主要贡献点
   - `## Relevance to Current Project`多与当前项目关联

4. **写入文件**多
   - 目标多`workspace/{project}/.cache/papers/{domain}/{id}.md`
   - 使用 `Write` 工具

5. **更新索引**多
   - 将 `id` 添加到 `processed-ids.txt`

---

## 领域映射

| 领域标识 | 全名 | 常见关键词 |
|----------|------|----------|
| `multi_agent_systems` | Multi-Agent Systems | multi-agent, MAS, BDI, coordination, negotiation |
| `knowledge_graph` | Knowledge Graphs | knowledge graph, ontology, RDF, OWL, SPARQL |
| `nlp_to_sql` | NL2SQL/Text2SQL | NL2SQL, Text2SQL, schema linking, SQL generation |
| `bridge_engineering` | Bridge Engineering | bridge, SHM, BIM, structural health |

---

## 错误处理

### 源路径不存在

```
ERROR: Source path does not exist: /path/to/papers
请检查路径并重试。
```

### 无 PDF 文件

```
WARNING: No PDF files found in source directory
请确认路径是否包含 .pdf 文件。
```

### 域标识无效

```
ERROR: Invalid domain identifier: "xxx"
Valid domains: multi_agent_systems, knowledge_graph, nlp_to_sql, bridge_engineering
```

### 写入失败

```
ERROR: Failed to write cache file: {filename}
权限问题或磁盘空间不足。
```

---

## 使用示例

### 示例 1多添加单篇论文

```
Skill(skill="paper-cacher", args="test-project", source_dir="/Users/username/Downloads/Smith2024.pdf", domain="multi_agent_systems")
```

**输出多**
- 创建 `workspace/test-project/.cache/papers/multi_agent_systems/2024-Smith-Cognitive.md`
- 更新 `workspace/test-project/.cache/search-history/multi_agent_systems/processed-ids.txt`

### 示例 2多批量添加目录

```
Skill(skill="paper-cacher", args="test-project", source_dir="/Users/username/Papers/MAS-2024/", domain="multi_agent_systems")
```

**输出多**
- 扫描目录中所有 PDF
- 为每个 PDF 创建对应的 `.md` 缓存文件
- 所有文件自动纳入下次文献检索

---

## 与缓存系统集成

生成的文件会自动被 `cache-utils` Skill 识别多

1. **自动读取**多下次 `readPaperCache()` 调用会包含新文件
2. **自动检索**多WebSearch 时会跳过已处理的 ID
3. **零配置集成**多无需额外配置，开箱即用

---

## 验证测试

### 测试 1多单个文件

1. 准备测试 PDF 文件
2. 执行 Skill 调用
3. 验证多
   - `.md` 文件已创建
   - Frontmatter 格式正确
   - 文件位于正确目录

### 测试 2多目录扫描

1. 准备包含多个 PDF 的目录
2. 执行带 `source_dir` 的目录扫描
3. 验证多
   - 所有 PDF 都有对应 `.md` 文件
   - `processed-ids.txt` 已更新
   - 文件命名合理

### 测试 3多集成验证

1. 执行 `paper-cacher` 添加论文
2. 执行 `cache-utils` 的 `readPaperCache`
3. 验证新添加的论文出现在返回结果中

---

## 技术说明

### PDF 元数据提取

**方法 A多文件名解析（默认）**
- 优点多无需额外工具
- 缺点多信息有限

**方法 B多PDF 工具读取**
- 使用 PDF Skill 或 MCP 工具
- 提取完整元数据
- 依赖工具可用性

**方法 C多用户输入**
- 最准确
- 需要用户交互

### 文件命名冲突

如果目标文件名已存在多

1. **同源同名**多覆盖旧文件（用户更新了论文）
2. **不同源同名**多添加计数后缀 (`_v2`, `_v3`)

---

## 配置建议

在 `config.json` 中添加多

```json
"skills": {
  "paper-cacher": {
    "description": "论文缓存管理 — 从源目录批量添加论文到缓存",
    "default_domain": "multi_agent_systems",
    "auto_tag": true,
    "ask_confirm": false
  }
}
```

---

## 最佳实践

1. **组织源文件**多按领域/年份组织 PDF 文件
2. **命名规范**多使用 `{年份}{作者}{主题}.pdf` 格式
3. **批量添加**多优先使用目录扫描而非单个文件
4. **验证结果**多添加后检查生成的 `.md` 文件内容
5. **定期清理**多删除重复或过时的缓存文件
