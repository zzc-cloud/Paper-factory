# 领域知识注入与动态专家选择机制

## 问题背景

当前 Paper Factory 的 Phase 4 评审架构存在两个核心问题：

### 问题 1：静态的专家列表
当前设计固定启动 5 个评审专家（技术、领域、清晰度、重要性、写作质量），但实际上：
- 领域专家涵盖范围过广：KG、MAS、NL2SQL、桥梁工程、交通、数据分析等
- 并非每篇论文都需要所有评审视角
- 应该根据**论文的实际内容**动态选择需要的评审专家

### 问题 2：领域专家的"领域知识"来源不明
当前 `D1-Domain-Expert` 的 prompt 声称从以下来源获取领域知识：
```
- workspace/{project}/phase1/input-context.md  (项目概述)
- workspace/{project}/output/paper.md  (论文内容)
```

这存在严重问题：
- **input-context.md** 只是用户输入的项目描述，不包含该领域的专业知识
- **paper.md** 是要评审的对象，不能作为知识来源
- Agent 缺乏该领域的**理论基础、评审标准、常见问题**

这导致领域评审专家实际上只是一个"通用评审模板"，无法提供有价值的领域反馈。

---

## 设计方案

### 核心思路：Skill + Agent 协同

```
┌─────────────────────────────────────────────────────────────────────┐
│                    Phase 4: Quality Orchestrator           │
│                                                             │
│  1. 读取 paper.md → 分析论文涉及哪些领域                   │
│                                                             │
│  2. 动态判断需要哪些评审专家                              │
│     ┌─────────────────────────────────────────────┐              │
│     │ 智能决策逻辑（Team Lead + Skill）    │              │
│     └─────────────────────────────────────────────┘              │
│                       ↓                                     │
│  3. 为选定的专家准备领域知识                            │
│     ┌───────────────────────────────────────┐                  │
│     │ domain-knowledge-prep Skill        │                  │
│     │ - 基于论文内容生成领域评审指南       │                  │
│     │ - 包含该领域的理论要点、评审标准    │                  │
│     └───────────────────────────────────────┘                  │
│                       ↓                                     │
│  4. 启动评审专家（传入领域知识）                            │
│     ┌───────────────────────────────────────┐                  │
│     │ D1-Reviewer-{domain} Agent       │                  │
│     │ - 接收领域评审指南                │                  │
│     │ - 基于指南执行评审                │                  │
│     └───────────────────────────────────────┘                  │
│                       ↓                                     │
│  5. 收集评审报告，执行 D2 修订                           │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 组件设计

### Component 1: domain-knowledge-prep Skill

**文件**: `.claude/skills/domain-knowledge-prep/SKILL.md`

**职责**: 为指定的评审专家准备领域知识

**输入**:
- `workspace/{project}/output/paper.md` — 要评审的论文
- `workspace/{project}/phase1/input-context.md` — 项目概述
- `{domain}` — 目标领域（如 "knowledge_graph", "multi_agent_systems", "nl2sql"）

**输出**: `workspace/{project}/phase4/domain-knowledge-{domain}.json`

```json
{
  "domain": "knowledge_graph",
  "domain_full_name": "Knowledge Graphs and Ontology Engineering",
  "paper_relevance": "high",
  "detection_keywords": ["RDF", "OWL", "SPARQL", "ontology", "knowledge graph"],
  "found_in_paper": true,
  "review_guidance": {
    "core_concepts": [
      {
        "concept": "RDF",
        "expect": "论文应正确定义 RDF 三元组模型",
        "common_issues": ["与 XML 混淆", "忽略 blank node 处理"]
      },
      {
        "concept": "OWL 2",
        "expect": "应说明使用的 OWL 2 子语言（DL、QL、Full）",
        "common_issues": ["声称 OWL 支持但未指明子语言", "混淆 OWL 与 RDF Schema"]
      }
    ],
    "evaluation_criteria": [
      "领域理论引用的准确性（是否引用经典的 KG 论文如 RDF2004、OWL2008）",
      "本体设计方法的合理性（是否采用标准的本体设计模式）",
      "推理方法的评估（是否对推理能力有量化评估）",
      "与 SOTA 的比较（是否与最新的 GNN、KGE 方法对比）"
    ],
    "key_questions": [
      "论文声称的本体表达能力是否与使用的 OWL 子语言匹配？",
      "图数据规模是否充分支撑实验结论？",
      "是否讨论了本体对齐/融合的挑战？"
    ],
    "common_pitfalls": [
      "将知识图谱等同于关系数据库",
      "忽视本体演化与版本管理",
      "缺少对推理复杂度的分析"
    ]
  }
}
```

**执行逻辑**:
1. 读取论文全文，提取关键词和主题
2. 检查目标领域的检测关键词是否在论文中出现
3. 如果匹配度低（< 20%），返回 `{ "paper_relevance": "low" }`，建议跳过该专家
4. 如果匹配度高，生成该领域的评审指南
5. 评审指南包含：
   - **核心概念**: 该领域的关键概念，论文应如何正确使用
   - **评审标准**: 评估论文时应关注的维度
   - **常见问题**: 该领域论文容易犯的错误
   - **关键问题**: 应该问作者的具体问题

---

### Component 2: 智能专家选择协议

**文件**: 在 `paper-phase4-quality` Skill 中实现

**决策逻辑**: Team Lead 读取论文后，自主判断需要哪些评审专家

```python
# 伪代码：Team Lead 的决策逻辑

