# 系统架构

## 架构总览

Paper Factory 是一个基于 **Skill + Agent 混合架构** 的多智能体学术论文生成系统。系统采用分层编排设计，通过 Skill 层（同步执行）和 Agent 层（异步执行）的协作完成从文献调研到论文撰写的全流程。

```
╔══════════════════════════════════════════════════════════════════╗
║               Paper Factory — Skill + Agent 混合架构                      ║
╠═══��══════════════════════════════════════════════════════════════╣
║                                                                          ║
║  ┌────────────────────────────────────────────────────────────────────────────┐    ║
║  │  User Request                                              │    ║
║  │      ↓                                                         │    ║
║  │  ┌──────────────────────────────────────────────────────────┐    │    ║
║  │  │         Team Lead (主会话编排)              │    │    ║
║  │  │                                                 │    │    ║
║  │  │  ══════════════════════════════════════   │    │    ║
║  │  │  │  Skill 层 (同步调用，共享上下文)          │    │    ║
║  │  │  │                                                 │    │    ║
║  │  │  │  1. Orchestrator Level                        │    │    ║
║  │  │  │     paper-generation (主编排器)                 │    │    ║
║  │  │  │       ↓ 管理完整 4-Phase 流程                   │    │    ║
║  │  │  │  2. Phase Level                            │    │    ║
║  │  │  │     paper-phase1-research (Phase 1 编排)        │    │    ║
║  │  │  │     paper-phase2-design (Phase 2 编排)          │    │    ║
║  │  │  │     paper-phase3-writing (Phase 3 编排)         │    │    ║
║  │  │  │     paper-phase4-quality (Phase 4 编排)         │    │    ║
║  │  │  │                                                 │    │    ║
║  │  │  │  ══════════════════════════════════════   │    │    ║
║  │  │  │  │  3. Domain Research Skills (领域分析)        │    │    ║
║  │  │  │  │     research-mas-theory (MAS 理论)      │    │    ║
║  │  │  │  │     research-kg-theory (KG/本体)           │    │    ║
║  │  │  │  │     research-nlp-sql (NL2SQL)              │    │    ║
║  │  │  │  │     research-bridge-eng (桥梁工程)           │    │    ║
║  │  │  │  └─────────────────────────────────────┘    │    ║
║  │  │                                           │    ║
║  │  │  ↓ Skill 同步调用 + 领域分析              │    ║
║  │  └─────────────────────────────────────────────┘    │    ║
║                                                                          ║
║  ══════════════════════════════════════════════════════════════   ║
║                                                                          ║
║                    ↓ (文件系统作为 Agent 间的通信媒介)                        ║
║  ════════════════════════════════════════════════════════════════   ║
║                                                                          ║
║  ┌────────────────────────────────────────────────────────────────────────────┐    ║
║  │         Agent Teams (独立进程，异步执行)               │    ║
║  │                                                                  ║
║  │  Phase 1: Research                      │    ║
║  │  ├─ A1 (文献调研) → a1-literature-survey.json/md      │    ║
║  │  ├─ A2 (工程分析) → a2-engineering-analysis.json/md [条件] │    ║
║  │  ├─ A3-agent (MAS文献) → a3-mas-literature.json/md [条件]│    ║
║  │  └─ A4 (创新聚合) → a4-innovations.json/md        │    ║
║  │                                                                  ║
║  │  Phase 2: Design                        │    ║
║  │  ├─ B1 (相关工作) → b1-related-work.json/md          │    ║
║  │  ├─ B2 (实验设计) → b2-experiment-design.json/md      │    ║
║  │  └─ B3 (架构设计) → b3-paper-outline.json/md          │    ║
║  │                                                                  ║
║  │  Phase 3: Writing                        │    ║
║  │  ├─ C1 (章节撰写) → sections/*.md [多次调用]        │    ║
║  │  ├─ C2 (图表设计) → figures/all-figures.md,tables.md │    ║
║  │  └─ C3 (格式整合) → output/paper.md               │    ║
║  │                                                                  ║
║  │  Phase 4: Quality                       │    ║
║  │  ├─ D1 (同行评审) → d1-review-report.json/md         │    ║
║  │  └─ D2 (修订执行) → d2-revision-log.json/md [迭代]   │    ║
║  └────────────────────────────────────────────────────────────────────────────┘    ║
║                                                                          ║
╚══════════════════════════════════════════════════════════════════════╝
```

