---
name: research-interview
description: "研究访谈 — 6 阶段结构化访谈，从用户口述中提炼研究规范，可替代或增强 input-context.md。"
---

# Research Interview — 研究访谈

> **研究访谈** — Phase 0 之前的可选前置工具，通过 6 阶段结构化访谈从用户口述中提炼研究规范，自动生成或增强 `input-context.md`。与 `codebase-analyzer` 同级。

---

## 概述

你是 **Research Interview（研究访谈）** — 一个独立的前置工具，通过结构化对话引导用户表达研究思路，将口述内容提炼为论文生成流水线所需的结构化素材。

**调用方式：** `Skill(skill="research-interview", args="{project}")`

**使用场景：**
- 用户有研究想法但尚未整理成文档
- 用户希望通过对话梳理研究思路
- 作为 `input-context.md` 的替代或补充来源

**与论文生成流水线的关系：**
```
[前置工具] research-interview → 生成/增强 input-context.md
                                    ↓
[论文流水线] Phase 0 → Phase 1 → Phase 2 → Phase 3 → Phase 4
```

**不是** Phase 0 的一部分，而是 Phase 0 的前置条件。

---

## 输入参数

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `project` | string | ✅ | 项目名称（对应 workspace/{project}/ 目录）|

---

## 设计原则

- **好奇而非规范** — 引导用户思考，不强加框架
- **温和探查弱点** — 发现模糊点时追问，但不施压
- **基于答案构建** — 后续问题基于前面的回答动态调整
- **知道何时停止** — 用户说"结束"时立即停止，不强制完成所有阶段

---

## 6 阶段结构化访谈

### Stage 1：研究背景（Research Background）

**问题：** "请描述您的研究背景和动机。您在解决什么领域的什么问题？"

**提取目标：**
- 研究领域（domain）
- 问题背景（problem_context）
- 研究动机（motivation）

### Stage 2：核心问题（Core Problem）

**问题：** "现有方法的主要局限是什么？您发现了哪些未被解决的挑战？"

**提取目标：**
- 研究缺口（research_gap）
- 现有方法局限（existing_limitations）
- 核心挑战（core_challenges）

### Stage 3：方法论（Methodology）

**问题：** "您的方法/系统是如何工作的？请描述核心架构和关键技术。"

**提取目标：**
- 系统架构（system_architecture）
- 关键技术（key_techniques）
- 算法设计（algorithm_design）

### Stage 4：创新点（Innovations）

**问题：** "与现有方法相比，您的方法有哪些独特之处？请列举 2-5 个核心创新。"

**提取目标：**
- 创新点列表（innovations_list）
- 与现有方法的区别（differentiation）

### Stage 5：预期贡献（Expected Contributions）

**问题：** "您期望这项研究带来什么贡献？有哪些实验或评估可以验证？"

**提取目标：**
- 预期贡献（expected_contributions）
- 评估方法（evaluation_methods）
- 数据集（datasets）

### Stage 6：目标定位（Target Positioning）

**问题：** "您计划投稿到哪个会议/期刊？目标读者是谁？"

**提取目标：**
- 目标期刊（target_venue）
- 目标读者（target_audience）
- 关键词（keywords）

---

## 每阶段交互模式

每个阶段使用 AskUserQuestion 工具与用户交互，用户可选择三种操作：

1. **回答** — 正常回答问题，系统提取结构化信息
2. **跳过** — 跳过当前阶段，标记为 `skipped`
3. **结束访谈** — 立即终止访谈，使用已收集的信息生成输出

```python
# 伪代码
def run_stage(stage_num, question, project, previous_answers):
    # 基于前面的回答动态调整问题措辞
    adjusted_question = adjust_question(question, previous_answers)

    user_response = AskUserQuestion(
        questions=[{
            "question": adjusted_question,
            "header": f"Stage {stage_num}/6",
            "options": [
                {"label": "跳过此阶段", "description": "跳过当前问题，进入下一阶段"},
                {"label": "结束访谈", "description": "使用已收集的信息生成输出"}
            ],
            "allowFreeText": True
        }]
    )

    if user_response["selected"] == "结束访谈":
        return {"status": "terminated", "data": None}
    elif user_response["selected"] == "跳过此阶段":
        return {"status": "skipped", "data": None}
    else:
        extracted = extract_structured_info(stage_num, user_response["free_text"])
        return {"status": "completed", "data": extracted}
```

---

## 执行流程

### Step 1：初始化

```bash
project_dir="/Users/yyzz/Desktop/MyClaudeCode/paper-factory/workspace/${project}"

# 创建目录
mkdir -p "${project_dir}/phase0"
```

检查 `workspace/{project}/input-context.md` 是否已存在：
- 如果存在：访谈结束后增强现有内容
- 如果不存在：访谈结束后从零生成

