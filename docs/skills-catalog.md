# Paper Factory 技能目录

本文档记录 paper-factory 项目中所有技能的完整清单和分类说明，是项目的"技能知识库"。

---

## 更新日志

### 2025-02-13
- 统一 Skill 命名规范（Phase Skills 统一为 `paper-phase*` 格式）
- 重构主 Orchestrator Skill 为层级化架构

### 技能结构概览

Paper Factory 采用 **分层 Skill 架构**多
- **Orchestrator Level**: `paper-generation` — 总编排器
- **Phase Level**: `paper-phase1-research`, `paper-phase2-design`, `paper-phase3-writing`, `paper-phase4-quality`, `paper-phase1-parallel`
- **Domain Research Skills**: `research-mas-theory`, `research-kg-theory`, `research-nlp-sql`, `research-bridge-eng`

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

**调用链路**多
```
User: "生成论文，project X"
  ↓
系统（主会话） 检查 input-context.md
  ↓
系统（主会话）: Skill(skill="paper-generation", args="X")
  ↓
paper-generation Skill 按 Phase 顺序编排多
  ├─→ Skill("paper-phase1-research", args="X")    ─────────────────┐
  │   ↓
  ├─→ Skill("paper-phase2-design", args="X")    ─────────────────┐
  │   ↓
  ├─→ Skill("paper-phase3-writing", args="X")    ─────────────────┐
  │   ↓
  └─→ Skill("paper-phase4-quality", args="X")    ─────────────────┘
  ↓
最终输出多workspace/X/output/paper.md
```

**职责**多
- 启动流程验证
- 顺序编排 4 个 Phase
- 执行质量门控
- 管理 Agent 组件
- 错误处理和预算监控

**关键特征**多
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
description: "Phase 1 文献调研与理论分析 — 素材收集阶段。支持并行执行优化。"
---
```

### paper-phase1-parallel

**目录**: `.claude/skills/paper-phase1-parallel/`
**YAML Frontmatter**:
```yaml
---
name: paper-phase1-parallel
description: "Phase 1 并行执行增强 — 使用 Task 工具实现真正的 Agent 并行执行。"
---
```

**功能说明**多
- **并行执行**多使用 `Task` 工具的 `run_in_background` 参数实现 A1/A3 Agent 的真正并发执行
- **预期收益**多Phase 1 执行时间减少 40-60%
- **配置开关**多通过 `config.json` 中的 `parallel.phase1_enabled` 控制
- **错误隔离**多单个 Agent 失败不影响其他 Agent 的执行

### paper-phase2-design

**目录**: `.claude/skills/paper-phase2-design/`
**YAML Frontmatter**:
```yaml
---
name: paper-phase2-design
description: "Phase 2 论文设计阶段 — 相关工作分析、实验设计、论文架构设计。"
---
```

### paper-phase3-writing

**目录**: `.claude/skills/paper-phase3-writing/`
**YAML Frontmatter**:
```yaml
---
name: paper-phase3-writing
description: "Phase 3 论文撰写阶段 — 章节撰写、图表设计、学术格式化。"
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

**核心特性**多
- 多视角评审多5 个独立专家评审 Agent（技术、领域、清晰度、重要性、写作质量）
- 迭代修订多D1 评审 ⇄ D2 修订，直到达标或达到最大轮次
- 专家辩论协作多D2 与 5 个评审专家的多轮交互与辩论，确保修订质量
- 质量门控多验证所有输出文件的完整性

**新增功能**多
- **版本快照系统**多每次迭代后根据配置创建版本快照（V1/V2/V3...），保留完整历史
- **里程碑确认**多达到目标评分（如 9.0 分）时自动暂停，等待人类审稿员审查
- **反馈回路**多用户可提出修改意见，注入到下一轮迭代，D2 优先处理
- **版本历史追溯**多可查看每个版本的变化日志和评分历史

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

**功能说明**多
- **版本快照创建**多在 Phase 4 迭代关键点创建完整版本备份
- **元数据管理**多追踪每个版本的评分、迭代次数、时间戳、变更统计
- **变更日志生成**多人类可读的变更记录（改进点、剩余问题）
- **版本比较**多对比两个版本之间的差异
- **版本回滚**多支持回滚到指定历史版本

**调用方式**多
- 创建版本多`Skill(skill="version-manager", args="{project}:create")`
- 版本比较多`Skill(skill="version-manager", args="{project}:compare:V01:V02")`
- 版本回滚多`Skill(skill="version-manager", args="{project}:rollback:V01")`

**核心特性**多
- **自动化集成**多由 Phase 4 根据配置自动调用
- **完整快照**多每个版本包含论文、元数据、评审摘要、变更日志
- **灵活配置**多支持 all/milestones/smart/off 四种模式
- **历史清理**多可配置最大保留版本数，自动清理旧版本

---

## Domain Research Skills

### research-mas-theory

