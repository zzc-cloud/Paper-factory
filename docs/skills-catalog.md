# Paper Factory 技能目录

本文档记录 paper-factory 项目中所有技能的完整清单和分类说明，是项目的"技能知识库"。

---

## 技能结构概览

Paper Factory 采用 **分层 Skill 架构**：
- **Orchestrator Level**: `paper-generation` — 总编排器
- **Phase Level**: `paper-phase1-research`, `paper-phase2-design`, `paper-phase3-writing`, `paper-phase4-quality`
- **Agent Skills**: 11 个 Agent Skill（A1, B1, B2, B3, C1, C2, C3, C4, D1, D1-DE, D2）— 由 Phase Skill spawn 的 Agent 通过 Skill 调用
- **Domain Knowledge Documents**: `docs/domain-knowledge/` 目录下 5 个领域知识文档（纯 Markdown，非 Skill）
- **Domain Knowledge Update Skill**: `domain-knowledge-update`（唯一保留的领域 Skill，负责动态更新文档）

---

## Orchestrator Level

### paper-generation

**目录**: `.claude/skills/paper-generation/`
**YAML Frontmatter**:
```yaml
---
name: paper-generation
description: "论文生成主编排器 — 管理完整的 4 阶段学术论文生成流程。当用户请求'生成论文，project X'时，系统（主会话） 通过此 Skill 进行全流程编排。"
---
```

**调用链路**：
```
User: "生成论文，project X"
  ↓
系统（主会话） 检查 input-context.md
  ↓
系统（主会话）: Skill(skill="paper-generation", args="X")
  ↓
paper-generation Skill 按 Phase 顺序编排：
  ├─→ Skill("paper-phase1-research", args="X")    ─────────────────┐
  │   ↓
  ├─→ Skill("paper-phase2-design", args="X")    ─────────────────┐
  │   ↓
  ├─→ Skill("paper-phase3-writing", args="X")    ─────────────────┐
  │   ↓
  └─→ Skill("paper-phase4-quality", args="X")    ─────────────────┘
  ↓
最终输出：workspace/X/output/paper.md
```

**职责**：
- 启动流程验证
- 顺序编排 4 个 Phase
- 执行质量门控
- 管理 Agent 组件
- 错误处理和预算监控

**关键特征**：
- 严格串行执行（Phase 2-4）
- 依赖 input-context.md 进行动态激活
- 通过 Glob 动态发现输入文件

---

## Phase Level

### paper-phase1-research

**目录**: `.claude/skills/paper-phase1-research/`
**YAML Frontmatter**:
```yaml
---
name: paper-phase1-research
description: "Phase 1 文献调研与相关工作分析 — 素材收集阶段，支持缓存优化和串行执行。"
---
```

**核心流程**：
1. **领域识别**：使用 LLM 语义分析识别项目研究领域
2. **A1 文献调研**：根据领域动态生成搜索类别并执行检索
3. **B1 相关工作分析**：系统性比较和缺口分析
4. **创新聚合**：内联聚合创新点和支撑证据（不再作为独立 Agent）
5. **Quality Gate 1**：验证输出完整性

### paper-phase2-design

**目录**: `.claude/skills/paper-phase2-design/`
**YAML Frontmatter**:
```yaml
---
name: paper-phase2-design
description: "Phase 2 论文设计阶段 — 实验设计、论文架构设计（B2 → B3）。"
---
```

**核心流程**：B2 实验设计 → B3 论文架构设计。

### paper-phase3-writing

**目录**: `.claude/skills/paper-phase3-writing/`
**YAML Frontmatter**:
```yaml
---
name: paper-phase3-writing
description: "Phase 3 论文撰写阶段 — 章节撰写、图表设计、学术格式化、LaTeX 编译。"
---
```

### paper-phase4-quality

**目录**: `.claude/skills/paper-phase4-quality/`
**YAML Frontmatter**:
```yaml
---
name: paper-phase4-quality
description: "Phase 4 质量保障阶段 — 多视角同行评审与修订循环，支持多智能体辩论与协作优化。"
---
```