---

## 核心设计原则

### 1. 分层架构（Layered Architecture）

系统采用 **Skill + Agent 混合架构**，按任务类型分层：

| 层级 | 执行方式 | 典型任务 | 通信模式 |
|------|----------|----------|----------|
| **Orchestrator Level** | 同步调用 | 流程编排、启动验证 | Team Lead 直接控制 |
| **Phase Level** | 同步调用 | 单阶段 Agent 编排、Quality Gate | Team Lead 直接控制 |
| **Domain Skills** | 同步调用 | 理论映射、领域分析（LLM 知识） | Team Lead 主会话上下文 |
| **Agent Teams** | 异步执行 | 文献检索、代码分析、论文撰写、评审 | 文件系统（JSON/MD） |

**关键区别**：
- **Skill**：轻量级、同步执行、共享会话上下文、不需要外部工具
- **Agent**：重量级、异步执行、独立进程、可使用 WebSearch/Bash 等

### 2. 委派模式（Delegation Mode）

- Team Lead 不直接撰写内容，仅负责编排和协调
- 所有专业工作委派给对应的 Skill 或 Agent teammate
- Skill 在主会话中同步执行，Agent 作为独立进程异步执行
- 通过文件系统进行上下文传递，不依赖对话历史

### 3. 质量门控（Quality Gates）

- 每个阶段完成后执行文件完整性检查
- 记录门控结果到 `quality-gates/gate-{N}.json`
- 失败时提供重试、跳过或手动补充选项

### 4. 混合执行模式

- **Phase 1**：Skill 串行 + Agent 并行（扇出-聚合）
- **Phase 2**：严格串行（B1 → B2 → B3）
- **Phase 3**：串行（C1 → C2 → C3）
- **Phase 4**：迭代循环（D1 ⇄ D2）

### 5. 预算与模型分配

| 任务类型 | 模型选择 | 预算范围 |
|----------|----------|----------|
| **文献调研** (A1) | Sonnet | $3 |
| **论文撰写** (C1, C2, C3) | Sonnet | $2-3 |
| **深度分析** (A2, A3, A4, B1-B3, D1, D2) | Opus | $3-5 |
| **评审** (D1) | Opus | $5 |

---

## Skill 层详解

### Orchestrator Level

#### paper-generation（论文生成主编排器）

- **文件**：`.claude/skills/paper-generation/SKILL.md`
- **调用方式**：`Skill(skill="paper-generation", args="{project}")`
- **职责**：
  - 验证启动条件（input-context.md 存在且完整）
  - 初始化项目目录结构
  - 加载配置（模型、预算、质量阈值）
  - 按顺序编排 4 个 Phase
  - 执行每个 Phase 后的 Quality Gate
  - 错误处理和预算监控
- **不直接撰写论文内容** — 所有工作委派给 Phase Skill 和 Agent

### Phase Level

#### paper-phase1-research（Phase 1 编排器）

- **文件**：`.claude/skills/paper-phase1-research/SKILL.md`
- **调用方式**：`Skill(skill="paper-phase1-research", args="{project}")`
- **执行模式**：LLM 自主决策 + 并行 Agent + 串行 Skill
- **职责**：
  - 分析项目特征，自主判断激活哪些 Agent/Skill
  - 并行启动 A1（必选）、A2（条件）、A3-agent（条件）
  - 串行调用领域 Skills（research-mas-theory、research-kg-theory 等）
  - 启动 A4 聚合所有分析结果
  - 执行 Quality Gate 1

