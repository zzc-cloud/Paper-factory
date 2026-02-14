---
name: cache-utils
description: "论文缓存工具集 — 提供论文缓存的读写、搜索、更新等核心功能"
---

# 论文缓存工具集

## 概述

提供论文缓存系统的核心工具函数，支持多
- 缓存初始化与验证
- 论文条目读写 (Markdown + Frontmatter)
- 增量检索（基于历史避免重复）
- 缓存索引生成和维护
- 用户手动添加论文的解析

**调用方式多** 这些函数通常由 `paper-phase1-research` Skill 调用，也可独立使用。

---

## 缓存目录结构

```
workspace/.cache/
├── papers/                          # 论文缓存
│   ├── {domain}/
│   │   ├── README.md            # 领域说明
│   │   ├── {paper-id}.md       # 论文条目
│   │   ├── .index.json          # 索引（自动生成）
│   │   └── .last-update.json    # 更新时间戳
├── search-history/                  # 检索历史
│   ├── {domain}/
│   │   ├── queries.log           # 历史检索查询
│   │   └── processed-ids.txt      # 已处理的论文ID列表
└── .cache-info.json               # 全局缓存元数据
```

---

## 核心函数

### 1. initCache(project, domain)

**功能多** 初始化指定领域的缓存目录结构

**参数多**
- `project`: 项目名称
- `domain`: 领域标识符（如 "multi_agent_systems"）

**执行多**
1. 检查 `workspace/{project}/.cache/` 目录
2. 创建 `{domain}/` 和 `search-history/{domain}/` 子目录
3. 初始化 `processed-ids.txt`（如不存在）
4. 写入或更新 `.last-update.json`

**输出多** 无返回值，确保目录结构完整

---

### 2. readPaperCache(project, domain)

**功能多** 读取指定领域的所有缓存论文

**参数多**
- `project`: 项目名称
- `domain`: 领域标识符

**执行多**
1. 使用 `Glob` 查找 `workspace/{project}/.cache/papers/{domain}/*.md`
2. 排除 `README.md` 和以 `.` 开头的文件
3. 解析每个文件的 Frontmatter 元数据
4. 返回结构化的论文列表

**返回格式多**
```json
[
  {
    "id": "arxiv-2402-xxxxx",
    "title": "Paper Title",
    "authors": ["Author A", "Author B"],
    "year": 2024,
    "venue": "arXiv preprint arXiv:2402.xxxxx",
    "citation_count": 7,
    "source": "websearch",
    "added_date": "2024-02-14",
    "tags": ["multi-agent", "cognitive architecture"],
    "status": "read",
    "relevance_score": 0.9,
    "file": "workspace/{project}/.cache/papers/{domain}/arxiv-2402-xxxxx.md"
  },
  ...
]
```

---

### 3. writePaperCache(project, domain, paperData)

**功能多** 写入单篇论文到缓存

**参数多**
- `project`: 项目名称
- `domain`: 领域标识符
- `paperData`: 论文数据对象（包含 Frontmatter 字段和内容）

**paperData 结构多**
```json
{
  "id": "arxiv-2402-xxxxx",
  "title": "Paper Title",
  "authors": ["Author A", "Author B"],
  "year": 2024,
  "venue": "arXiv preprint arXiv:2402.xxxxx",
  "citation_count": 7,
  "source": "websearch" | "manual",
  "added_date": "2024-02-14",
  "tags": ["multi-agent", "cognitive architecture"],
  "status": "read" | "skm" | "todo",
  "relevance_score": 0.9,
  "summary": "## Summary\n\n论文摘要...",
  "contributions": "## Key Contributions\n\n1. ...\n2. ...",
  "relevance": "## Relevance to Current Project\n\n关联点..."
}
```

**执行多**
1. 生成 Markdown 格式（Frontmatter + 内容）
2. 写入 `workspace/{project}/.cache/papers/{domain}/{id}.md`
3. 更新 `.last-update.json`
4. 将 `id` 添加到 `search-history/{domain}/processed-ids.txt`

**输出多** 写入的文件路径

---

### 4. getProcessedIds(project, domain)

**功能多** 获取已处理的论文ID列表

**参数多**
- `project`: 项目名称
- `domain`: 领域标识符

