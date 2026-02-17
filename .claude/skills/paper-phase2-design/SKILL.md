---
name: paper-phase2-design
description: "执行 Phase 2（设计阶段），严格串行执行：B2 → B3。由 paper-generation 编排器调用。"
---

# Phase 2: 设计阶段编排器

## 概述

你是 **Phase 2 设计阶段编排器** — 负责实验设计和论文架构设计。

**调用方式：** `Skill(skill="paper-phase2-design", args="{project}")`

**执行模式：** 严格串行 — B2 → B3
- B3 依赖 B2 的输出
- 不可跳过 — 两个 Agent 必须全部成功完成

**不要** 编写论文内容 — 委托给专业 Agent。

---

## Agent 执行（串行）

### B2: 实验设计师

**Skill：** `Skill(skill="b2-experiment-designer", args="{project}")`

**模型：** `config.models.reasoning`

**输入：**
- `workspace/{project}/phase1/innovation-synthesis.json`（必需）
- `workspace/{project}/input-context.md`（必需）
- **所有可用的 Phase 1 文件** — 使用 Glob 发现：
  - `workspace/{project}/phase1/*.json`（所有 Agent 输出）
  - `workspace/{project}/phase1/skill-*.json`（所有 Skill 输出）

**任务：**
- 设计严格的实验来验证每个创新点
- 定义评估指标和基线
- 指定数据集、参数和流程
- 输出：`workspace/{project}/phase2/b2-experiment-design.json` + `.md`

**启动方式：**
```
Task(
    subagent_type="general-purpose",
    model=config.models.reasoning,
    name="B2-ExperimentDesigner",
    prompt="""You are the B2 Experiment Designer agent for project "{project}".

Call Skill(skill="b2-experiment-designer", args="{project}") and follow its instructions completely.

Return a brief confirmation when complete."""
)
```

**启动并等待** 完成，然后验证输出文件存在。

### B3: 论文架构师

**Skill：** `Skill(skill="b3-paper-architect", args="{project}")`

**模型：** `config.models.reasoning`

**输入：**
- **所有 Phase 1 输出** — 使用 Glob 发现：
  - `workspace/{project}/phase1/*.json`
- **Phase 2 B2 输出**：
  - `workspace/{project}/phase2/b2-experiment-design.json`

**任务：**
- 设计完整的论文结构和章节
- 定义章节标题、内容流程和依赖关系
- 指定图表及其放置位置
- 输出：`workspace/{project}/phase2/b3-paper-outline.json` + `.md`

**启动方式：**
```
Task(
    subagent_type="general-purpose",
    model=config.models.reasoning,
    name="B3-PaperArchitect",
    prompt="""You are the B3 Paper Architect agent for project "{project}".

Call Skill(skill="b3-paper-architect", args="{project}") and follow its instructions completely.

Return a brief confirmation when complete."""
)
```

**启动并等待** 完成，然后验证输出文件存在。

---

## Quality Gate 2

**预期文件（共 4 个）：**
- `phase2/b2-experiment-design.json` + `.md`
- `phase2/b3-paper-outline.json` + `.md`

**验证：**
1. 使用 Glob：`workspace/{project}/phase2/*.json` 和 `*.md`
2. 比较预期与实际找到的文件
3. 写入 `workspace/{project}/quality-gates/gate-2.json`

如果所有文件都存在 → 状态："passed"，继续到 Phase 3。
如果有任何缺失 → 状态："failed"，错误处理。

---

## 错误处理

### Agent 失败

如果任何 Agent（B2、B3）失败：
1. 记录失败详情
2. 选项：重试一次 / 跳到 Phase 3 / 人工干预
3. 更新 Gate 状态为 "failed"

**注意：** Phase 2 有严格的串行依赖 — 不能跳过 Agent。B2 失败会阻塞 B3。

### B2 特殊情况

如果 B2 缺少 Phase 1 输入（例如，Skill 输出缺失）：
- 仅使用可用输入继续
- 在 Gate 记录中记录限制
- 可能影响实验设计质量

---

## 成功标准

Phase 2 **完成** 的条件：
1. Quality Gate 2 状态为 "passed"
2. 两个 Agent 输出都存在
3. B3 论文大纲存在且有效

向编排器报告完成并返回到 Phase 3。
