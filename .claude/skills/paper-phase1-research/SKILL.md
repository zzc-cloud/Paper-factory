---
name: paper-phase1-research
description: "Phase 1 文献调研与相关工作分析 — 素材收集阶段，支持缓存优化和串行执行。"
---

# Phase 1：研究编排器

## 概述

你是 **Phase 1 研究编排器** — 负责文献调研和相关工作分析。

**调用方式：** `Skill(skill="paper-phase1-research", args="{project}")`

**执行模式：** 串行执行（顺序启动 Agent，简单可靠）

**核心流程：**
1. **领域识别**：使用 LLM 语义分析识别项目研究领域
2. **A1 文献调研**：根据领域动态生成搜索类别并执行检索
3. **B1 相关工作分析**：系统性比较和缺口分析
3.5. **领域理论分析**：Agent Teams 并行读取匹配的领域知识文档（`docs/domain-knowledge/`）
4. **创新聚合**：内联聚合创新点和支撑证据（不再作为独立 Agent）
5. **Quality Gate 1**：验证输出完整性

**缓存支持**（config.cache.enabled=true）：
- **首次执行**：建立缓存基础，检索并存储论文
- **后续执行**：从缓存读取已处理论文，只检索新增内容
- **手动添加**：支持用户直接在缓存目录添加论文

**请勿** 直接撰写论文内容 — 你的职责是协调和聚合。

---

## 步骤 0：领域识别（LLM 语义判断）

### 0.1 读取项目上下文

读取 `workspace/{project}/input-context.md` 并提取：
- `paper_title`
- `target_system`
- `innovations`（创新列表）
- `system_architecture`
- `key_terminology`

### 0.2 LLM 语义分析识别领域

**不要使用硬编码的关键词匹配**。使用 LLM 的语义理解能力分析项目内容，判断涉及哪些研究领域。

**可用领域列表**（从 `config.domain_skills` 获取）：
- `knowledge_graph` — Knowledge Graphs and Ontology Engineering
- `multi_agent_systems` — Multi-Agent Systems (MAS)
- `nl2sql` — Natural Language to SQL (NL2SQL / Text2SQL)
- `bridge_engineering` — Bridge Engineering
- `data_analysis` — Data Analysis and Machine Learning

**分析方法：**
1. 阅读 `input-context.md` 的完整内容
2. 理解项目的核心技术、架构和创新点
3. 判断项目与哪些领域相关（可以是多个领域）
4. 为每个相关领域评估相关度（primary / secondary）

**输出格式：**
```json
{
  "primary_domains": ["knowledge_graph", "nl2sql"],
  "secondary_domains": ["data_analysis"],
  "domain_analysis": {
    "knowledge_graph": {
      "relevance": "primary",
      "reason": "项目使用本体建模和 SPARQL 查询作为核心技术"
    },
    "nl2sql": {
      "relevance": "primary",
      "reason": "项目的主要功能是将自然语言转换为结构化查询"
    },
    "data_analysis": {
      "relevance": "secondary",
      "reason": "项目涉及数据分析和特征工程，但不是核心贡献"
    }
  }
}
```

**记录到文件：** `workspace/{project}/phase1/domain-analysis.json`

### 0.3 生成 A1 搜索类别

根据识别的领域，为 A1 Agent 生成搜索类别列表。

**规则：**
- **Primary 领域** → 每个领域生成 1-2 个搜索类别，最少 8 篇论文/类别
- **Secondary 领域** → 每个领域生成 1 个搜索类别，最少 5 篇论文/类别
- **总类别数** → 3-5 个类别

