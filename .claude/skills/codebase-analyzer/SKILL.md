---
name: codebase-analyzer
description: "代码库分析工具 — 从工程项目代码库自动生成 input-context.md，作为论文生成流水线的前置工具。当用户有代码库但没有 input-context.md 时使用。"
---

# Codebase Analyzer — 代码库分析工具

## 概述

你是 **Codebase Analyzer（代码库分析工具）** — 一个独立的前置工具，用于从工程项目的代码库中自动提炼学术论文所需的结构化素材，生成 `input-context.md` 文件。

**调用方式：** `Skill(skill="codebase-analyzer", args="{project},{codebase_path}")`

**使用场景：**
- 用户有一个工程项目，想基于它写论文，但还没有准备 `input-context.md`
- 用户提供代码库路径，本工具自动分析并生成论文素材

**与论文生成流水线的关系：**
```
[前置工具] codebase-analyzer → 生成 input-context.md
                                    ↓
[论文流水线] Phase 1 → Phase 2 → Phase 3 → Phase 4
```

**不是** Phase 1 的一部分，而是 Phase 1 的前置条件。

---

## 执行流程

### Step 1: 解析参数

从 args 中提取：
- `{project}` — 项目名称
- `{codebase_path}` — 代码库绝对路径

### Step 2: 验证代码库路径

使用 Bash 验证路径存在且是有效目录：
```bash
ls {codebase_path}
```

如果路径无效，报错并提示用户提供正确路径。

### Step 3: 创建项目目录

```bash
mkdir -p workspace/{project}
```

### Step 4: 启动 A2 代码库分析 Agent

```python
Task(
    subagent_type="general-purpose",
    model="opus",
    name="A2-CodebaseAnalyzer",
    prompt="""You are the Codebase Analyzer Agent.

READ: agents/phase1/a2-engineering-analyst.md for your full system prompt.

CODEBASE TO ANALYZE: {codebase_path}
PROJECT NAME: {project}

YOUR TASK:
1. Analyze the codebase architecture, design patterns, and technical stack
2. Identify potential academic innovation points
3. Extract quantitative metrics
4. Generate a complete input-context.md file

OUTPUT FILES:
- workspace/{project}/input-context.md (primary — for paper generation pipeline)
- workspace/{project}/codebase-analysis.json (reference — detailed analysis)

Return: brief confirmation when complete."""
)
```

### Step 5: 等待完成并验证输出

1. 等待 Agent 完成
2. 验证 `workspace/{project}/input-context.md` 存在
3. 验证文件包含必填字段：
   - `## 论文主题`
   - `## 创新点列表`（至少 3 个）
   - `## 系统架构概述`
   - `## 关键术语定义`

### Step 6: 提示用户审查

生成完成后，提示用户：

```
代码库分析完成！

生成的文件：
- workspace/{project}/input-context.md — 论文素材（请审查和补充）
- workspace/{project}/codebase-analysis.json — 详细分析报告

建议操作：
1. 审查 input-context.md 中的创新点列表，确认是否准确
2. 补充目标会议/期刊信息（target_venue）
3. 调整论文标题和主题方向
4. 准备好后，运行：生成论文，project {project}
```

---

## 错误处理

### 代码库路径无效
- 报错并提示用户提供正确的绝对路径

### Agent 执行失败
- 检查部分输出
- 选项：重试 / 手动创建 input-context.md

### 输出不完整
- 如果 input-context.md 缺少必填字段，提示用户手动补充

---

## 成功标准

Codebase Analyzer **完成** 当：
1. `workspace/{project}/input-context.md` 存在且包含所有必填字段
2. `workspace/{project}/codebase-analysis.json` 存在
3. 用户已被提示审查生成的素材
```
