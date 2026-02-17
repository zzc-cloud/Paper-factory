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
- 智能选择需要的评审专家（动态决策）
- 为领域专家准备领域知识（通过 domain-knowledge-update Skill 读取领域知识文档）
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
- `quality.min_review_score` — 最低通过评分（现在 9.0）
- `quality.max_review_iterations` — 最大评审轮次（现在 10）
- `quality.max_response_rounds` — 专家回复最大轮数（默认 2）
- `quality.dynamic_scoring` — 是否使用动态评分判定模式（默认 true）

---

## 动态专家选择协议

### Step 3: 读取 Phase 1 领域分析结果

**直接复用 Phase 1 的领域识别结果**，不再重复分析论文领域。

读取 `workspace/{project}/phase1/domain-analysis.json`，获取：
- `primary_domains` — 主要领域列表
- `secondary_domains` — 次要领域列表
- `domain_analysis` — 每个领域的相关度和原因

> Phase 1 步骤 0.2 已使用 LLM 语义分析完成了领域识别，结果比关键词匹配更准确。Phase 4 直接复用，避免冗余计算。

### Step 4: 确定评审专家

**目标**：基于 Phase 1 的领域分析结果，决定需要哪些评审专家。

**评审专家组成**：

| Agent 类型 | 数量 | 说明 |
|-----------|------|------|
| **D1-General-Reviewer**（通用评审） | 1 个 Agent | 内含 5 位评审者（技术、新颖性、清晰度、重要性、实验严谨性），输出一份综合报告 |
| **D1-Domain-Expert**（领域评审） | N 个 Agent | `primary_domains` 中每个领域 spawn 一个独立 Agent，数量由 Phase 1 领域分析结果决定 |

> `d1-general-reviewer` Skill 本身已模拟多视角评审小组，不需要为每个通用维度单独启动 Agent。领域评审专家按 Phase 1 识别的 `primary_domains` 数量动态 spawn，每个领域加载对应的领域知识文档。

---

### Step 5: 记录专家选择

写入 `workspace/{project}/phase4/expert-selection.json`：

```json
{
  "paper_title": "论文标题",
  "domain_source": "phase1/domain-analysis.json",
  "selected_reviewers": [
    {
      "expert_id": "D1-General-Reviewer",
      "skill": "Skill(skill=\"d1-general-reviewer\", args=\"{project}\")",
      "type": "generic",
      "note": "内含 5 位评审者（技术、新颖性、清晰度、重要性、实验严谨性）"
    },
    {
      "expert_id": "D1-Domain-Expert-KG",
      "skill": "Skill(skill=\"d1-reviewer-domain-expert\", args=\"{project}:knowledge_graph\")",
      "type": "domain",
      "domain_id": "knowledge_graph",
      "domain_doc": "docs/domain-knowledge/kg.md",
      "domain_full_name": "Knowledge Graphs and Ontology Engineering"
    }
  ],
  "domains_from_phase1": {
    "primary_domains": ["knowledge_graph", "nl2sql"],
    "secondary_domains": ["data_analysis"]
  }
}
```

---

## 领域知识更新前置操作

### Step 0.1: 执行领域知识更新（新增）
**在启动评审专家前**，调用 `domain-knowledge-update` 技能动态更新领域知识：

```bash
# 从 Phase 1 的领域分析结果获取相关领域
domain_analysis = read("workspace/{project}/phase1/domain-analysis.json")
sorted_domains = domain_analysis["primary_domains"] + domain_analysis["secondary_domains"]

for domain in sorted_domains:
    Skill(skill="domain-knowledge-update", args=f"{project}:{domain}")
```

**输出文件**：
- `workspace/{project}/phase4/domain-knowledge-{domain}.json` — 更新后的领域知识
- `workspace/{project}/phase4/knowledge-update-report.json` — 更新报告摘要

### Step 0.2: 验证知识更新完成
检查所有高相关领域的知识更新是否完成：
```bash
# 检查更新文件是否存在
if all([check_file(f"workspace/{project}/phase4/domain-knowledge-{d}.json")
       for d in sorted_domains.keys()]):
    print("All domain knowledge updates completed")
else:
    print("Waiting for domain knowledge updates...")
```

---

## 执行步骤

### Step 6: 启动评审专家

**总共 spawn 1 + N 个 Agent**：1 个通用评审 + N 个领域评审（N = `primary_domains` 的数量）。

#### 6.1 通用评审专家（D1-General-Reviewer）— 1 个 Agent

`d1-general-reviewer` Skill 内部已包含 5 位评审者（技术、新颖性、清晰度、重要性、实验严谨性），只需 spawn 一次。

