# Interaction Manager Skill

> **交互管理器（简化版）** — 管理论文生成流程中的关键交互节点，使用 AskUserQuestion 工具获取用户确认和反馈。仅支持关键节点确认（Phase 0 期刊/题目/摘要，Phase 2 大纲），自动应用用户反馈。

---

## Skill 概述

本 Skill 是"人类在环"(Human-in-the-Loop)流程的核心控制器，负责：

1. **管理交互节点**：定义关键确认点和可选确认点
2. **调用 AskUserQuestion**：在适当时机向用户提问
3. **收集用户反馈**：结构化存储用户输入
4. **自动应用反馈**：根据用户选择调整后续策略

### 设计原则

根据用户确认的设计决策：
- **仅关键节点**：不在 Agent 级别打断流程
- **自动应用反馈**：系统自动解析用户反馈并调整策略
- **混合期刊支持**：区分预定义期刊和自定义期刊

---

## 输入参数

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `project` | string | ✅ | 项目名称（对应 workspace/{project}/ 目录）|
| `checkpoint` | string | ✅ | 当前交互节点 ID（如 phase0_venue_selection）|
| `question_data` | object | ✅ | 问题配置（标题、选项、默认值）|

---

## 支持的交互节点

### Phase 0：启动确认阶段

#### phase0_venue_selection

```json
{
  "checkpoint": "phase0_venue_selection",
  "question": "请选择目标会议/期刊",
  "options_mode": "venue_list",
  "output_field": "target_venue",
  "custom_venue_handler": "prompt_for_config"
}
```

**行为**：
1. 从 config.json 读取 `venue_analysis.defined_venues` 列表
2. 生成选项列表（AAAI, IJCAI, ... + Other）
3. 如果用户选择 "Other"，提示输入自定义期刊 ID
4. 检测是否为预定义期刊
5. 写入 `workspace/{project}/input-context.md` 的 `target_venue` 字段

#### phase0_title_confirmation

```json
{
  "checkpoint": "phase0_title_confirmation",
  "question": "请确认论文题目",
  "options_mode": "generated_titles",
  "allow_custom": true,
  "output_field": "paper_title"
}
```

**行为**：
1. 读取 Phase 1 创新聚合的输出（`phase1/innovation-synthesis.json`）
2. 生成 3-5 个候选题目选项
3. 提供用户选择或自定义
4. 写入 `workspace/{project}/input-context.md` 的 `paper_title` 字段

#### phase0_abstract_framework

```json
{
  "checkpoint": "phase0_abstract_framework",
  "question": "请确认摘要框架",
  "options_mode": "abstract_structure",
  "allow_edit": true,
  "output_file": "workspace/{project}/phase0/abstract-framework.md"
}
```

**行为**：
1. 基于 `venue-style-guide.md` 中的摘要结构生成框架
2. 用户可编辑确认
3. 保存到 `workspace/{project}/phase0/abstract-framework.md`

### Phase 2：设计阶段

#### phase2_b3_outline_confirmation

```json
{
  "checkpoint": "phase2_b3_outline_confirmation",
  "question": "请确认论文章节大纲",
  "options_mode": "outline_structure",
  "allow_reorder": true,
  "actions": ["accept", "modify", "regenerate"]
}
```

**行为**：
1. 读取 B3 生成的论文大纲（`phase2/b3-paper-outline.json`）
2. 展示章节结构
3. 用户可接受、修改或重新生成
4. 保存用户反馈到 `workspace/{project}/user-feedback.json`

---

## 输出文件

### 1. `workspace/{project}/user-feedback.json`

```json
{
  "project": "{project_name}",
  "last_updated": "ISO-8601 timestamp",
  "checkpoints_completed": [
    "phase0_venue_selection",
    "phase0_title_confirmation"
  ],
  "feedback_history": {
    "phase0_venue_selection": {
      "checkpoint": "phase0_venue_selection",
      "selected_option": "AAAI",
      "timestamp": "ISO-8601",
      "is_predefined_venue": true,
      "custom_input": null
    },
    "phase0_title_confirmation": {
      "checkpoint": "phase0_title_confirmation",
      "selected_option": "option_2",
      "custom_input": "Multi-Agent Coordination for Adaptive Task Allocation: A Neuro-Symbolic Approach",
      "timestamp": "ISO-8601"
    }
  }
}
```

### 2. `workspace/{project}/feedback-history.md`

```markdown
# 用户反馈历史

## phase0_venue_selection

**时间**：2026-02-14 10:30:00
**选择**：AAAI（预定义期刊）

---

## phase0_title_confirmation

**时间**：2026-02-14 10:32:15
**选择**：option_2
**自定义输入**：Multi-Agent Coordination for Adaptive Task Allocation: A Neuro-Symbolic Approach

---

```

### 3. 返回值（成功）

