# 论文工厂：多智能体学术论文生成系统

> 一个自动化生成高质量学术论文的多智能体协作系统

---

## 项目概述

"论文工厂"（Paper Factory）是一个创新的多智能体协作系统，旨在自动化学术论文的生成流程。该系统通过 **12 个专业化智能体**的协作，将论文创作过程分解为 **4 个阶段**，实现了从研究素材收集到最终论文生成的端到端自动化。

本系统已成功生成一篇完整的学术论文：

- **标题**: Cognitive Hub: A Multi-Agent Architecture for Ontology-Driven Natural Language Data Querying at Enterprise Scale
- **字数**: ~10,000 字
- **章节**: 7 个主要章节 + 摘要
- **图表**: 6 个图表 + 4 个表格
- **引用**: 35+ 篇学术论文引用
- **最终评分**: 7.3/10 (Minor Revision, Accept-Leaning)

---

## 系统架构

```
╔════════════════════════════════════════════════════════════════════════════╗
║                    论文工厂系统 — 完整执行流程                                 ║
╠════════════════════════════════════════════════════════════════════════════╣
║                                                                             ║
║  ┌───────────────────────────────────────────────────────────────────────┐   ║
║  │  Phase 1: Research (素材收集)                                      │   ║
║  │                                                                     │   ║
║  │  ┌─────────┐  ┌─────────┐  ┌─────────┐                           │   ║
║  │  │   A1    │  │   A2    │  │   A3    │   并行执行                │   ║
║  │  │文献调研 │  │工程分析 │  │理论构建 │                           │   ║
║  │  │35篇论文 │  │7367行代码│  │6种MAS范式│                         │   ║
║  │  └────┬────┘  └────┬────┘  └────┬────┘                           │   ║
║  │       └────────────┴────────────┘                                  │   ║
║  │                      ▼                                              │   ║
║  │                  ┌─────────┐                                        │   ║
║  │                  │   A4    │   创新形式化 (依赖 A2)                 │   ║
║  │                  │创新总结 │   13项创新 → 3-4个贡献主题              │   ║
║  │                  └────┬────┘                                        │   ║
║  └───────────────────┼───────────────────────────────────────────────┘   ║
║                      ▼                                                      ║
║  ═════════════════════════════════════════════════════════════════════════  ║
║  Quality Gate 1: 检查 A1-A4 输出文件 (8个文件) ✅                          ║
║  ═════════════════════════════════════════════════════════════════════════  ║
║                      ▼                                                      ║
║  ┌─────────────────────────────────────────────────────────────────────┐   ║
║  │  Phase 2: Design (论文设计)                                         │   ║
║  │                                                                     │   ║
║  │  ┌─────────┐  ┌─────────┐  ┌─────────┐                           │   ║
║  │  │   B1    │→│   B2    │→│   B3    │   串行执行                │   ║
║  │  │相关工作 │  │实验设计 │  │结构设计 │                           │   ║
║  │  │系统定位 │  │5基线6消融│  │8200字大纲│                         │   ║
║  │  └─────────┘  └─────────┘  └─────────┘                           │   ║
║  └───────────────────┼───────────────────────────────────────────────┘   ║
║                      ▼                                                      ║
║  ═════════════════════════════════════════════════════════════════════════  ║
║  Quality Gate 2: 检查 B1-B3 输出文件 (6个文件) ✅                          ║
║  ═════════════════════════════════════════════════════════════════════════  ║
║                      ▼                                                      ║
║  ┌─────────────────────────────────────────────────────────────────────┐   ║
║  │  Phase 3: Writing (论文撰写)                                        │   ║
║  │                                                                     │   ║
║  │  ┌─────────┐  ┌─────────┐  ┌─────────┐                           │   ║
║  │  │   C1    │  │   C2    │  │   C3    │   串行执行                │   ║
║  │  │章节写作 │  │图表设计 │  │格式整合 │                           │   ║
║  │  │ 7次调用 │  │ 6图4表  │  │最终组装 │                           │   ║
║  │  └─────────┘  └─────────┘  └─────────┘                           │   ║
║  └───────────────────┼───────────────────────────────────────────────┘   ║
║                      ▼                                                      ║
║  ═════════════════════════════════════════════════════════════════════════  ║
║  Quality Gate 3: 检查所有章节和最终论文 (10个文件) ✅                       ║
║  ═════════════════════════════════════════════════════════════════════════  ║
║                      ▼                                                      ║
║  ┌─────────────────────────────────────────────────────────────────────┐   ║
║  │  Phase 4: Quality (质量评审)                                        │   ║
║  │                                                                     │   ║
║  │  ┌─────────┐  ┌─────────┐                                         │   ║
║  │  │   D1    │→│   D2    │   串行执行 (迭代循环)                    │   ║
║  │  │同行评审 │  │修订执行 │   3轮迭代达到 7.3/10                    │   ║
║  │  │3视角评审│  │修订日志 │                                         │   ║
║  │  └─────────┘  └─────────┘                                         │   ║
║  └───────────────────┼───────────────────────────────────────────────┘   ║
║                      ▼                                                      ║
║  ═════════════════════════════════════════════════════════════════════════  ║
║  Quality Gate 4: 检查评审报告和修订记录 ✅                                 ║
║  ═════════════════════════════════════════════════════════════════════════  ║
║                      ▼                                                      ║
║                   ┌─────────┐                                             ║
║                   │ 最终论文 │                                             ║
║                   │paper.md │                                             ║
║                   │~10,000字│                                             ║
║                   └─────────┘                                             ║
║                                                                             ║
╚════════════════════════════════════════════════════════════════════════════╝
```

