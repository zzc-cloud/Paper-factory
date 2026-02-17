---
name: exploration-manager
description: "探索沙箱管理器 — 管理轻量级实验空间，支持快速试验不同研究方向、实验设计或写作风格，无需走完整流水线。"
---

# Exploration Manager — 探索沙箱管理器

## 概述

你是 **Exploration Manager（探索沙箱管理器）** — 负责管理轻量级实验空间，让用户可以快速试验不同的研究方向、实验设计或写作风格，无需走完整的 Phase 0 → Phase 4 流水线。

**调用方式**：

- 创建：`Skill(skill="exploration-manager", args="{project}:create:{name}")`
- 列出：`Skill(skill="exploration-manager", args="{project}:list")`
- 升级：`Skill(skill="exploration-manager", args="{project}:promote:{name}")`
- 归档：`Skill(skill="exploration-manager", args="{project}:archive:{name}")`

**核心职责**：

- 创建和管理独立于主流水线的实验空间
- 维护活跃实验索引
- 将成功实验的产物合并回主项目
- 归档已完成或放弃的实验

---

## 参数解析

从 `args` 解析（以 `:` 分隔）：

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `project` | string | 是 | 项目名称 |
| `action` | string | 是 | 操作类型：create / list / promote / archive |
| `name` | string | 条件 | 实验名称（create / promote / archive 时必填） |

验证：
1. `workspace/{project}/` 目录存在
2. `action` 为 create / list / promote / archive 之一
3. create / promote / archive 操作时 `name` 不为空

如果验证失败，返回 `"status": "blocked"` 并描述缺失内容。

---

## 实验目录结构

```
workspace/{project}/explorations/
├── ACTIVE_PROJECTS.md          # 活跃实验索引
├── {experiment-name}/
│   ├── README.md               # 目标、状态、发现
│   ├── input-context.md        # 实验专用上下文
│   ├── output/                 # 实验输出
│   └── session-log.md          # 进度笔记
└── ARCHIVE/
    ├── completed_{name}/
    └── abandoned_{name}/
```

---

## Action: create

创建新的实验空间。

### 输入

- `{project}` — 项目名称
- `{name}` — 实验名称
- 读取 `config.json` 中的 `exploration` 配置

### 输出

- `workspace/{project}/explorations/{name}/` — 实验目录
- `workspace/{project}/explorations/{name}/README.md` — 实验说明
- `workspace/{project}/explorations/{name}/output/` — 输出目录（空）
- `workspace/{project}/explorations/ACTIVE_PROJECTS.md` — 更新后的索引

### 执行步骤

#### Step 1: 读取配置

```python
config = read_json("config.json")
exploration_config = config.get("exploration", {})
max_active = exploration_config.get("max_active_experiments", 5)
```

#### Step 2: 检查活跃实验数量

```python
explorations_dir = f"workspace/{project}/explorations"
active_projects = scan_subdirectories(explorations_dir, exclude=["ARCHIVE"])

if len(active_projects) >= max_active:
    return {
        "status": "blocked",
        "message": f"活跃实验数量已达上限（{max_active}）。请先归档旧实验。",
        "active_experiments": active_projects
    }
```

#### Step 3: 检查名称冲突

```python
experiment_dir = f"workspace/{project}/explorations/{name}"

if directory_exists(experiment_dir):
    return {
        "status": "blocked",
        "message": f"实验名称 '{name}' 已存在。请选择不同名称。",
        "existing_experiments": active_projects
    }
```

#### Step 4: 创建实验目录及子目录

```bash
mkdir -p "workspace/{project}/explorations/{name}/output"
```

#### Step 5: 生成 README.md 模板

```python
timestamp = iso_timestamp()

readme_content = f"""# 实验：{name}

> 创建时间：{timestamp}
> 状态：进行中

## 目标

[描述实验目标]

## 假设

[描述实验假设]

## 方法

[描述实验方法]

## 发现

[记录实验发现]

## 结论

[实验结论和下一步]
"""

write_file(f"{experiment_dir}/README.md", readme_content)
```

#### Step 6: 可选复制 input-context.md

使用 `AskUserQuestion` 询问用户是否从主项目复制 `input-context.md` 作为基础：

```python
main_input = f"workspace/{project}/input-context.md"

if file_exists(main_input):
    answer = AskUserQuestion(
        "是否从主项目复制 input-context.md 作为实验基础？(yes/no)"
    )
    if answer.lower() in ["yes", "y", "是"]:
        copy_file(main_input, f"{experiment_dir}/input-context.md")
```

#### Step 7: 更新 ACTIVE_PROJECTS.md 索引

```python
index_path = f"workspace/{project}/explorations/ACTIVE_PROJECTS.md"
index = read_or_create_active_projects(index_path)

# 在活跃实验表格中追加新行
append_to_table(index, {
    "实验名称": name,
    "创建时间": timestamp[:10],
    "目标": "[待填写]",
    "状态": "进行中"
})

write_file(index_path, index)
```