```json
{
  "success": true,
  "checkpoint": "phase0_venue_selection",
  "user_choice": "AAAI",
  "is_predefined_venue": true,
  "feedback_saved": true,
  "auto_apply_strategy": "update_venue_config"
}
```

---

## 执行流程

### Step 1：初始化

```bash
project_dir="/Users/yyzz/Desktop/MyClaudeCode/paper-factory/workspace/${project}"
feedback_file="${project_dir}/user-feedback.json"
history_file="${project_dir}/feedback-history.md"

# 创建目录
mkdir -p "${project_dir}/phase0"
```

### Step 2：加载现有反馈（如果存在）

使用 Read 工具读取 `user-feedback.json`，获取已完成的交互节点和历史反馈。

### Step 3：根据 checkpoint 类型调用 AskUserQuestion

#### phase0_venue_selection

```python
# 伪代码
venued_venues = config.json["venue_analysis"]["defined_venues"]
options = []
for venue in venued_venues:
  options.append({
    "label": venue,
    "description": f"{venues.md[venue].full_name}"
  })
options.append({
    "label": "Other",
    "description": "输入自定义会议/期刊"
  })

user_choice = AskUserQuestion(
  questions=[{
    "question": "请选择目标会议/期刊",
    "header": "期刊选择",
    "options": options,
    "multiSelect": false
  }]
)

if user_choice == "Other":
  # 引导用户输入自定义期刊
  custom_venue_id = prompt_for_custom_venue()
  # 检查是否在 venues.md 中
  is_predefined = check_if_venued(custom_venue_id)
else:
  custom_venue_id = user_choice
  is_predefined = true

# 写入 input-context.md
update_input_context(project, "target_venue", custom_venue_id)
```

#### phase0_title_confirmation

```python
# 伪代码
# 读取创新聚合生成的候选题目
innovations_file = f"{project_dir}/phase1/innovation-synthesis.json"
innovations = read_json(innovations_file)

candidate_titles = generate_candidate_titles(innovations)

options = []
for i, title in enumerate(candidate_titles[:3]):
  options.append({
    "label": f"选项 {i+1}",
    "description": title
  })
options.append({
    "label": "自定义",
    "description": "输入自定义题目"
  })

user_response = AskUserQuestion(
  questions=[{
    "question": "请确认论文题目",
    "header": "题目确认",
    "options": options,
    "multiSelect": false
  }]
)

if user_response["selected"] == "自定义":
  final_title = user_response["custom_input"]
else:
  final_title = candidate_titles[int(user_response["selected"][-1]) - 1]

# 写入 input-context.md
update_input_context(project, "paper_title", final_title)
```

#### phase0_abstract_framework

```python
# 伪代码
# 读取 venue-style-guide.md
venue_guide = read_venue_style_guide(project)
abstract_structure = venue_guide["abstract_structure"]

framework = generate_abstract_framework(abstract_structure)

# 展示框架并允许编辑
user_confirmed_framework = AskUserQuestion(
  questions=[{
    "question": f"请确认摘要框架：\n\n{framework}",
    "header": "摘要框架确认",
    "options": [
      {"label": "接受", "description": "使用此框架生成摘要"},
      {"label": "编辑", "description": "修改框架内容"}
    ],
    "multiSelect": false
  }]
)

# 保存框架
write_framework_to_file(project, user_confirmed_framework)
```

#### phase2_b3_outline_confirmation

```python
# 伪代码
# 读取 B3 生成的论文大纲
outline_file = f"{project_dir}/phase2/b3-paper-outline.json"
outline = read_json(outline_file)

# 展示大纲结构
outline_summary = format_outline_for_display(outline)

user_response = AskUserQuestion(
  questions=[{
    "question": f"请确认论文章节大纲：\n\n{outline_summary}",
    "header": "大纲确认",
    "options": [
      {"label": "接受", "description": "接受此大纲结构"},
      {"label": "修改", "description": "提供修改意见"},
      {"label": "重新生成", "description": "使用不同配置重新生成大纲"}
    ],
    "multiSelect": false
  }]
)

# 保存反馈
save_feedback(project, "phase2_b3_outline_confirmation", user_response)
```

### Step 4：保存反馈

将用户的选择和反馈写入 `user-feedback.json` 和 `feedback-history.md`。

### Step 5：自动应用反馈

根据用户选择自动调整后续策略：

