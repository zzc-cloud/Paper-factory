---
name: domain-knowledge-update
description: "领域知识动态更新 — 通过 Web Search 获取前沿论文，直接更新对应的 review-{domain}-domain Skill 文件。"
---

# Domain Knowledge Update Skill

## 概述

You are the **Domain Knowledge Update Skill** — responsible for dynamically updating domain knowledge through Web Search and directly updating the corresponding `review-{domain}-domain` Skill file.

**调用方式：** `Skill(skill="domain-knowledge-update", args="{domain}")`

**核心职责：**
- Search for cutting-edge research papers in the target domain (past 2 years)
- Analyze paper content to extract core concepts and research trends
- **Directly update** the corresponding `review-{domain}-domain/SKILL.md` file
- Generate a summary report of changes
- All updates are tracked via git

**DO NOT** execute peer review — focus on knowledge acquisition and update.

---

## 输入参数

**args 格式**: `{domain}`

- `{domain}`: Target domain identifier (e.g., "knowledge_graph", "multi_agent_systems", "nl2sql", "bridge_engineering")

**示例调用**:
```bash
Skill(skill="domain-knowledge-update", args="knowledge_graph")
Skill(skill="domain-knowledge-update", args="multi_agent_systems")
```

---

## 执行步骤

### Step 1: Domain Validation and Skill Path Resolution

```python
SUPPORTED_DOMAINS = {
    "knowledge_graph": {"skill": "review-kg-domain", "full_name": "Knowledge Graphs and Ontology Engineering"},
    "multi_agent_systems": {"skill": "review-mas-domain", "full_name": "Multi-Agent Systems"},
    "nl2sql": {"skill": "review-nl2sql-domain", "full_name": "Natural Language to SQL"},
    "bridge_engineering": {"skill": "review-bridge-domain", "full_name": "Bridge Engineering"},
    "data_analysis": {"skill": "review-data-domain", "full_name": "Data Analysis and Machine Learning"},
    "software_engineering": {"skill": "review-se-domain", "full_name": "Software Engineering"},
    "human_computer_interaction": {"skill": "review-hci-domain", "full_name": "Human-Computer Interaction"}
}

def get_skill_path(domain):
    """获取对应 review-domain Skill 的文件路径"""
    if domain not in SUPPORTED_DOMAINS:
        raise ValueError(f"Unsupported domain: {domain}")
    skill_name = SUPPORTED_DOMAINS[domain]["skill"]
    return f".claude/skills/{skill_name}/SKILL.md"
```

### Step 2: Search for Cutting-Edge Papers

```python
def search_recent_papers(domain):
    """
    Search for recent research papers in the target domain
    """
    domain_info = SUPPORTED_DOMAINS[domain]
    current_year = 2025  # 或从系统获取当前年份

    # 构建搜索查询
    search_query = f"{domain_info['full_name']} recent research papers {current_year-1} {current_year}"

    # 使用 WebSearch 搜索
    search_results = WebSearch(
        query=search_query,
        result_limits=10
    )

    return search_results
```

### Step 3: Paper Analysis and Knowledge Extraction

```python
def analyze_papers_and_extract_updates(search_results, domain):
    """
    分析论文并提取知识更新
    """
    extracted_updates = {
        "new_concepts": [],
        "new_criteria": [],
        "new_papers": [],
        "new_pitfalls": [],
        "updated_descriptions": []
    }

    for result in search_results:
        try:
            # 使用 WebFetch 获取论文内容
            paper_content = WebFetch(
                url=result['url'],
                description=f"Extract domain knowledge updates for {domain}"
            )

            # 提取各类更新
            concepts = extract_new_concepts(paper_content, domain)
            criteria = extract_new_criteria(paper_content, domain)
            papers = extract_new_papers(paper_content, result)
            pitfalls = extract_new_pitfalls(paper_content, domain)

            extracted_updates["new_concepts"].extend(concepts)
            extracted_updates["new_criteria"].extend(criteria)
            extracted_updates["new_papers"].extend(papers)
            extracted_updates["new_pitfalls"].extend(pitfalls)

        except Exception as e:
            print(f"Error analyzing paper {result['url']}: {str(e)}")
            continue

    return extracted_updates
```

### Step 4: Read and Parse Current Skill File

```python
def read_current_skill(skill_path):
    """
    读取当前的 Skill 文件内容
    """
    with open(skill_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # 解析现有内容结构
    parsed = {
        "header": extract_header(content),
        "core_paradigms": extract_section(content, "核心研究范式"),
        "core_concepts": extract_section(content, "核心概念与评估维度"),
        "evaluation_dimensions": extract_section(content, "领域评审维度"),
        "common_pitfalls": extract_section(content, "常见评审陷阱"),
        "classic_papers": extract_section(content, "经典文献")
    }

    return content, parsed
```

### Step 5: Merge Updates into Skill Content