**执行多**
1. 读取 `workspace/{project}/.cache/search-history/{domain}/processed-ids.txt`
2. 按行分割符（换行）解析ID列表
3. 返回 Set 或 Array

**返回多** `["id1", "id2", ...]`

---

### 5. searchWithCache(project, domain, query, webSearchFunction)

**功能多** 增量检索 — 避免重复检索已处理的论文

**参数多**
- `project`: 项目名称
- `domain`: 领域标识符
- `query`: 检索查询字符串
- `webSearchFunction`: 执行 WebSearch 的函数引用

**执行流程多**
```javascript
// 1. 获取已处理的ID列表
const knownIds = getProcessedIds(project, domain);
const knownSet = new Set(knownIds);

// 2. 执行 WebSearch
const results = await webSearchFunction(query);

// 3. 分离新增和已缓存
const newPapers = results.filter(r => !knownSet.has(r.id));
const cachedPapers = results.filter(r => knownSet.has(r.id));

// 4. 只为新增论文生成详细缓存
for (const paper of newPapers) {
    await writePaperCache(project, domain, paper);
    knownSet.add(paper.id);
}

// 5. 记录检索历史
const logEntry = `${new Date().toISOString()} | QUERY | "${query}"`;
const resultEntry = `${new Date().toISOString()} | RESULT | ${results.length} papers found, ${newPapers.length} new, ${cachedPapers.length} from cache`;
appendToLog(`workspace/{project}/.cache/search-history/${domain}/queries.log`, [logEntry, resultEntry]);

// 6. 保存更新后的ID列表
saveProcessedIds(project, domain, Array.from(knownSet));

// 7. 返回结果
return {
    all: results,
    new: newPapers,
    cached: cachedPapers,
    stats: {
        total: results.length,
        newCount: newPapers.length,
        cachedCount: cachedPapers.length,
        cacheRate: (cachedPapers.length / results.length * 100).toFixed(1) + '%'
    }
};
```

**返回多**
```json
{
  "all": [...],          // 所有检索结果
  "new": [...],          // 新增论文（已写缓存）
  "cached": [...],       // 来自缓存的论文
  "stats": {
    "total": 12,
    "newCount": 3,
    "cachedCount": 9,
    "cacheRate": "75.0%"
  }
}
```

---

### 6. parsePaperFrontmatter(markdownContent)

**功能多** 解析论文 Markdown 文件的 Frontmatter

**参数多**
- `markdownContent`: Markdown 文件内容字符串

**执行多**
1. 提取 `---` 分隔的 Frontmatter 块
2. 解析 YAML 格式的元数据
3. 处理数据类型（字符串、数组、数字）

**返回多** 解析后的元数据对象

---

### 7. generateCacheIndex(project, domain)

**功能多** 生成或更新领域缓存索引

**参数多**
- `project`: 项目名称
- `domain`: 领域标识符

**执行多**
1. 读取所有 `.md` 文件
2. 提取元数据
3. 生成 `.index.json`，包含多
   - 论文数量统计
   - 按年份/venue/tag 的分类统计
   - 最后更新时间

**输出示例多**
```json
{
  "domain": "multi_agent_systems",
  "total_papers": 42,
  "last_update": "2024-02-14T10:30:00Z",
  "by_year": {
    "2024": 18,
    "2023": 15,
    "2022": 9
  },
  "by_source": {
    "websearch": 35,
    "manual": 7
  },
  "papers": [
    { "id": "...", "title": "...", "year": 2024, ... }
  ]
}
```

---

### 8. logQuery(project, domain, query, result)

**功能多** 记录检索查询到历史日志

**参数多**
- `project`: 项目名称
- `domain`: 领域标识符
- `query`: 检索查询字符串
- `result`: 检索结果摘要

**格式多**
```
2024-02-14T10:30:00.000Z | QUERY | "multi-agent cognitive architecture 2024"
2024-02-14T10:30:15.500Z | RESULT | Found 12 papers (3 new, 9 cached)
```

---

## 论文条目 Markdown 模板

