# Agent 目录

本文档列出 Paper Factory 系统中所有 10 个 Agent 的完整定义、职责和配置信息。

---

## 快速索引

| Phase | Agent | 角色 | 模型 | 预算 |
|-------|--------|------|------|----------|
| Phase 1 | A1 | 文献调研 | Opus | $3 |
| Phase 1 | B1 | 相关工作分析 | Opus | $3 |
| Phase 2 | B2 | 实验设计 | Opus | $3 |
| Phase 2 | B3 | 论文架构设计 | Opus | $4 |
| Phase 3 | C1 | 章节撰写 | Sonnet | $2 |
| Phase 3 | C2 | 可视化设计 | Sonnet | $3 |
| Phase 3 | C3 | 学术格式化 | Sonnet | $2 |
| Phase 3 | C4 | LaTeX 编译 | Sonnet | $2 |
| Phase 4 | D1 | 同行评审 | Opus | $5 |
| Phase 4 | D1-Domain-Expert | 领域评审专家（动态选择） | Opus | $3 |
| Phase 4 | D2 | 修订执行 | Opus | $4 |

> **前置工具**：codebase-analyzer 已从 Phase 1 移至独立的 Skill，不计入流水线 Agent。

---

## Phase 1: Research Agents

### A1 - Literature Surveyor（文献调研专家）

**Skill**：`Skill(skill="a1-literature-surveyor", args="{project}")`

**核心职责**：
- 搜索并分类整理 40+ 篇相关学术论文
- 提取文献元数据：标题、作者、会议/期刊、年份、引用
- 输出结构化的文献调研报告供下游使用

**输入**：
- `workspace/{project}/input-context.md`

**输出**：
- `workspace/{project}/phase1/a1-literature-survey.json`
- `workspace/{project}/phase1/a1-literature-survey.md`

**工具**：WebSearch, WebFetch, Read, Write

**激活**：必选（始终启动）

---
### B1 - Related Work Analyst（相关工作分析专家）

**Skill**：`Skill(skill="b1-related-work-analyst", args="{project}")`

**核心职责**：
- 对比分析现有工作，定位本研究的创新点
- 识别研究空白和机会
- 构建相关工作章节的学术叙事

**输入**：
- `workspace/{project}/phase1/a1-literature-survey.json`
- `workspace/{project}/input-context.md`

**输出**：
- `workspace/{project}/phase1/b1-related-work.json`
- `workspace/{project}/phase1/b1-related-work.md`

**工具**：Read, Write, WebSearch

**激活**：必选（始终启动）

---

## Phase 2: Design Agents

### B2 - Experiment Designer（实验设计专家）

**Skill**：`Skill(skill="b2-experiment-designer", args="{project}")`

**核心职责**：
- 设计对比实验方案
- 选择评价指标和基线方法
- 预测实验结果趋势

**输入**：
- Phase 1 全部输出
- `workspace/{project}/input-context.md`

**输出**：
- `workspace/{project}/phase2/b2-experiment-design.json`
- `workspace/{project}/phase2/b2-experiment-design.md`

**工具**：Read, Write, Glob

**激活**：必选（始终启动）

---

### B3 - Paper Architect（论文架构设计专家）

**Skill**：`Skill(skill="b3-paper-architect", args="{project}")`

**核心职责**：
- 设计论文整体结构和章节大纲
- 分配各章节的内容要点和字数
- 确保论文逻辑流畅、结构完整

**输入**：
- Phase 1 全部输出
- `workspace/{project}/phase2/b2-experiment-design.json`

**输出**：
- `workspace/{project}/phase2/b3-paper-outline.json`
- `workspace/{project}/phase2/b3-paper-outline.md`

**工具**：Read, Write, Glob

**激活**：必选（始终启动）

---
## Phase 3: Writing Agents

### C1 - Section Writer（章节撰写专家）

**Skill**：`Skill(skill="c1-section-writer", args="{project}")`

**核心职责**：
- 按照 B3 大纲逐章节撰写论文内容
- 确保学术语言规范、论证逻辑严密
- 适配目标会议/期刊的写作风格

**输入**：
- Phase 1 + Phase 2 全部输出
- `workspace/{project}/venue-style-guide.md`（如有）

**输出**：
- `workspace/{project}/phase3/sections/sec{N}-{name}.md`

**工具**：Read, Write

**激活**：必选（始终启动）

---

### C2 - Visualization Designer（可视化设计专家）

**Skill**：`Skill(skill="c2-visualization-designer", args="{project}")`

**核心职责**：
- 设计论文中的图表和可视化
- 生成图表描述和数据表格
- 确保图表与文本内容一致

**输入**：
- Phase 2 实验设计
- Phase 3 章节内容

**输出**：
- `workspace/{project}/phase3/figures/all-figures.md`
- `workspace/{project}/phase3/figures/all-tables.md`

**工具**：Read, Write

**激活**：必选（始终启动）

---

### C3 - Academic Formatter（学术格式化专家）

**Skill**：`Skill(skill="c3-academic-formatter", args="{project}")`

**核心职责**：
- 将各章节和图表整合为完整论文
- 统一格式、引用风格、术语
- 生成最终的 `output/paper.md`