#### Step 8: 提示用户

```
实验空间已创建：workspace/{project}/explorations/{name}/

你可以在实验目录中自由修改和测试：
- 编辑 README.md 记录目标和发现
- 直接调用单个 Agent Skill（如 A1 文献调研、B2 实验设计）
- 质量阈值降低到 60/100（快速迭代模式）
- 完成后使用 promote 合并回主项目，或 archive 归档
```

---

## Action: list

列出所有实验及其状态。

### 输入

- `{project}` — 项目名称

### 输出

- 返回活跃实验列表和归档实验列表（Markdown 格式）

### 执行步骤

#### Step 1: 读取索引

```python
index_path = f"workspace/{project}/explorations/ACTIVE_PROJECTS.md"
index_content = read_file(index_path)
```

#### Step 2: 扫描实验目录

```python
explorations_dir = f"workspace/{project}/explorations"
active_dirs = scan_subdirectories(explorations_dir, exclude=["ARCHIVE"])
archive_dir = f"{explorations_dir}/ARCHIVE"
archived_dirs = scan_subdirectories(archive_dir) if directory_exists(archive_dir) else []
```

#### Step 3: 读取每个实验的状态

```python
experiments = []
for exp_name in active_dirs:
    readme_path = f"{explorations_dir}/{exp_name}/README.md"
    if file_exists(readme_path):
        readme = read_file(readme_path)
        status = extract_status_from_readme(readme)
        objective = extract_objective_from_readme(readme)
        experiments.append({
            "name": exp_name,
            "status": status,
            "objective": objective
        })
```

#### Step 4: 展示结果

```python
output = """## 活跃实验

| 实验名称 | 状态 | 目标 |
|---------|------|------|
"""

for exp in experiments:
    output += f"| {exp['name']} | {exp['status']} | {exp['objective']} |\n"

output += f"\n## 已归档（{len(archived_dirs)} 个）\n\n"

if archived_dirs:
    output += "| 实验名称 | 归档类型 |\n|---------|----------|\n"
    for arch in archived_dirs:
        archive_type = "completed" if arch.startswith("completed_") else "abandoned"
        output += f"| {arch} | {archive_type} |\n"

return output
```

---

## Action: promote

将实验产物合并回主项目。

### 输入

- `{project}` — 项目名称
- `{name}` — 实验名称
- 读取实验的 README.md 和 output/ 内容

### 输出

- 选中的产物复制到主项目对应的 Phase 目录
- 实验移动到 `ARCHIVE/completed_{name}/`
- `ACTIVE_PROJECTS.md` 更新

### 执行步骤

#### Step 1: 验证实验存在且有内容

```python
experiment_dir = f"workspace/{project}/explorations/{name}"

if not directory_exists(experiment_dir):
    available = scan_subdirectories(f"workspace/{project}/explorations", exclude=["ARCHIVE"])
    return {
        "status": "error",
        "message": f"实验 '{name}' 不存在。",
        "available_experiments": available
    }

output_dir = f"{experiment_dir}/output"
output_files = list_files(output_dir)

if not output_files:
    return {
        "status": "blocked",
        "message": f"实验 '{name}' 的 output/ 目录为空，无可合并内容。"
    }
```

#### Step 2: 列出产物供用户选择

```python
artifacts = []
for f in output_files:
    artifacts.append(f)

# 同时检查实验目录下的其他产物
experiment_files = list_files(experiment_dir)
for f in experiment_files:
    if f not in ["README.md", "session-log.md"] and f != "output":
        artifacts.append(f)

answer = AskUserQuestion(
    f"实验 '{name}' 包含以下产物，请选择要合并的内容（逗号分隔序号，或 'all'）：\n"
    + "\n".join([f"  {i+1}. {a}" for i, a in enumerate(artifacts)])
)

selected = parse_selection(answer, artifacts)
```

#### Step 3: 复制选中产物到主项目

```python
for artifact in selected:
    source = f"{experiment_dir}/{artifact}"
    # 根据文件类型推断目标 Phase 目录
    target_phase = infer_target_phase(artifact)
    target = f"workspace/{project}/{target_phase}/{artifact}"
    copy_file(source, target)
```

#### Step 4: 更新主项目 input-context.md（如有变更）

```python
exp_input = f"{experiment_dir}/input-context.md"
main_input = f"workspace/{project}/input-context.md"

if file_exists(exp_input):
    answer = AskUserQuestion(
        "实验中的 input-context.md 与主项目不同。是否更新主项目的 input-context.md？(yes/no)"
    )
    if answer.lower() in ["yes", "y", "是"]:
        copy_file(exp_input, main_input)
```

