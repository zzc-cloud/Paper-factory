# Agent 目录

本文档列出 Paper Factory 系统中所有 11 个 Agent 的完整定义、职责和配置信息。

---

## 快速索引

| Phase | Agent | 角色 | 模型 | 预算 |
|-------|--------|------|------|----------|
| Phase 1 | A1 | 文献调研 | Sonnet | $3 |
| Phase 1 | A3 | MAS 文献调研 | Opus | $4 |
| Phase 1 | A4 | 创新形式化 | Opus | $3 |
| Phase 2 | B1 | 相关工作分析 | Opus | $3 |
| Phase 2 | B2 | 实验设计 | Opus | $3 |
| Phase 2 | B3 | 论文架构设计 | Opus | $4 |
| Phase 3 | C1 | 章节撰写 | Sonnet | $2 |
| Phase 3 | C2 | 可视化设计 | Sonnet | $3 |
| Phase 3 | C3 | 学术格式化 | Sonnet | $2 |
| Phase 4 | D1 | 同行评审 | Opus | $5 |
| Phase 4 | D2 | 修订执行 | Opus | $4 |
| Phase 4 | D1-Technical-Expert | 技术评审专家 | Opus | $5 |
| Phase 4 | D1-Domain-Expert | 领域评审专家 | Opus | $5 |
| Phase 4 | D1-Clarity-Expert | 清晰度评审专家 | Opus | $5 |
| Phase 4 | D1-Significance-Expert | 重要性评审专家 | Opus | $5 |
| Phase 4 | D1-Writing-Quality-Expert | 写作质量评审专家 | Opus | $5 |

> **前置工具**：A2（代码库分析师）已从 Phase 1 移至独立的 `codebase-analyzer` Skill，不计入流水线 Agent。

---

## Phase 1: Research Agents

### A1 - Literature Surveyor（文献调研专家）

**Prompt 文件**多`agents/phase1/a1-literature-surveyor.md`

**核心职责**多
- 搜索并分类整理 30+ 篇相关学术论文
- 提取文献元数据多标题、作者、会议/期刊、年份、引用
- 输出结构化的文献调研报告供下游使用

**输入**多
- `workspace/{project}/input-context.md`

**输出**多
- `workspace/{project}/phase1/a1-literature-survey.json`
- `workspace/{project}/phase1/a1-literature-survey.md`

**工具**多WebSearch, WebFetch, Read, Write

**激活**多必选（始终启动）

---

### A2 - Codebase Analyzer（代码库分析师）— 独立前置工具

> A2 已从 Phase 1 的条件性研究 Agent 重新定位为独立的前置工具 `codebase-analyzer` Skill。
> 它不再参与 Phase 1 流水线，而是在用户没有 `input-context.md` 但有代码库时使用。
>
> **调用方式**：`Skill(skill="codebase-analyzer", args="{project},{codebase_path}")`
>
> **Prompt 文件**：`agents/phase1/a2-engineering-analyst.md`（保留作为 Skill 的执行 Agent）

---

### A3 - MAS Literature Researcher（MAS 文献调研）

**Prompt 文件**多`agents/phase1/a3-mas-theorist.md`

**核心职责**多
- 研究最新多智能体系统文献（AutoGen, CrewAI, MetaGPT 等）
- 分析 MAS 领域的理论进展和实际应用
- 提供 MAS 相关文献的理论支撑

**输入**多
- `workspace/{project}/input-context.md`

**输出**多
- `workspace/{project}/phase1/a3-mas-literature.json`
- `workspace/{project}/phase1/a3-mas-literature.md`

**工具**多WebSearch, WebFetch, Read, Write

**激活**多条件（当项目深度涉及多智能体架构且需要最新文献支撑时）

---

### A4 - Innovation Formalizer（创新形式化专家）

**Prompt 文件**多`agents/phase1/a4-innovation-formalizer.md`

**核心职责**多
- 将工程创新点转化为学术贡献声明
- 综合所有分析结果，提炼核心创新
- 映射创新点到学术价值和影响

**输入**多
- `workspace/{project}/input-context.md`
- 所有可用的 Phase 1 分析文件（通过 Glob 发现）

**输出**多
- `workspace/{project}/phase1/a4-innovations.json`
- `workspace/{project}/phase1/a4-innovations.md`

**工具**多Read, Write, Glob

**激活**多必选（Phase 1 聚合点）

---

## Phase 2: Design Agents

### B1 - Related Work Analyst（相关工作分析专家）

**Prompt 文件**多`agents/phase2/b1-related-work-analyst.md`

**核心职责**多
- 对比分析现有工作，定位本研究的创新点
- 识别研究空白和机会
- 构建相关工作章节的学术叙事

**输入**多
- `workspace/{project}/phase1/a1-literature-survey.json`
- `workspace/{project}/phase1/a4-innovations.json`