**输入**：
- `workspace/{project}/phase3/sections/`
- `workspace/{project}/phase3/figures/`

**输出**：
- `workspace/{project}/output/paper.md`

**工具**：Read, Write, Glob

**激活**：必选（始终启动）

---

### C4 - LaTeX Compiler（LaTeX 编译专家）

**Skill**：`Skill(skill="c4-latex-compiler", args="{project}")`

**核心职责**：
- 将 Markdown 论文转换为 LaTeX 源码
- 根据目标会议/期刊选择正确的 LaTeX 模板
- 编译生成 PDF，支持多引擎和自动诊断修复

**输入**：
- `workspace/{project}/output/paper.md`
- `templates/manifest.json`（模板查找）

**输出**：
- `workspace/{project}/output/paper.tex`
- `workspace/{project}/output/references.bib`
- `workspace/{project}/output/paper.pdf`（如编译成功）
- `workspace/{project}/output/compile-log.json`

**工具**：Read, Write, Bash

**激活**：必选（始终启动）

---
## Phase 4: Quality Agents

### D1 - General Reviewer（通用评审专家）

**Skill**：`Skill(skill="d1-general-reviewer", args="{project}")`

**核心职责**：
- 协调多视角评审，从 5 个通用维度评分（技术、新颖性、清晰度、重要性、实验严谨性）
- 输出结构化评审报告（JSON + Markdown）
- 与 D2 形成迭代修订循环

**评审维度**：
1. Technical Soundness（技术严谨性）
2. Novelty（新颖性）
3. Clarity（清晰度）
4. Significance（重要性与影响力）
5. Experimental Rigor（实验严谨性）

**内置评审视角**：
- R1-Technical：技术深度与方法论严谨性
- R2-Novelty：创新性与学术贡献
- R3-Clarity：表达清晰度与可读性
- R4-Significance：研究重要性与影响力
- R5-Experimental Rigor：实验设计与评估严谨性

**动态领域评审**：Phase 4 编排器会根据论文领域动态 spawn `d1-reviewer-domain-expert` Agent，选择匹配的领域专家进行评审。

**输入**：
- `workspace/{project}/output/paper.md`

**输出**：
- `workspace/{project}/phase4/d1-review-report.json`
- `workspace/{project}/phase4/d1-review-report.md`

**工具**：Read, Write

**激活**：必选（始终启动）

**质量阈值**：`average_score >= 9.0`（可在 config.json 中调整）

---

### D1-Domain-Expert（领域评审专家）

**Skill**：`Skill(skill="d1-reviewer-domain-expert", args="{project}:{domain}")`

**核心职责**：
- 提供特定领域的专业评审视角
- 评估论文在该领域的学术贡献和技术准确性
- 参考 `docs/domain-knowledge/{domain}.md` 中的领域知识

**支持领域**：
- `kg` — 知识图谱
- `mas` — 多智能体系统
- `nl2sql` — 自然语言到 SQL
- `bridge` — 桥梁工程
- `data` — 数据分析与机器学习

**激活**：由 D1 动态选择（基于论文领域自动匹配）

---

### D2 - Revision Specialist（修订执行专家）

**Skill**：`Skill(skill="d2-revision-specialist", args="{project}")`

**核心职责**：
- 读取 D1 评审报告，逐条修复问题
- 修改 `output/paper.md`
- 记录修订日志

**输入**：
- `workspace/{project}/phase4/d1-review-report.json`
- `workspace/{project}/output/paper.md`

**输出**：
- 更新后的 `workspace/{project}/output/paper.md`
- `workspace/{project}/phase4/d2-revision-log.json`
- `workspace/{project}/phase4/d2-revision-log.md`

**工具**：Read, Write

**激活**：条件执行（仅当 D1 评分 < 9.0 时启动）

---

## 工具权限矩阵

| Agent | Read | Write | WebSearch | WebFetch | Glob | Bash |
|-------|------|-------|-----------|----------|------|------|
| A1 | ✅ | ✅ | ✅ | ✅ | - | - |
| B1 | ✅ | ✅ | ✅ | - | - | - |
| B2 | ✅ | ✅ | - | - | ✅ | - |
| B3 | ✅ | ✅ | - | - | ✅ | - |
| C1 | ✅ | ✅ | - | - | - | - |
| C2 | ✅ | ✅ | - | - | - | - |
| C3 | ✅ | ✅ | - | - | ✅ | - |
| C4 | ✅ | ✅ | - | - | - | ✅ |
| D1 | ✅ | ✅ | - | - | - | - |
| D2 | ✅ | ✅ | - | - | - | - |

---

## 扩展指南

### 添加新 Agent

1. 在 `.claude/skills/` 下创建新的 Skill 目录
2. 编写 `SKILL.md`，定义角色、输入、输出、工具权限
3. 在 `config.json` 的 `agents` 节中注册
4. 在对应 Phase Skill 中添加调用逻辑

### 添加新领域评审

1. 在 `docs/domain-knowledge/` 下创建新的领域知识文档
2. 在 `config.json` 的 `domain_skills` 中注册领域映射
3. D1 会自动根据关键词匹配新领域

---

**最后更新**: 2026-02-18
