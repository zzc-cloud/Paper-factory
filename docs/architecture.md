# 系统架构

## 架构总览

Paper Factory 是一个基于 **Skill + Agent 混合架构** 的多智能体学术论文生成系统。系统采用分层编排设计，通过 Skill 层（同步执行）和 Agent 层（独立执行）的协作完成从文献调研到论文撰写的全流程。

```
╔══════════════════════════════════════════════════════════════╗
║               Paper Factory — Skill + Agent 混合架构        ║
╠══════════════════════════════════════════════════════════════╣
║                                                             ║
║  ┌────────────────────────────────────────────────────────┐  ║
║  │  User Request                                          │  ║
║  │      ↓                                                 │  ║
║  │ ┌────────────────────────────────────────────────────┐ │  ║
║  │ │         系统 (主编排器)                             │ │  ║
║  │ │                                                    │ │  ║
║  │ │  ════════════════════════════════════════════════   │ │  ║
║  │ │  │  Skill 层 (同步调用，共享上下文)                │ │  ║
║  │ │  │       ↓ 管理完整 4-Phase 流程                   │ │  ║
║  │ │  │  ├─→ paper-generation (主编排器)                │ │  ║
║  │ │  │       ↓                                         │ │  ║
║  │ │  │  ├─→ Phase Skills (4 阶段编排)                  │ │  ║
║  │ │  │       ↓                                         │ │  ║
║  │ │  │  ├─→ Agent Skills (10 个专业 Agent)             │ │  ║
║  │ │  │       ↓                                         │ │  ║
║  │ │  │  └─→ 辅助 Skills (缓存/版本/模板)              │ │  ║
║  │ │  ════════════════════════════════════════════════   │ │  ║
║  │ └────────────────────────────────────────────────────┘ │  ║
║  └────────────────────────────────────────────────────────┘  ║
║                                                             ║
║  ↓ (文件系统作为 Agent 间的通信媒介)                        ║
║                                                             ║
║  ↓ (Skill 同步调用 + 领域分析)                              ║
║                                                             ║
║  Phase 1: Research                                          ║
║  ├─ A1 (文献调研) → a1-literature-survey.json/md            ║
║  ├─ B1 (相关工作) → b1-related-work.json/md                ║
║  └─ 创新聚合（内联）→ innovation-synthesis.json/md          ║
║                                                             ║
║  Phase 2: Design                                            ║
║  ├─ B2 (实验设计) → b2-experiment-design.json/md            ║
║  └─ B3 (架构设计) → b3-paper-outline.json/md               ║
║                                                             ║
║  Phase 3: Writing                                           ║
║  ├─ C1 (章节撰写) → sections/*.md [多次调用]               ║
║  ├─ C2 (图表设计) → figures/all-figures.md, tables.md       ║
║  ├─ C3 (格式整合) → output/paper.md                        ║
║  └─ C4 (LaTeX编译) → output/paper.tex + paper.pdf          ║
║                                                             ║
║  Phase 4: Quality                                           ║
║  ├─ D1 (同行评审) → d1-review-report.json/md               ║
║  ├─ D2 (修订执行) → d2-revision-log.json/md [迭代]         ║
║  ├─ versions/ (版本快照) → V01/, V02/...                    ║
║  └─ user-feedback.json (用户反馈)                           ║
║                                                             ║
╚══════════════════════════════════════════════════════════════╝
```

---

## 核心设计原则

### 1. 分层架构（Layered Architecture）

系统采用 **Skill + Agent 混合架构**，按任务类型分层：

| 层级 | 组件 | 作用 | 通信模式 |
|--------|------|----------|----------|
| **Orchestrator Level** | `paper-generation` — 总编排器，通过 Skill 层实现 |
| **Phase Level** | Phase 编排 Skill — 4 阶段 Skill，串行编排流程 |
| **Domain Research Skills** | 领域分析 Skill — 通过 WebSearch 获取前沿文献 |
| **Agent 层** | 10 个 Agent 组件 — 通过 Skill 调用执行，文件系统通信 |
| **Version Manager Skill** | version-manager — 版本管理器，创建快照和管理历史 |

**关键区别**：
- **Skill**：轻量级、同步执行、共享会话上下文
- **Agent**：重量级、异步执行、独立进程