#### Step 5: 归档实验

```python
archive_dir = f"workspace/{project}/explorations/ARCHIVE"
mkdir_p(archive_dir)
move_directory(experiment_dir, f"{archive_dir}/completed_{name}")
```

#### Step 6: 更新 ACTIVE_PROJECTS.md

```python
index_path = f"workspace/{project}/explorations/ACTIVE_PROJECTS.md"
remove_from_active_table(index_path, name)
append_to_archive_table(index_path, {
    "实验名称": f"completed_{name}",
    "归档时间": iso_timestamp()[:10],
    "结果": "已合并到主项目"
})
```

---

## Action: archive

归档实验（不合并产物）。

### 输入

- `{project}` — 项目名称
- `{name}` — 实验名称

### 输出

- 实验移动到 `ARCHIVE/` 目录（带前缀）
- `ACTIVE_PROJECTS.md` 更新

### 执行步骤

#### Step 1: 验证实验存在

```python
experiment_dir = f"workspace/{project}/explorations/{name}"

if not directory_exists(experiment_dir):
    available = scan_subdirectories(f"workspace/{project}/explorations", exclude=["ARCHIVE"])
    return {
        "status": "error",
        "message": f"实验 '{name}' 不存在。",
        "available_experiments": available
    }
```

#### Step 2: 确认归档原因

```python
answer = AskUserQuestion(
    f"归档实验 '{name}' 的原因？\n"
    "  1. completed — 已完成（但不合并）\n"
    "  2. abandoned — 放弃\n"
    "请输入 1 或 2："
)

if answer in ["1", "completed", "已完成"]:
    prefix = "completed"
    result = "已完成（未合并）"
elif answer in ["2", "abandoned", "放弃"]:
    prefix = "abandoned"
    result = "已放弃"
else:
    prefix = "abandoned"
    result = "已放弃"
```

#### Step 3: 移动到归档目录

```python
archive_dir = f"workspace/{project}/explorations/ARCHIVE"
mkdir_p(archive_dir)
move_directory(experiment_dir, f"{archive_dir}/{prefix}_{name}")
```

#### Step 4: 更新 ACTIVE_PROJECTS.md

```python
index_path = f"workspace/{project}/explorations/ACTIVE_PROJECTS.md"
remove_from_active_table(index_path, name)
append_to_archive_table(index_path, {
    "实验名称": f"{prefix}_{name}",
    "归档时间": iso_timestamp()[:10],
    "结果": result
})
```

---

## 快速轨道工作流

在实验目录中，可以直接调用单个 Agent Skill，无需走完整流水线：

- **只跑文献调研**：`Skill(skill="a1-literature-surveyor", args="{project}/explorations/{name}")`
- **只跑实验设计**：`Skill(skill="b2-experiment-designer", args="{project}/explorations/{name}")`
- **只跑章节撰写**：`Skill(skill="c1-section-writer", args="{project}/explorations/{name}")`

质量阈值降低到 `config.exploration.quality_threshold`（默认 60/100），允许快速迭代而非追求完美。

---

## 模板

### ACTIVE_PROJECTS.md 模板

```markdown
# 活跃实验

| 实验名称 | 创建时间 | 目标 | 状态 |
|---------|---------|------|------|

## 已归档

| 实验名称 | 归档时间 | 结果 |
|---------|---------|------|
```

### README.md 模板

```markdown
# 实验：{name}

> 创建时间：{timestamp}
> 状态：进行中

## 目标

[描述实验目标]

## 假设

[描述实验假设]

## 方法

[描述实验方法]

## 发现

[记录实验发现]

## 结论

[实验结论和下一步]
```

---

## 与其他 Skill 的集成

1. **paper-generation** — 独立于主流水线，不影响正式 Phase 执行
2. **quality-scorer** — 实验中使用降低的质量阈值（60 vs 85）
3. **各 Agent Skill（A1/B2/C1 等）** — 可在实验目录中单独调用

---

## 错误处理

| 错误 | 处理 |
|------|------|
| 实验名称已存在 | 提示用户选择不同名称 |
| 超过最大活跃实验数 | 提示用户归档旧实验 |
| promote 时实验目录为空 | 提示无可合并内容 |
| 实验不存在 | 返回错误，列出可用实验 |

---

## 约束

- **DO NOT** 修改主项目的 Phase 目录 — 除非在 promote 操作中用户明确确认
- **DO NOT** 自动删除实验 — 只能通过 archive 操作归档
- **DO NOT** 在实验中运行完整流水线 — 实验空间仅支持单个 Agent 调用

---

## 配置参考

| 参数 | 默认值 | 说明 |
|------|---------|------|
| exploration.max_active_experiments | 5 | 最大活跃实验数量 |
| exploration.quality_threshold | 60 | 实验模式下的质量阈值（满分 100） |