#### paper-phase2-design（Phase 2 编排器）

- **文件**：`.claude/skills/paper-phase2-design/SKILL.md`
- **调用方式**：`Skill(skill="paper-phase2-design", args="{project}")`
- **执行模式**：严格串行 B1 → B2 → B3
- **职责**：
  - 依次启动 B1、B2、B3 Agent
  - 每个 Agent 依赖前一个的输出
  - 执行 Quality Gate 2

#### paper-phase3-writing（Phase 3 编排器）

- **文件**：`.claude/skills/paper-phase3-writing/SKILL.md`
- **调用方式**：`Skill(skill="paper-phase3-writing", args="{project}")`
- **执行模式**：串行 C1（按章节）→ C2 → C3
- **职责**：
  - 根据 b3-paper-outline.json 逐章节调用 C1
  - 所有章节完成后启动 C2 设计图表
  - 最后启动 C3 组装最终论文
  - 执行 Quality Gate 3

#### paper-phase4-quality（Phase 4 编排器）

- **文件**：`.claude/skills/paper-phase4-quality/SKILL.md`
- **调用方式**：`Skill(skill="paper-phase4-quality", args="{project}")`
- **执行模式**：迭代循环 D1 ⇄ D2
- **核心特性**：
  - **动态专家选择**：基于论文内容选择相关度最高的 1-2 个领域专家
  - **领域知识注入**：通过 domain-knowledge-prep Skill 为评审专家准备领域知识
  - **专家回复协调**（可选）：D2 与 5 个评审专家的多轮交互与辩论
- **职责**：
  - 循环评审论文直到质量达标或达到最大迭代次数
  - 每轮迭代：D1 评审 → 如果分数低则 D2 修订
  - 执行 Quality Gate 4

### Domain Research Skills

| Skill | 领域 | 调用时机 |
|-------|------|----------|
| research-mas-theory | 多智能体系统 | Phase 1 内部调用（涉及 MAS 时） |
| research-kg-theory | 知识图谱/本体 | Phase 1 内部调用（涉及 KG 时） |
| research-nlp-sql | NL2SQL/Text2SQL | Phase 1 内部调用（涉及 NL2SQL 时） |
| research-bridge-eng | 桥梁工程 | Phase 1 内部调用（涉及桥梁领域时） |

**领域 Skill 特点**：
- 基于 LLM 训练知识，不需要 WebSearch
- 在 Team Lead 主会话中同步执行
- 输出统一的 JSON 格式供下游 Agent 消费

---

## Agent 层详解

### 12 个 Agent 完整列表

| Agent | 文件 | 角色 | 模型 | 预算 | 激活条件 |
|-------|--------|------|------|----------|
| A1 | `agents/phase1/a1-literature-surveyor.md` | 文献调研 | Sonnet | $3 | 必选 |
| A2 | `agents/phase1/a2-engineering-analyst.md` | 工程分析 | Opus | $5 | 条件：有 codebase_path |
| A3 | `agents/phase1/a3-mas-theorist.md` | MAS 文献调研 | Opus | $4 | 条件：涉及 MAS 且需最新文献 |
| A4 | `agents/phase1/a4-innovation-formalizer.md` | 创新形式化（聚合） | Opus | $3 | 必选 |
| B1 | `agents/phase2/b1-related-work-analyst.md` | 相关工作分析 | Opus | $3 | 必选 |
| B2 | `agents/phase2/b2-experiment-designer.md` | 实验设计 | Opus | $3 | 必选 |
| B3 | `agents/phase2/b3-paper-architect.md` | 论文架构设计 | Opus | $4 | 必选 |
| C1 | `agents/phase3/c1-section-writer.md` | 章节撰写 | Sonnet | $2 | 必选 |
| C2 | `agents/phase3/c2-visualization-designer.md` | 可视化设计 | Sonnet | $3 | 必选 |
| C3 | `agents/phase3/c3-academic-formatter.md` | 学术格式化 | Sonnet | $2 | 必选 |
| D1 | `agents/phase4/d1-peer-reviewer.md` | 同行评审 | Opus | $5 | 必选 |
| D2 | `agents/phase4/d2-revision-specialist.md` | 修订执行 | Opus | $4 | 条件：评审分数低于阈值 |

