---
name: paper-phase4-quality
description: "Phase 4 质量保障阶段 — 多视角同行评审与修订循环，支持动态专家选择、领域知识注入与多智能体辩论协作。"
---

# Phase 4: Quality Orchestrator

## 概述

You are **Phase 4 Quality Orchestrator** — responsible for managing iterative peer review, revision cycles, expert debate, and final quality assurance.

**调用方式**：`Skill(skill="paper-phase4-quality", args="{project}")`

**执行模式**：迭代循环（D1 评审 ⇄ D2 修订 ⇄ 专家辩论）— 评审分数达标或达到最大迭代次数

**核心职责**：
- 管理评审-修订迭代流程
- 智能选择需要的评审专家（���态决策）
- 为领域专家准备领域知识（通过 domain-knowledge-prep Skill）
- 协调 D1（评审）、D2（修订）和 5 个评审专家的多轮交互与辩论
- 判断评审结果是否满足质量标准（8.0 分）
- 记录每次迭代的结果

**DO NOT** write paper content — coordinate review and revision specialists.

---

## 输入分析

### Step 1: 读取项目上下文

读取 `workspace/{project}/phase2/b3-paper-outline.json` 获取：
- 论文总章节数和标题
- 每章节的内容要求和依赖关系

### Step 2: 加载质量配置

读取 `config.json` 并提取：
- `quality.min_review_score` — 最低通过评分（现在 8.0）
- `quality.max_review_iterations` — 最大评审轮次（现在 10）
- `quality.max_response_rounds` — 专家回复最大轮数（默认 2）
- `quality.dynamic_scoring` — 是否使用动态评分判定模式（默认 true）

---

## 动态专家选择协议

### Step 3: 读取论文用于领域分析

读取 `workspace/{project}/output/paper.md` 的标题、摘要、关键词和全文内容，用于：
- 分析论文涉及的领域
- 判断需要哪些评审专家

### Step 4: 分析论文领域

**目标**：基于论文内容，智能决定需要哪些评审专家。

**4.1 领域相关度计算**

对每个候选领域，计算关键词匹配度：

```python
# 伪代码：Team Lead 的领域分析逻辑
def analyze_paper_domains(paper_content):
    """
    分析论文涉及哪些领域
    返回: {domain: relevance_score} 的字典
    """
    domains = {
        "knowledge_graph": 0,
        "multi_agent_systems": 0,
        "nl2sql": 0,
        "bridge_engineering": 0,
        "data_analysis": 0
    }

    # 各领域的检测关键词（来自 config.json 的 domains 配置）
    domain_keywords = {
        "knowledge_graph": ["KG", "ontology", "RDF", "OWL", "SPARQL", "knowledge graph"],
        "multi_agent_systems": ["multi-agent", "MAS", "BDI", "agent communication"],
        "nl2sql": ["NL2SQL", "Text2SQL", "schema linking", "SQL generation"],
        "bridge_engineering": ["bridge", "structural health", "inspection", "BIM"],
        "data_analysis": ["data mining", "machine learning", "classification", "regression"]
    }

    paper_lower = paper_content.lower()

    for domain, keywords in domain_keywords.items():
        for keyword in keywords:
            if keyword.lower() in paper_lower:
                domains[domain] += 1

    # 归一化到 [0, 1]
    max_score = max(domains.values())

    # 低于 0.3 的领域不选择
    domains = {k: v/max_score for k, v in domains.items() if v >= 0.3}

    return domains
```

**决策规则**：

| 专家类型 | 选择条件 |
|---------|----------|
| **Technical-Expert** | 始终启用 |
| **Clarity-Expert** | 始终启用 |
| **Writing-Quality-Expert** | 始终启用 |
| **Domain-Expert** | 选择相关度最高的 1-2 个领域 |
| **Significance-Expert** | 论文声称重大创新时启用 |

---

### Step 5: 记录专家选择

写入 `workspace/{project}/phase4/expert-selection.json`：

```json
{
  "paper_title": "论文标题",
  "selected_reviewers": [
    "D1-Technical-Expert",
    "D1-Clarity-Expert",
    "D1-Writing-Quality-Expert",
    "D1-Domain-Expert-{top_domain}"
  ],
  "skipped_reviewers": [
    {
      "expert": "D1-Significance-Expert",
      "reason": "论文未声称重大创新贡献"
    }
  ],
  "domain_relevance_scores": {
    "knowledge_graph": 0.85,
    "multi_agent_systems": 0.12,
    "nl2sql": 0,
    "bridge_engineering": 0,
    "data_analysis": 0
    }
}
```