**核心特性**：
- 多视角评审：D1-General-Reviewer（5 个通用维度：技术、新颖性、清晰度、重要性、实验严谨性）+ N 个 D1-Domain-Expert（按领域动态 spawn）
- 迭代修订：D1 评审 ⇄ D2 修订，直到达标或达到最大轮次
- 专家辩论协作：D2 与 5 个评审专家的多轮交互与辩论，确保修订质量
- 质量门控：验证所有输出文件的完整性

**扩展功能**：
- **版本快照系统**：每次迭代后根据配置创建版本快照（V1/V2/V3...），保留完整历史
- **里程碑确认**：达到目标评分（如 9.0 分）时自动暂停，等待人类审稿员审查
- **反馈回路**：用户可提出修改意见，注入到下一轮迭代，D2 优先处理
- **版本历史追溯**：可查看每个版本的变化日志和评分历史

---

### version-manager

**目录**: `.claude/skills/version-manager/`

**YAML Frontmatter**:
```yaml
---
name: version-manager
description: "版本快照与版本管理 — 为论文迭代创建版本快照、管理版本元数据、生成变更日志和版本比较。"
---
```

**功能说明**：
- **版本快照创建**：在 Phase 4 迭代关键点创建完整版本备份
- **元数据管理**：追踪每个版本的评分、迭代次数、时间戳、变更统计
- **变更日志生成**：人类可读的变更记录（改进点、剩余问题）
- **版本比较**：对比两个版本之间的差异
- **版本回滚**：支持回滚到指定历史版本

**调用方式**：
- 创建版本：`Skill(skill="version-manager", args="{project}:create")`
- 版本比较：`Skill(skill="version-manager", args="{project}:compare:V01:V02")`
- 版本回滚：`Skill(skill="version-manager", args="{project}:rollback:V01")`

**核心特性**：
- **自动化集成**：由 Phase 4 根据配置自动调用
- **完整快照**：每个版本包含论文、元数据、评审摘要、变更日志
- **灵活配置**：支持 all/milestones/smart/off 四种模式
- **历史清理**：可配置最大保留版本数，自动清理旧版本

---

## Domain Knowledge Documents

> 以下 5 个领域知识文件已从 Skill 降级为纯 Markdown 文档，存放在 `docs/domain-knowledge/` 目录下。
> 它们不再通过 `Skill()` 调用，而是由 Agent 通过 `Read` 工具直接读取。
> 唯一保留的领域 Skill 是 `domain-knowledge-update`，负责通过 WebSearch 动态更新这些文档。

### docs/domain-knowledge/mas.md

**说明**: Multi-Agent Systems 领域知识 — 理论分析 + 评审认知框架
**读取方式**: `Read("docs/domain-knowledge/mas.md")`

**功能**：
- **Part 1: 理论分析** — BDI、Blackboard、Contract Net 等范式映射，认知架构分析（ACT-R、SOAR、GWT）
- **Part 2: 评审认知框架** — 核心概念、评估维度、常见陷阱、经典文献对标、SOTA 对比

---

### docs/domain-knowledge/kg.md

**说明**: Knowledge Graph 领域知识 — 理论分析 + 评审认知框架
**读取方式**: `Read("docs/domain-knowledge/kg.md")`

**功能**：
- **Part 1: 理论分析** — 描述逻辑（DL）基础、本体设计模式、KG 推理方法、神经符号融合
- **Part 2: 评审认知框架** — RDF/OWL/SPARQL 评估、本体设计评审、推理复杂度分析

---

### docs/domain-knowledge/nl2sql.md

**说明**: NL2SQL 领域知识 — 理论分析 + 评审认知框架
**读取方式**: `Read("docs/domain-knowledge/nl2sql.md")`

**功能**：
- **Part 1: 理论分析** — Schema Linking、SQL 生成策略、执行引导优化
- **Part 2: 评审认知框架** — 精确匹配、执行准确率、跨数据库泛化评估

---

### docs/domain-knowledge/bridge.md

**说明**: Bridge Engineering 领域知识 — 理论分析 + 评审认知框架
**读取方式**: `Read("docs/domain-knowledge/bridge.md")`