---

## 4 个执行阶段

### Phase 1: Research 素材收集
- **A1**: Literature Surveyor — 文献调研
- **A2**: Engineering Analyst — 工程分析
- **A3**: MAS Theorist — 理论构建
- **A4**: Innovation Formalizer — 创新形式化

### Phase 2: Design 论文设计
- **B1**: Related Work Analyst — 相关工作分析
- **B2**: Experiment Designer — 实验设计
- **B3**: Paper Architect — 结构设计

### Phase 3: Writing 论文撰写
- **C1**: Section Writer — 章节撰写 (7 次)
- **C2**: Visualization Designer — 图表设计
- **C3**: Academic Formatter — 格式整合

### Phase 4: Quality 质量评审
- **D1**: Peer Reviewer — 同行评审 (多轮迭代)
- **D2**: Revision Specialist — 修订执行

---
### 已生成论文

详细内容请查看 [papers/](papers/) 目录中的独立文档。

---

## 目录结构

## 目录结构

```
research/
├── README.md                    # 本文档 — 项目总览
├── orchestrator.sh              # 主编排脚本
├── config.env                   # 配置文件
│
├── papers/                      # 知识库 — 已生成论文的可读文档
│   └── 001-smart-query-cognitive-hub.md    # 第一篇论文
│
├── agents/                      # 智能体定义 (12个)
│   ├── phase1/                  # Phase 1: Research
│   │   ├── a1-literature-surveyor.md      # 文献调研员
│   │   ├── a2-engineering-analyst.md       # 工程分析员
│   │   ├── a3-mas-theorist.md              # MAS理论家
│   │   └── a4-innovation-formalizer.md    # 创新形式化专家
│   ├── phase2/                  # Phase 2: Design
│   │   ├── b1-related-work-analyst.md     # 相关工作分析员
│   │   ├── b2-experiment-designer.md       # 实验设计员
│   │   └── b3-paper-architect.md           # 论文架构师
│   ├── phase3/                  # Phase 3: Writing
│   │   ├── c1-section-writer.md            # 章节撰写员
│   │   ├── c2-visualization-designer.md    # 可视化设计师
│   │   └── c3-academic-formatter.md        # 学术格式员
│   └── phase4/                  # Phase 4: Quality
│       ├── d1-peer-reviewer.md             # 同行评审员
│       └── d2-revision-specialist.md       # 修订专家
│
├── scripts/                     # 执行脚本
│   ├── run-agent.sh             # 通用智能体执行器
│   ├── run-phase1.sh            # Phase 1 执行脚本
│   ├── run-phase2.sh            # Phase 2 执行脚本
│   ├── run-phase3.sh            # Phase 3 执行脚本
│   ├── run-phase4.sh            # Phase 4 执行脚本
│   └── check-quality-gate.sh    # 质量门控检查
│
├── workspace/                   # 工作空间（各阶段输出）
│   ├── phase1/                  # Phase 1 输出 (8个文件)
│   │   ├── a1-literature-survey.json
│   │   ├── a1-literature-survey.md
│   │   ├── a2-engineering-analysis.json
│   │   ├── a2-engineering-analysis.md
│   │   ├── a3-mas-theory.json
│   │   ├── a3-mas-theory.md
│   │   ├── a4-innovations.json
│   │   └── a4-innovations.md
│   ├── phase2/                  # Phase 2 输出 (6个文件)
│   │   ├── b1-related-work.json
│   │   ├── b1-related-work.md
│   │   ├── b2-experiment-design.json
│   │   ├── b2-experiment-design.md
│   │   ├── b3-paper-outline.json
│   │   └── b3-paper-outline.md
│   ├── phase3/                  # Phase 3 输出 (10个文件)
│   │   ├── sections/
│   │   │   ├── 01-introduction.md
│   │   │   ├── 02-related-work.md
│   │   │   ├── 03-system-architecture.md
│   │   │   ├── 04-theoretical-analysis.md
│   │   │   ├── 05-experiments.md
│   │   │   ├── 06-discussion.md
│   │   │   └── 07-conclusion.md
│   │   └── figures/
│   │       ├── all-figures.md
│   │       └── all-tables.md
│   ├── phase4/                  # Phase 4 输出 (4个文件)
│   │   ├── d1-review-report.json
│   │   ├── d1-review-report.md
│   │   ├── d2-revision-log.json
│   │   └── d2-revision-log.md
│   └── quality-gates/           # 质量门控记录
│       ├── gate-1-complete.json
│       ├── gate-2-complete.json
│       ├── gate-3-complete.json
│       └── gate-4-complete.json
│
├── output/                      # 最终输出
│   └── paper.md                 # 最终论文 (~10,000字)
│
├── logs/                        # 执行日志
│   ├── a1-literature-surveyor.log
│   ├── a2-engineering-analyst.log
│   ├── a3-mas-theorist.log
│   ├── a4-innovation-formalizer.log
│   ├── b1-related-work-analyst.log
│   ├── b2-experiment-designer.log
│   ├── b3-paper-architect.log
│   ├── c1-section-writer.log
│   ├── c2-visualization-designer.log
│   ├── c3-academic-formatter.log
│   ├── d1-peer-reviewer.log
│   └── d2-revision-specialist.log
│
├── references/                  # 参考文档
│   └── smart-query-innovations.md
│
└── README.md                    # 本文档
```