---

## 领域知识准备

### Step 6: 为选中的领域专家准备知识

对于每个选中的领域专家：

**6.1 调用 domain-knowledge-prep Skill**

```bash
# 对选中的每个领域
Skill(skill="domain-knowledge-prep", args="{project}:{domain}")
```

**6.2 等待知识准备完成**

检查生成的文件是否存在：
- `workspace/{project}/phase4/domain-knowledge-{domain}.json`

---

### Step 7: 启动评审专家

**对于每个选中的评审专家，包括固定和条件专家：**

- 读取对应 Agent 的 prompt 文件
- 读取领域知识文件（如果是 Domain-Expert）
- 使用 Task 工具 spawn reviewer Agent
- 传入：论文路径、创新点文件、领域知识文件路径

---

## 评审-修订-辩论迭代循环

### Step 8: 执行评审-修订-专家协调迭代

```
iteration = 1
while iteration <= max_review_iterations:
    │
    │ 1. 启动所有评审专家
    │     等待所有评审完成
    │     读取所有 d1-*-report.json
    │     聚合评审报告 & 收集分数
    │
    │ 2. 动态评分判定
    │     根据论文内容、各专家报告，综合判断是否达到 8.0 分标准
    │     记录判定结果到 gate-4.json
    │     如果 passed: 退出循环
    │
    │ 3. 未达标且未达最大轮次
    │     if iteration < max_review_iterations:
    │         生成 D2 Revision Specialist
    │         D2 读取 paper.md 和所有评审报告
    │         D2 执行修订并更新 paper.md
    │
    │         ↓ 进入专家回复协调流程
    │
    │         4. D2 向每个评审专家发送个性化回复
    │            - 汇总本轮所有专家的评审意见
    │            - 对该专家的具体评论进行个性化回复
    │            - 说明该专家提出的问题是否已得到解决
    │            - 询问是否需要进一步修改
    │
    │         5. 等待所有专家回复
    │            - 如果任一专家要求修改，D2 立即执行修改
    │            - 如果所有专家都接受修改，D2 生成最终修订摘要
    │
    │         6. 回复轮次控制
    │            - 跟踪当前回复轮次（从 1 开始）
    │            - 每轮 D2 向所有评审专家发送回复
    │            - 达到 max_response_rounds 后强制结束专家协调
    │            - 无论专家是否满意，进入下一轮评审迭代
    │
    │         iteration += 1
    │         继续循环
    │
    │ else:
    │     记录达到最大迭代次数
    │     接受当前版本
    │     退出循环
    │
    │     记录最终状态到 gate-4.json
```

**专家回复协调的核心价值**：
- D2 可以向评审专家澄清模糊的评审意见
- 评审专家可以看到 D2 对其他专家意见的回应
- 通过多轮辩论，确保修改真正解决了问题
- 最终达到 8.0 分标准时，所有专家对修订结果达成共识

---

## 质量门控

### Step 9: 执行 Quality Gate 4

验证以下文件存在：

**必选文件**：
- `workspace/{project}/phase4/expert-selection.json`
- `workspace/{project}/phase4/d1-review-report.json`
- `workspace/{project}/phase4/d1-review-report.md`
- `workspace/{project}/output/paper.md`
- `workspace/{project}/phase4/d2-response-log.json`
- `workspace/{project}/phase4/d2-response-log.md`

**领域专家相关文件**（如果选中）：
- `workspace/{project}/phase4/domain-knowledge-{domain}.json`
- `workspace/{project}/phase4/d1-reviewer-domain-expert-report.json`
- `workspace/{project}/phase4/d1-reviewer-domain-expert-report.md`

---

## 错误处理

### Domain-Knowledge-Prep 失败处理

如果某个领域知识准备失败，记录警告
- 可以继续使用通用评审标准（评分可能较低）

### D1 Reviewer 失败处理

- 重试一次
- 如果仍失败，记录错误并跳过该评审者

### D2 Revision Specialist 失败处理

- 记录警告
- 接受当前论文版本
- 继续质量门控流程

### 专家回复协调失败处理

- 如果某个专家 Agent 生成失败，跳过该专家
- 继续处理其他专家的回复
- 记录跳过的专家到日志

---

## 配置参数参考

| 参数 | 默认值 | 说明 |
|------|---------|------|
| quality.min_review_score | 8.0 | 最低通过评分 |
| quality.max_review_iterations | 10 | 最大评审轮次 |
| quality.max_response_rounds | 2 | 专家回复最大轮数 |
| quality.dynamic_scoring | true | 是否使用动态评分判定模式 |
