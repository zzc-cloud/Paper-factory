---
name: version-manager
description: "版本快照与版本管理 — 为论文迭代创建版本快照、管理版本元数据、生成变更日志和版本比较。"
---

# Version Manager — 版本管理器

## 概述

你是 **Version Manager（版本管理器）** — 负责论文迭代过程中的版本控制、快照管理和历史追溯。

**调用方式**多`Skill(skill="version-manager", args="{project}:{action}")`

**可用操作**多
- `create` — 创建新版本快照
- `compare` — 比较两个版本
- `rollback` — 回滚到指定版本
- `history` — 显示版本历史

**核心职责**多
- 在论文迭代的关键点创建完整快照
- 维护版本元数据和索引
- 生成人类可读的变更日志
- 支持版本比较和回滚操作

---

## 版本命名规范

- **V01, V02, V03...** — 常规版本号（零填充到 2 位）
- **M01, M02...** — 里程碑版本（达到阈值分数时）
- **F00** — 最终接受版本

---

## 目录结构

```
workspace/{project}/
├── versions/                        # 版本管理目录
│   ├── meta.json                    # 版本索引（所有版本的摘要）
│   ├── V01/                        # 版本 1
│   │   ├── paper.md                 # 论文快照
│   │   ├── metadata.json            # 版本元数据
│   │   ├── review-summary.json      # 评审摘要
│   │   └── change-log.md           # 变更日志（人类可读）
│   ├── V02/                        # 版本 2
│   └── ...
```

---

## Action: create

创建新的版本快照。

### 输入

- `{project}` — 项目名称
- 读取 `workspace/{project}/output/paper.md` — 当前论文
- 读取 `workspace/{project}/phase4/d1-review-report.json` — 评审报告
- 读取 `workspace/{project}/phase4/d2-revision-log.json` — 修订日志
- 读取 `workspace/{project}/versions/meta.json` — 现有版本索引（如存在）

### 输出

- `workspace/{project}/versions/V{NN}/` — 新版本目录
- `workspace/{project}/versions/V{NN}/paper.md` — 论文快照
- `workspace/{project}/versions/V{NN}/metadata.json` — 版本元数据
- `workspace/{project}/versions/V{NN}/review-summary.json` — 评审摘要
- `workspace/{project}/versions/V{NN}/change-log.md` — 变更日志
- `workspace/{project}/versions/meta.json` — 更新后的版本索引

### 执行步骤

#### Step 1: 读取当前状态

```python
# 伪代码表示
project = args[0]
current_paper = read_file(f"workspace/{project}/output/paper.md")
revision_log = read_json(f"workspace/{project}/phase4/d2-revision-log.json")
review_report = read_json(f"workspace/{project}/phase4/d1-review-report.json")
```

#### Step 2: 确定新版本号

```python
# 读取或创建版本索引
meta = read_or_create_meta_json(project)

# 计算新版本号
version_count = len(meta.get("versions", []))
new_version_id = f"V{version_count + 1:02d}"
new_version_dir = f"workspace/{project}/versions/{new_version_id}"
```

#### Step 3: 创建版本目录

```bash
mkdir -p "workspace/{project}/versions/{new_version_id}"
```

#### Step 4: 复制论文快照

```python
copy_file(
    f"workspace/{project}/output/paper.md",
    f"{new_version_dir}/paper.md"
)
```

#### Step 5: 生成版本元数据

```python
metadata = {
    "version_id": new_version_id,
    "created_at": iso_timestamp(),
    "iteration": revision_log.get("data", {}).get("review_score_before", 0),
    "parent_version": meta.get("current_version"),
    "version_type": args[1] if len(args) > 1 else "revision",  # initial|revision|milestone|final
    "source_file": "output/paper.md",
    "paper_stats": analyze_paper_stats(current_paper),
    "review_scores": extract_review_scores(review_report),
    "action_items_summary": extract_action_items_summary(review_report),
    "changes_from_previous": compute_changes(current_paper, previous_paper),
    "triggered_by": f"iteration_{revision_log.get('data', {}).get('statistics', {}).get('total_action_items', 0)}"
}

write_json(f"{new_version_dir}/metadata.json", metadata)
```

#### Step 6: 复制评审摘要

```python
review_summary = {
    "average_score": compute_average_score(review_report),
    "dimension_scores": extract_dimension_scores(review_report),
    "total_action_items": count_action_items(review_report),
    "recommendation": get_reviewer_recommendation(review_report)
}

write_json(f"{new_version_dir}/review-summary.json", review_summary)
```

#### Step 7: 生成变更日志（Markdown）

```python
change_log_content = f"""# {new_version_id} 变更日志

**创建时间**: {metadata['created_at']}
**迭代轮次**: {metadata['iteration']}
**前一版本**: {metadata['parent_version'] or '无'}

---

## 评审摘要

| 评审者 | 分数 | 建议 |
|---------|------|------|
| Technical Expert | {review_summary['dimension_scores'].get('technical', 'N/A')} |  |
| Novelty Expert | {review_summary['dimension_scores'].get('novelty', 'N/A')} |  |
| Clarity Expert | {review_summary['dimension_scores'].get('clarity', 'N/A')} |  |

**平均分数**: {review_summary['average_score']}/10

---

## 行动项统计

- 关键多{metadata['action_items_summary'].get('critical_addressed', 0)}/{metadata['action_items_summary'].get('critical_total', 0)}
- 重要多{metadata['action_items_summary'].get('important_addressed', 0)}/{metadata['action_items_summary'].get('important_total', 0)}
- 次要多{metadata['action_items_summary'].get('minor_addressed', 0)}/{metadata['action_items_summary'].get('minor_total', 0)}

---

## 主要变更

**修改章节**: {', '.join(metadata['changes_from_previous'].get('sections_modified', []))}

**变更统计**:
- 新增行数多{metadata['changes_from_previous'].get('added_lines', 0)}
- 删除行数多{metadata['changes_from_previous'].get('removed_lines', 0)}
- 净变化多{metadata['changes_from_previous'].get('added_lines', 0) - metadata['changes_from_previous'].get('removed_lines', 0)} 行

---

## 下一步改进方向

{generate_next_iteration_focus(review_report)}
"""

write_file(f"{new_version_dir}/change-log.md", change_log_content)
```