### Frontmatter 字段定义

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `id` | string | ✅ | 唯一标识符（如 "arxiv-2402-xxxxx"）|
| `title` | string | ✅ | 论文标题 |
| `authors` | array | ✅ | 作者列表 |
| `year` | number | ✅ | 发表年份 |
| `venue` | string | ✅ | 发表场所 |
| `citation_count` | number | ❌ | 引用数 |
| `source` | string | ✅ | 来源多"websearch" \| "manual" |
| `added_date` | string | ✅ | 添加到缓存的日期 (ISO 8601) |
| `tags` | array | ✅ | 标签/关键词 |
| `status` | string | ✅ | 阅读状态多"read" \| "skm" \| "todo" |
| `relevance_score` | number | ❌ | 与当前项目的相关度 (0-1) |

### 正文结构

```markdown
---
id: "paper-id"
title: "Paper Title"
authors: ["Author A", "Author B"]
year": 2024
venue: "Conference/Journal"
source: "websearch"
added_date: "2024-02-14T10:30:00Z"
tags": ["keyword1", "keyword2"]
status": "read"
---

## Summary

论文的核心内容摘要...

## Key Contributions

1. 贡献点一
2. 贡献点二

## Relevance to Current Project

本论文与当前项目的关联多
- 具体关联点一
- 具体关联点二

## Notes (可选)

额外的注释、摘录或想法...
```

---

## 用户手动添加论文

用户可以在 `workspace/{project}/.cache/papers/{domain}/` 下直接创建 `.md` 文件多

**示例多**
```markdown
---
id: "manual-bdi-1989"
title: "Multiagent Systems: A Distributed AI Approach"
authors: ["Bond, A.H.", "Gasser, L."]
year": 1989
venue: "Readings in Distributed Artificial Intelligence"
source: "manual"
added_date: "2024-02-14"
tags": ["foundational", "BDI", "multi-agent"]
status": "read"
---

## Summary

这是多智能体系统的奠基性论文，提出了BDI参考架构...

## Key Contributions

1. 定义了多智能体系统的核心概念
2. 提出了BDI参考架构

## Relevance to Current Project

本论文提供了我们系统的理论基础...
```

系统会自动多
1. 解析新添加的文件
2. 将 `id` 添加到 `processed-ids.txt`
3. 在下次检索时纳入该论文
4. 更新 `.index.json`

---

## 错误处理

### 目录不存在

- **检测**多`!Glob("workspace/{project}/.cache/papers/{domain}/*")`
- **处理**多自动调用 `initCache(project, domain)`
- **日志**多记录"缓存目录不存在，已初始化"

### Frontmatter 解析失败

- **检测**多`!markdownContent.match(/^---$/m)`
- **处理**多跳过该文件，记录警告
- **日志**多`"Warning: {filename} has invalid Frontmatter, skipping"`

### ID 冲突

- **检测**多尝试写缓存时发现 `id` 已存在
- **处理**多覆盖旧文件（用户可能更新了论文信息）
- **日志**多`"Info: Updated existing paper {id}"`

---

## 配置支持

缓存系统支持从 `config.json` 读取配置多

```json
{
  "cache": {
    "enabled": true,
    "max_papers_per_domain": 500,
    "purge_after_days": 365,
    "auto_generate_index": true
  }
}
```

---

## 使用示例

### 在 paper-phase1-research 中使用

```
# Phase 1: Research Orchestrator

## Step 1: 初始化缓存

Call: `Skill(skill="cache-utils", action="init", args="{project}", domain="{domain}")`

## Step 2: 执行增量检索

const searchResult = await searchWithCache(
    "{project}",
    "{domain}",
    "multi-agent cognitive architecture 2024",
    webSearch
);

Log: `Found ${searchResult.stats.total} papers (${searchResult.stats.newCount} new, ${searchResult.stats.cachedCount} from cache)`

## Step 3: 读取所有缓存论文

const cachedPapers = await readPaperCache("{project}", "{domain}");
```

---

## 验证测试

缓存初始化多
1. 创建 `.cache/` 目录结构
2. 生成初始 `processed-ids.txt`
3. 写入 `.cache-info.json`

论文读写多
1. 写入测试论文
2. 读取并验证 Frontmatter 解析
3. 验证 `processed-ids.txt` 更新

增量检索多
1. 执行 WebSearch
2. 验证缓存论文正确识别
3. 验证只有新论文被写缓存
4. 检查 `queries.log` 记录

用户添加多
1. 手动创建 `.md` 文件
2. 验证系统能正确解析
3. 验证 ID 被添加到 `processed-ids.txt`
