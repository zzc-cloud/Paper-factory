# Paper Factory 技能目录

本文档记录 paper-factory 项目中所有技能的完整清单和分类说明，是项目的"技能知识库"。

---

## 更新日志

### 2025-02-13
- 统一 Skill 命名规范（Phase Skills 统一为 `paper-phase*` 格式）
- 重构主 Orchestrator Skill 为层级化架构

### 技能结构概览

Paper Factory 采用 **分层 Skill 架构**：
- **Orchestrator Level**: `paper-generation` — 总编排器
- **Phase Level**: `paper-phase1-research`, `paper-phase2-design`, `paper-phase3-writing`, `paper-phase4-quality`
- **Domain Research Skills**: `research-mas-theory`, `research-kg-theory`, `research-nlp-sql`, `research-bridge-eng`

---

## Orchestrator Level

### paper-generation

**目录**: `.claude/skills/paper-generation/`
**YAML Frontmatter**:
```yaml
---
name: paper-generation
description: "论文生成主编排器 — 管理完整的 4 阶段学术论文生成流程。当用户���求'生成论文，project X'时，Team Lead 通过此 Skill 进行全流程编排。"
---
```

**调用链路**：
```
User: "生成论文，project X"
  ↓
Team Lead 检查 input-context.md
  ↓
Team Lead: Skill(skill="paper-generation", args="X")
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
- 管理 teammate 生成
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
description: "Phase 1 文献调研与工程分析 — 素材收集阶段。"
---
```

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

**核心特性**：
- 多视角评审：5 个独立专家评审 Agent（技术、领域、清晰度、重要性、写作质量）
- 迭代修订：D1 评审 ⇄ D2 修订，直到达标或达到最大轮次
- 专家辩论协作：D2 与 5 个评审专家的多轮交互与辩论，确保修订质量
- 质量门控：验证所有输出文件的完整性

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

按照技能在 pipeline 中的用途，将所有技能分为以下几类：

### 1. 论文生成核心技能

| 技能 | 目录 | 用途 |
|------|------|------|
| paper-generation | [.claude/skills/paper-generation/](.claude/skills/paper-generation/SKILL.md) | 总编排器 |
| paper-phase1-research | [.claude/skills/paper-phase1-research/](.claude/skills/paper-phase1-research/SKILL.md) | Phase 1 Research Orchestrator |
| paper-phase2-design | [.claude/skills/paper-phase2-design/](.claude/skills/paper-phase2-design/SKILL.md) | Phase 2 Design Orchestrator |
| paper-phase3-writing | [.claude/skills/paper-phase3-writing/](.claude/skills/paper-phase3-writing/SKILL.md) | Phase 3 Writing Orchestrator |
| paper-phase4-quality | [.claude/skills/paper-phase4-quality](.claude/skills/paper-phase4-quality/SKILL.md) | Phase 4 Quality Orchestrator |

**说明**：所有 Phase Skill 都由 Orchestrator 统一调用

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

---

## 技能来源说明

- **obra/superpowers**: 来自 Obra 库 — 超级 prompt 工程参考
- **affaan-m/everything-claude-code**: 来自 affan-m 库 — 顶级 AI 模型

**本地项目自定义**: paper-factory 项目内部自定义的技能

---

## 版本历史

- **v1.0** (2025-02-13): 创建 skills-catalog.md，建立 17 技能的初始体系
- **v1.1** (2025-02-13): 统一 Phase Skill 命名，重构主 Orchestrator 为层级化架构
- **v1.2** (2025-02-13): **本次更新** — Phase 4 增强专家辩论协作功能
  - 新增 5 个独立评审专家 Agent（Technical、Domain、Clarity、Significance、Writing Quality）
  - D2 Revision Specialist 支持与 5 个评审专家的多轮交互与辩论（始终启用）
  - paper-phase4-quality Skill 将专家辩论整合为评审-修订-辩论迭代循环的核心部分
  - 配置项：`quality.max_response_rounds`（控制每轮迭代的专家回复轮数）
  - 移除 `enable_individual_responses` 开关，专家辩论功能始终启用以保障最高质量