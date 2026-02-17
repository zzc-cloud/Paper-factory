---
name: requirements-spec
description: "需求规范协议 — 对模糊指令进行结构化需求澄清，生成 MUST/SHOULD/MAY 标记的需求规范文档，用户确认后进入正式流水线。"
---

# Requirements Spec Skill — 需求规范协议

> **需求规范协议** — 对模糊指令进行结构化需求澄清，生成 MUST/SHOULD/MAY 标记的需求规范文档，用户确认后进入正式流水线。在论文生成流水线启动前，确保所有关键需求字段清晰、完整、可执行。

---

## Skill 概述

本 Skill 是论文生成流水线的**前置守门员**，负责：

1. **模糊度检测**：扫描 `input-context.md`，对每个关键字段标记清晰度（CLEAR / ASSUMED / BLOCKED）
2. **需求分级**：对每个需求项标记优先级（MUST / SHOULD / MAY）
3. **交互澄清**：对 ASSUMED 项生成系统推断供用户确认，对 BLOCKED 项生成引导性问题
4. **保存与应用**：将确认的需求写入结构化文件，自动生成或更新 `input-context.md`

### 触发条件

- `input-context.md` 不存在
- `input-context.md` 存在但缺少 2+ 个 MUST 字段

### 跳过条件

- `config.json` 中 `requirements_spec.enabled` 为 `false`
- 所有字段均为 CLEAR（内容充分，无需澄清）

---

## 输入参数

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `project` | string | ✅ | 项目名称（对应 workspace/{project}/ 目录）|

**调用方式：** `Skill(skill="requirements-spec", args="{project}")`

---

## 执行流程

### Step 1：模糊度检测

1. **读取配置**
   - 从 `config.json` 读取 `requirements_spec` 配置块
   - 获取 `must_fields`、`should_fields`、`may_fields` 列表
   - 检查 `enabled` 是否为 `true`，若为 `false` 则跳过本 Skill

2. **读取 input-context.md**（如存在）
   - 路径：`workspace/{project}/input-context.md`
   - 如果文件不存在，标记所有 MUST 字段为 BLOCKED

3. **逐字段检查清晰度**

   对每个字段标记清晰度等级：

   | 清晰度 | 含义 | 判定标准 |
   |--------|------|----------|
   | CLEAR | 字段存在且内容充分 | 字段存在、内容 > 50 字符、含具体信息 |
   | ASSUMED | 字段存在但内容模糊，系统可推断 | 字段存在但过于简短或笼统 |
   | BLOCKED | 字段缺失或完全不清晰 | 字段不存在或内容为空/占位符 |

4. **判断是否跳过**
   - 如果所有字段均为 CLEAR，返回 `{"skip": true, "reason": "all_fields_clear"}`，跳过本 Skill
   - 如果 BLOCKED 字段数 < `min_blocked_to_trigger`（默认 2）且 `auto_trigger` 为 `true`，仍继续执行
   - 否则正常进入 Step 2

### Step 2：生成需求规范文档

1. **对每个需求项标记优先级**

   | 优先级 | 含义 | 对应字段 |
   |--------|------|----------|
   | MUST | 论文生成必需，缺失则无法启动 | `paper_title`、`innovations`、`system_architecture`、`key_terminology` |
   | SHOULD | 强烈建议提供，缺失会降低质量 | `target_venue`、`target_system` |
   | MAY | 可选增强，缺失不影响核心流程 | `codebase_path`、`additional_context` |

2. **对每个需求项标记清晰度**
   - 复用 Step 1 的清晰度检测结果（CLEAR / ASSUMED / BLOCKED）

3. **对 ASSUMED 项生成系统推断值**
   - 基于 `input-context.md` 中的已有信息进行推断
   - 例如：标题过于简短 → 系统扩展为完整学术标题
   - 推断值供用户确认，不自动采用