**示例输出：**
```json
{
  "search_categories": [
    {
      "id": "category_1",
      "name": "NL2SQL / Text-to-SQL Systems",
      "domain": "nl2sql",
      "min_papers": 8,
      "focus": "最新的基于 LLM 的方法、基准测试和领域适配工作"
    },
    {
      "id": "category_2",
      "name": "Ontology-Based Data Access (OBDA)",
      "domain": "knowledge_graph",
      "min_papers": 8,
      "focus": "本体驱动的数据访问框架、映射技术和语义方法"
    },
    {
      "id": "category_3",
      "name": "Knowledge Graph + LLM Integration",
      "domain": "knowledge_graph",
      "min_papers": 5,
      "focus": "KG 增强的 LLM 推理、Graph RAG 和结构化知识引导"
    },
    {
      "id": "category_4",
      "name": "Data Analysis and Feature Engineering",
      "domain": "data_analysis",
      "min_papers": 5,
      "focus": "数据预处理、特征提取和机器学习方法"
    }
  ]
}
```

**记录到文件：** `workspace/{project}/phase1/a1-search-categories.json`

---

## 步骤 1：缓存初始化

### 1.1 初始化缓存目录

**调用：** `Skill(skill="cache-utils", action="init", args="{project}", domain="{primary_domain}")`

**逻辑：**
1. 检查 `workspace/{project}/.cache/` 目录结构
2. 如不存在则创建：`papers/{domain}/`, `search-history/{domain}/`
3. 初始化 `search-history/{domain}/processed-ids.txt`
4. 创建或更新 `papers/{domain}/.last-update.json`

### 1.2 读取已缓存论文

**调用：** `Skill(skill="cache-utils", action="read", args="{project}", domain="{primary_domain}")`

**返回格式：**
```json
[
  {
    "id": "arxiv-2402-xxxxx",
    "title": "Paper Title",
    "authors": ["Author A", "Author B"],
    "year": 2024,
    "venue": "arXiv preprint arXiv:2402.xxxxx",
    "source": "websearch",
    "tags": ["multi-agent", "cognitive architecture"],
    "status": "read",
    "file": "workspace/{project}/.cache/papers/{domain}/arxiv-2402-xxxxx.md"
  }
]
```

**用途：**
- 将缓存的论文传递给 A1 Agent 作为"已有论文"参考
- 在 WebSearch 前告知 Agent 哪些论文已处理过

---

## 步骤 2：A1 文献调研

### 2.1 启动 A1 Agent

**Skill：** `Skill(skill="a1-literature-surveyor", args="{project}")`

```python
Task(
    subagent_type="general-purpose",
    model=config.models.reasoning,
    name="A1-LiteratureSurveyor",
    prompt="""You are the A1 Literature Surveyor agent for project "{project}".

Call Skill(skill="a1-literature-surveyor", args="{project}") and follow its instructions completely.

Return a brief confirmation when complete."""
)
```

**等待完成** 并验证输出：
- `workspace/{project}/phase1/a1-literature-survey.json` 存在
- `workspace/{project}/phase1/a1-literature-survey.md` 存在

**失败处理：**
- A1 失败 → **关键错误**（必需 agent），重试一次
- 重试前验证 workspace 中的部分输出

---

## 步骤 3：B1 相关工作分析

### 3.1 启动 B1 Agent

**调用方式：**
```python
Task(
    subagent_type="general-purpose",
    model="opus",  # config.agents.b1.model -> "reasoning" -> "opus"
    name="B1-RelatedWorkAnalyst",
    prompt="""You are the B1 Related Work Analyst agent for project "{project}".

Call Skill(skill="b1-related-work-analyst", args="{project}") and follow its instructions completely.

Return a brief confirmation when complete."""
)
```

**等待完成** 并验证输出：
- `workspace/{project}/phase1/b1-related-work.json` 存在
- `workspace/{project}/phase1/b1-related-work.md` 存在

**失败处理：**
- B1 失败 → **关键错误**（必需 agent），重试一次

---

## 步骤 3.5：领域理论分析（Agent Teams 并行）

**条件执行**：仅当步骤 0 识别出的领域有对应的领域知识文档（`docs/domain-knowledge/`）时执行。

### 3.5.1 确定需要读取的领域知识文档

从步骤 0 的 `domain-analysis.json` 读取 `primary_domains` 和 `secondary_domains`，映射到对应的文档：