### Phase 4: 多视角评审架构

#### 5 个独立评审专家

| 专家 | 文件 | 评审维度 | 激活条件 |
|------|--------|----------|----------|
| **D1-Technical-Expert** | `agents/phase4/reviewers/d1-reviewer-technical-expert.md` | 技术实现、算法设计、系统架构 | 始终启用 |
| **D1-Domain-Expert** | `agents/phase4/reviewers/d1-reviewer-domain-expert.md` | 知识图谱、本体工程、应用领域 | 动态选择（相关度最高的 1-2 个） |
| **D1-Clarity-Expert** | `agents/phase4/reviewers/d1-reviewer-clarity-expert.md` | 表述清晰度、逻辑流畅性、组织结构 | 始终启用 |
| **D1-Significance-Expert** | `agents/phase4/reviewers/d1-reviewer-significance-expert.md` | 学术价值、原创性、贡献影响力 | 条件：论文声称重大创新 |
| **D1-Writing-Quality-Expert** | `agents/phase4/reviewers/d1-reviewer-writing-quality-expert.md` | 写作风格、术语使用、语言规范 | 始终启用 |

**动态专家选择示例**：

| 论文类型 | 选中的评审专家 | 其他专家 |
|----------|--------------|----------|
| KG 本体论文 | Technical, Clarity, Writing, **Domain-KG** | - |
| MAS 系统论文 | Technical, Clarity, Writing, **Domain-MAS**, Significance | - |
| 纯算法论文（无领域） | Technical, Clarity, Writing | 不选择 Domain 专家 |
| 桥梁检测论文 | Technical, Clarity, Writing, **Domain-Bridge**, Significance | - |

### Agent 工具权限

| 工具 | 典型使用 Agent |
|-------|----------------|
| WebSearch, WebFetch | A1, A3, B1 |
| Read, Glob, Grep, Write, Bash | A2, B2, B3, C3 |
| Read, Write | A4, C1, C2, D1, D2 |

---

## 4 阶段 Pipeline 详解

### Phase 1: Research（素材收集）

**执行模式：并行 Agent + 串行 Skill 混合**

```
input-context.md
       │
       ▼
┌─────────────────────────────────────────────┐
│  Team Lead 分析项目特征               │
│  ───────────────────────────────────────┤    │
│                                      ▼    │
│  ┌─────────┐  ┌─────────┐             │    │
│  │Domain Skills│  │Parallel  │             │    │
│  │(串行调用) │  │Agents     │             │    │
│  │             │  │             │    │
│  │r-mas-theory│  │  A1 ────────┐    │    │
│  │r-kg-theory │  │  A2 ────────┤    │    │
│  │r-nlp-sql   │  │  A3-agent ─────┤    │    │
│  │r-bridge-eng │  │             │    │    │
│  └─────────┘  └─────────────┘    │    │
│       │              │             │    │
│       ▼              ▼             │    │
│  ┌─────────────────────────────────┐    │
│  │      A4 (聚合点)           │    │
│  │  读取所有 a*.json           │    │
│  │  读取所有 skill-*.json        │    │
│  │  结合 input-context.md          │    │
│  └─────────────────────────────────┤    │
│              ▼                    │
│     a4-innovations.json/md      │
│                                  │
└─────────────────────────────────────┘    │
                                   │
                                   ▼
                            Quality Gate 1
```

### Phase 2: Design（论文设计）

**执行模式：严格串行 B1 → B2 → B3**

### Phase 3: Writing（论文撰写）

**执行模式：串行 C1（按章节）→ C2 → C3**

### Phase 4: Quality（质量保障）

**执行模式：迭代循环 D1 ⇄ D2**