4. **对 BLOCKED 项生成引导性问题**
   - 为每个 BLOCKED 字段生成具体的引导性问题
   - 例如：`innovations` 缺失 → "请描述您的系统相比现有方案的 2-3 个核心创新点"

### Step 3：交互确认

1. **使用 AskUserQuestion 展示需求规范**

   展示格式：

   ```
   需求规范确认
   ─────────────────────

   MUST（必需）:
   ┌────┬──────────────────┬──────────┬──────────────────────────┐
   │ ID │ 字段             │ 清晰度   │ 值/问题                  │
   ├────┼──────────────────┼──────────┼──────────────────────────┤
   │ R1 │ paper_title      │ ASSUMED  │ 推断: "SmartQuery: ..."  │
   │ R2 │ innovations      │ BLOCKED  │ ❓ 请描述核心创新点      │
   │ R3 │ system_architecture │ CLEAR │ ✅ 已提供                │
   │ R4 │ key_terminology  │ BLOCKED  │ ❓ 请列出关键术语        │
   └────┴──────────────────┴──────────┴──────────────────────────┘

   SHOULD（建议）:
   ┌────┬──────────────────┬──────────┬──────────────────────────┐
   │ R5 │ target_venue     │ BLOCKED  │ ❓ 请选择目标会议/期刊   │
   │ R6 │ target_system    │ ASSUMED  │ 推断: "基于知识图谱的..." │
   └────┴──────────────────┴──────────┴──────────────────────────┘

   MAY（可选）:
   ┌────┬──────────────────┬──────────┬──────────────────────────┐
   │ R7 │ codebase_path    │ CLEAR    │ ✅ 已提供                │
   │ R8 │ additional_context│ BLOCKED │ （可选，跳过亦可）       │
   └────┴──────────────────┴──────────┴──────────────────────────┘
   ```

2. **处理用户输入**
   - 对 BLOCKED 的 MUST 项，用户**必须**提供输入才能继续
   - 对 BLOCKED 的 SHOULD/MAY 项，用户可跳过
   - 对 ASSUMED 项，用户可确认系统推断或提供修改值

3. **确认循环**
   - 如果用户提供了部分输入，重新检测清晰度
   - 直到所有 MUST 项至少为 ASSUMED（有系统推断且用户确认）

### Step 4：保存并应用

1. **写入 requirements-spec.json**
   - 路径：`workspace/{project}/phase0/requirements-spec.json`
   - 包含完整的结构化需求数据（见下方数据结构）

2. **写入 requirements-spec.md**
   - 路径：`workspace/{project}/phase0/requirements-spec.md`
   - 人类可读的需求规范表（见下方模板）

3. **更新 input-context.md**
   - 如果 `input-context.md` **不存在**：基于确认的需求自动生成完整文件
   - 如果 `input-context.md` **已存在**：将确认的需求合并更新到对应字段

---

## 输出文件

### 1. `workspace/{project}/phase0/requirements-spec.json`

```json
{
  "project": "{project}",
  "timestamp": "ISO-8601",
  "trigger_reason": "missing_fields|incomplete_context|user_requested",
  "overall_clarity": "clear|partial|blocked",
  "requirements": [
    {
      "id": "REQ-01",
      "field": "paper_title",
      "priority": "MUST",
      "clarity": "ASSUMED",
      "current_value": "Smart Query System",
      "assumed_value": "SmartQuery: An Ontology-Driven Natural Language Interface for Heterogeneous Data Sources",
      "user_confirmed_value": null,
      "guidance_question": null
    },
    {
      "id": "REQ-02",
      "field": "innovations",
      "priority": "MUST",
      "clarity": "BLOCKED",
      "current_value": null,
      "assumed_value": null,
      "user_confirmed_value": null,
      "guidance_question": "请描述您的系统相比现有方案的 2-3 个核心创新点，包括技术方法和预期效果"
    },
    {
      "id": "REQ-03",
      "field": "system_architecture",
      "priority": "MUST",
      "clarity": "CLEAR",
      "current_value": "三层架构：NL解析层 → 知识图谱映射层 → 查询执行层...",
      "assumed_value": null,
      "user_confirmed_value": null,
      "guidance_question": null
    }
  ],
  "blocked_count": 0,
  "assumed_count": 1,
  "clear_count": 5,
  "user_confirmed": false
}
```

