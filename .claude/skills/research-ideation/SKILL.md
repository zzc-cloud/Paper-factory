---
name: research-ideation
description: "研究构思 — 从模糊主题生成 3-5 个研究方向，每个方向包含假设、方法、创新点和目标期刊建议。"
---

# Research Ideation — 研究构思工具

## 概述

你是 **Research Ideation（研究构思工具）** — Phase 0 之前的可选前置工具，当用户只有模糊主题但尚未形成明确研究方向时使用。通过趋势分析和方向生成，帮助用户从模糊想法快速收敛到可执行的研究规范。

**调用方式：**
- `Skill(skill="research-ideation", args="{project}")` — 从 input-context.md 或对话上下文获取主题
- `Skill(skill="research-ideation", args="{project}:{topic}")` — 直接指定模糊主题

**使用场景：**
- 用户有一个模糊的研究兴趣，但不确定具体研究方向
- 用户想探索某个领域的多个可能方向后再决定
- 用户需要在正式启动论文生成前进行方向筛选

**与论文生成流水线的关系：**
```
[前置工具] research-ideation → 生成研究方向 → 用户选择
                                    ↓
[前置工具] codebase-analyzer → 生成 input-context.md（可选）
                                    ↓
[论文流水线] Phase 0 → Phase 1 → Phase 2 → Phase 3 → Phase 4
```

**不是** Phase 0 的一部分，而是 Phase 0 的可选前置步骤。

---

## 输入参数

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `project` | string | 是 | 项目名称（对应 workspace/{project}/ 目录）|
| `topic` | string | 否 | 模糊主题描述（可选，从 input-context.md 或对话上下文获取）|

---

## 参数解析

从 `args` 解析：
- 格式 `{project}` — 仅项目名称，从 `workspace/{project}/input-context.md` 或对话上下文获取主题
- 格式 `{project}:{topic}` — 项目名称 + 模糊主题（以第一个 `:` 分隔）

验证：
1. `project` 非空
2. 如果 `topic` 未提供，尝试读取 `workspace/{project}/input-context.md`
3. 如果 input-context.md 也不存在，从对话上下文推断主题
4. 如果仍无法获取主题，使用 AskUserQuestion 询问用户

如果最终无法确定主题，返回 `"status": "blocked"` 并描述缺失内容。

---

## 执行步骤

### Step 1：主题分析

1. 读取 `workspace/{project}/input-context.md`（如存在）或使用 `topic` 参数
2. 使用 WebSearch 搜索该主题的最新研究趋势（3-5 次搜索）
   - 搜索查询示例：
     - `"{topic}" recent advances 2024 2025 survey`
     - `"{topic}" open problems challenges`
     - `"{topic}" emerging methods techniques`
     - `"{topic}" benchmark dataset evaluation`
     - `"{topic}" interdisciplinary applications`
3. 识别热点方向、未解决问题、新兴技术
4. 将趋势分析结果结构化为 `trend_analysis` 对象

### Step 2：生成研究方向（3-5 个）

基于 Step 1 的趋势分析，生成 3-5 个差异化的研究方向。每个方向必须包含：

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | string | 方向编号（DIR-01, DIR-02, ...）|
| `title` | string | 研究方向标题 |
| `hypothesis` | string | 核心假设 |
| `methodology` | string | 建议方法概述 |
| `innovations` | string[] | 预期创新点（2-3 个）|
| `target_venues` | string[] | 建议投稿期刊（1-2 个）|
| `feasibility` | enum | 可行性评估（high / medium / low）|
| `novelty_assessment` | enum | 新颖性评估（high / medium / low）|
| `rationale` | string | 选择此方向的理由 |

**方向差异化原则：**
- 至少覆盖 2 种不同的方法论（如理论驱动 vs 数据驱动）
- 至少包含 1 个高可行性方向和 1 个高新颖性方向
- 避免方向之间过度重叠

### Step 3：交互选择

使用 AskUserQuestion 展示所有方向，格式如下：

```
基于对 "{topic}" 的趋势分析，我生成了以下 N 个研究方向：

---
**DIR-01: {title}**
- 假设：{hypothesis}
- 方法：{methodology}
- 创新点：{innovations}
- 建议期刊：{target_venues}
- 可行性：{feasibility} | 新颖性：{novelty_assessment}
- 理由：{rationale}

---
**DIR-02: {title}**
...

---

请选择：
1. 输入方向编号选择（如 "DIR-01"）
2. 输入多个编号组合（如 "DIR-01+DIR-03"）
3. 输入 "修改 DIR-XX: 你的修改意见" 调整某个方向
4. 输入 "全部保存" 保存所有方向供后续参考
5. 输入 "重新生成" 要求重新分析
```

**交互处理逻辑：**
- 用户选择单个方向 → 记录选择，进入 Step 4
- 用户组合多个方向 → 合并创新点和方法，进入 Step 4
- 用户要求修改 → 应用修改后重新展示
- 用户选择"全部保存" → 保存所有方向，不更新 input-context.md
- 用户选择"重新生成" → 回到 Step 1 重新搜索

### Step 4：生成输出

基于用户选择，执行以下操作：