| domain_id | 文档路径 | 输出文件 |
|-----------|---------|---------|
| knowledge_graph | docs/domain-knowledge/kg.md | skill-kg-theory.json |
| multi_agent_systems | docs/domain-knowledge/mas.md | skill-mas-theory.json |
| nl2sql | docs/domain-knowledge/nl2sql.md | skill-nl2sql-theory.json |
| bridge_engineering | docs/domain-knowledge/bridge.md | skill-bridge-theory.json |
| data_analysis | docs/domain-knowledge/data.md | skill-data-theory.json |

### 3.5.2 并行启动 DK-Agent Teams

为每个匹配的领域知识文档启动一个独立 Agent，使用 `run_in_background=true` 实现并行：

```python
dk_tasks = {}
for domain_id in identified_domains:
    doc_path = DOMAIN_DOC_MAP[domain_id]["doc"]
    output_file = DOMAIN_DOC_MAP[domain_id]["output"]
    domain_full_name = DOMAIN_DOC_MAP[domain_id]["full_name"]

    task = Task(
        subagent_type="general-purpose",
        model="sonnet",
        name=f"DK-{domain_id}",
        run_in_background=True,
        prompt=f"""You are a Domain Theory Analyst for the {domain_full_name} domain.

READ: {doc_path}
This document contains domain knowledge for {domain_full_name}.
Follow the "Phase 1 执行步骤" (or equivalent theory analysis section) in the document.

INPUT: workspace/{{project}}/input-context.md
OUTPUT: workspace/{{project}}/phase1/{output_file}

CONSTRAINTS:
- Do NOT use WebSearch — all analysis is based on LLM knowledge + the domain knowledge document
- Only use Read, Write, Glob, Grep tools
- Read input-context.md first to understand the target system
- Map the target system to the domain's theoretical frameworks
- Generate structured findings with academic significance

Return: brief confirmation when complete."""
    )
    dk_tasks[domain_id] = task
```

### 3.5.3 等待所有 DK-Agent 完成

```python
for domain_id, task_id in dk_tasks.items():
    result = TaskOutput(task_id=task_id, block=True, timeout=180000)
    if result["status"] == "completed":
        log(f"DK-{domain_id} completed successfully")
    else:
        log(f"DK-{domain_id} failed — non-critical, continuing")
```

**失败处理：**
- DK-Agent 失败 → **非关键错误**（领域理论分析是增强性的）
- 记录失败并继续，论文可以在缺少任何单个领域分析的情况下继续
- 在 Quality Gate 1 中报告

---

## 步骤 4：创新聚合（内联执行）

**不再作为独立 Agent**。编排器直接执行聚合逻辑。

### 4.1 发现所有分析文件

使用 `Glob` 发现 `workspace/{project}/phase1/` 中所有可用的分析文件：
- Agent 输出：`a1-literature-survey.json`, `b1-related-work.json`
- 领域 Skill 输出（如果存在）：`skill-*.json`

### 4.2 读取并聚合

读取以下文件：
1. `input-context.md` — 创新点的权威来源
2. `a1-literature-survey.json` — 文献调研结果
3. `b1-related-work.json` — 相关工作分析和缺口识别
4. 所有 `skill-*.json` 文件（如果存在）

### 4.3 提取创新点并映射证据

对于 `input-context.md` 中列出的每个创新点：
1. 从 B1 的缺口分析中提取支撑证据
2. 从 A1 的文献调研中提取相关论文
3. 从领域 Skill 输出中提取理论支撑（如果存在）

### 4.4 生成聚合输出

**输出文件：** `workspace/{project}/phase1/innovation-summary.json`

