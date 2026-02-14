---
name: domain-knowledge-prep
description: "领域知识准备 — 为评审专家生成特定领域的评审指南和知识点。"
---

# Domain Knowledge Preparation Skill

## 概述

You are the **Domain Knowledge Preparation Skill** — responsible for preparing domain-specific review guidance for peer reviewers.

**调用方式多** `Skill(skill="domain-knowledge-prep", args="{project}:{domain}")`

**核心职责**多
- 读取论文内容，分析目标领域与论文的相关度
- 从对应的 `review-{domain}-domain` Skill 获取领域认知框架
- 根据相关度生成适配的评审指南
- 输出结构化的领域知识供评审专家 Agent 使用

**DO NOT** execute peer review — prepare knowledge for reviewers.

---

## 输入参数

**args 格式**: `{project}:{domain}`

- `{project}`: 项目名称（如 "bridge-test"）
- `{domain}`: 目标领域标识符（如 "knowledge_graph", "multi_agent_systems", "nl2sql", "bridge_engineering"）

**示例调用**:
```bash
Skill(skill="domain-knowledge-prep", args="bridge-test:knowledge_graph")
Skill(skill="domain-knowledge-prep", args="my-project:multi_agent_systems")
```

---

## 执行步骤

### Step 1: 读取论文内容

读取 `workspace/{project}/output/paper.md`，提取多
- 论文标题、摘要、关键词
- 全文内容用于关键词匹配
- 各章节的主题分布

```python
def read_paper_content(project):
    """
    读取论文内容
    """
    paper_path = f"workspace/{project}/output/paper.md"

    with open(paper_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # 提取关键信息
    title = extract_title(content)
    abstract = extract_abstract(content)
    keywords = extract_keywords(content)
    full_text = content

    return {
        "title": title,
        "abstract": abstract,
        "keywords": keywords,
        "full_text": full_text
    }
```

### Step 2: 读取项目上下文

读取 `workspace/{project}/phase1/input-context.md`，提取多
- 研究领域
- 目标系统名称
- 声明的创新点

```python
def read_project_context(project):
    """
    读取项目上下文
    """
    context_path = f"workspace/{project}/phase1/input-context.md"

    with open(context_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # 提取关键信息
    research_area = extract_research_area(content)
    system_name = extract_system_name(content)
    innovations = extract_innovations(content)

    return {
        "research_area": research_area,
        "system_name": system_name,
        "innovations": innovations
    }
```

### Step 3: 加载领域认知框架

**重要**多领域认知框架由对应的 `review-{domain}-domain` Skill 提供。

```python
def load_domain_framework(domain):
    """
    从对应的 review-domain Skill 加载领域认知框架

    domain_skills 映射多
    - knowledge_graph → review-kg-domain
    - multi_agent_systems → review-mas-domain
    - nl2sql → review-nl2sql-domain
    - bridge_engineering → review-bridge-domain
    - data_analysis → review-data-domain
    - software_engineering → review-se-domain
    - human_computer_interaction → review-hci-domain
    """
    skill_mapping = {
        "knowledge_graph": "review-kg-domain",
        "multi_agent_systems": "review-mas-domain",
        "nl2sql": "review-nl2sql-domain",
        "bridge_engineering": "review-bridge-domain",
        "data_analysis": "review-data-domain",
        "software_engineering": "review-se-domain",
        "human_computer_interaction": "review-hci-domain"
    }

    if domain not in skill_mapping:
        raise ValueError(f"Unsupported domain: {domain}")

    skill_name = skill_mapping[domain]

    # 读取对应的 Skill 文件
    skill_path = f".claude/skills/{skill_name}/SKILL.md"
    with open(skill_path, 'r', encoding='utf-8') as f:
        skill_content = f.read()

    # 解析 Skill 内容，提取领域认知框架
    framework = parse_domain_framework(skill_content)

    return framework
```

**领域认知框架包含**（由各 review-domain Skill 提供）多
- 核心研究范式
- 核心概念与评估维度
- 领域评审维度
- 常见评审陷阱及识别方法
- 经典文献对标清单

### Step 4: 计算领域相关度

统计论文中该领域关键词出现的频率多

```python
def calculate_relevance(paper_content, domain_framework):
    """
    计算论文与目标领域的相关度 [0, 1]
    """
    paper_lower = paper_content.lower()
    keywords = domain_framework.get("keywords", [])

    keyword_count = sum(1 for kw in keywords if kw.lower() in paper_lower)

    # 归一化多至少出现 3 个关键词认为完全相关
    relevance = min(keyword_count / 3, 1.0)

    return relevance
```

**判断逻辑**:
- `relevance >= 0.7`: 论文高度相关，生成完整评审指南
- `0.3 <= relevance < 0.7`: 论文中度相关，生成简化评审指南
- `relevance < 0.3`: 论文低相关，建议跳过该评审专家

### Step 5: 生成领域评审指南

根据相关度和领域定义，生成评审指南多

```python
def generate_review_guidance(paper_content, domain_framework, relevance):
    """
    根据相关度生成评审指南
    """
    if relevance >= 0.7:
        return generate_full_guidance(domain_framework)
    elif relevance >= 0.3:
        return generate_simplified_guidance(domain_framework)
    else:
        return generate_skip_guidance()
```