---

## 使用方法

### 运行完整流程

```bash
bash orchestrator.sh
```

### 运行单个阶段

```bash
bash orchestrator.sh --phase 1    # 只运行 Phase 1
bash orchestrator.sh --phase 2    # 只运行 Phase 2
```

### 从指定阶段开始运行

```bash
bash orchestrator.sh --from-phase 2    # 从 Phase 2 运行到结束
```

---

## 配置说明

`config.env` 文件包含系统的核心配置：

```bash
# 路径配置
RESEARCH_DIR="/Users/yyzz/Desktop/MyClaudeCode/research"
SMART_QUERY_DIR="/Users/yyzz/Desktop/MyClaudeCode/smart-query"

# 默认模型
MODEL_REASONING="opus"     # 深度推理任务
MODEL_WRITING="sonnet"     # 写作任务

# 各智能体预算（美元）
BUDGET_A1=3    # Literature Surveyor
BUDGET_A2=5    # Engineering Analyst
BUDGET_A3=4    # MAS Theorist
BUDGET_A4=3    # Innovation Formalizer
BUDGET_B1=3    # Related Work Analyst
BUDGET_B2=3    # Experiment Designer
BUDGET_B3=4    # Paper Architect
BUDGET_C1=2    # Section Writer (per section)
BUDGET_C2=3    # Visualization Designer
BUDGET_C3=2    # Academic Formatter
BUDGET_D1=5    # Peer Reviewer
BUDGET_D2=4    # Revision Specialist

# 质量门控
MIN_PAPERS=30              # Gate 1: 最少文献数量
MIN_REVIEW_SCORE=7         # Gate 4: 最低评审分数
MAX_REVIEW_ITERATIONS=3    # Gate 4: 最大评审迭代次数
```

---

## 技术亮点

### 1. 智能体间文件通信

后续智能体读取前面智能体的 JSON/Markdown 输出，实现跨智能体的知识传递。

### 2. 并行 + 串行混合执行

- Phase 1: A1/A2/A3 **并行执行**（后台进程）
- Phase 2-4: B1-B3、C1-C3、D1-D2 **串行执行**（有依赖关系）

### 3. 依赖管理

通过脚本控制智能体间的依赖关系，例如 A4 必须等待 A2 完成后才执行。

### 4. 质量门控

每个阶段结束后自动检查输出文件完整性，确保流程可靠性。

### 5. 可扩展设计

新增智能体只需：
- 在 `agents/` 目录下创建 `.md` 文件（定义系统提示词）
- 在对应的 `run-phaseN.sh` 中添加执行调用
- 更新 `check-quality-gate.sh` 中的检查逻辑

---

## 项目适用性

本论文工厂是一个通用的学术论文生成系统，可以为任何技术项目生成论文：

1. 提供 `input-context.md` 描述项目创新点
2. 系统自动完成文献调研、工程分析、理论构建、实验设计
3. 生成完整的学术论文草稿
4. 通过多轮评审迭代提升质量

---

## 设计决策

### 为什么不需要 CLAUDE.md？

CLAUDE.md 通常作为项目的全局系统提示词，在每次 LLM 交互时注入。但对于本项目，**不需要** CLAUDE.md，理由如下：

1. **每个智能体已有专门的系统提示词** — 12 个智能体各自有明确的职责定义，无需额外全局上下文
2. **orchestrator.sh 是全局编排器** — 脚本已经定义了完整的执行流程和智能体间关系
3. **保持智能体专注** — 过多的全局上下文可能分散智能体的注意力，降低任务执行质量
4. **README.md 已提供完整文档** — 项目结构和用法已清晰记录

每个智能体通过自己的 `agents/phase*/**.md` 文件获得充分的指令，输入路径在 task prompt 中明确给出。这种设计确保了智能体的"专注"优于"知情"。

---

**最后更新**: 2026-02-11