**目录**: `.claude/skills/research-mas-theory/`
**说明**: 多智能体系统理论分析 — BDI、Blackboard、Contract Net 等范式映射，认知架构分析，信息论形式化
**调用方式**: `Skill(skill="research-mas-theory", args="{project}")`

---

### research-kg-theory

**目录**: `.claude/skills/research-kg-theory/`
**说明**: 知识图谱与本体工程理论分析 — DL 基础、本体设计模式、KG 推理方法、神经符号融合、KG 作为认知枢纽
**调用方式**: `Skill(skill="research-kg-theory", args="{project}")`

---

### research-nlp-sql

**目录**: `.claude/skills/research-nlp-sql/`
**说明**: NL2SQL/Text2SQL 领域理论分析和技术定位
**调用方式**: `Skill(skill="research-nlp-sql", args="{project}")`

---

### research-bridge-eng

**目录**: `.claude/skills/research-bridge-eng/`
**说明**: 桥梁工程领域知识分析 — 检测方法论、结构健康监测、BIM+KG 融合、桥梁领域本体
**调用方式**: `Skill(skill="research-bridge-eng", args="{project}")`

---

## 技能分类

按照技能在 pipeline 中的用途，将所有技能分为以下几类多

### 1. 论文生成核心技能

| 技能 | 目录 | 用途 |
|------|------|------|
| paper-generation | [.claude/skills/paper-generation/](.claude/skills/paper-generation/SKILL.md) | 总编排器 |
| paper-phase1-research | [.claude/skills/paper-phase1-research/](.claude/skills/paper-phase1-research/SKILL.md) | Phase 1 Research Orchestrator |
| paper-phase2-design | [.claude/skills/paper-phase2-design/](.claude/skills/paper-phase2-design/SKILL.md) | Phase 2 Design Orchestrator |
| paper-phase3-writing | [.claude/skills/paper-phase3-writing/](.claude/skills/paper-phase3-writing/SKILL.md) | Phase 3 Writing Orchestrator |
| paper-phase4-quality | [.claude/skills/paper-phase4-quality](.claude/skills/paper-phase4-quality/SKILL.md) | Phase 4 Quality Orchestrator |

**说明**多所有 Phase Skill 都由 Orchestrator 统一调用

### 2. 领域研究技能

| 技能 | 目录 | 用途 | 领域 |
|------|------|------|
| research-mas-theory | [.claude/skills/research-mas-theory/](.claude/skills/research-mas-theory/SKILL.md) | 多智能体系统理论 |
| research-kg-theory | [.claude/skills/research-kg-theory/](.claude/skills/research-kg-theory/SKILL.md) | 知识图谱/本体 |
| research-nlp-sql | [.claude/skills/research-nlp-sql/](.claude/skills/research-nlp-sql/SKILL.md) | NL2SQL |
| research-bridge-eng | [.claude/skills/research-bridge-eng/](.claude/skills/research-bridge-eng/SKILL.md) | 桥梁工程 |

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
| dispatching-parallel-agents | [.claude/skills/dispatching-parallel-agents/](../dispatching-parallel-agents/SKILL.md) | 并行 Agent 调度 |
| domain-knowledge-prep | [.claude/skills/domain-knowledge-prep/](../domain-knowledge-prep/SKILL.md) | 领域知识准备 |
| using-superpowers | - Superpowers 仓库技能 |

### 5. 交互式论文生成技能

| 技能 | 目录 | 功能说明 |
|------|------|----------|
| **venue-analyzer** | [.claude/skills/venue-analyzer/](../venue-analyzer/SKILL.md) | 期刊配置解析器 — 解析 venues.md 中的期刊配置（包括写作风格、审稿标准、历史数据），生成 workspace/{project}/venue-style-guide.md 写作风格指南 |
| **interaction-manager** | [.claude/skills/interaction-manager/](../interaction-manager/SKILL.md) | 交互管理器（简化版）— 管理关键交互节点多Phase 0（期刊选择、题目确认、摘要框架）、Phase 2（大纲确认），使用 AskUserQuestion 工具获取用户确认和反馈 |
| **feedback-collector** | [.claude/skills/feedback-collector/](../feedback-collector/SKILL.md) | 反馈收集器 — 收集用户在各交互节点的反馈，结构化存储到 workspace/{project}/user-feedback.json，自动解析用户反馈并智能调整后续策略 |

### 6. 前置工具技能

| 技能 | 目录 | 功能说明 |
|------|------|----------|
| **codebase-analyzer** | [.claude/skills/codebase-analyzer/](../codebase-analyzer/SKILL.md) | 代码库分析工具 — 从工程项目代码库自动生成 input-context.md，作为论文生成流水线的前置工具。当用户有代码库但没有 input-context.md 时使用。调用方式：`Skill(skill="codebase-analyzer", args="{project},{codebase_path}")` |

---

## 技能来源说明

- **obra/superpowers**: 来自 Obra 库 — 超级 prompt 工程参考
- **affaan-m/everything-claude-code**: 来自 affan-m 库 — 顶级 AI 模型

**本地项目自定义**: paper-factory 项目内部自定义的技能