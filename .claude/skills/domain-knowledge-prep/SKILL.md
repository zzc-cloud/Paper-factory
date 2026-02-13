---
name: domain-knowledge-prep
description: "领域知识准备 — 为评审专家生成特定领域的评审指南和知识点。"
---

# Domain Knowledge Preparation Skill

## 概述

You are the **Domain Knowledge Preparation Skill** — responsible for preparing domain-specific review guidance for peer reviewers.

**调用方式：** `Skill(skill="domain-knowledge-prep", args="{project}:{domain}")`

**核心职责**：
- 读取论文内容，分析目标领域与论文的相关度
- 生成该领域的评审指南（core concepts、evaluation criteria、common pitfalls）
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

读取 `workspace/{project}/output/paper.md`，提取：
- 论文标题、摘要、关键词
- 全文内容用于关键词匹配
- 各章节的主题分布

### Step 2: 读取项目上下文

读取 `workspace/{project}/phase1/input-context.md`，提取：
- 研究领域
- 目标系统名称
- 声明的创新点

### Step 3: 加载领域定义

从内置的领域注册表中加载目标领域的定义：

```json
{
  "knowledge_graph": {
    "full_name": "Knowledge Graphs and Ontology Engineering",
    "keywords": ["KG", "ontology", "RDF", "OWL", "SPARQL", "knowledge graph", "RDFS", "triple", "description logic"],
    "core_concepts": [
      {"name": "RDF", "expect": "论文应正确定义 RDF 三元组模型（subject, predicate, object）", "common_issues": ["与 XML 混淆", "忽略 blank node 处理"]},
      {"name": "OWL", "expect": "应说明使用的 OWL 2 子语言（DL、QL、Full）", "common_issues": ["声称 OWL 支持但未指明子语言", "混淆 OWL 与 RDF Schema"]},
      {"name": "SPARQL", "expect": "应使用 SPARQL 标准语法", "common_issues": ["与 SQL 混淆", "忽略查询优化"]},
      {"name": "Description Logic", "expect": "应正确使用 DL 构子（如 ALC、SHIQ）", "common_issues": ["声称表达能力但未验证", "忽略推理复杂度"]},
      {"name": "Ontology Alignment", "expect": "应讨论本体对齐方法（如匹配、映射）", "common_issues": ["忽视本体异构性", "缺乏对齐评估"]},
      {"name": "Knowledge Graph Embedding", "expect": "应与经典 KGE 方法对比", "common_issues": ["缺乏 SOTA 比较", "评估指标不全面"]}
    ],
    "evaluation_criteria": [
      "领域理论引用的准确性（是否引用经典的 KG 论文如 RDF2004、OWL2008、Horrocks2008）",
      "本体设计方法的合理性（是否采用标准的本体设计模式如 Single Inheritance、Multilingual、 Modular）",
      "推理方法的评估（是否对推理能力有量化评估，如查询响应时间、推理复杂度）",
      "与 SOTA 的比较（是否与最新的 GNN、KGE 方法如 TransE、RotatE 对比）",
      "应用场景的多样性（是否在多个领域/数据集上验证）"
    ],
    "key_questions": [
      "论文声称的本体表达能力是否与使用的 OWL 子语言匹配？",
      "图数据规模是否充分支撑实验结论（节点数、边数）？",
      "是否讨论了本体对齐/融合的挑战？",
      "推理方法是否与传统推理机（如 Pellet、HermiT）对比？",
      "KG 嵌入方法是否与最新的图神经网络方法对比？"
    ],
    "common_pitfalls": [
      "将知识图谱等同于关系数据库（忽视推理能力）",
      "忽视本体演化与版本管理",
      "缺少对推理复杂度的分析",
      "声称支持 OWL DL 但未实际验证",
      "与 KG 相关工作对比不充分（仅对比传统数据库）"
    ],
    "classic_papers": [
      "RDF Primer (2004)",
      "OWL Web Ontology Language (2004, 2008)",
      "Resource Description Framework (RDF) (2004)",
      "Horrocks et al.: Requirements for Ontology Languages (2008)",
      "Bordes et al.: Translating Embeddings for Knowledge Graph Completion (2013)"
    ]
  },
  "multi_agent_systems": {
    "full_name": "Multi-Agent Systems (MAS)",
    "keywords": ["multi-agent", "MAS", "BDI", "Contract Net", "Blackboard", "agent communication", "coordination", "negotiation", "emergent behavior"],
    "core_concepts": [
      {"name": "BDI Architecture", "expect": "应正确定义 Belief-Desire-Intention 模型", "common_issues": ["与规划系统混淆", "忽略信念更新机制"]},
      {"name": "Agent Communication", "expect": "应说明通信协议（如 FIPA ACL、KQML）", "common_issues": ["忽视通信开销", "未讨论消息可靠性"]},
      {"name": "Coordination Protocols", "expect": "应描述协调机制（如 Contract Net、Blackboard、Voting）", "common_issues": ["协调策略与任务特性不匹配", "缺乏死锁分析"]},
      {"name": "Emergent Behavior", "expect": "应分析个体行为如何涌现为集体行为", "common_issues": ["缺乏涌现性验证", "个体最优不等于集体最优"]},
      {"name": "Agent Organization", "expect": "应说明组织结构（如层次、扁平、混合）", "common_issues": ["忽视可扩展性", "缺乏中心化/去中心化分析"]}
    ],
    "evaluation_criteria": [
      "MAS 架构是否与经典范式（BDI、Blackboard、Contract Net）对应",
      "通信协议的设计是否考虑了可扩展性和可靠性",
      "协调机制是否与问题特性匹配（如任务依赖、资源冲突）",
      "是否提供了理论证明或形式化验证",
      "实验是否在标准 MAS 平台（如 JADE、Jason）上验证",
      "是否与最新的 LLM-based MAS 方法对比"
    ],
    "key_questions": [
      "Agent 的 BDI 模型是否完整定义？信念如何更新？",
      "通信协议如何处理消息丢失和顺序错乱？",
      "协调机制是否能证明无死锁？",
      "系统的可扩展性如何评估（节点数增加时的性能）？",
      "是否与最新的 AutoGen、CrewAI、MetaGPT 系统对比？"
    ],
    "common_pitfalls": [
      "声称多智能体但实际只是集中式系统",
      "忽视通信开销和延迟",
      "协调协议与任务特性不匹配",
      "缺乏对系统收敛性的证明",
      "未讨论安全性和恶意 Agent"
    ],
    "classic_papers": [
      "Wooldridge et al.: Agent theories (2000)",
      "Smith et al.: Contract Net protocols (1990)",
      "Jennings et al.: Commitment protocols (2000)",
      "Shoham & Leyton-Brown: BDI architecture (1990)",
      "Lesser et al.: BRIDGE multi-agent system (1999)"
    ]
  },
  "nl2sql": {
    "full_name": "Natural Language to SQL (NL2SQL / Text2SQL)",
    "keywords": ["NL2SQL", "Text2SQL", "schema linking", "SQL generation", "text-to-SQL", "natural language interface", "query interface"],
    "core_concepts": [
      {"name": "Schema Linking", "expect": "应正确定义如何将自然语言短语映射到数据库 schema", "common_issues": ["忽视值域模糊性", "缺少歧义处理"]},
      {"name": "SQL Synthesis", "expect": "应生成符合语法的 SQL 查询", "common_issues": ["SQL 注入风险", "不支持嵌套查询"]},
      {"name": "Execution Feedback", "expect": "应利用查询执行结果改进后续查询", "common_issues": ["忽视错误反馈", "缺少学习机制"]},
      {"name": "Generalization", "expect": "应讨论跨数据库/跨领域的泛化能力", "common_issues": ["仅在单一数据集评估", "忽视 schema 差异"]}
    ],
    "evaluation_criteria": [
      "Schema Linking 的准确性（是否正确识别表、列、关系）",
      "SQL 查询的正确性和执行效率",
      "对模糊和复杂查询的处理能力",
      "跨数据库泛化能力（能否适应未见过的 schema）",
      "与最新方法的比较（如基于 LLM 的方法、Spider、Crawler 基准）",
      "用户研究或真实场景的评估"
    ],
    "key_questions": [
      "Schema Linking 模块如何处理歧义（如同名列）？",
      "是否支持多跳查询和复杂嵌套？",
      "如何处理超出训练 schema 的查询？",
      "是否与 Spider、WikiSQL 等基准对比？",
      "是否评估了跨数据库泛化能力？",
      "用户研究中的错误如何分析并改进系统？"
    ],
    "common_pitfalls": [
      "仅在单一、干净的 schema 上评估",
      "忽视 SQL 注入等安全问题",
      "对复杂查询（多跳、嵌套）支持不足",
      "缺少与最新 LLM-based 方法对比",
      "忽视跨数据库泛化挑战"
    ],
    "classic_papers": [
      "Androudakis et al.: Natural Language Interfaces for Databases (1990s)",
      "Popescu et al.: Template-based NL2SQL (1990s)",
      "Zhong et al.: NL2SQL with deep learning (2017)",
      "Yu et al.: Seq2SQL (2018)",
      "Scholak et al.: Spider benchmark (2019)"
    ]
  },
  "bridge_engineering": {
    "full_name": "Bridge Engineering",
    "keywords": ["bridge", "structural health", "inspection", "BIM", "SHM", "non-destructive testing", "load rating", "damage detection"],
    "core_concepts": [
      {"name": "NDE (Non-Destructive Evaluation)", "expect": "应说明 NDE 方法类型（如超声波、雷达、冲击回弹）", "common_issues": ["忽视环境影响", "各方法互补性分析不足"]},
      {"name": "Structural Health Monitoring (SHM)", "expect": "应描述传感器网络、数据采集、异常检测", "common_issues": ["传感器布设不足", "数据融合策略缺失"]},
      {"name": "BIM Integration", "expect": "应讨论 BIM 与 SHM 的数据融合", "common_issues": ["数据格式不统一", "缺乏实时更新机制"]},
      {"name": "Damage Assessment", "expect": "应定义损伤指标和评级标准", "common_issues": ["缺乏量化标准", "主观性过强"]},
      {"name": "Load Testing", "expect": "应描述加载测试方法和评估", "common_issues": ["忽视实际交通荷载", "缺乏安全系数"]}
    ],
    "evaluation_criteria": [
      "检测方法的准确性（灵敏度、特异度）",
      "传感器网络的覆盖率和数据质量",
      "BIM/KG 集成的有效性",
      "与标准方法（如传统检测、商业 SHM 系统）的对比",
      "实际桥梁应用或案例研究",
      "成本效益分析"
    ],
    "key_questions": [
      "NDE 方法的选择是否基于桥梁材料类型和结构特点？",
      "传感器网络如何处理数据缺失和噪声？",
      "BIM 模型如何与实际结构对应？",
      "损伤检测算法的误报率和漏报率如何评估？",
      "是否在真实桥梁上验证或在标准数据集上测试？",
      "系统部署的成本和可行性如何？"
    ],
    "common_pitfalls": [
      "仅在模拟数据上验证，缺乏实际应用",
      "传感器类型和位置选择缺乏理论依据",
      "忽视环境因素（温度、湿度、交通）的影响",
      "BIM 与物理模型对齐不充分",
      "缺乏长期可靠性和维护性分析"
    ],
    "classic_papers": [
      "Sohn & Law: Bridge condition assessment (1990s)",
      "Brown et al.: NDE methods for bridges (1990s-2000s)",
      "GL: BIM standard (ISO 16739)",
      "Strauss et al.: Structural health monitoring (2010s)",
      "Farrar & Torrenti: Bridge monitoring review (2016)"
    ]
  },
  "data_analysis": {
    "full_name": "Data Analysis and Machine Learning",
    "keywords": ["data mining", "machine learning", "classification", "regression", "clustering", "feature engineering", "cross-validation"],
    "core_concepts": [
      {"name": "Feature Engineering", "expect": "应说明特征选择和构造方法", "common_issues": ["忽视特征重要性", "数据泄露"]},
      {"name": "Model Evaluation", "expect": "应使用适当的评估指标（准确率、F1、AUC）", "common_issues": ["仅用准确率", "忽视类别不平衡"]},
      {"name": "Cross-Validation", "expect": "应说明验证策略（k-fold、分层、时间序列）", "common_issues": ["数据泄露", "忽视分布偏移"]},
      {"name": "Statistical Significance", "expect": "应提供统计显著性检验", "common_issues": ["缺乏置信区间", "p-hacking"]}
    ],
    "evaluation_criteria": [
      "方法的创新性（是否提出新算法或改进）",
      "实验设计的严谨性（对比基线、消融实验）",
      "评估指标的全面性（不能仅用准确率）",
      "数据集的选择和代表性",
      "可重复性（代码、数据公开）",
      "与 SOTA 的公平比较"
    ],
    "key_questions": [
      "特征选择是否有理论或实证支持？",
      "是否进行了充分的消融实验验证各组件贡献？",
      "如何处理类别不平衡问题？",
      "是否提供了统计显著性检验和置信区间？",
      "实验是否可重复（代码、数据公开）？",
      "与基线方法的比较是否公平（相同设置、数据）？"
    ],
    "common_pitfalls": [
      "数据泄露（特征或预处理中使用目标信息）",
      "忽视类别不平衡问题",
      "过度拟合（训练集表现好，测试集差）",
      "cherry-picking 基线或超参数",
      "缺乏统计显著性检验",
      "不可复现（代码或数据不公开）"
    ],
    "classic_papers": [
      "Breiman: Random Forests (2001)",
      "Hastie et al.: The Elements of Statistical Learning (2009)",
      "Kohavi: A Study of Cross-Validation (1995)",
      "He & Garcia: Learning from Imbalanced Data (2009)"
    ]
  }
}
```

