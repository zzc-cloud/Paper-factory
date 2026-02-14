# Feedback Collector Skill

> **反馈收集器** — 收集用户在各交互节点的反馈，结构化存储，并提供自动应用逻辑。
>
> **V2 新增**：交互式论文生成流程 — 自动解析用户反馈并智能调整后续策略，无需手动干预。

---

## Skill 概述

本 Skill 是用户反馈的中央存储和分析组件，负责：

1. **收集中存储**：从 interaction-manager 接收用户反馈
2. **结构化处理**：将反馈分类为确认、修改、补充等类型
3. **智能应用**：根据反��内容自动调整后续 Agent 策略
4. **历史追踪**：记录完整的反馈历史供版本管理使用

---

## 输入参数

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `project` | string | ✅ | 项目名称（对应 workspace/{project}/ 目录）|
| `checkpoint` | string | ✅ | 交互节点 ID（如 phase0_title_confirmation）|
| `user_feedback` | object | ✅ | 用户反馈数据（从 AskUserQuestion 获取）|

---

## 输出

### 1. 主输出：`workspace/{project}/user-feedback.json`

```json
{
  "project": "my-project",
  "created_at": "2026-02-14T10:00:00Z",
  "last_updated": "2026-02-14T11:30:00Z",
  "checkpoints_completed": [
    "phase0_venue_selection",
    "phase0_title_confirmation",
    "phase0_abstract_framework"
  ],
  "feedback_summary": {
    "total_checkpoints": 4,
    "completed": 3,
    "pending": 1,
    "custom_inputs_count": 2
  },
  "feedback_history": {
    "phase0_venue_selection": {
      "checkpoint": "phase0_venue_selection",
      "timestamp": "2026-02-14T10:05:00Z",
      "user_choice": "AAAI",
      "is_predefined": true,
      "custom_input": null,
      "feedback_type": "selection"
    },
    "phase0_title_confirmation": {
      "checkpoint": "phase0_title_confirmation",
      "timestamp": "2026-02-14T10:15:00Z",
      "user_choice": "custom",
      "custom_input": "Multi-Agent Coordination for Adaptive Task Allocation: A Neuro-Symbolic Approach",
      "feedback_type": "custom_input",
      "applied_to": {
        "file": "workspace/my-project/input-context.md",
        "field": "paper_title"
      }
    }
  }
  },
  "auto_apply_log": [
    {
      "timestamp": "2026-02-14T10:05:01Z",
      "action": "update_venue_config",
      "success": true,
      "details": "Called venue-analyzer with AAAI"
    },
    {
      "timestamp": "2026-02-14T10:15:01Z",
      "action": "update_paper_title",
      "success": true,
      "details": "Updated input-context.md with custom title"
    }
  ]
}
```

### 2. 辅助输出：`workspace/{project}/feedback-analysis.json`

```json
{
  "analysis_timestamp": "2026-02-14T11:30:00Z",
  "total_feedback_items": 3,
  "custom_inputs_count": 2,
  "modification_requests": 0,
  "auto_apply_success_rate": 1.0,
  "feedback_categories": {
    "selection": 1,
    "custom_input": 2,
    "modification": 0
  }
}
```

### 3. 返回值（成功）

```json
{
  "success": true,
  "feedback_saved": true,
  "feedback_type": "custom_input",
  "auto_applied": true,
  "applied_action": "update_paper_title",
  "feedback_file": "workspace/{project}/user-feedback.json"
}
```

---

## 执行流程

### Step 1：初始化与验证

```bash
project_dir="/Users/yyzz/Desktop/MyClaudeCode/paper-factory/workspace/${project}"
feedback_file="${project_dir}/user-feedback.json"

# 如果文件不存在，创建基础结构
if [ ! -f "${feedback_file}" ]; then
  init_feedback_file("${feedback_file}")
fi
```

### Step 2：读取现有反馈

使用 Read 工具读取 `user-feedback.json`，获取已完成的交互节点和历史反馈。

### Step 3：分类新反馈

根据用户反馈类型进行分类：