**关键原则**：
- **Skill 在主会话中同步执行**：适合快速分析、知识检索、编排协调
- **Agent 作为独立进程异步执行**：适合长流程、需要专注的写作/评审任务
- **串行执行**：Phase 1 采用 A1 → B1 串行执行，简化架构，提高可靠性
- **文件系统通信**：Agent 通过读写 workspace 目录传递数据，不依赖对话历史

### 2. 版本管理与用户确认（Versioning & Confirmation）

系统支持完整的版本管理和人类审稿员交互机制。

#### 核心特性

1. **版本快照系统**
   - 每次 Phase 4 迭代后根据配置创建版本快照（V1/V2/V3...）
   - 每个版本包含：论文快照、元数据、评审摘要、变更日志
   - 支持版本比较和回滚
   - 自动清理旧版本（可配置最大保留数量）

2. **里程碑确认机制**
   - 达到目标评分（如 9.0 分）时自动暂停
   - 使用 AskUserQuestion 向人类审稿员展示版本摘要
   - 三种选择：接受定稿 / 提供反馈继续 / 手动编辑

3. **反馈回路**
   - 人类审稿员的修改意见优先级高于评审建议
   - D2 修订专家优先处理用户反馈
   - 反馈状态追踪（pending → addressed）

#### 数据流

```
用户反馈 → user-feedback.json
       ↓
D2 读取 → 用户反馈优先级设为 critical
       ↓
D2 执行修订 → 更新 paper.md
       ↓
D2 更新反馈状态 → addressed
       ↓
下一轮评审 → 验证反馈已解决
```

4. **目录结构扩展**
```
workspace/{project}/
├── versions/              # 版本管理目录
│   ├── meta.json          # 版本索引
│   ├── V01/               # 版本快照
│   │   ├── V02/
│   └── ...
├── phase4/
│   ├── user-feedback.json   # 用户反馈
│   └── user-decision.json   # 用户决策记录
```

---

### 3. 质门控（Quality Gates）

每个阶段完成后验证输出完整性，确保下一阶段有正确的输入：

| Gate | 验证内容 | 失败处理 |
|------|----------|----------|
| Gate 1 | Phase 1 输出文件 | 记录缺失，通知用户 |
| Gate 2 | Phase 2 固定输出 | 验证完整性 |
| Gate 3 | Phase 3 论文完整性 | 质门控最终检查 |
| Gate 4 | 评审报告 + 版本历史 | 质量与可追溯性 |

---

## 4 阶段 Pipeline 详解

### Phase 0: 交互式启动确认

> **设计原则**：在正式进入文献调研之前，通过交互确认确保方向正确。早期确认可以减少 60-70% 的后期返工成本。

**执行模式**：仅在首次生成或 `target_venue` 未指定时执行

**交互节点**：
```
Phase 0: 交互式启动确认
├── 期刊选择与配置加载（interaction-manager + venue-analyzer）
│   ├── phase0_venue_selection ──────────────────┐
│   │   ├── 预定义期刊 → venue-analyzer 自动配置
│   │   └── 自定义期刊 → 提示配置模板
│   │
│   ├── 题目确认（interaction-manager）───────┐
│   │   ├── 候选题目 → 选择/自定义
│   │   └── 确认 → 写入 input-context.md
│   │
│   └── 摘要框架确认（interaction-manager）─────────┘
│       ├── 接受 → 保存默认框架
│       └── 编辑 → 保存用户编辑版本
│
└── 输出文件
    ├── phase0/venue-analysis.json
    ├── phase0/title-options.json
    ├── phase0/abstract-framework.md
    └── venue-style-guide.md（传递给后续 Phase）
```
**文件结构**：
```
workspace/{project}/
├── phase0/                   # 启动确认阶段
│   ├── venue-analysis.json
│   ├── title-options.json
│   └── abstract-framework.md
├── venue-style-guide.md      # 期刊写作风格指南
├── user-feedback.json         # 用户反馈结构化存储
├── feedback-history.md        # 反馈历史记录
```

**完成条件**：`input-context.md` 将包含完整的期刊、题目、摘要框架信息

### Phase 1: Research（素材收集）

**执行模式**：串行 Agent + Skill 混合 + 缓存优化