**功能**：
- **Part 1: 理论分析** — 结构健康监测（SHM）、BIM+KG 融合、损伤检测方法
- **Part 2: 评审认知框架** — 传感器布置、监测指标、BIM 数据提取评估

---

### docs/domain-knowledge/data.md

**说明**: Data Analysis & ML 领域知识 — 理论分析 + 评审认知框架
**读取方式**: `Read("docs/domain-knowledge/data.md")`

**功能**：
- **Part 1: 理论分析** — 数据预处理、特征工程、模型选择与评估
- **Part 2: 评审认知框架** — 数据质量、特征工程、模型评估严谨性

---

## Deprecated Skills

以下 Skills 已被 `docs/domain-knowledge/` 文档替代：

- `domain-knowledge-mas` → `docs/domain-knowledge/mas.md`
- `domain-knowledge-kg` → `docs/domain-knowledge/kg.md`
- `domain-knowledge-nl2sql` → `docs/domain-knowledge/nl2sql.md`
- `domain-knowledge-bridge` → `docs/domain-knowledge/bridge.md`
- `domain-knowledge-data` → `docs/domain-knowledge/data.md`
- `research-mas-theory` → `docs/domain-knowledge/mas.md`
- `research-kg-theory` → `docs/domain-knowledge/kg.md`
- `research-nlp-sql` → `docs/domain-knowledge/nl2sql.md`
- `research-bridge-eng` → `docs/domain-knowledge/bridge.md`
- `review-mas-domain` → `docs/domain-knowledge/mas.md`
- `review-kg-domain` → `docs/domain-knowledge/kg.md`
- `review-nl2sql-domain` → `docs/domain-knowledge/nl2sql.md`
- `review-bridge-domain` → `docs/domain-knowledge/bridge.md`
- `review-data-domain` → `docs/domain-knowledge/data.md`
- `domain-knowledge-se` → 已移除（SE 作为独立领域不适用于学术论文评审）
- `domain-knowledge-hci` → 已移除（HCI 作为独立领域不适用于学术论文评审）
- `review-se-domain` → 已移除
- `review-hci-domain` → 已移除

---

## 技能分类

按照技能在 pipeline 中的用途，将所有技能分为以下几类：

### 1. 论文生成核心技能

| 技能 | 目录 | 用途 |
|------|------|------|
| paper-generation | [.claude/skills/paper-generation/](.claude/skills/paper-generation/SKILL.md) | 总编排器 |
| paper-phase1-research | [.claude/skills/paper-phase1-research/](.claude/skills/paper-phase1-research/SKILL.md) | Phase 1 Research Orchestrator |
| paper-phase2-design | [.claude/skills/paper-phase2-design/](.claude/skills/paper-phase2-design/SKILL.md) | Phase 2 Design Orchestrator |
| paper-phase3-writing | [.claude/skills/paper-phase3-writing/](.claude/skills/paper-phase3-writing/SKILL.md) | Phase 3 Writing Orchestrator |
| paper-phase4-quality | [.claude/skills/paper-phase4-quality](.claude/skills/paper-phase4-quality/SKILL.md) | Phase 4 Quality Orchestrator |
| b1-related-work-analyst | [.claude/skills/b1-related-work-analyst/](.claude/skills/b1-related-work-analyst/SKILL.md) | B1 相关工作分析师（Agent Skill） |
| a1-literature-surveyor | [.claude/skills/a1-literature-surveyor/](.claude/skills/a1-literature-surveyor/SKILL.md) | A1 文献调研专家（Agent Skill） |
| b2-experiment-designer | [.claude/skills/b2-experiment-designer/](.claude/skills/b2-experiment-designer/SKILL.md) | B2 实验设计师（Agent Skill） |
| b3-paper-architect | [.claude/skills/b3-paper-architect/](.claude/skills/b3-paper-architect/SKILL.md) | B3 论文架构师（Agent Skill） |
| c1-section-writer | [.claude/skills/c1-section-writer/](.claude/skills/c1-section-writer/SKILL.md) | C1 章节撰写专家（Agent Skill） |
| c2-visualization-designer | [.claude/skills/c2-visualization-designer/](.claude/skills/c2-visualization-designer/SKILL.md) | C2 可视化设计专家（Agent Skill） |
| c3-academic-formatter | [.claude/skills/c3-academic-formatter/](.claude/skills/c3-academic-formatter/SKILL.md) | C3 学术格式化专家（Agent Skill） |
| c4-latex-compiler | [.claude/skills/c4-latex-compiler/](.claude/skills/c4-latex-compiler/SKILL.md) | C4 LaTeX 编译专家（Agent Skill） |
| d1-general-reviewer | [.claude/skills/d1-general-reviewer/](.claude/skills/d1-general-reviewer/SKILL.md) | D1 通用评审专家（Agent Skill） |
| d1-reviewer-domain-expert | [.claude/skills/d1-reviewer-domain-expert/](.claude/skills/d1-reviewer-domain-expert/SKILL.md) | D1-DE 领域评审专家（Agent Skill） |
| d2-revision-specialist | [.claude/skills/d2-revision-specialist/](.claude/skills/d2-revision-specialist/SKILL.md) | D2 修订执行专家（Agent Skill） |