```python
# 伪代码
def classify_feedback(checkpoint, user_feedback):
  feedback_type = None
  feedback_value = None
  auto_apply_action = None

  if checkpoint == "phase0_venue_selection":
    feedback_type = "selection"
    feedback_value = user_feedback["selected_option"]
    auto_apply_action = "update_venue_config"

  elif checkpoint == "phase0_title_confirmation":
    if user_feedback.get("custom_input"):
      feedback_type = "custom_input"
      feedback_value = user_feedback["custom_input"]
      auto_apply_action = "update_paper_title"
    else:
      feedback_type = "selection"
      feedback_value = user_feedback["selected_option"]
      auto_apply_action = "confirm_title_choice"

  elif checkpoint == "phase0_abstract_framework":
    if user_feedback.get("edited_content"):
      feedback_type = "modification"
      feedback_value = user_feedback["edited_content"]
      auto_apply_action = "update_abstract_framework"
    else:
      feedback_type = "confirmation"
      feedback_value = "accepted"
      auto_apply_action = "confirm_framework"

  elif checkpoint == "phase2_b3_outline_confirmation":
    feedback_type = "confirmation" if user_feedback["selected_option"] == "accept" else "modification"
    feedback_value = user_feedback
    auto_apply_action = "handle_outline_feedback"

  return {
    "type": feedback_type,
    "value": feedback_value,
    "auto_apply_action": auto_apply_action
  }
```

### Step 4：自动应用反馈

根据反馈类型执行自动应用：

#### 4.1 期刊选择反馈

```python
def apply_venue_selection(project, venue_id, is_predefined):
  if is_predefined:
    # 调用 venue-analyzer
    result = Skill(skill="venue-analyzer", args=f"{project},{venue_id}")
    return {
      "action": "update_venue_config",
      "success": result.get("success", false),
      "details": f"Called venue-analyzer with {venue_id}"
    }
  else:
    # 自定义期刊，提示用户补充配置
    return {
      "action": "prompt_custom_config",
      "success": True,
      "details": "Custom venue selected, configuration may be incomplete"
    }
```

#### 4.2 题目确认反馈

```python
def apply_title_feedback(project, user_choice):
  if user_choice.get("custom_input"):
    # 更新 input-context.md
    update_input_context(project, "paper_title", user_choice["custom_input"])
    # 通知后续 Agent 使用确认的题目
    notify_agents_about_title(project, user_choice["custom_input"])
    return {
      "action": "update_paper_title",
      "success": True,
      "details": "Updated input-context.md with custom title"
    }
  else:
    # 选择候选题目
    selected_index = int(user_choice["selected_option"][-1]) - 1
    update_input_context(project, "paper_title", f"option_{selected_index}")
    return {
      "action": "confirm_title_choice",
      "success": True,
      "details": f"Selected candidate title {selected_index}"
    }
```

#### 4.3 摘要框架反馈

```python
def apply_abstract_framework_feedback(project, user_choice):
  framework_file = f"workspace/{project}/phase0/abstract-framework.md"

  if user_choice.get("edited_content"):
    # 保存用户编辑的框架
    write_file(framework_file, user_choice["edited_content"])
    return {
      "action": "update_abstract_framework",
      "success": True,
      "details": "Saved user-edited abstract framework"
    }
  else:
    # 接受默认框架
    generate_default_framework(project, framework_file)
    return {
      "action": "confirm_framework",
      "success": True,
      "details": "Confirmed default abstract framework"
    }
```

#### 4.4 大纲确认反馈

```python
def apply_outline_feedback(project, user_choice):
  action = user_choice["selected_option"]

  if action == "accept":
    # 标记大纲已接受，Phase 3 按大纲撰写
    mark_outline_accepted(project)
    return {
      "action": "confirm_outline",
      "success": True,
      "details": "Outline marked as accepted for Phase 3"
    }

  elif action == "modify":
    # 收集修改意见
    modifications = collect_modifications(project)
    save_modifications(project, modifications)
    return {
      "action": "collect_outline_modifications",
      "success": True,
      "details": "Collected modification requests for B3"
    }

  elif action == "regenerate":
    # 使用不同配置触发 B3 重新运行
    trigger_outline_regeneration(project)
    return {
      "action": "regenerate_outline",
      "success": True,
      "details": "Triggered B3-paper-architect regeneration"
    }
```

### Step 5：更新反馈文件

```python
def update_feedback_file(project, checkpoint, feedback_data, apply_result):
  feedback_file = f"workspace/{project}/user-feedback.json"

  # 读取现有数据
  data = read_json(feedback_file) if exists else init_feedback_structure()

  # 更新数据
  data["last_updated"] = get_iso_timestamp()
  data["checkpoints_completed"].append(checkpoint)

  feedback_entry = {
    "checkpoint": checkpoint,
    "timestamp": get_iso_timestamp(),
    "user_choice": feedback_data["user_choice"],
    "custom_input": feedback_data.get("custom_input"),
    "feedback_type": feedback_data["feedback_type"]
  }

  data["feedback_history"][checkpoint] = feedback_entry

  # 记录自动应用
  if apply_result:
    data["auto_apply_log"].append({
      "timestamp": get_iso_timestamp(),
      "action": apply_result["action"],
      "success": apply_result["success"],
      "details": apply_result["details"]
    })

  # 写回文件
  write_json(feedback_file, data)
```