**输出**多
- `workspace/{project}/phase2/b1-related-work.json`
- `workspace/{project}/phase2/b1-related-work.md`

**工具**多Read, Write, WebSearch

**激活**多必选

---

### B2 - Experiment Designer（实验设计专家）

**Prompt 文件**多`agents/phase2/b2-experiment-designer.md`

**核心职责**多
- 设计实验方案验证每个创新点
- 定义评估指标和基线对比
- 指定数据集、参数和实验流程

**输入**多
- `workspace/{project}/phase1/a4-innovations.json`
- `workspace/{project}/input-context.md`
- 所有可用的 Phase 1 分析文件（通过 Glob 发现）

**输出**多
- `workspace/{project}/phase2/b2-experiment-design.json`
- `workspace/{project}/phase2/b2-experiment-design.md`

**工具**多Read, Write

**激活**多必选

---

### B3 - Paper Architect（论文架构设计专家）

**Prompt 文件**多`agents/phase2/b3-paper-architect.md`

**核心职责**多
- 设计论文整体结构、章节划分、内容分配
- 指定图表、表格及其在论文中的位置
- 确保逻辑流程和论证链的完整性

**输入**多
- 所有 Phase 1 + Phase 2 前序输出（通过 Glob 发现）

**输出**多
- `workspace/{project}/phase2/b3-paper-outline.json`
- `workspace/{project}/phase2/b3-paper-outline.md`

**工具**多Read, Write

**激活**多必选

---

## Phase 3: Writing Agents

### C1 - Section Writer（章节撰写专家）

**Prompt 文件**多`agents/phase3/c1-section-writer.md`

**核心职责**多
- 根据 `b3-paper-outline.json` 逐章节撰写内容
- 保持学术写作规范和术语一致性
- 确保章节间的逻辑连贯性

**输入**多
- `workspace/{project}/phase2/b3-paper-outline.json`
- 对应章节所需的源材料

**输出**多
- `workspace/{project}/phase3/sections/{section_id}-{section_name}.md`
- 例如多`01-introduction.md`, `02-related-work.md`, `03-methodology.md` ...

**工具**多Read, Write

**激活**多必选（按章节数多次调用）

---

### C2 - Visualization Designer（可视化设计专家）

**Prompt 文件**多`agents/phase3/c2-visualization-designer.md`

**核心职责**多
- 设计论文所需的图表、表格、算法伪代码
- 确保可视化元素与论文内容一致
- 生成图表描述供绘图工具使用

**输入**多
- `workspace/{project}/phase2/b3-paper-outline.json`
- 相关数据文件

**输出**多
- `workspace/{project}/phase3/figures/all-figures.md`
- `workspace/{project}/phase3/figures/all-tables.md`

**工具**多Read, Write

**激活**多必选

---

### C3 - Academic Formatter（学术格式化专家）

**Prompt 文件**多`agents/phase3/c3-academic-formatter.md`

**核心职责**多
- 组装所有章节、图表、参考文献，生成最终论文
- 应用目标会议/期刊的格式规范
- 生成完整的引用列表和交叉引用

**输入**多
- 所有章节文件多`workspace/{project}/phase3/sections/*.md`
- 图表文件多`workspace/{project}/phase3/figures/*.md`
- 文献数据多`workspace/{project}/phase1/a1-literature-survey.json`

**输出**多
- `workspace/{project}/output/paper.md`

**工具**多Read, Write, Glob

**激活**多必选

---

## Phase 4: Quality Agents

### D1 - Multi-Perspective Reviewer（多视角评审架构）

**注意**多D1 已扩展为多视角评审机制，支持两种执行模式多

**模式 A多多专家评审（推荐用于专家回复协调）**
评审包含两类专家多
- **通用评审专家**（内嵌于 `agents/phase4/d1-peer-reviewer.md`）多
  - **R1-Technical-Expert**多技术评审专家 — 技术实现、算法设计、系统架构
  - **R2-Novelty-Expert**多新颖性评审专家 — 学术价值、原创性、贡献影响力
  - **R3-Clarity-Expert**多清晰度评审专家 — 表述清晰度、逻辑流畅性、组织结构
- **D1-Domain-Expert**多领域评审专家（动态选择） — `agents/phase4/d1-reviewer-domain-expert.md`

**新模式关键特性**多
- **Domain-Expert**（动态选择）多根据论文内容，选择最相关的 1-2 个领域专家，确保评审有针对性
- **其他专家**（固定启用）多Technical、Clarity、Writing 始终启用，提供基础评审维度
- **领域知识准备**多选中的领域专家先通过 `domain-knowledge-prep` Skill 准备知识
- **资源优化**多不启动低相关度的领域专家，避免无关专家给出低质量反馈

