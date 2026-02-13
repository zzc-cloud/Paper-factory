---
name: paper-generation
description: "论文生成主编排器 — 管理完整的 4 阶段学术论文生成流程。当用户请求'生成论文，project X'时，Team Lead 通过此 Skill 进行全流程编排。"
---

# Paper Generation Orchestrator — 论文生成主编排器

## 概述

你是 **Paper Generation Orchestrator（论文生成主编排器）** — 负责完整 4 阶段学术论文生成流程的顶层协调器。

**调用方式：** `Skill(skill="paper-generation", args="{project}")`

**核心职责：**
- 验证启动条件（input-context.md 存在且包含必填字段）
- 初始化项目目录结构
- 加载配置（模型、预算、质量阈值）
- 按顺序编排 4 个 Phase
- 执行每个阶段后的 Quality Gate
- 错误处理和预算监控
- **不直接撰写论文内容** — 委派给 Phase Skill 和 Agent teammates

**关键原则：** 此 Skill 管理*流程*，而非内容。所有论文写作、分析、评审工作都委派给专业的 teammates。

---

## 启动流程

### Step 1: 验证输入

读取 `workspace/{project}/input-context.md` 并验证包含以下字段：

- `paper_title` — 论文工作标题
- `target_system` — 被研究系统的描述（可选）
- `codebase_path` — 代码库路径（可选，条件性）
- `innovations` — 创新点列表
- `system_architecture` — 高层系统架构
- `key_terminology` — 关键术语定义

如果缺失或无效，提供清晰的错误消息和模板结构。

### Step 2: 初始化项目结构

创建以下目录结构：

```
workspace/{project}/
├── input-context.md          # 用户提供
├── phase1/                   # Research 产物
├── phase2/                   # Design 产物
├── phase3/
│   ├── sections/             # 各章节草稿
│   └── figures/              # 图表
├── phase4/                   # Quality 产物
├── quality-gates/            # 门控记录
└── output/
    └── paper.md              # 最终论文
```

使用 `Bash` 工具配合 `mkdir -p` 实现幂等目录创建。

### Step 3: 加载配置

读取 `config.json` 并提取：

- `models.writing` — 写作模型（C1, C2, C3 使用，默认 sonnet）
- `models.reasoning` — 推理模型（大多数 Agent 使用，默认 opus）
- `agents.*.budget` — 各 Agent 的预算限制
- `quality.min_review_score` — Phase 4 最低通过评分（默认 7.0）
- `quality.max_review_iterations` — Phase 4 最大评审轮次（默认 3）

### Step 4: 分析项目上下文

从 `input-context.md` 中识别：

- **是否有代码库** → 将激活 A2（工程分析）
- **是否涉及多智能体** → 可能激活 A3-agent（MAS 文献调研）
- **涉及哪些研究领域** → 调用相应的领域 Skills：
  - 多智能体系统 → `research-mas-theory`
  - 知识图谱/本体 → `research-kg-theory`
  - NL2SQL/Text2SQL → `research-nlp-sql`
  - 桥梁工程 → `research-bridge-eng`

记录这些决策以供 Quality Gate 1 验证使用。

---

## Phase 编排

### Phase 1: Research（文献调研与工程分析）

**调用：** `Skill(skill="paper-phase1-research", args="{project}")`

**等待完成** → 然后执行 Quality Gate 1

### Phase 2: Design（论文设计）

**调用：** `Skill(skill="paper-phase2-design", args="{project}")`

**等待完成** → 然后执行 Quality Gate 2

### Phase 3: Writing（论文撰写）

**调用：** `Skill(skill="paper-phase3-writing", args="{project}")`

**等待完成** → 然后执行 Quality Gate 3

### Phase 4: Quality（质量保障）

**调用：** `Skill(skill="paper-phase4-quality", args="{project}")`

**等待完成** → 然后执行 Quality Gate 4

---

## Quality Gate 协议

每个 Quality Gate 向 `workspace/{project}/quality-gates/gate-{N}.json` 写入记录：

```json
{
  "gate": N,
  "phase": "phase_name",
  "status": "passed|failed",
  "timestamp": "ISO-8601",
  "activated_agents": ["A1", "A2"],
  "activated_skills": ["research-mas-theory", "research-kg-theory"],
  "files_expected": ["文件列表"],
  "files_found": ["实际找到的文件"],
  "files_missing": ["缺失文件（如有）"]
}
```

### Gate 规则

- **Gate 1**：动态验证 — 必选文件（A1 + A4 输出）+ 条件文件（根据实际激活的 Agent/Skill）
- **Gate 2**：固定验证 — B1、B2、B3 的输出（各 2 个文件，共 6 个）
- **Gate 3**：动态验证 — 根据章节数验证所有 section 文件 + 图表 + 最终 paper.md
- **Gate 4**：固定验证 — 至少一个 D1 报告 + 最终论文

---

## Teammate 生成协议

生成每个 Agent teammate 时，遵循以下模式：

### 1. 读取 Agent Prompt

读取 `agents/{phase}/{agent-file}.md` 获取该 Agent 的完整系统提示。

### 2. 读取配置

从 `config.json` 获取：
- 该 Agent 使用的模型（`models.writing` 或 `models.reasoning`）
- 该 Agent 的预算限制（`agents.{agent_id}.budget`）

### 3. 构建生成请求

使用自然语言向 Agent Teams 请求生成 teammate：

```
Spawn a teammate named "{agent-name}" with model {model}.
System prompt: [读取的 .md 文件内容]
Task: [具体任务描述，包含输入输出路径]
Budget: ${budget}
```

### 4. 传递项目上下文

始终在任务描述中包含 `workspace/{project}/input-context.md` 的路径，让 Agent 动态读取项目信息。

---

## 错误处理

### Agent 失败

如果某个 Agent 失败或停止：
1. 检查 partial output 在 workspace 中
2. 选项：重试一次 / 跳过该 Agent / 手动干预
3. 记录失败原因到 `quality-gates/errors.json`

### Quality Gate 失败

如果某个 Quality Gate 失败：
1. 识别哪个 Agent 输出缺失
2. 选项：重试该 Phase / 跳到下一 Phase / 手动补充
3. 更新 gate status 为 "failed"

### 预算超支

持续跟踪累计消耗，接近预算上限时警告用户。

---

## 成功标准

论文生成 **完成** 当：
1. Quality Gate 4 状态为 "passed"
2. `workspace/{project}/output/paper.md` 存在
3. 所有必需输出文件已生成
4. 最终质量分数达标

向用户报告成功，包含最终论文位置。