**格式：**
```json
{
  "agent_id": "phase1-orchestrator",
  "phase": 1,
  "status": "complete",
  "timestamp": "YYYY-MM-DDTHH:MM:SSZ",
  "summary": "聚合了 N 个创新点，映射了来自 A1、B1 和领域 Skill 的支撑证据",
  "data": {
    "innovations": [
      {
        "innovation_id": "I1",
        "title": "创新点标题（来自 input-context.md）",
        "description": "创新点描述（来自 input-context.md）",
        "evidence": {
          "from_b1_gaps": ["缺口 G1", "缺口 G2"],
          "from_a1_papers": ["P01", "P05", "P12"],
          "from_skills": {
            "skill-kg-theory": "理论支撑描述",
            "skill-mas-theory": "理论支撑描述"
          }
        },
        "novelty_argument": "基于 B1 缺口分析的新颖性论证"
      }
    ],
    "research_positioning": {
      "primary_domains": ["knowledge_graph", "nl2sql"],
      "unique_contributions": ["贡献 1", "贡献 2"],
      "positioning_statement": "目标系统相对于最先进技术的独特贡献（来自 B1）"
    }
  }
}
```

**同时生成 Markdown 版本：** `workspace/{project}/phase1/innovation-summary.md`

---

## 步骤 5：Quality Gate 1

### 5.1 验证预期输出

**必选文件（4 个）：**
- `phase1/domain-analysis.json`
- `phase1/a1-literature-survey.json`
- `phase1/a1-literature-survey.md`
- `phase1/b1-related-work.json`
- `phase1/b1-related-work.md`
- `phase1/innovation-summary.json`
- `phase1/innovation-summary.md`

**条件文件**（基于领域 Skill 调用）：
- 如果调用了领域 Skill：`phase1/skill-*.json`

### 5.2 执行验证

1. 使用 `Glob` 模式：`workspace/{project}/phase1/*.json` 和 `*.md`
2. 对比预期与实际
3. 识别缺失文件
4. 验证 JSON 文件的结构完整性

### 5.3 记录 Gate 结果

写入 `workspace/{project}/quality-gates/gate-1.json`：
```json
{
  "gate": 1,
  "phase": "phase1-research",
  "status": "passed|failed",
  "timestamp": "ISO-8601",
  "execution_mode": "serial_with_parallel_dk",
  "activated_agents": ["A1", "B1"],
  "activated_dk_agents": ["DK-knowledge_graph", "DK-multi_agent_systems"],
  "identified_domains": {
    "primary": ["knowledge_graph", "nl2sql"],
    "secondary": ["data_analysis"]
  },
  "files_expected": [...],
  "files_found": [...],
  "files_missing": [...],
  "validation_details": {
    "a1_papers_count": 35,
    "b1_gaps_count": 7,
    "innovations_count": 5
  }
}
```

### 5.4 Gate 判定

**通过条件：**
1. 所有必选文件存在
2. A1 论文数量 >= 30
3. B1 缺口数量 >= 5
4. 创新点数量 >= 3

**失败处理：**
- 如果 Gate 1 失败 → 记录错误并通知用户
- 选项：重试失败的 Agent / 手动干预 / 中止流水线

---

## 错误处理

### Agent 启动失败

如果 Agent 启动失败或崩溃：
1. 检查 workspace 中是否有部分输出
2. 选项：重试一次 / 人工干预
3. 记录到 quality-gates/errors.json

### 领域识别失败

如果步骤 0 的领域识别失败：
- 回退到默认领域：`knowledge_graph` + `data_analysis`
- 记录警告并继续

### 缓存读取失败

如果缓存读取失败：
- 非关键错误 — 继续执行，不使用缓存
- 记录警告

---

## 成功标准

Phase 1 在以下条件满足时 **完成**：
1. Quality Gate 1 状态为 "passed"
2. 所有必选输出文件存在且有效
3. A1 和 B1 均已成功完成

向编排器报告完成并进入 Phase 2。

---

## 与旧版本的主要变化

1. **删除并行模式** — 只保留串行执行，简化逻辑
2. **删除 A3 Agent** — 不再单独启动 MAS 文献研究员
3. **删除 A4 Agent** — 创新聚合改为编排器内联执行
4. **添加 B1 Agent** — 相关工作分析从 Phase 2 前移到 Phase 1
5. **LLM 语义判断** — 步骤 0 使用 LLM 分析领域，不再硬编码关键词
6. **动态搜索类别** — A1 的搜索类别由编排器根据领域动态生成
7. **简化 Quality Gate** — 只验证核心输出，不再追踪并行性能指标