def select_reviewers(paper_content, config):
    """
    Team Lead 基于论文内容自主判断需要哪些评审专家
    """
    reviewers_needed = []

    # 必选专家：几乎所有论文都需要
    reviewers_needed.append("D1-Technical-Expert")      # 技术实现评审
    reviewers_needed.append("D1-Clarity-Expert")        # 清晰度评审
    reviewers_needed.append("D1-Writing-Quality-Expert")  # 写作质量评审

    # 条件专家：基于论文内容判断

    # 领域评审专家 - 选择最相关的 1-2 个
    domain_relevance = analyze_paper_domains(paper_content)
    top_domains = sorted(domain_relevance.items(), key=lambda x: x[1], reverse=True)[:2]
    for domain, score in top_domains:
        if score > 0.3:  # 相关度阈值
            reviewers_needed.append(f"D1-Domain-Expert-{domain}")

    # 重要性评审专家 - 论文声称有重大贡献时
    if claims_novel_contribution(paper_content):
        reviewers_needed.append("D1-Significance-Expert")

    return reviewers_needed


def analyze_paper_domains(paper_content):
    """
    分析论文涉及哪些领域
    返回: {domain: relevance_score}
    """
    domains = {
        "knowledge_graph": 0,
        "multi_agent_systems": 0,
        "nl2sql": 0,
        "bridge_engineering": 0,
        "data_analysis": 0,
        # ... 可扩展更多领域
    }

    # 基于关键词匹配
    domain_keywords = {
        "knowledge_graph": ["KG", "ontology", "RDF", "OWL", "SPARQL", "knowledge graph"],
        "multi_agent_systems": ["multi-agent", "MAS", "BDI", "agent communication"],
        "nl2sql": ["NL2SQL", "Text2SQL", "schema linking", "SQL generation"],
        "bridge_engineering": ["bridge", "structural health", "inspection", "BIM"],
        "data_analysis": ["data mining", "clustering", "classification", "regression"]
    }

    for domain, keywords in domain_keywords.items():
        for keyword in keywords:
            if keyword.lower() in paper_content.lower():
                domains[domain] += 1

    # 归一化到 [0, 1]
    max_score = max(domains.values())
    if max_score > 0:
        domains = {k: v/max_score for k, v in domains.items()}

    return domains
```

**决策示例**:

| 论文类型 | 选中的评审专家 | 原因 |
|----------|--------------|------|
| KG 本体论文 | Technical, Clarity, Writing, Domain-KG | 涉及 KG 领域 |
| MAS 系统论文 | Technical, Clarity, Writing, Domain-MAS, Significance | 涉及 MAS 且声称创新 |
| NL2SQL 论文 | Technical, Clarity, Writing, Domain-NL2SQL | 涉及 NL2SQL 领域 |
| 纯算法论文（无领域） | Technical, Clarity, Writing | 不涉及特定领域 |

---

### Component 3: 领域评审专家 Agent

**重构**: `agents/phase4/reviewers/d1-reviewer-domain-expert.md`

**核心变化**: 从"通用领域专家"改为"接收领域知识的评审执行者"

```markdown
## 输入文件

### 领域评审指南（新增，必需）：
```
workspace/{project}/phase4/domain-knowledge-{domain}.json
```

这是由 `domain-knowledge-prep` Skill 生成的该领域评审指南。**如果此文件不存在，拒绝执行评审**并要求 Team Lead 先调用 domain-knowledge-prep。