```python
def merge_updates_to_skill(current_content, updates, domain):
    """
    将更新合并到 Skill 文件中
    """
    updated_content = current_content

    # 1. 添加新的核心概念
    for concept in updates["new_concepts"]:
        updated_content = insert_new_concept(updated_content, concept)

    # 2. 添加新的评估标准
    for criterion in updates["new_criteria"]:
        updated_content = insert_new_criterion(updated_content, criterion)

    # 3. 添加新的经典文献
    for paper in updates["new_papers"]:
        updated_content = insert_new_paper(updated_content, paper)

    # 4. 添加新的常见陷阱
    for pitfall in updates["new_pitfalls"]:
        updated_content = insert_new_pitfall(updated_content, pitfall)

    # 5. 更新版本信息
    updated_content = update_version_info(updated_content)

    return updated_content

def insert_new_concept(content, concept):
    """
    在"核心概念与评估维度"部分插入新概念
    """
    concept_section = find_section(content, "核心概念与评估维度")

    new_concept_text = f"""
#### {concept['name']}

**期望用法**：
- {concept['expect']}

**常见问题**：
{chr(10).join(f"- {issue}" for issue in concept['common_issues'])}

**评审要点**：
- {concept['review_points']}
"""

    # 在该部分末尾插入
    return insert_at_end_of_section(content, "核心概念与评估维度", new_concept_text)
```

### Step 6: Write Updated Skill File

```python
def write_updated_skill(skill_path, updated_content):
    """
    写入更新后的 Skill 文件
    """
    with open(skill_path, 'w', encoding='utf-8') as f:
        f.write(updated_content)

    return skill_path
```

### Step 7: Generate Update Summary

```markdown
# Domain Knowledge Update Summary

## Domain: {domain_full_name}
**Date**: {current_date}
**Skill File Updated**: {skill_path}

## Changes Summary

### New Core Concepts Added ({count})
{concept_list}

### New Evaluation Criteria Added ({count})
{criteria_list}

### New Classic Papers Added ({count})
{paper_list}

### New Common Pitfalls Identified ({count})
{pitfall_list}

## Source Papers Analyzed
{source_papers}

## Git Commit Message
```
git add .claude/skills/{skill_name}/SKILL.md
git commit -m "docs: update {domain} domain knowledge with recent research

- Added {n} new core concepts
- Added {n} new evaluation criteria
- Added {n} new classic papers
- Added {n} new common pitfalls

Source: Web Search {date}"
```
```

---

## 领域知识存储架构

```
.claude/skills/
├── review-kg-domain/SKILL.md       ← KG 领域知识的唯一存储（可被此 Skill 更新）
├── review-mas-domain/SKILL.md      ← MAS 领域知识的唯一存储
├── review-nl2sql-domain/SKILL.md   ← NL2SQL 领域知识的唯一存储
├── review-bridge-domain/SKILL.md   ← Bridge Engineering 领域知识的唯一存储
├── review-data-domain/SKILL.md     ← Data Analysis 领域知识的唯一存储
├── review-se-domain/SKILL.md       ← Software Engineering 领域知识的唯一存储
├── review-hci-domain/SKILL.md      ← HCI 领域知识的唯一存储
└── domain-knowledge-update/SKILL.md ← 更新工具（本 Skill）
```

**架构优势**：
- **单一数据源**：每个领域的知识只存储在一个 Skill 文件中
- **可自动更新**：通过此 Skill 使用 Web Search 自动更新
- **可手动编辑**：也可以直接手动编辑 Skill 文件
- **Git 可追溯**：所有更新通过 git commit 追踪
- **直接读取**：评审专家直接读取对应的 Skill

---

## 支持的领域

| 标识符 | Skill 文件 | 全称 |
|--------|-----------|------|
| knowledge_graph | review-kg-domain | Knowledge Graphs and Ontology Engineering |
| multi_agent_systems | review-mas-domain | Multi-Agent Systems (MAS) |
| nl2sql | review-nl2sql-domain | Natural Language to SQL |
| bridge_engineering | review-bridge-domain | Bridge Engineering |
| data_analysis | review-data-domain | Data Analysis and Machine Learning |
| software_engineering | review-se-domain | Software Engineering |
| human_computer_interaction | review-hci-domain | Human-Computer Interaction |

---

## 错误处理

### Search Errors
- If no papers are found: Report warning, no update made
- If search fails: Retry with alternative keywords
- If too few results: Lower search constraints

### Analysis Errors
- If paper content is unreadable: Skip to next paper
- If extraction fails: Skip to next paper
- If validation fails: Skip to next paper

### File Update Errors
- If Skill file is not found: Report error with correct path
- If file update fails: Report error, keep original file intact
- Always create backup before updating

---

## 使用建议

1. **定期更新**：每 1-2 个月执行一次，保持领域知识前沿性
2. **审查更新**：更新后检查 Skill 文件，确保新增内容准确
3. **Git 提交**：每次更新后通过 git commit 追踪变更历史
4. **手动补充**：对于特别重要的新概念，可以手动编辑 Skill 文件

---

## 与 domain-knowledge-prep 的协作

| Skill | 职责 | 操作 |
|-------|------|------|
| **domain-knowledge-update** | 更新领域知识 | 读取 Web Search → **写入** `review-{domain}-domain/SKILL.md` |
| **domain-knowledge-prep** | 准备评审指南 | **读取** `review-{domain}-domain/SKILL.md` → 生成评审指南 |

两者操作同一个 Skill 文件，实现单一数据源的读写分离。