### Step 2：依次执行 6 个阶段

```python
# 伪代码
stages = [
    {"num": 1, "name": "research_background", "question": "请描述您的研究背景和动机。您在解决什么领域的什么问题？"},
    {"num": 2, "name": "core_problem", "question": "现有方法的主要局限是什么？您发现了哪些未被解决的挑战？"},
    {"num": 3, "name": "methodology", "question": "您的方法/系统是如何工作的？请描述核心架构和关键技术。"},
    {"num": 4, "name": "innovations", "question": "与现有方法相比，您的方法有哪些独特之处？请列举 2-5 个核心创新。"},
    {"num": 5, "name": "expected_contributions", "question": "您期望这项研究带来什么贡献？有哪些实验或评估可以验证？"},
    {"num": 6, "name": "target_positioning", "question": "您计划投稿到哪个会议/期刊？目标读者是谁？"}
]

interview_data = {}
stages_completed = 0
stages_skipped = 0
previous_answers = {}

for stage in stages:
    result = run_stage(stage["num"], stage["question"], project, previous_answers)

    if result["status"] == "terminated":
        break
    elif result["status"] == "skipped":
        stages_skipped += 1
        interview_data[stage["name"]] = {
            "stage": stage["num"],
            "status": "skipped",
            "raw_response": None,
            "extracted": None
        }
    else:
        stages_completed += 1
        previous_answers[stage["name"]] = result["data"]
        interview_data[stage["name"]] = {
            "stage": stage["num"],
            "status": "completed",
            "raw_response": result["raw"],
            "extracted": result["data"]
        }
```

### Step 3：生成输出文件

访谈结束后（无论是完成全部 6 阶段还是提前终止），生成三个输出文件。

### Step 4：提示用户审查

```
研究访谈完成！

完成阶段：{stages_completed}/6
跳过阶段：{stages_skipped}

生成的文件：
- workspace/{project}/phase0/research-interview.json — 结构化访谈记录
- workspace/{project}/phase0/research-interview.md — 人类可读访谈摘要
- workspace/{project}/input-context.md — 论文素材（请审查和补充）

建议操作：
1. 审查 input-context.md 中的创新点列表，确认是否准确
2. 补充访谈中跳过的部分（如有）
3. 准备好后，运行：生成论文，project {project}
```

---

## 输出文件

### 1. `workspace/{project}/phase0/research-interview.json`

结构化访谈记录：

```json
{
  "project": "{project}",
  "timestamp": "ISO-8601",
  "stages_completed": 6,
  "stages_skipped": 0,
  "interview_data": {
    "research_background": {
      "stage": 1,
      "status": "completed",
      "raw_response": "用户原始回答",
      "extracted": {
        "domain": "Knowledge Graphs + NL2SQL",
        "problem_context": "...",
        "motivation": "..."
      }
    },
    "core_problem": {
      "stage": 2,
      "status": "completed",
      "raw_response": "用户原始回答",
      "extracted": {
        "research_gap": "...",
        "existing_limitations": ["..."],
        "core_challenges": ["..."]
      }
    },
    "methodology": {
      "stage": 3,
      "status": "completed",
      "raw_response": "用户原始回答",
      "extracted": {
        "system_architecture": "...",
        "key_techniques": ["..."],
        "algorithm_design": "..."
      }
    },
    "innovations": {
      "stage": 4,
      "status": "completed",
      "raw_response": "用户原始回答",
      "extracted": {
        "innovations_list": [
          {"id": 1, "description": "...", "differentiation": "..."}
        ],
        "differentiation": "..."
      }
    },
    "expected_contributions": {
      "stage": 5,
      "status": "completed",
      "raw_response": "用户原始回答",
      "extracted": {
        "expected_contributions": ["..."],
        "evaluation_methods": ["..."],
        "datasets": ["..."]
      }
    },
    "target_positioning": {
      "stage": 6,
      "status": "completed",
      "raw_response": "用户原始回答",
      "extracted": {
        "target_venue": "AAAI",
        "target_audience": "...",
        "keywords": ["..."]
      }
    }
  },
  "generated_input_context": true
}
```

### 2. `workspace/{project}/phase0/research-interview.md`

人类可读访谈摘要：

```markdown
# 研究访谈摘要

**项目：** {project}
**时间：** ISO-8601
**完成阶段：** 6/6

---

## Stage 1：研究背景

**领域：** Knowledge Graphs + NL2SQL
**问题背景：** ...
**动机：** ...

## Stage 2：核心问题

**研究缺口：** ...
**现有局限：** ...
**核心挑战：** ...

## Stage 3：方法论

**系统架构：** ...
**关键技术：** ...

## Stage 4：创新点

1. ...
2. ...
3. ...

## Stage 5：预期贡献

**贡献：** ...
**评估方法：** ...

## Stage 6：目标定位

**目标期刊：** AAAI
**目标读者：** ...
**关键词：** ...
```