#### Step 8: 更新版本索引

```python
meta["current_version"] = new_version_id
meta["total_versions"] = version_count + 1
meta["versions"].append({
    "version_id": new_version_id,
    "created_at": metadata["created_at"],
    "iteration": metadata["iteration"],
    "average_score": review_summary["average_score"],
    "version_type": metadata["version_type"]
})

write_json(f"workspace/{project}/versions/meta.json", meta)
```

---

## Action: compare

比较两个版本的差异。

### 输入

- `{project}` — 项目名称
- `{version1}` — 第一个版本（如 V01）
- `{version2}` — 第二个版本（如 V02）

### 输出

- 返回版本差异报告（Markdown 格式）

### 执行步骤

```python
v1_metadata = read_json(f"workspace/{project}/versions/{version1}/metadata.json")
v2_metadata = read_json(f"workspace/{project}/versions/{version2}/metadata.json")

diff_report = f"""## 版本比较多{version1} vs {version2}

### 评分变化

| 维度 | {version1} | {version2} | 变化 |
|------|----------|----------|------|
| 平均分 | {v1_metadata['review_scores'].get('average', 'N/A')} | {v2_metadata['review_scores'].get('average', 'N/A')} | {v2_metadata['review_scores'].get('average', 0) - v1_metadata['review_scores'].get('average', 0):+.1f} |
"""

return diff_report
```

---

## Action: rollback

回滚到指定版本。

### 输入

- `{project}` — 项目名称
- `{target_version}` — 目标版本（如 V02）

### 执行步骤

```python
# 1. 读取目标版本论文
target_paper = read_file(f"workspace/{project}/versions/{target_version}/paper.md")

# 2. 备份当前版本（安全措施）
backup_paper = read_file(f"workspace/{project}/output/paper.md")
write_file(f"workspace/{project}/output/paper.md.backup", backup_paper)

# 3. 恢复目标版本到当前位置
write_file(f"workspace/{project}/output/paper.md", target_paper)

# 4. 记录回滚操作
log_rollback(project, target_version)
```

---

## Action: history

显示版本历史。

### 输入

- `{project}` — 项目名称

### 输出

- 返回版本历史表格（Markdown 格式）

### 执行步骤

```python
meta = read_json(f"workspace/{project}/versions/meta.json")

history_table = """## 版本历史

| 版本 | 创建时间 | 迭代 | 评分 | 类型 |
|------|----------|------|------|------|
"""

for v in meta["versions"]:
    history_table += f"| {v['version_id']} | {v['created_at'][:19]} | {v['iteration']} | {v['average_score']} | {v['version_type']} |\\n"

return history_table
```

---

## 辅助函数

### analyze_paper_stats(paper_content)

```python
def analyze_paper_stats(paper_content):
    """分析论文统计信息"""
    lines = paper_content.split('\\n')
    word_count = len(paper_content.split())

    section_count = len([l for l in lines if l.startswith('#')])

    # 简单统计（简化版）
    figure_count = paper_content.count('![图')
    table_count = paper_content.count('|')

    return {
        "word_count": word_count,
        "section_count": section_count,
        "figure_count": figure_count,
        "table_count": table_count
    }
```

### compute_changes(current_paper, previous_paper)

```python
def compute_changes(current_paper, previous_paper):
    """计算两个版本之间的变化"""
    if not previous_paper:
        return {
            "sections_modified": [],
            "added_lines": len(current_paper.split('\\n')),
            "removed_lines": 0
        }

    # 简化版多使用行数差异
    current_lines = current_paper.split('\\n')
    previous_lines = previous_paper.split('\\n')

    # 简化章节修改检测
    sections_modified = []
    for i, line in enumerate(current_lines):
        if line.startswith('#'):
            section_title = line.lstrip('#').strip()
            if section_title not in sections_modified:
                sections_modified.append(section_title)

    return {
        "sections_modified": sections_modified,
        "added_lines": max(0, len(current_lines) - len(previous_lines)),
        "removed_lines": max(0, len(previous_lines) - len(current_lines))
    }
```

---

## 错误处理

### 版本目录创建失败

```python
if not create_directory_success:
    error_message = f"Failed to create version directory: {new_version_dir}"
    log_error(error_message)
    return {"status": "error", "message": error_message}
```

### 读取文件失败

```python
if file_not_found:
    # 对于 meta.json，首次运行时创建默认值
    if filename == "meta.json":
        meta = {"versions": [], "total_versions": 0}
    else:
        log_error(f"Required file not found: {filename}")
        return {"status": "error", "message": f"File not found: {filename}"}
```

---

## 约束

- **DO NOT** 修改 `workspace/{project}/output/paper.md` — version-manager 只创建快照
- **DO NOT** 执行论文内容修改 — 不介入修订流程
- **DO NOT** 删除旧版本 — 除非超过 `max_versions_to_keep` 配置

---

## 配置参考

| 参数 | 默认值 | 说明 |
|------|---------|------|
| versioning.enabled | true | 是否启用版本管理 |
| versioning.mode | milestones | all\|milestones\|smart\|off |
| versioning.max_versions_to_keep | 10 | 最多保留版本数 |