**高度相关 (relevance >= 0.7)**多
- 包含所有 `core_concepts`
- 包含所有 `evaluation_criteria`
- 包含所有 `key_questions`
- 包含 `common_pitfalls`
- 包含 `classic_papers` 用于对比参考

**中度相关 (0.3 <= relevance < 0.7)**多
- 包含核心 `core_concepts`（减少数量）
- 包含关键 `evaluation_criteria`（减少数量）
- 省略详细问题，只保留核心问题

**低相关 (relevance < 0.3)**多
- 设置 `paper_relevance: "low"`
- 建议跳过该评审专家
- 不生成详细评审指南

---

## 输出文件

### 文件 1: 领域知识 JSON

```
workspace/{project}/phase4/domain-knowledge-{domain}.json
```

**格式**:

```json
{
  "skill_id": "domain-knowledge-prep",
  "domain": "{domain}",
  "domain_full_name": "{领域全称}",
  "timestamp": "ISO-8601",
  "paper_analysis": {
    "title": "论文标题",
    "keywords": ["论文中提取的关键词"],
    "domain_keywords_found": ["匹配到的领域关键词"],
    "relevance_score": 0.85
  },
  "paper_relevance": "high|medium|low",
  "review_guidance": {
    "core_concepts": [
      {
        "concept": "概念名称",
        "expect": "论文应该如何使用这个概念",
        "common_issues": ["该概念常见的错误理解或用法"]
      }
    ],
    "evaluation_criteria": [
      "评审标准 1",
      "评审标准 2"
    ],
    "key_questions": [
      "应该问作者的问题 1",
      "应该问作者的问题 2"
    ],
    "common_pitfalls": [
      "该领域论文常见的问题 1",
      "该领域论文常见的问题 2"
    ],
    "classic_references": [
      "经典论文 1",
      "经典论文 2"
    ]
  },
  "recommendation": "proceed|skip",
  "recommendation_reason": "建议原因（如相关度足够）或建议跳过（如相关度过低）"
}
```

### 文件 2: 人类可读摘要（可选）

```
workspace/{project}/phase4/domain-knowledge-{domain}.md
```

包含多
- 领域概述
- 相关度分析
- 核心概念列表
- 评审标准
- 建议的关键问题

---

## 错误处理

### 未知领域
如果请求的领域不在注册表中多
- 返回错误，说明支持的领域列表
- 建议用户扩展领域注册表

### 论文文件不存在
如果 `workspace/{project}/output/paper.md` 不存在多
- 返回错误，要求先生成论文

### 相关度过低
如果相关度 < 0.3多
- 在 JSON 中设置 `recommendation: "skip"`
- 在摘要中明确说明建议跳过该评审专家

---

## 扩展指南

### 添加新领域

按照以下步骤添加新的领域评审支持多

**步骤 1**多创建新的领域评审 Skill

```
.claude/skills/review-{new_domain}-domain/SKILL.md
```

Skill 结构参考现有领域 Skill（如 review-kg-domain），包含多
- 核心研究范式
- 核心概念与评估维度
- 领域评审维度
- 常见评审陷阱
- 经典文献对标

**步骤 2**多在 `config.json` 中添加映射

```json
{
  "skills": {
    "review-{new_domain}-domain": { "description": "{New Domain} 领域评审认知框架" }
  },
  "domain_skills": {
    "new_domain": {
      "skill": "review-{new_domain}-domain",
      "full_name": "New Domain Full Name",
      "keywords": ["keyword1", "keyword2", ...]
    }
  }
}
```

**步骤 3**多更新本 Skill

在 `load_domain_framework` 函数中添加新领域的映射。

---

## 支持的领域

| 标识符 | 全称 | Skill 文件 |
|--------|------|-----------|
| knowledge_graph | Knowledge Graphs and Ontology Engineering | review-kg-domain |
| multi_agent_systems | Multi-Agent Systems (MAS) | review-mas-domain |
| nl2sql | Natural Language to SQL | review-nl2sql-domain |
| bridge_engineering | Bridge Engineering | review-bridge-domain |
| data_analysis | Data Analysis and Machine Learning | review-data-domain |
| software_engineering | Software Engineering | review-se-domain |
| human_computer_interaction | Human-Computer Interaction | review-hci-domain |

**可扩展**: 如需添加新领域，按照扩展指南操作。

---

## 架构说明

**单一数据源架构**多
- 领域认知框架统一由 `review-{domain}-domain` Skill 管理
- `domain-knowledge-prep` 通过读取对应 Skill 文件获取框架
- 知识源单一，易于维护和版本追踪

**知识更新方式**多
- **自动更新**多使用 `domain-knowledge-update` Skill 通过 Web Search 自动获取前沿论文并更新
- **手动编辑**多直接手动编辑 `.claude/skills/review-{domain}-domain/SKILL.md` 文件
- **Git 追踪**多所有更新通过 git commit 追踪历史
- **审核机制**多自动更新后建议人工审核新增内容

**与 domain-knowledge-update 的协作**多
| Skill | 职责 | 操作 |
|-------|------|------|
| **domain-knowledge-update** | 更新领域知识 | Web Search → **写入** `review-{domain}-domain/SKILL.md` |
| **domain-knowledge-prep** | 准备评审指南 | **读取** `review-{domain}-domain/SKILL.md` → 生成评审指南 |

两者操作同一个 Skill 文件，实现单一数据源的读写分离。