### 项目上下文：
```
workspace/{project}/phase1/input-context.md
```
项目概述，用于理解论文背景。

### 主要输入：
```
workspace/{project}/output/paper.md
```
这是完整的已组装论文。

---

## 执行步骤

### Step 1: 加载领域评审指南

读取 `domain-knowledge-{domain}.json`，提取：
- `review_guidance.core_concepts` — 核心概念及其常见问题
- `review_guidance.evaluation_criteria` — 该领域的评审标准
- `review_guidance.key_questions` — 应该问作者的问题
- `review_guidance.common_pitfalls` — 该领域常见误区

### Step 2: 基于领域指南评审论文

**对于每个核心概念**：
1. 检查论文是否正确定义和使用该概念
2. 识别是否出现了 `common_issues` 中的任何问题
3. 在评审报告中指出具体问题

**对于每个评审标准**：
1. 根据标准评估论文
2. 给出 1-5 分的评分和具体评语

**对于每个关键问题**：
1. 基于论文内容回答问题
2. 如果论文未涉及该问题，标注"不适用"

### Step 3: 输出评审报告

生成与领域相关的评审报告，突出：
- 领域概念的准确性
- 与 SOTA 的比较
- 领域特定的缺失或问题
- 改进建议
```

---

## 实施计划

### Step 1: 创建 domain-knowledge-prep Skill
- 文件: `.claude/skills/domain-knowledge-prep/SKILL.md`
- 包含各领域的知识模板
- 支持可扩展的领域注册表

### Step 2: 重构领域评审专家 Agent
- 修改 `agents/phase4/reviewers/d1-reviewer-domain-expert.md`
- 新增领域评审指南作为必需输入
- 添加领域知识加载逻辑

### Step 3: 更新 paper-phase4-quality Skill
- 添加动态专家选择协议
- 添加 domain-knowledge-prep Skill 调用逻辑
- 更新评审流程图

### Step 4: 更新配置和文档
- `config.json`: 新增领域注册表
- `docs/agents-catalog.md`: 更新领域评审专家描述
- `docs/architecture.md`: 更新 Phase 4 数据流图

---

## 领域注册表（可扩展）

```json
{
  "domains": {
    "knowledge_graph": {
      "full_name": "Knowledge Graphs and Ontology Engineering",
      "keywords": ["KG", "ontology", "RDF", "OWL", "SPARQL", "knowledge graph", "RDFS"],
      "core_concepts": ["RDF", "OWL", "SPARQL", "DL", "reasoning"],
      "review_criteria": ["theory_accuracy", "ontology_design", "reasoning_evaluation", "sota_comparison"]
    },
    "multi_agent_systems": {
      "full_name": "Multi-Agent Systems",
      "keywords": ["multi-agent", "MAS", "BDI", "Contract Net", "Blackboard", "agent communication"],
      "core_concepts": ["BDI", "coordination", "negotiation", "organization"],
      "review_criteria": ["architecture_correctness", "protocol_design", "emergent_behavior"]
    },
    "nl2sql": {
      "full_name": "Natural Language to SQL",
      "keywords": ["NL2SQL", "Text2SQL", "schema linking", "SQL generation", "text-to-SQL"],
      "core_concepts": ["schema linking", "SQL synthesis", "execution feedback", "generalization"],
      "review_criteria": ["coverage", "accuracy", "generalization", "execution"]
    },
    "bridge_engineering": {
      "full_name": "Bridge Engineering",
      "keywords": ["bridge", "structural health", "inspection", "BIM", "SHM"],
      "core_concepts": ["NDE", "sensors", "damage detection", "load rating"],
      "review_criteria": ["methodology", "sensor_fusion", "standard_compliance"]
    }
  }
}
```

---

## 优势总结

1. **真正的领域专家**: 通过 domain-knowledge-prep Skill 注入领域知识，确保评审专家"懂"该领域

2. **智能专家选择**: Team Lead 基于论文内容动态决策，不启动无关的评审专家，节省资源

3. **可扩展性**: 新增领域只需：
   - 在领域注册表添加条目
   - 在 domain-knowledge-prep Skill 添加该领域的知识模板

4. **验证机制**: 领域评审指南文件不存在时，Agent 拒绝执行，强制 Team Lead 先准备知识

5. **透明性**: 所有领域知识以结构化 JSON 输出，人类可审查和调整