**专家选择逻辑**多
| 论文类型 | Domain-Expert | 其他专家 |
|----------|-------------|-----------|
| KG 本体论文 | Domain-KG (相关度高) | Technical, Clarity, Writing |
| MAS 系统论文 | Domain-MAS (相关度高) | Technical, Clarity, Writing, Significance (条件) |
| 纯算法论文（无特定领域） | 不选择 Domain | Technical, Clarity, Writing, Significance (条件) |
| 桥梁检测论文 | Domain-Bridge (相关度高) | Technical, Clarity, Writing, Significance (条件) |

**模式 B多单一综合评审**
- **原 D1 Agent**多`agents/phase4/d1-peer-reviewer.md`（已保留作为参考）

**Prompt 文件**多`agents/phase4/d1-peer-reviewer.md`

**核心职责**多
- 从创新性、严谨性、可读性等维度评审论文
- 提供具体的修订建议和优先级
- 给出量化评分和总体质量判断

**评审维度**多
- Originality（原创性）
- Significance（学术价值）
- Methodology（方法论严谨性）
- Clarity（表述清晰度）
- Writing Quality（写作质量）
- Technical Soundness（技术合理性）

**输入**多
- `workspace/{project}/output/paper.md`
- `workspace/{project}/phase1/a4-innovations.json`

**输出**多
- `workspace/{project}/phase4/d1-review-report.json`
- `workspace/{project}/phase4/d1-review-report.md`

**工具**多Read, Write

**激活**多必选（循环调用）

---

### D2 - Revision Specialist（修订执行专家）

**Prompt 文件**多`agents/phase4/d2-revision-specialist.md`

**核心职责**多
- 根据评审意见修订论文
- 保持学术语气和论证连贯性
- 记录所有修改内容
- **专家辩论协调**多向 5 个评审专家发送个性化回复并处理反馈

**输入**多
- `workspace/{project}/output/paper.md`
- `workspace/{project}/phase4/d1-review-report.json`
- 5 个评审专家的报告

**输出**多
- 修订后的 `workspace/{project}/output/paper.md`
- `workspace/{project}/phase4/d2-revision-log.json`
- `workspace/{project}/phase4/d2-revision-log.md`
- `workspace/{project}/phase4/d2-response-log.json`
- `workspace/{project}/phase4/d2-response-log.md`

**工具**多Read, Write

**激活**多条件（当评审分数低于阈值且未达到最大迭代次数时）

**专家辩论协调模式**（始终启用）多
1. 向 5 个评审专家发送个性化回复
2. 处理专家反馈，如需修改则立即执行
3. 最多执行 `quality.max_response_rounds` 轮回复
4. 通过多轮辩论确保修订真正解决问题

---

## Agent 工具权限汇总

| 工具 | 主要使用 Agent |
|-------|----------------|
| WebSearch, WebFetch | A1, A3, B1 |
| Read, Glob, Grep, Write, Bash | B2, B3, C3 |
| Read, Write | A4, C1, C2, C3, D1, D2 |

---

## 输出文件命名规范

所有 Agent 输出文件遵循统一命名规范多

```
{agent_id}-{output-type}.{json|md}
```

例如多
- `a1-literature-survey.json` + `.md`
- `b1-related-work.json` + `.md`
- `c3-academic-formatter` 不输出（其工作体现在组装的 paper.md）

---

## 激活条件总结

| Agent | 激活条件 | 说明 |
|-------|----------|------|
| A1 | 必选 | 文献调研是所有论文的基础 |
| A3 | 涉及 MAS 且需文献 | 仅在项目深度涉及 MAS 时启动 |
| A4 | 必选 | 创新形式化是 Phase 1 聚合点 |
| B1-B3 | 必选 | Design 阶段的三个 Agent 构成论文设计骨架 |
| C1-C3 | 必选 | Writing 阶段的三个 Agent 完成论文撰写 |
| D1 | 必选 | 评审是质量保障的必需环节 |
| D1-Technical-Expert | 必选 | 技术实现、算法设计、系统架构评审 |
| D1-Domain-Expert | 必选 | 知识图谱、本体工程、应用领域评审 |
| D1-Clarity-Expert | 必选 | 表述清晰度、逻辑流畅性、组织结构评审 |
| D1-Significance-Expert | 必选 | 学术价值、原创性、贡献影响力评审 |
| D1-Writing-Quality-Expert | 必选 | 写作风格、术语使用、语言规范评审 |
| D2 | 分数 < 阈值 | 仅在评审不达标时启动 |

---

## 扩展指南

添加新 Agent 时，需要同步更新以下文件多

1. **创建 Prompt 文件**多在 `agents/{phase}/` 下创建 `{agent-id}-{name}.md`
2. **更新配置**多在 `config.json` 中添加模型和预算配置
3. **更新本目录**多在上述表格中添加新 Agent 的定义
4. **更新架构图**多在 `docs/architecture.md` 中更新数据流图
5. **更新 Quality Gate**多在对应 Phase 的 Gate 检查中添加新输出文件