```
while iteration ≤ max_iterations:
    │
    ├─→ Spawn D1 (评审 paper.md)
    │       ↓
    │   读取 d1-review-report.json
    │       ↓
    │   average_score ≥ min_score? ──→ YES → 结束
    │       ↓ NO
    │   iteration < max? ──→ YES → Spawn D2 (修订)
    │                              ↓
    │                         修订 paper.md
    │                              ↓
    └──────────────────────────────────→ 下一轮迭代
```

---

## Quality Gate 机制

### 门控流程

1. 使用 Glob 工具检查所有预期输出文件是否存在
2. 记录门控结果到 `quality-gates/gate-{N}.json`
3. 若有关键文件缺失，通知用户并提供选项

### 门控记录格式

```json
{
  "gate": 1,
  "phase": "phase1-research",
  "status": "passed",
  "timestamp": "ISO-8601",
  "activated_agents": ["A1", "A2"],
  "activated_skills": ["research-mas-theory", "research-kg-theory"],
  "files_expected": [
    "phase1/a1-literature-survey.json",
    "phase1/a1-literature-survey.md",
    "phase1/a4-innovations.json",
    "phase1/a4-innovations.md"
  ],
  "files_found": [...],
  "files_missing": []
}
```

---

## 数据流：两种通信模式

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        通信模式对比                          │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                  │
│  同步通信 (Skill)                        │    │
│  Team Lead 主会话                          │    │
│  ─────────────────────┐                      │    │
│  │ Skill() 调用     │                      │    │
│  ├─→ paper-generation      │                      │    │
│  │   ├─→ paper-phase1-research                  │                      │    │
│  │   │   ├─→ [同步调用 domain Skills]            │                      │    │
│  │   │   │  └─→ [并行启动 Agents]               │                      │    │
│  │   │   │       │        │                           │                      │    │
│  │   │   │       │  research-mas-theory (同步)        │                      │    │
│  │   │   │       │  research-kg-theory (同步)         │                      │    │
│  │   │   │       │  research-nlp-sql (同步)            │                      │    │
│  │   │   │       │  research-bridge-eng (同步)          │                      │    │
│  │   │   │       │        │                           │                      │    │
│  │   │   │       └─→ [并行 Agents → 文件]          │                      │    │
│  │   │   │       │        │  A1, A2, A3 (异步)       │                      │    │
│  │   │   │       │  ───────────────────────────→ │                      │    │
│  │   └───────────────────────────────────────────────────┤                      │    │
│  │                                                    │                       │                      │
│  └─────────────────────────────────────────────────────┘                       │    │
│                                                    ▼                       │    │
│                                                            │    │
│  异步通信 (Agent)                            │    │
│  文件系统作为消息队列                            │    │
│  ─────────────────────┐                      │    │
│  Agent 进程读写文件   │                      │    │
│  A1 → a1-output.json/md                        │    │
│  A2 → a2-output.json/md                        │    │
│  A4 ← 读取所有 a*.json + skill-*.json          │    │
│    └──→ a4-output.json/md                      │    │
│                                                    │    │
└──────────────────────────────────────────────────────��──────────────────────┘
```

---

## 项目目录结构

```
workspace/{project}/
├── input-context.md              # 用户提供的项目输入
├── phase1/                       # Research 阶段产物
│   ├── a1-literature-survey.json
│   ├── a1-literature-survey.md
│   ├── a2-engineering-analysis.json (条件)
│   ├── a2-engineering-analysis.md (条件)
│   ├── a3-mas-literature.json (条件)
│   ├── a3-mas-literature.md (条件)
│   ├── skill-mas-theory.json (条件)
│   ├── skill-kg-theory.json (条件)
│   ├── skill-nlp-sql.json (条件)
│   ├── skill-bridge-eng.json (条件)
│   ├── a4-innovations.json
│   └── a4-innovations.md
├── phase2/                       # Design 阶段产物
│   ├── b1-related-work.json
│   ├── b1-related-work.md
│   ├── b2-experiment-design.json
│   ├── b2-experiment-design.md
│   ├── b3-paper-outline.json
│   └── b3-paper-outline.md
├── phase3/                       # Writing 阶段产物
│   ├── sections/             # 各章节 Markdown
│   │   ├── 01-introduction.md
│   │   ├── 02-related-work.md
│   │   ├── 03-methodology.md
│   │   ├── 04-implementation.md
│   │   ├── 05-evaluation.md
│   │   └── 06-conclusion.md
│   └── figures/              # 图表描述
│       ├── all-figures.md
│       └── all-tables.md
├── phase4/                       # Quality 阶段产物
│   ├── expert-selection.json
│   ├── domain-knowledge-{domain}.json (条件)
│   ├── d1-review-report.json
│   ├── d1-review-report.md
│   ├── d2-revision-log.json (条件)
│   ├── d2-revision-log.md (条件)
│   ├── d2-response-log.json (条件)
│   └── d2-response-log.md (条件)
├── quality-gates/                # 门控记录
│   ├── gate-1.json
│   ├── gate-2.json
│   ├── gate-3.json
│   └── gate-4.json
└── output/
    └── paper.md                  # 最终论文