**说明**：所有 Phase Skill 都由 Orchestrator 统一调用。Agent Skill（如 b1-related-work-analyst、a1-literature-surveyor 等）由 Phase Skill 内部 spawn 的 Agent 通过 Skill 调用启动。

### 2. 领域知识

| 类型 | 路径 | 用途 |
|------|------|------|
| 文档 | [docs/domain-knowledge/mas.md](../docs/domain-knowledge/mas.md) | MAS 领域知识（理论 + 评审） |
| 文档 | [docs/domain-knowledge/kg.md](../docs/domain-knowledge/kg.md) | KG 领域知识（理论 + 评审） |
| 文档 | [docs/domain-knowledge/nl2sql.md](../docs/domain-knowledge/nl2sql.md) | NL2SQL 领域知识（理论 + 评审） |
| 文档 | [docs/domain-knowledge/bridge.md](../docs/domain-knowledge/bridge.md) | Bridge 领域知识（理论 + 评审） |
| 文档 | [docs/domain-knowledge/data.md](../docs/domain-knowledge/data.md) | Data 领域知识（理论 + 评审） |
| Skill | [.claude/skills/domain-knowledge-update/](.claude/skills/domain-knowledge-update/SKILL.md) | 领域知识动态更新工具 |

### 3. 基础设施技能

| 技能 | 目录 | 来源 |
|------|------|------|
| python-patterns | [.claude/skills/python-patterns/](../python-patterns/SKILL.md) | Python 最佳实践 |
| python-testing | [.claude/skills/python-testing/](../python-testing/SKILL.md) | pytest 测试策略 |
| test-driven-development | [.claude/skills/test-driven-development/](../test-driven-development/SKILL.md) | TDD 开发流程 |
| iterative-retrieval | [.claude/skills/iterative-retrieval/](../iterative-retrieval/SKILL.md) | 渐进式检索 |
| systematic-debugging | [.claude/skills/systematic-debugging/](../systematic-debugging/SKILL.md) | 系统化调试 |
| verification-before-completion | [.claude/skills/verification-before-completion/](../verification-before-completion/SKILL.md) | 完成前验证 |

### 4. 通用工具技能

| 技能 | 目录 | 来源 |
|------|------|------|
| brainstorming | [.claude/skills/brainstorming/](../brainstorming/SKILL.md) | 创意探索 |
| writing-plans | [.claude/skills/writing-plans/](../writing-plans/SKILL.md) | 编写计划 |
| executing-plans | [.claude/skills/executing-plans/](../executing-plans/SKILL.md) | 执行计划 |
| subagent-driven-development | [.claude/skills/subagent-driven-development/](../subagent-driven-development/SKILL.md) | 子 Agent 驱动开发 |
| using-superpowers | - | Superpowers 仓库技能 |

### 5. 交互式论文生成技能