### 2. `workspace/{project}/phase0/requirements-spec.md`

```markdown
# 需求规范文档 — {project}

> 生成时间：{timestamp}
> 触发原因：{trigger_reason}
> 整体清晰度：{overall_clarity}

---

## MUST — 必需字段

| ID | 字段 | 清晰度 | 当前值 | 系统推断 | 引导问题 |
|----|------|--------|--------|----------|----------|
| REQ-01 | paper_title | ASSUMED | Smart Query System | SmartQuery: An Ontology-Driven... | — |
| REQ-02 | innovations | BLOCKED | — | — | 请描述核心创新点 |
| REQ-03 | system_architecture | CLEAR | 三层架构... | — | — |
| REQ-04 | key_terminology | BLOCKED | — | — | 请列出关键术语 |

## SHOULD — 建议字段

| ID | 字段 | 清晰度 | 当前值 | 系统推断 | 引导问题 |
|----|------|--------|--------|----------|----------|
| REQ-05 | target_venue | BLOCKED | — | — | 请选择目标会议/期刊 |
| REQ-06 | target_system | ASSUMED | — | 基于知识图谱的... | — |

## MAY — 可选字段

| ID | 字段 | 清晰度 | 当前值 | 系统推断 | 引导问题 |
|----|------|--------|--------|----------|----------|
| REQ-07 | codebase_path | CLEAR | /path/to/repo | — | — |
| REQ-08 | additional_context | BLOCKED | — | — | （可选，跳过亦可） |

---

## 统计

- BLOCKED: {blocked_count} 项
- ASSUMED: {assumed_count} 项
- CLEAR: {clear_count} 项
- 用户已确认: {user_confirmed}
```

### 3. 返回值

**成功（需要交互）：**

```json
{
  "success": true,
  "skip": false,
  "action": "requirements_confirmed",
  "blocked_count": 0,
  "assumed_count": 1,
  "clear_count": 5,
  "user_confirmed": true,
  "files_written": [
    "workspace/{project}/phase0/requirements-spec.json",
    "workspace/{project}/phase0/requirements-spec.md"
  ],
  "input_context_updated": true
}
```

**成功（跳过）：**

```json
{
  "success": true,
  "skip": true,
  "reason": "all_fields_clear"
}
```

---

## 与其他 Skill 的集成

### 1. paper-generation（主编排器）

在 **Step 0.0** 调用本 Skill（Step 0.1 验证输入之前）：

```python
# 伪代码 — paper-generation 编排器中的调用位置
def orchestrate(project):
    # Step 0.0: 需求规范检查（在验证输入之前）
    spec_result = Skill(skill="requirements-spec", args=f"{project}")

    if spec_result["skip"]:
        # 所有字段清晰，直接进入 Step 0.1
        pass
    else:
        # 需求已确认，input-context.md 已更新
        pass

    # Step 0.1: 验证输入（原有流程）
    validate_input_context(project)
    # ...后续 Phase 编排
```

### 2. codebase-analyzer（代码库分析工具）

当 `codebase_path` 存在但 `input-context.md` 缺失时，建议先调用 `codebase-analyzer`：

```python
if has_codebase_path and not has_input_context:
    # 建议用户先运行 codebase-analyzer
    suggest_action = "建议先运行 codebase-analyzer 从代码库自动生成 input-context.md"
```

### 3. research-interview（研究访谈）

如果 `research-interview` 已完成（存在访谈记录文件），`requirements-spec` 可跳过：

```python
interview_file = f"workspace/{project}/phase0/research-interview.json"
if file_exists(interview_file):
    return {"skip": true, "reason": "research_interview_completed"}
```