```

---

## 重要注意事项

### 文件冲突避免

- 确保同一时间不会有两个 teammate 写同一个文件
- Phase 内的并行任务必须输出到不同文件
- 串行任务按顺序执行，避免竞态条件

### Phase 间依赖管理

- 必须等前一个 Phase 的 Quality Gate 通过后才能启动下一个 Phase
- 若门控失败，提供重试、跳过或手动补充选项
- 记录所有门控结果，便于问题追溯

### 上下文传递机制

- **Skill 通信**：在 Team Lead 主会话中同步执行，直接共享上下文
- **Agent 通信**：每个 agent 通过读写文件获取上下文，不依赖对话历史
- 所有路径使用绝对路径，避免工作目录问题

### 错误处理策略

- 如果 teammate 失败或停止，检查其输出日志
- 决定是重新生成该 agent 还是手动干预
- 记录失败原因到门控日志

### 预算监控

- 跟踪每个 teammate 的实际消耗
- 在 quality-gates 记录中汇总总预算使用情况
- 若超出预算，提供降级方案（如使用 Sonnet 替代 Opus）

---

## 扩展性设计

### 添加新 Agent

1. 在 `agents/{phase}/` 创建新的 `.md` 文件
2. 在 `config.json` 中添加模型和预算配置
3. 更新对应 Phase 的 Quality Gate 检查列表
4. 更新数据流依赖图

### 添加新 Skill

1. 在 `.claude/skills/` 创建新的 Skill 目录和 SKILL.md
2. 在 SKILL.md 中定义 YAML frontmatter（name, description）
3. 更新 [skills-catalog.md](skills-catalog.md) 注册新 Skill
4. 更新调用链路（如 Phase Skill 需调用新 Skill）

### 添加新领域

1. 在 `config.json` 的 `domains` 节点添加新领域定义
2. 在 `domain-knowledge-prep/SKILL.md` 中添加对应领域知识
3. 更新支持领域列表

---

## 架构优势总结

相比纯 Agent 架构，混合架构的核心优势：

1. **任务分类与资源优化**：理论分析等轻量任务由 Skill 同步完成，无需启动独立 Agent
2. **执行效率提升**：Skill 在主会话中直接执行，减少 API 调用开销
3. **扩展性增强**：添加新领域分析只需创建 Skill 文件，比创建 Agent 更简单
4. **多智能体特性保留**：Agent 间仍通过文件系统异步通信协作
5. **LLM 自主决策能力**：Phase 1 采用"扇出-聚合"架构，Team Lead 根据项目特征自主激活能力
6. **领域知识注入**：Phase 4 通过 domain-knowledge-prep Skill 确保评审专家具备领域专业知识
7. **动态专家选择**：根据论文内容智能选择相关度最高的评审专家，避免低质量反馈