| 技能 | 目录 | 功能说明 |
|------|------|----------|
| **venue-analyzer** | [.claude/skills/venue-analyzer/](../venue-analyzer/SKILL.md) | 期刊配置解析器 — 解析 venues.md 中的期刊配置（包括写作风格、审稿标准、历史数据），生成 workspace/{project}/venue-style-guide.md 写作风格指南 |
| **interaction-manager** | [.claude/skills/interaction-manager/](../interaction-manager/SKILL.md) | 交互管理器（简化版）— 管理关键交互节点：Phase 0（期刊选择、题目确认、摘要框架）、Phase 2（大纲确认），使用 AskUserQuestion 工具获取用户确认和反馈 |
| **feedback-collector** | [.claude/skills/feedback-collector/](../feedback-collector/SKILL.md) | 反馈收集器 — 收集用户在各交互节点的反馈，结构化存储到 workspace/{project}/user-feedback.json，自动解析用户反馈并智能调整后续策略 |
| **template-transfer** | [.claude/skills/template-transfer/](.claude/skills/template-transfer/SKILL.md) | 模板转换专家 — 将论文从一个会议/期刊格式转换为另一个格式，支持 LaTeX→LaTeX 迁移 |

### 6. 前置工具技能

| 技能 | 目录 | 功能说明 |
|------|------|----------|
| **codebase-analyzer** | [.claude/skills/codebase-analyzer/](../codebase-analyzer/SKILL.md) | 代码库分析工具 — 从工程项目代码库自动生成 input-context.md，作为论文生成流水线的前置工具。当用户有代码库但没有 input-context.md 时使用。调用方式：`Skill(skill="codebase-analyzer", args="{project},{codebase_path}")` |

### 7. Pre-Phase 工具（研究增强）

| 技能 | 目录 | 功能说明 |
|------|------|----------|
| **requirements-spec** | [.claude/skills/requirements-spec/](.claude/skills/requirements-spec/SKILL.md) | 需求规范协议 — 对模糊指令进行结构化需求澄清，生成 MUST/SHOULD/MAY 标记的需求规范文档，用户确认后进入正式流水线。触发条件：input-context.md 不存在或缺少 2+ MUST 字段 |
| **research-interview** | [.claude/skills/research-interview/](.claude/skills/research-interview/SKILL.md) | 研究访谈 — 6 阶段结构化访谈（研究背景→核心问题→方法论→创新点→预期贡献→目标定位），从用户口述中提炼研究规范，可替代或增强 input-context.md |
| **research-ideation** | [.claude/skills/research-ideation/](.claude/skills/research-ideation/SKILL.md) | 研究构思 — 从模糊主题生成 3-5 个研究方向，每个方向包含假设、方法、创新点和目标期刊建议。使用 WebSearch 搜索最新研究趋势 |

### 8. 质量与实验工具

| 技能 | 目录 | 功能说明 |
|------|------|----------|
| **quality-scorer** | [.claude/skills/quality-scorer/](.claude/skills/quality-scorer/SKILL.md) | 量化评分引擎 — 基于 100 分制扣分模型对各阶段输出进行内容质量评估，支持 4 级严重性（Fatal/Critical/Major/Minor）和 3 级门控阈值（70 阻塞/85 通过/95 卓越） |
| **devils-advocate** | [.claude/skills/devils-advocate/](.claude/skills/devils-advocate/SKILL.md) | 魔鬼代言人 — Phase 2 大纲确认后、Phase 3 撰写前的批判性审查，生成 5-7 个挑战（逻辑漏洞、方法弱点、审稿人质疑等），并将防御策略注入论文大纲 |
| **exploration-manager** | [.claude/skills/exploration-manager/](.claude/skills/exploration-manager/SKILL.md) | 探索沙箱管理器 — 管理轻量级实验空间，支持创建/列出/升级/归档实验，降低质量阈值（60/100），无需走完整流水线 |

---

## 技能来源说明

- **obra/superpowers**: 来自 Obra 库 — 超级 prompt 工程参考
- **affaan-m/everything-claude-code**: 来自 affan-m 库 — 顶级 AI 模型

**本地项目自定义**: paper-factory 项目内部自定义的技能