```
input-context.md (用户提供的项目上下文)
       │
       ↓
系统分析项目特征 → Phase 1 激活条件判断
       │
       ↓
A1 (文献调研，必选) → B1 (相关工作分析) → 创新聚合（内联）
       │
       ↓
串行启动 A1 → B1 Agent (Skill 调用)
       │
       ↓
domain-knowledge-update (更新领域知识文档，根据论文内容)
       │
       ↓
缓存优化：通过 cache-utils Skill 的 searchWithCache 减数实现
       │
       ↓
Quality Gate 1 (验证输出完整性)
```

### Phase 2: Design（论文设计）

**执行模式**：严格串行 B2 → B3

```
Phase 1 输出
       │
       ↓
B2 (实验设计)
       │       ↓
B3 (论文架构设计)
       │       ↓
Quality Gate 2
```

### Phase 3: Writing（论文撰写）

**执行模式**：串行 C1 (按章节）→ C2 → C3 → C4

```
b3-paper-outline.json (Phase 2 的 B3 输出)
       │
       ↓
C1 逐章节撰写
       │       ↓
C2 (设计图表)
       │       ↓
C3 (格式整合)
       │       ↓
C4 (LaTeX编译) → output/paper.md + paper.tex + paper.pdf
       │       ↓
Quality Gate 3
```

### Phase 4: Quality（质量保障）

**执行模式**：迭代循环 D1 ⇄ D2 + 版本管理 + 用户确认

```
d1-review-report.json (评审报告)
       │
       ↓
d2-revision-log.json (修订日志)
       │
       ↓
[版本创建循环] (versioning 配置控制)
       │       │  ├─ 创建版本快照 → versions/V{NN}/
       │       │ ├─ 达到阈值？ → 用户确认 (confirmation 配置)
       │       │ └─ 接受 → 定稿 / 反馈继续 / 手动编辑
       │       │ └─ ↓
       ↓
[用户反馈回路] (feedback 配置控制)
       │       │ ├─ 用户提出修改 → user-feedback.json
       │       │ └─ D2 优先处理 → 下一轮迭代
       │       │ └─ ↓
       ↓
Quality Gate 4 (最终门控 + 版本历史验证)
```

---

## 5. 辅助工具与技能

### Skills 层（25+ 个专业技能）

| 类别 | Skill | 功能说明 |
|------|------|----------|
| **主编排器** |
| `paper-generation` | 论文生成主编排器，管理完整 4 阶段流程 |
| **Phase 编排** |
| `paper-phase1-research` | Phase 1 编排器，支持串行/并行执行模式 |
| `paper-phase2-design` | Phase 2 编排器，相关工作分析、实验设计、架构 |
| `paper-phase3-writing` | Phase 3 编排器，章节撰写、图表设计、格式整合 |
| `paper-phase4-quality` | Phase 4 编排器，多视角评审、版本管理、用户确认 |
| **缓存优化** |
| **版本管理** |
| `domain-knowledge-update` | 领域知识更新（Skill） |
| **领域知识文档** |
| `docs/domain-knowledge/*.md` | 5 个领域知识文档（纯 Markdown） |
| **论文缓存** |
| `paper-cacher` | 论文缓存管理 |
| `cache-utils` | 论文缓存工具集 |
| **版本管理器** |
| `version-manager` | 版本快照与版本管理 |
| **模板系统** |
| `c4-latex-compiler` | LaTeX 编译与诊断修复 |
| `template-transfer` | 模板转换（会议格式一键切换） |

### Domain Knowledge Documents（5 个，已降级为纯文档）

| 文档 | 用途 |
|------|------|
| `docs/domain-knowledge/mas.md` | MAS 理论分析 + 评审认知 |
| `docs/domain-knowledge/kg.md` | KG/本体理论分析 + 评审认知 |
| `docs/domain-knowledge/nl2sql.md` | NL2SQL 理论分析 + 评审认知 |
| `docs/domain-knowledge/bridge.md` | 桥梁工程理论分析 + 评审认知 |
| `docs/domain-knowledge/data.md` | 数据分析理论分析 + 评审认知 |

### 辅助工具（可选）

| MCP 工具集 | Chrome DevTools Protocol |
| --- | --- | --- |

### 模板系统

系统内置 LaTeX 模板库，支持多会议/期刊格式的一键切换。

**目录结构**：
```
templates/
├── manifest.json      # 模板清单（含 targetVenues 映射）
├── acl/               # ACL/EMNLP/NAACL/COLING 模板
├── cvpr/              # CVPR/ICCV/ECCV 模板
├── neurips/           # NeurIPS 模板
├── icml/              # ICML 模板
├── lncs/              # Springer LNCS 模板（ISWC/ESWC/K-CAP）
├── aaai/              # AAAI Press 模板（AAAI/IJCAI/KR）
├── acm/               # ACM 模板（WWW/KDD/TOIS/TKDE/SIGMOD）
└── arxiv/             # arXiv 通用模板（默认）
```

**targetVenues 映射机制**：`manifest.json` 中每个模板通过 `targetVenues` 字段声明适用的会议/期刊列表。Phase 0 期刊选择后，`venue-analyzer` 根据此映射自动匹配对应模板，供 C4 LaTeX 编译使用。

**template-transfer 工具**：独立 Skill，支持将已生成的论文从一个会议格式转换为另一个格式（如 ACL → NeurIPS），自动处理样式、页面布局、引用格式等差异。

---

## 6. 配置文件详解

config.json 是系统的核心配置文件，控制模型选择、质量阈值、并行执行、缓存策略、版本管理、用户确认等所有关键行为。

### 配置节结构

```json
{
  // 模型配置
  "models": {
    "reasoning": "opus",
    "writing": "sonnet"
  },

  // 质量门控配置
  "quality": {
    "min_papers": 40,
    "min_review_score": 9.0,
    "max_review_iterations": 15,
    "max_response_rounds": 3,
    "dynamic_scoring": true
  },

  // 并行执行配置
  "parallel": {
    "phase1_enabled": false,
    "deprecated": "并行模式已移除",
    "use_task_tool": true,
    "timeout_per_agent": 300,
    "retry_on_failure": true,
    "max_retries": 1
  },
  // 论文缓存系统
  "cache": {
    "enabled": true,
    "max_papers_per_domain": 500,
    "purge_after_days": 365,
    "auto_generate_index": true
  },

  // 版本管理配置
  "versioning": {
    "enabled": true,
    "mode": "milestones",           // all | milestones | smart | off
    "max_versions_to_keep": 10
  },

  // 用户确认配置
  "confirmation": {
    "mode": "threshold",         // full | skip | threshold
    "threshold_score": 9.0,
    "confirm_at_milestones": true,
    "confirm_every_n_iterations": null,
    "require_approval_for_final": true
  },

  // 反馈回路配置
  "feedback": {
    "enabled": true,
    "priority_over_reviewer": true,  // 用户反馈优先级高于评审者
    "track_status": true
  },

  // 领域映射
  "domain_skills": { ... },
  "skills": { ... }
}
```

---

## 7. Agent 组件（已迁移为 Skill）

> 所有 Agent 已从 `agents/{phase}/*.md` 迁移为独立 Skill（`.claude/skills/{agent-id}/SKILL.md`）。

| Phase | Agent | 文件 | 角色 | 模型 | 激活条件 |
|------|---------|--------|------|---------|----------|
| Research | A1 | `.claude/skills/a1-literature-surveyor/SKILL.md` | 文献调研 | Opus | 必选 |
| Research | B1 | `.claude/skills/b1-related-work-analyst/SKILL.md` | 相关工作分析 | Opus | 必选 |
| Design | B2 | `.claude/skills/b2-experiment-designer/SKILL.md` | 实验设计 | Opus | 必选 |
| Design | B3 | `.claude/skills/b3-paper-architect/SKILL.md` | 论文架构设计 | Opus | 必选 |
| Writing | C1 | `.claude/skills/c1-section-writer/SKILL.md` | 章节撰写 | Sonnet | 必选 |
| Writing | C2 | `.claude/skills/c2-visualization-designer/SKILL.md` | 可视化设计 | Sonnet | 必选 |
| Writing | C3 | `.claude/skills/c3-academic-formatter/SKILL.md` | 学术格式化 | Sonnet | 必选 |
| Writing | C4 | `.claude/skills/c4-latex-compiler/SKILL.md` | LaTeX 编译 | Sonnet | 必选 |
| Quality | D1 | `.claude/skills/d1-general-reviewer/SKILL.md` | 通用评审 | Opus | 必选 |
| Quality | D2 | `.claude/skills/d2-revision-specialist/SKILL.md` | 修订执行 | Opus | 条件：评审分数低于阈值 |

**关键特性**：
- **异步执行**：所有 Agent 作为独立进程通过文件系统通信，不依赖对话历史
- **专用 Prompt**：每个 Agent 有精心设计的系统提示，专注于其任务
- **可复用性**：Agent Prompt 通用模板，可跨项目使用
- **工具权限**：根据任务需求分配 WebSearch、Read、Write、Bash 等

---

## 8. 数据流详解

### Skill 层通信（主会话 → Phase Skills）

```
系统(CLAUDE.md) 主会话 → Skill(paper-phase1-research)
    ↓
Skill(paper-phase1-research) → Domain Research Skills (按需调用)
    ↓
Skill(paper-phase2-design) → ...
    ↓
Skill(paper-phase3-writing) → ...
    ↓
Skill(paper-phase4-quality) → ...
```

### Agent 层通信（主会话 → Agent）

```
系统(CLAUDE.md) 主会话 → Skill(A1) → Skill(B1) → 创新聚合（内联）
    ↓
Agent(A1) → a1-literature-survey.json/md
    ↓
Agent(B1) → b1-related-work.json/md
    ↓
创新聚合 → innovation-synthesis.json/md
    ↓
Quality Gate 1 → 合并输出
    ↓
Phase 2 开始
```

### 版本管理数据流

```
Phase 4 迭代完成
    ↓
检查 versioning 配置
    ↓
根据模式判断是否创建版本
    ├─ 是 → Skill(version-manager) 创建版本快照
    │     ├─ 否 → 继续
    ↓
版本快照创建完成
    ↓
检查 confirmation 配置
    ├─ 达到阈值？ → 是 → Skill 内部调用 AskUserQuestion
    │  │     └─ 否 → 继续
    ↓
用户决策
    ├─ 接受 → 定稿完成
    │ │     ├─ 反馈继续 → 记录到 user-feedback.json
    │  │     └─ 手动编辑 → 暂停等待
    ↓
Quality Gate 4
```

---

## 9. 错误处理与恢复

### Agent 失败重试
- Quality Gate 失败记录错误
- 文件系统通信失败通知用户

### 版本清理
- 保留版本数超限时自动清理
- 版本回滚到上一个稳定版本

### 用户中断恢复
- 支持手动编辑后恢复流程
- 版本比较确认当前状态正确性

---

## 10. 系统扩展性

### 新增 Skill 扩展流程

1. 在 `.claude/skills/` 创建新 Skill 目录
2. 编写 SKILL.md 定义功能和调用方式
3. 在 SKILL.md 使用 YAML Frontmatter 定义元数据
4. 更新 skills-catalog.md 注册新 Skill
5. 在 config.json 的 skills 节点添加配置

### 新增 Agent 扩展流程

1. 在 `.claude/skills/{agent-id}/` 创建 `SKILL.md`（含 YAML frontmatter + 调用方式 + 参数解析 + 完整 prompt）
2. 更新对应 Phase 编排器 Skill 的 spawn 逻辑
3. 更新 agents-catalog.md 和 skills-catalog.md 注册新 Agent Skill

### 新增领域

1. 创建 `docs/domain-knowledge/your-domain.md`（包含理论分析 + 评审认知框架）
2. 在 config.json 的 `domain_skills` 中添加映射

---

## 11. 总结

**核心理念**：Skill-Agent 混合架构通过分层职责协作，实现端到端的学术论文自动生成。

**关键特性**：
- **串行执行**：Phase 1 采用串行模式（A1 → B1 → 创新聚合），简化架构，提高可靠性
- **质量保障**：4 阶段迭代评审，确保学术质量
- **版本管理**：完整历史追溯，可回滚
- **人类交互**：里程碑确认，反馈回路，人机协作
- **通用框架**：不绑定特定主题，适配任意研究领域
- **缓存优化**：第二次生成提速 60-80%
- **模板系统**：内置多会议模板，支持格式一键转换

---

**设计演进**：从纯 Agent 架构 → Skill-Agent 混合架构 → 版本管理 + 用户确认 + 交互式生成 + 模板系统