- **Skill：** `Skill(skill="d1-general-reviewer", args="{project}")`

```
Task(
    subagent_type="general-purpose",
    model=config.models.reasoning,
    name="D1-General-Reviewer",
    prompt="""You are the General Reviewer for project "{project}".

Call Skill(skill="d1-general-reviewer", args="{project}") and follow its instructions completely.

Return a brief confirmation when complete."""
)
```

#### 6.2 领域评审专家（D1-Domain-Expert-{domain}）— N 个 Agent

领域评审专家使用新的架构：**Skill + 领域知识文档**

- **Skill：** `Skill(skill="d1-reviewer-domain-expert", args="{project}:{domain_id}")`
- 使用 Task 工具为每个 `primary_domain` spawn 独立 Agent

```
Task(
    subagent_type="general-purpose",
    model=config.models.reasoning,
    name="D1-Domain-Expert-{domain}",
    prompt="""You are the Domain Expert Reviewer for project "{project}", domain "{domain_id}".

Call Skill(skill="d1-reviewer-domain-expert", args="{project}:{domain_id}") and follow its instructions completely.

Return a brief confirmation when complete."""
)
```

### Step 7: 收集评审报告

等待所有评审专家完成，读取对应的报告文件：

- 通用专家：`d1-review-report.json`
- 领域专家：`d1-reviewer-domain-{domain_id}-report.json`

---

## 版本管理与用户确认

### Step 7.5: 版本快照创建

**在每次迭代完成后，根据 versioning 配置决定是否创建版本**：

#### 1. 读取 versioning 配置

从 `config.json` 读取：
- `versioning.enabled` — 是否启用版本管理（默认 true）
- `versioning.mode` — 创建模式
  - `all`：每次迭代都创建版本
  - `milestones`多达到阈值分数时创建版本
  - `smart`：分数提升 >0.5 时创建版本
  - `off`：不创建版本
- `versioning.max_versions_to_keep` — 最多保留版本数（默认 10）

#### 2. 判断是否需要创建版本

```python
# 伪代码：版本创建判断
should_create_version = False
version_type = "revision"

if versioning_config["mode"] == "all":
    should_create_version = True
elif versioning_config["mode"] == "milestones":
    if current_score >= config["quality"]["min_review_score"]:
        should_create_version = True
        version_type = "milestone"
elif versioning_config["mode"] == "smart":
    if current_score - previous_score >= 0.5:
        should_create_version = True
```

#### 3. 创建版本快照

如果需要创建版本：

```python
# 调用 version-manager Skill
Skill(skill="version-manager", args=f"{project}:create:{version_type}")

# version-manager 将创建：
# - workspace/{project}/versions/V{NN}/ 目录
# - paper.md — 论文快照
# - metadata.json — 版本元数据（评分、时间戳、迭代次数等）
# - review-summary.json — 评审摘要
# - change-log.md — 人类可读的变更日志
# - 更新 versions/meta.json 索引
```

#### 4. 版本清理（可选）

```python
# 如果版本数超过 max_versions_to_keep
if version_count > versioning_config["max_versions_to_keep"]:
    # 删除最旧的版本
    oldest_version = get_oldest_version(project)
    remove_version_directory(project, oldest_version)
```

---

### Step 7.6: 用户确认检查

**根据 confirmation 配置判断是否需要用户确认**：

#### 1. 读取 confirmation 配置

从 `config.json` 读取：
- `confirmation.mode` — 确认模式
  - `full`：每次迭代都确认
  - `threshold`多达到阈值分数时确认
  - `skip`：跳过所有确认
- `confirmation.threshold_score` — 阈值分数（默认 9.0）
- `confirmation.confirm_at_milestones` — 是否在里程碑版本确认（默认 true）
- `confirmation.confirm_every_n_iterations` — 每 N 轮确认一次（默认 null）

#### 2. 判断是否需要确认

```python
# 伪代码：确认判断
requires_confirmation = False

if confirmation_config["mode"] == "full":
    requires_confirmation = True
elif confirmation_config["mode"] == "threshold":
    if current_score >= confirmation_config["threshold_score"]:
        requires_confirmation = True
elif confirmation_config["mode"] == "skip":
    requires_confirmation = False

# 里程碑确认
if confirmation_config.get("confirm_at_milestones"):
    if version_type == "milestone":
        requires_confirmation = True

# 固定间隔确认
if confirmation_config.get("confirm_every_n_iterations"):
    if iteration % confirmation_config["confirm_every_n_iterations"] == 0:
        requires_confirmation = True
```

#### 3. 生成版本摘要

如果需要确认，从版本元数据生成摘要：