### Step 4: 计算领域相关度

统计论文中该领域关键词出现的频率：

```python
def calculate_relevance(paper_content, domain_keywords):
    """
    计算论文与目标领域的相关度 [0, 1]
    """
    paper_lower = paper_content.lower()
    keyword_count = sum(1 for kw in domain_keywords if kw.lower() in paper_lower)
    # 归一化：至少出现 3 个关键词认为完全相关
    relevance = min(keyword_count / 3, 1.0)
    return relevance
```

**判断逻辑**:
- `relevance >= 0.7`: 论文高度相关，生成完整评审指南
- `0.3 <= relevance < 0.7`: 论文中度相关，生成简化评审指南
- `relevance < 0.3`: 论文低相关，建议跳过该评审专家

### Step 5: 生成领域评审指南

根据相关度和领域定义，生成评审指南：

**高度相关 (relevance >= 0.7)**：
- 包含所有 `core_concepts`
- 包含所有 `evaluation_criteria`
- 包含所有 `key_questions`
- 包含 `common_pitfalls`
- 包含 `classic_papers` 用于对比参考

**中度相关 (0.3 <= relevance < 0.7)**：
- 包含核心 `core_concepts`（减少数量）
- 包含关键 `evaluation_criteria`（减少数量）
- 省略详细问题，只保留核心问题