1. 创建项目目录（如不存在）：`workspace/{project}/phase0/`
2. 写入 `research-ideation.json` — 所有方向的结构化数据
3. 写入 `research-ideation.md` — 人类可读的方向概述
4. 可选：如果用户确认了方向，更新或创建 `workspace/{project}/input-context.md`
   - 将选中方向的 title 写入 `## 论文主题`
   - 将 innovations 写入 `## 创新点列表`
   - 将 methodology 写入 `## 系统架构概述`（初稿）

---

## 输出文件

### 文件 1：JSON 输出

**路径**：`workspace/{project}/phase0/research-ideation.json`

```json
{
  "project": "{project}",
  "timestamp": "ISO-8601",
  "input_topic": "模糊主题描述",
  "web_search_used": true,
  "trend_analysis": {
    "hot_topics": ["topic1", "topic2"],
    "open_problems": ["problem1", "problem2"],
    "emerging_tech": ["tech1", "tech2"]
  },
  "directions": [
    {
      "id": "DIR-01",
      "title": "方向标题",
      "hypothesis": "核心假设",
      "methodology": "方法概述",
      "innovations": ["创新1", "创新2"],
      "target_venues": ["AAAI", "IJCAI"],
      "feasibility": "high",
      "novelty_assessment": "high",
      "rationale": "选择此方向的理由"
    }
  ],
  "user_selection": {
    "selected_direction_ids": ["DIR-01"],
    "modifications": [],
    "confirmed": true
  }
}
```

### 文件 2：Markdown 输出

**路径**：`workspace/{project}/phase0/research-ideation.md`

按以下结构构建 Markdown 文件：

```markdown
# 研究构思：{topic}

> 生成时间：{timestamp}
> 项目：{project}

## 趋势分析

### 热点方向
- {hot_topics 列表}

### 未解决问题
- {open_problems 列表}

### 新兴技术
- {emerging_tech 列表}

## 研究方向

### DIR-01: {title}

- **核心假设**：{hypothesis}
- **建议方法**：{methodology}
- **预期创新点**：
  1. {innovation_1}
  2. {innovation_2}
- **建议期刊**：{target_venues}
- **可行性**：{feasibility} | **新颖性**：{novelty_assessment}
- **选择理由**：{rationale}

### DIR-02: {title}
...

## 用户选择

- **选中方向**：{selected_direction_ids}
- **修改说明**：{modifications}
- **确认状态**：{confirmed}
```

---

## 与其他 Skill 的集成

| 集成目标 | 关系说明 |
|---------|---------|
| `paper-generation` | Phase 0 之前的可选前置工具。ideation 完成后，用户可直接启动论文生成流水线 |
| `research-interview` | 可在 ideation 之后使用，通过结构化访谈深化选中方向的细节 |
| `a1-literature-surveyor` | ideation 的 `trend_analysis` 可作为 A1 的搜索种子，加速文献调研 |
| `codebase-analyzer` | 如果选中方向涉及已有代码库，可用 codebase-analyzer 生成 input-context.md |
| `venue-analyzer` | ideation 的 `target_venues` 建议可直接传递给 venue-analyzer 进行期刊配置解析 |

---

## 错误处理

| 错误 | 处理 |
|------|------|
| WebSearch 失败 | 回退到纯 LLM 知识生成方向，在 JSON 输出中标记 `web_search_used: false` |
| 用户不选择任何方向 | 保存所有方向供后续参考，不更新 input-context.md |
| input-context.md 不存在且无 topic 参数 | 使用 AskUserQuestion 询问用户主题 |
| 项目目录不存在 | 自动创建 `workspace/{project}/phase0/` 目录 |

---

## 质量标准

1. **方向数量**：生成 3-5 个研究方向，少于 3 个为硬性失败
2. **差异化**：方向之间必须有明显差异，不能是同一思路的微调变体
3. **完整性**：每个方向必须包含所有 8 个必填字段
4. **可行性**：至少 1 个方向的可行性评估为 high
5. **新颖性**：至少 1 个方向的新颖性评估为 high
6. **期刊匹配**：建议的 target_venues 必须与方向的研究领域匹配
7. **趋势支撑**：每个方向的 rationale 必须引用 trend_analysis 中的发现

---

## 可用工具

- **WebSearch**：用于搜索研究趋势、热点方向、最新论文。每次 ideation 执行 3-5 次搜索。
- **WebFetch**：用于从搜索结果中获取详细信息（如综述论文摘要、会议主题列表）。
- **Read**：用于读取 `workspace/{project}/input-context.md`（如存在）。
- **Write**：用于写入 `research-ideation.json` 和 `research-ideation.md`。
- **AskUserQuestion**：用于展示研究方向并收集用户选择。

---

## 使用示例

```bash
# 示例 1：从对话上下文获取主题
Skill(skill="research-ideation", args="my-project")

# 示例 2：直接指定模糊主题
Skill(skill="research-ideation", args="my-project:多智能体系统在自动驾驶中的应用")

# 示例 3：主题包含英文
Skill(skill="research-ideation", args="llm-agents:LLM-based multi-agent collaboration")
```

---

## 成功标准

Research Ideation **完成** 当：
1. `workspace/{project}/phase0/research-ideation.json` 存在且包含 3-5 个完整方向
2. `workspace/{project}/phase0/research-ideation.md` 存在且人类可读
3. 用户已通过 AskUserQuestion 做出选择（或选择"全部保存"）
4. 如果用户确认了方向，`user_selection.confirmed` 为 `true`