```
版本 V03 已就绪
─────────────────────────────
评分：9.2/10（目标：9.0）
迭代：第 2 轮
创建时间：2026-02-14 13:20:00

主要改进：
- 添加了统计显著性分析
- 扩展了实验评估，新增 3 个基线对比
- 修复了 4 个关键问题
- 改进了领域特定术语的准确性

剩余问题：
- Related Work 可补充最新文献
- Discussion 缺少更广泛影响的讨论
```

#### 4. 使用 AskUserQuestion 工具

```python
AskUserQuestion(
    questions=[
        {
            "question": f"""版本 {new_version_id} 已就绪，评分 {current_score}/10

主要改进：
{generate_improvements_summary()}

请选择下一步操作：""",
            "header": "版本确认",
            "options": [
                {
                    "label": "接受",
                    "description": "此版本已满足要求，定稿论文"
                },
                {
                    "label": "继续并反馈",
                    "description": "提供修改意见，继续下一轮迭代"
                },
                {
                    "label": "手动编辑",
                    "description": "暂停流程，手动编辑论文后继续"
                }
            ],
            "multiSelect": false
        }
    ]
)
```

#### 5. 处理用户选择

**选择 1：接受**
- 标记版本为 `version_type="final"`
- 退出迭代循环
- 完成 Phase 4

**选择 2：继续并反馈**
- 使用 AskUserQuestion 收集用户反馈内容
- 将用户反馈写入 `workspace/{project}/phase4/user-feedback.json`
- 设置 `feedback.status="pending"`
- 继续下一轮迭代（D2 将优先处理用户反馈）

**选择 3：手动编辑**
- 向用户展示当前论文位置：`workspace/{project}/output/paper.md`
- 暂示用户编辑完成后输入"RESUME"
- 等待用户完成
- 检测文件变更
- 如果有变更，创建 `version_type="manual"` 版本
- 询问是否需要再次评审

---

## 评审-修订-辩论迭代循环

### Step 8: 执行评审-修订-专家协调迭代（已更新）

**迭代循环已更新，集成版本创建和用户确认**：

```
iteration = 1
previous_score = 0.0
while iteration <= max_review_iterations:
    │
    │ 1. 启动所有评审专家
    │     等待所有评审完成
    │     读取所有 d1-*-report.json
    │     聚合评审报告 & 收集分数
    │     current_score = aggregate_scores()
    │
    │ 2. 动态评分判定
    │     根据论文内容、各专家报告，综合判断
    │     记录判定结果到 gate-4.json
    │
    │ 3. 【新增】版本快照创建（Step 7.5）
    │     检查 versioning 配置，判断是否创建版本
    │     如果需要：调用 version-manager 创建版本 V{NN}
    │     记录 version_type 到元数据
    │
    │ 4. 【新增】用户确认检查（Step 7.6）
    │     检查 confirmation 配置和当前分数
    │     如果需要确认：
    │       - 使用 AskUserQuestion 展示版本摘要
    │       - 根据用户选择：
    │         - 接受 → 退出循环，标记 final
    │         - 继续反馈 → 记录到 user-feedback.json，继续
    │         - 手动编辑 → 暂停等待，恢复后继续
    │     如果用户接受：退出循环
    │
    │ 5. 未达标且未达最大轮次
    │     if iteration < max_review_iterations:
    │         生成 D2 Revision Specialist:
    │         Task(
    │             subagent_type="general-purpose",
    │             model=config.models.reasoning,
    │             name="D2-Revision-Specialist",
    │             prompt="""You are the Revision Specialist for project "{project}".
    │             Call Skill(skill="d2-revision-specialist", args="{project}") and follow its instructions completely.
    │             Return a brief confirmation when complete."""
    │         )
    │         D2 读取 paper.md 和所有评审报告
    │         【新增】D2 检查并优先处理 user-feedback.json
    │         D2 执行修订并更新 paper.md
    │
    │         ↓ 进入专家回复协调流程
    │
    │         6. D2 向每个评审专家发送个性化回复
    │            ...
    │
    │         iteration += 1
    │         previous_score = current_score
    │         继续循环
    │
    │ else:
    │     记录达到最大迭代次数
    │     接受当前版本
    │     退出循环
```

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

### 领域知识准备失败处理

如果某个领域知识文档不存在或更新失败，记录警告
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
| quality.min_review_score | 9.0 | 最低通过评分 |
| quality.max_review_iterations | 10 | 最大评审轮次 |
| quality.max_response_rounds | 2 | 专家回复最大轮数 |
| quality.dynamic_scoring | true | 是否使用动态评分判定模式 |