### Step 6：生成反馈分析报告

可选：生成 `feedback-analysis.json` 提供反馈统计。

---

## 反馈类型定义

| 类型 | 说明 | 自动应用 |
|------|------|----------|
| `selection` | 用户从预设选项中选择 | ✅ |
| `custom_input` | 用户自定义输入内容 | ✅ |
| `confirmation` | 用户确认/接受 | ✅ |
| `modification` | 用户请求修改 | ✅ |
| `regeneration` | 用户请求重新生成 | ✅ |

---

## 自动应用策略

### 策略映射表

| 检查点 | 反馈类型 | 自动应用动作 |
|--------|---------|------------|
| phase0_venue_selection | selection | 调用 venue-analyzer |
| phase0_venue_selection | custom | 提示配置模板 |
| phase0_title_confirmation | selection | 确认候选题目 |
| phase0_title_confirmation | custom | 更新 input-context.md |
| phase0_abstract_framework | confirmation | 保存默认框架 |
| phase0_abstract_framework | modification | 保存编辑后的框架 |
| phase2_b3_outline_confirmation | accept | 标记接受 |
| phase2_b3_outline_confirmation | modification | 收集修改意见 |
| phase2_b3_outline_confirmation | regeneration | 触发 B3 |

---

## 与其他 Skill 的集成

1. **interaction-manager**：在获取用户反馈后调用本 Skill
2. **venue-analyzer**：在应用期刊选择反馈时调用
3. **Phase Skills**：读取 user-feedback.json 获取用户决策
4. **version-manager**：使用 feedback-history 生成版本变更日志

---

## 数据结构

### user-feedback.json 初始化结构

```json
{
  "project": "",
  "created_at": "",
  "last_updated": "",
  "checkpoints_completed": [],
  "feedback_summary": {
    "total_checkpoints": 0,
    "completed": 0,
    "pending": 0,
    "custom_inputs_count": 0
  },
  "feedback_history": {},
  "auto_apply_log": []
}
```

### feedback_history 条目格式

```json
{
  "checkpoint": "checkpoint_id",
  "timestamp": "ISO-8601",
  "user_choice": {
    "selected_option": "option_value",
    "custom_input": "custom_value or null"
  },
  "feedback_type": "selection|custom_input|confirmation|modification",
  "applied_to": {
    "file": "file_path",
    "field": "field_name",
    "action": "action_description"
  }
}
```

---

## 错误处理

| 错误类型 | 处理方式 |
|---------|---------|
| 项目不存在 | 返回错误，提示检查项目名称 |
| 无法写入反馈文件 | 返回错误，提示检查文件权限 |
| 无效的反馈数据 | 记录警告，使用默认值 |
| 自动应用失败 | 记录错误到 auto_apply_log，继续执行 |

---

## 使用示例

```bash
# 期刊选择反馈
Skill(skill="feedback-collector", args="my-project,phase0_venue_selection,{\"selected_option\":\"AAAI\"}")

# 题目确认反馈（自定义输入）
Skill(skill="feedback-collector", args="my-project,phase0_title_confirmation,{\"selected_option\":\"custom\",\"custom_input\":\"My Custom Title\"}")

# 大纲确认反馈
Skill(skill="feedback-collector", args="my-project,phase2_b3_outline_confirmation,{\"selected_option\":\"accept\"}")
```

---

## 反馈应用流程图

```
用户反馈
   │
   ▼
┌─────────────────────────────┐
│  Feedback Collector      │
│  接收并分类反馈        │
└─────────────────────────────┘
   │
   ├─► 类型判断
   │   ├─ selection ──────► 自动应用配置
   │   ├─ custom_input ───► 更新上下文文件
   │   ├─ confirmation ────► 标记确认状态
   │   └─ modification ────► 收集/触发重新生成
   │
   ▼
┌─────────────────────────────┐
│   保存反馈记录          │
│  user-feedback.json       │
│  feedback-analysis.json    │
└─────────────────────────────┘
   │
   ▼
┌─────────────────────────────┐
│  通知后续组件           │
│  - Agent 知道用户决策    │
│  - Phase 调整策略        │
└─────────────────────────────┘
```