### 4. interaction-manager（交互管理器）

复用 `interaction-manager` 的 AskUserQuestion 模式进行交互确认：

```python
# 使用 AskUserQuestion 展示需求规范
AskUserQuestion(
    questions=[{
        "question": formatted_requirements_table,
        "header": "需求规范确认",
        "options": [
            {"label": "确认全部", "description": "接受所有推断值，继续流程"},
            {"label": "逐项修改", "description": "对特定项提供修改"},
            {"label": "取消", "description": "取消需求规范，稍后再试"}
        ],
        "multiSelect": false
    }]
)
```

### 5. feedback-collector（反馈收集器）

保存用户确认到 `user-feedback.json`：

```python
# 将需求确认记录追加到 user-feedback.json
save_feedback(project, "requirements_spec", {
    "checkpoint": "requirements_spec",
    "timestamp": "ISO-8601",
    "confirmed_requirements": confirmed_list,
    "modified_fields": modified_list
})
```

---

## 错误处理

| 错误 | 处理 |
|------|------|
| 项目目录不存在 | 自动创建 `workspace/{project}/` 和 `phase0/` 目录 |
| 用户取消确认 | 记录取消状态到 `requirements-spec.json`，不阻塞后续流程 |
| 所有字段 BLOCKED | 建议用户先使用 `codebase-analyzer` 或 `research-interview` 生成基础素材 |
| config.json 缺少 requirements_spec | 使用默认配置：`enabled=true, min_blocked_to_trigger=2` |
| input-context.md 编码异常 | 尝试 UTF-8 读取，失败则提示用户检查文件编码 |

---

## 使用示例

```bash
# 标准调用 — 检测并澄清需求
Skill(skill="requirements-spec", args="smart-query")

# 在 paper-generation 编排器中自动调用
# （编排器在 Step 0.0 自动触发，无需手动调用）
```

---

## 流程图

```
┌─────────────────────────────────────────────────────────────┐
│                  需求规范协议流程                            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Step 1: 模糊度检测                                        │
│  ┌────────────────────────────────────────────────────┐     │
│  │ 读取 config.json → requirements_spec 配置          │     │
│  │ 读取 input-context.md（如存在）                    │     │
│  │ 逐字段检查: CLEAR / ASSUMED / BLOCKED              │     │
│  │                                                    │     │
│  │ 全部 CLEAR? ──→ 跳过，返回 skip=true              │     │
│  │      ↓ 否                                          │     │
│  └────────────────────────────────────────────────────┘     │
│                         ↓                                   │
│  Step 2: 生成需求规范文档                                  │
│  ┌────────────────────────────────────────────────────┐     │
│  │ 标记优先级: MUST / SHOULD / MAY                    │     │
│  │ ASSUMED → 生成系统推断值                           │     │
│  │ BLOCKED → 生成引导性问题                           │     │
│  └────────────────────────────────────────────────────┘     │
│                         ↓                                   │
│  Step 3: 交互确认                                          │
│  ┌────────────────────────────────────────────────────┐     │
│  │ AskUserQuestion 展示需求规范表                     │     │
│  │ BLOCKED MUST → 用户必须提供输入                    │     │
│  │ ASSUMED → 用户确认或修改推断值                     │     │
│  │ BLOCKED SHOULD/MAY → 用户可跳过                    │     │
│  └────────────────────────────────────────────────────┘     │
│                         ↓                                   │
│  Step 4: 保存并应用                                        │
│  ┌────────────────────────────────────────────────────┐     │
│  │ 写入 phase0/requirements-spec.json                 │     │
│  │ 写入 phase0/requirements-spec.md                   │     │
│  │ 生成/更新 input-context.md                         │     │
│  │ 保存反馈到 user-feedback.json                      │     │
│  └────────────────────────────────────────────────────┘     │
│                         ↓                                   │
│              返回结果 → 进入 paper-generation               │
└─────────────────────────────────────────────────────────────┘
```