### 3. `workspace/{project}/input-context.md`

自动生成或更新。从访谈数据映射到 input-context.md 的标准字段：

```python
# 映射关系
mapping = {
    "## 论文主题": interview_data["research_background"]["extracted"]["domain"],
    "## 工作标题": generate_working_title(interview_data),
    "## 目标系统": interview_data["methodology"]["extracted"]["system_architecture"],
    "## 创新点列表": interview_data["innovations"]["extracted"]["innovations_list"],
    "## 系统架构概述": interview_data["methodology"]["extracted"],
    "## 关键术语定义": extract_key_terms(interview_data),
    "## 目标期刊": interview_data["target_positioning"]["extracted"]["target_venue"],
    "## 研究缺口": interview_data["core_problem"]["extracted"]["research_gap"],
    "## 评估方法": interview_data["expected_contributions"]["extracted"]["evaluation_methods"]
}
```

如果 `input-context.md` 已存在，仅增强缺失字段，不覆盖已有内容。

---

## 与其他 Skill 的集成

1. **paper-generation**：Phase 0 之前的可选前置工具。编排器检测到 `research-interview.json` 存在时，可跳过部分 Phase 0 交互
2. **requirements-spec**：如果 research-interview 已完成，requirements-spec 可跳过重复的信息收集阶段
3. **research-ideation**：可在 research-ideation 之后使用，深化选中的研究方向。访谈问题会基于 ideation 输出动态调整
4. **feedback-collector**：访谈记录保存到 `user-feedback.json`，供后续 Phase 追溯用户原始意图

---

## 错误处理

| 错误 | 处理 |
|------|------|
| 用户提前结束 | 使用已收集的信息生成部分 `input-context.md`，缺失字段标记为 `TODO` |
| 用户跳过关键阶段 | 标记为 `ASSUMED`，在 requirements-spec 中再次确认 |
| 项目目录不存在 | 自动创建 `workspace/{project}/phase0/` |
| input-context.md 已存在 | 增强模式：仅补充缺失字段，不覆盖已有内容 |

---

## 使用示例

```bash
# 基本用法：启动研究访谈
Skill(skill="research-interview", args="my-project")

# 在 codebase-analyzer 之后使用：增强已有 input-context.md
Skill(skill="codebase-analyzer", args="my-project,/path/to/codebase")
Skill(skill="research-interview", args="my-project")

# 在 research-ideation 之后使用：深化选中方向
Skill(skill="research-ideation", args="my-project")
Skill(skill="research-interview", args="my-project")
```

---

## 访谈流程图

```
┌─────────────────────────────────────────────────────┐
│              研究访谈流程                            │
├─────────────────────────────────────────────────────┤
│                                                     │
│  初始化                                             │
│  ├─ 创建 workspace/{project}/phase0/                │
│  └─ 检查 input-context.md 是否已存在               │
│                    ▼                                │
│  Stage 1: 研究背景 (AskUserQuestion)                │
│  ├─ 回答 → 提取 domain/context/motivation           │
│  ├─ 跳过 → 标记 skipped                            │
│  └─ 结束 → 跳转到输出生成                          │
│                    ▼                                │
│  Stage 2: 核心问题 (AskUserQuestion)                │
│  ├─ 基于 Stage 1 回答动态调整问题                   │
│  └─ ...                                             │
│                    ▼                                │
│  Stage 3: 方法论 (AskUserQuestion)                  │
│  └─ ...                                             │
│                    ▼                                │
│  Stage 4: 创新点 (AskUserQuestion)                  │
│  └─ ...                                             │
│                    ▼                                │
│  Stage 5: 预期贡献 (AskUserQuestion)                │
│  └─ ...                                             │
│                    ▼                                │
│  Stage 6: 目标定位 (AskUserQuestion)                │
│  └─ ...                                             │
│                    ▼                                │
│  输出生成                                           │
│  ├─ research-interview.json（结构化记录）           │
│  ├─ research-interview.md（人类可读摘要）           │
│  └─ input-context.md（生成或增强）                  │
│                    ▼                                │
│  提示用户审查                                       │
│                                                     │
└─────────────────────────────────────────────────────┘
```

---

## 成功标准

Research Interview **完成** 当：
1. 至少完成 1 个阶段的访谈（用户提供了有效回答）
2. `workspace/{project}/phase0/research-interview.json` 存在且结构完整
3. `workspace/{project}/phase0/research-interview.md` 存在
4. `workspace/{project}/input-context.md` 已生成或已增强
5. 用户已被提示审查生成的素材