**低相关 (relevance < 0.3)**：
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

包含：
- 领域概述
- 相关度分析
- 核心概念列表
- 评审标准
- 建议的关键问题

---

## 错误处理

### 未知领域
如果请求的领域不在注册表中：
- 返回错误，说明支持的领域列表
- 建议用户扩展领域注册表

### 论文文件不存在
如果 `workspace/{project}/output/paper.md` 不存在：
- 返回错误，要求先生成论文

### 相关度过低
如果相关度 < 0.3：
- 在 JSON 中设置 `recommendation: "skip"`
- 在摘要中明确说明建议跳过该评审专家

---

## 扩展指南

### 添加新领域

在 `config.json` 的 `domains` 注册表中添加新条目：

```json
{
  "domains": {
    "new_domain": {
      "full_name": "New Domain Full Name",
      "keywords": ["keyword1", "keyword2", ...],
      "core_concepts": [
        {"name": "Concept 1", "expect": "期望用法", "common_issues": ["常见问题"]}
      ],
      "evaluation_criteria": ["评审标准 1", "评审标准 2"],
      "key_questions": ["问题 1", "问题 2"],
      "common_pitfalls": ["常见问题 1", "常见问题 2"],
      "classic_papers": ["经典论文 1", "经典论文 2"]
    }
  }
}
```

然后在 `SKILL.md` 的 `load_domain_definitions` 步骤中添加对应字段。

---

## 支持的领域

| 标识符 | 全称 | 关键词数 |
|--------|------|----------|
| knowledge_graph | Knowledge Graphs and Ontology Engineering | 8 |
| multi_agent_systems | Multi-Agent Systems (MAS) | 9 |
| nl2sql | Natural Language to SQL | 7 |
| bridge_engineering | Bridge Engineering | 7 |
| data_analysis | Data Analysis and Machine Learning | 8 |

**可扩展**: 如需添加新领域，按照扩展指南操作。