```python
# 伪代码
def auto_apply_feedback(checkpoint, user_choice, project):
  if checkpoint == "phase0_venue_selection":
    venue_id = user_choice
    # 调用 venue-analyzer 获取期刊配置
    Skill(skill="venue-analyzer", args=f"{project},{venue_id}")
    # 更新写作策略
    update_writing_strategy(project, venue_id)

  elif checkpoint == "phase0_title_confirmation":
    title = user_choice
    # 更新 input-context.md
    update_input_context(project, "paper_title", title)
    # 通知后续 Agent 使用确认的题目
    notify_agents_about_title(project, title)

  elif checkpoint == "phase0_abstract_framework":
    framework = user_choice
    # 保存框架供 C1 参考
    save_abstract_framework(project, framework)

  elif checkpoint == "phase2_b3_outline_confirmation":
    if user_choice == "accept":
      # 继续使用此大纲
      mark_outline_accepted(project)
    elif user_choice == "modify":
      # 收集修改意见供 B3 重新生成
      collect_outline_modifications(project)
    elif user_choice == "regenerate":
      # 使用不同配置重新生成
      trigger_outline_regeneration(project)
```

### Step 6：返回结果

---

## 自动应用反馈逻辑

### 期刊选择反馈

- **预定义期刊**：直接调用 venue-analyzer，生成完整风格指南
- **自定义期刊**：
  - 如果在 venues.md 中：调用 venue-analyzer（可能有警告）
  - 如果不在：提示用户添加配置，使用默认风格指南

### 题目确认反馈

- **选择候选题目**：更新 input-context.md，通知所有后续 Agent
- **自定义题目**：更新 input-context.md，触发创新聚合重新整理创新点

### 摘要框架反馈

- **接受**：保存框架供 Phase 3 C1 参考
- **编辑**：保存用户编辑的框架，C1 使用编辑后的版本

### 大纲确认反馈

- **接受**：标记大纲已接受，Phase 3 C1 按大纲撰写
- **修改**：收集修改意见，B3 调整大纲
- **重新生成**：使用不同配置触发 B3 重新运行

---

## 数据结构

### user-feedback.json

```json
{
  "project": "项目名称",
  "created_at": "ISO-8601",
  "last_updated": "ISO-8601",
  "checkpoints_completed": [],
  "feedback_history": {},
  "auto_apply_log": []
}
```

### checkpoint 记录格式

```json
{
  "checkpoint_id": "phase0_venue_selection",
  "timestamp": "ISO-8601",
  "user_choice": "AAAI",
  "is_predefined": true,
  "custom_input": null,
  "auto_applied": {
    "action": "update_venue_config",
    "success": true,
    "file_created": "venue-style-guide.md"
  }
}
```

---

## 与其他 Skill 的集成

1. **paper-generation**：在 Phase 0 之前按顺序调用本 Skill 的各个 checkpoint
2. **venue-analyzer**：在 phase0_venue_selection 后自动调用
3. **feedback-collector**：（可选）如果需要更复杂的反馈处理，调用 feedback-collector
4. **Phase Skills**：读取 user-feedback.json 获取用户决策

---

## 错误处理

| 错误 | 处理 |
|------|------|
| 项目不存在 | 返回错误，提示检查项目名称 |
| 无法读取 input-context.md | 尝试创建或提示用户创建 |
| 用户取消选择 | 记录取消，不强制要求 |
| AskUserQuestion 超时 | 记录超时，使用默认值 |

---

## 使用示例

```bash
# 期刊选择
Skill(skill="interaction-manager", args="my-project,phase0_venue_selection")

# 题目确认（需要先完成 Phase 1 创新聚合）
Skill(skill="interaction-manager", args="my-project,phase0_title_confirmation")

# 大纲确认（需要先完成 Phase 2 B3）
Skill(skill="interaction-manager", args="my-project,phase2_b3_outline_confirmation")
```

---

## 简化流程图

```
┌─────────────────────────────────────────────────────────┐
│              交互确认流程                              │
├─────────────────────────────────────────────────────────┤
│                                                                    │
│  Phase 0: 启动阶段                                        │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ 1. 期刊选择 (AskUserQuestion)                  │   │
│  │    ├─ 预定义期刊 → 自动配置                   │   │
│  │    └─ 自定义期刊 → 提示配置模板            │   │
│  │                   ▼                                │   │
│  │ 2. 题目确认 (AskUserQuestion)                  │   │
│  │    ├─ 候选题目 → 选择/自定义                   │   │
│  │    └─ 确认 → 写入 input-context.md            │   │
│  │                   ▼                                │   │
│  │ 3. 摘要框架确认 (AskUserQuestion)             │   │
│  │    ├─ 接受 → 保存框架                          │   │
│  │    └─ 编辑 → 用户修改后保存                 │   │
│  │                   ▼                                │   │
│  └─────────────────────────────────────────────────────┘   │
│                              ▼                                    │
│                    保存反馈记录                              │
│                    (user-feedback.json)                       │
│                              ▼                                    │
│                    自动应用反馈                                │
│                    (auto_apply_feedback)                       │
│                              ▼                                    │
│                    更新上下文文件                                │
│                    (input-context.md, etc.)                     │
└─────────────────────────────────────────────────────────┘
```
