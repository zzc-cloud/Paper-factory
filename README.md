# 论文工厂：多智能体学术论文生成系统

> 基于 Claude Code Agent Teams 的端到端学术论文自动生成框架

---

## 项目概述

论文工厂（Paper Factory）是一个多智能体协作系统，通过 **12 个专业化智能体** 分 **4 个阶段** 完成学术论文的全流程生成——从文献调研到同行评审。

系统基于 Claude Code 的 Agent Teams（实验性功能）构建。Team Lead 读取 `CLAUDE.md` 中的编排指令，动态创建和协调 teammate，通过消息传递和文件系统实现 agent 间协作。无需 bash 脚本，无需手动编排。

---

## 前置条件

- **Claude Code**：已安装并可用
- **Agent Teams 功能**：需启用实验性 Agent Teams 支持
  - `.claude/settings.local.json` 中设置 `"CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"`
- **API 额度**：完整 pipeline 预计消耗 ~$41（可通过 `config.json` 调整各 agent 预算）

---

## 系统架构

```
╔══════════════════════════════════════════════════════════════════════════╗
║                   论文工厂系统 — Agent Teams 执行流程                      ║
╠══════════════════════════════════════════════════════════════════════════╣
║                                                                          ║
║  ┌─────────────────────────────────────────────────────────────────┐    ║
║  │  Phase 1: Research（素材收集）                                  │    ║
║  │                                                                 │    ║
║  │  ┌─────────┐  ┌─────────┐  ┌─────────┐                       │    ║
║  │  │   A1    │  │   A2    │  │   A3    │   并行执行            │    ║
║  │  │文献调研 │  │工程分析 │  │理论构建 │                       │    ║
║  │  └────┬────┘  └────┬────┘  └────┬────┘                       │    ║
║  │       └────────────┴────────────┘                              │    ║
║  │                    ▼                                            │    ║
║  │                ┌─────────┐                                     │    ║
║  │                │   A4    │   创新形式化（依赖 A2）             │    ║
║  │                │创新总结 │                                     │    ║
║  │                └────┬────┘                                     │    ║
║  └─────────────────┼───────────────────────────────────────────┘    ║
║                    ▼                                                    ║
║  ════════════════════════════════════════════════════════════════════   ║
║  Quality Gate 1: 验证 Phase 1 全部输出文件                              ║
║  ════════════════════════════════════════════════════════════════════   ║
║                    ▼                                                    ║
║  ┌─────────────────────────────────────────────────────────────────┐    ║
║  │  Phase 2: Design（论文设计）                                    │    ║
║  │                                                                 │    ║
║  │  ┌─────────┐  ┌─────────┐  ┌─────────┐                       │    ║
║  │  │   B1    │→│   B2    │→│   B3    │   严格串行            │    ║
║  │  │相关工作 │  │实验设计 │  │结构设计 │                       │    ║
║  │  └─────────┘  └─────────┘  └─────────┘                       │    ║
║  └─────────────────┼───────────────────────────────────────────┘    ║
║                    ▼                                                    ║
║  ════════════════════════════════════════════════════════════════════   ║
║  Quality Gate 2: 验证 Phase 2 全部输出文件                              ║
║  ════════════════════════════════════════════════════════════════════   ║
║                    ▼                                                    ║
║  ┌─────────────────────────────────────────────────────────────────┐    ║
║  │  Phase 3: Writing（论文撰写）                                   │    ║
║  │                                                                 │    ║
║  │  ┌─────────┐  ┌─────────┐  ┌─────────┐                       │    ║
║  │  │   C1    │→│   C2    │→│   C3    │   串行执行            │    ║
║  │  │章节写作 │  │图表设计 │  │格式整合 │                       │    ║
║  │  └─────────┘  └─────────┘  └─────────┘                       │    ║
║  └─────────────────┼───────────────────────────────────────────┘    ║
║                    ▼                                                    ║
║  ════════════════════════════════════════════════════════════════════   ║
║  Quality Gate 3: 验证所有章节 + 图表 + 最终论文                         ║
║  ════════════════════════════════════════════════════════════════════   ║
║                    ▼                                                    ║
║  ┌─────────────────────────────────────────────────────────────────┐    ║
║  │  Phase 4: Quality（质量评审）                                   │    ║
║  │                                                                 │    ║
║  │  ┌─────────┐  ┌─────────┐                                     │    ║
║  │  │   D1    │→│   D2    │   迭代循环                          │    ║
║  │  │同行评审 │  │修订执行 │   直到评分达标或达到最大轮次        │    ║
║  │  └─────────┘  └─────────┘                                     │    ║
║  └─────────────────┼───────────────────────────────────────────┘    ║
║                    ▼                                                    ║
║  ════════════════════════════════════════════════════════════════════   ║
║  Quality Gate 4: 验证评审报告 + 最终论文                                ║
║  ════════════════════════════════════════════════════════════════════   ║
║                    ▼                                                    ║
║                 ┌─────────┐                                            ║
║                 │ 最终论文 │                                            ║
║                 │paper.md │                                            ║
║                 └─────────┘                                            ║
║                                                                          ║
╚══════════════════════════════════════════════════════════════════════════╝
```

---

## 4 个执行阶段 x 12 个智能体

### Phase 1: Research 素材收集
- **A1** Literature Surveyor — 文献调研：搜索并整理相关学术论文
- **A2** Engineering Analyst — 工程分析：深度分析目标代码库/系统
- **A3** MAS Theorist — 理论构建：研究多智能体系统理论框架
- **A4** Innovation Formalizer — 创新形式化：将工程创新转化为学术贡献

### Phase 2: Design 论文设计
- **B1** Related Work Analyst — 相关工作分析：系统定位与差异化
- **B2** Experiment Designer — 实验设计：基线对比与消融实验方案
- **B3** Paper Architect — 结构设计：完整论文大纲与字数规划

### Phase 3: Writing 论文撰写
- **C1** Section Writer — 章节撰写：按大纲逐章生成内容
- **C2** Visualization Designer — 图表设计：生成论文所需图表
- **C3** Academic Formatter — 格式整合：组装最终论文

### Phase 4: Quality 质量评审
- **D1** Peer Reviewer — 同行评审：多视角学术评审
- **D2** Revision Specialist — 修订执行：根据评审意见修订论文

---

## 目录结构

```
paper-factory/
├── CLAUDE.md                          # Team Lead 编排指令（核心）
├── config.json                        # 配置：模型、预算、质量阈值
├── agents/                            # 12 个 agent 系统提示
│   ├── phase1/                        # Research: A1-A4
│   │   ├── a1-literature-surveyor.md
│   │   ├── a2-engineering-analyst.md
│   │   ├── a3-mas-theorist.md
│   │   └── a4-innovation-formalizer.md
│   ├── phase2/                        # Design: B1-B3
│   │   ├── b1-related-work-analyst.md
│   │   ├── b2-experiment-designer.md
│   │   └── b3-paper-architect.md
│   ├── phase3/                        # Writing: C1-C3
│   │   ├── c1-section-writer.md
│   │   ├── c2-visualization-designer.md
│   │   └── c3-academic-formatter.md
│   └── phase4/                        # Quality: D1-D2
│       ├── d1-peer-reviewer.md
│       └── d2-revision-specialist.md
├── .claude/
│   └── settings.local.json            # Agent Teams 启用 + 工具权限
├── workspace/                         # 运行时产物（按项目组织）
│   └── {project-name}/
│       ├── input-context.md           # 用户提供的项目素材
│       ├── phase1/                    # A1-A4 输出
│       ├── phase2/                    # B1-B3 输出
│       ├── phase3/
│       │   ├── sections/              # 各章节
│       │   └── figures/               # 图表
│       ├── phase4/                    # D1-D2 输出
│       ├── quality-gates/             # 门控记录
│       └── output/
│           └── paper.md               # 最终论文
├── papers/                            # 历史论文存档
└── references/                        # 参考资料
```

---

## 使用方法

### 1. 准备输入素材

在 `workspace/{project-name}/` 下创建 `input-context.md`，包含：

- 论文主题和工作标题
- 目标系统/代码库路径（如有）
- 创新点列表
- 系统架构概述
- 关键术语定义

### 2. 启动 Claude Code

```bash
cd paper-factory
claude
```

### 3. 下达指令

在 Claude Code 中输入：

```
我要生成一篇关于 [你的主题] 的学术论文。
素材在 workspace/[project-name]/input-context.md。
请按 pipeline 开始。
```

Team Lead 会自动读取 `CLAUDE.md`，按 4 阶段 pipeline 创建 agent team 并推进全流程。

---

## 配置说明

`config.json` 包含系统的核心配置：

```json
{
  "models": {
    "reasoning": "opus",
    "writing": "sonnet"
  },
  "agents": {
    "a1": { "model": "writing",   "budget": 3, "tools": ["WebSearch", "WebFetch", "Read", "Write"] },
    "a2": { "model": "reasoning", "budget": 5, "tools": ["Read", "Glob", "Grep", "Write", "Bash"] },
    "a3": { "model": "reasoning", "budget": 4, "tools": ["WebSearch", "WebFetch", "Read", "Write"] },
    "a4": { "model": "reasoning", "budget": 3, "tools": ["Read", "Write"] },
    "b1": { "model": "reasoning", "budget": 3, "tools": ["Read", "Write", "WebSearch"] },
    "b2": { "model": "reasoning", "budget": 3, "tools": ["Read", "Write"] },
    "b3": { "model": "reasoning", "budget": 4, "tools": ["Read", "Write"] },
    "c1": { "model": "writing",   "budget": 2, "tools": ["Read", "Write"] },
    "c2": { "model": "writing",   "budget": 3, "tools": ["Read", "Write"] },
    "c3": { "model": "writing",   "budget": 2, "tools": ["Read", "Write", "Glob"] },
    "d1": { "model": "reasoning", "budget": 5, "tools": ["Read", "Write"] },
    "d2": { "model": "reasoning", "budget": 4, "tools": ["Read", "Write"] }
  },
  "quality": {
    "min_papers": 30,
    "min_review_score": 7,
    "max_review_iterations": 3
  },
  "paper": {
    "target_word_count": 10000
  }
}
```

配置项说明：
- **models** — 模型别名映射，reasoning 用于深度分析，writing 用于内容生成
- **agents** — 每个 agent 的模型选择、预算上限（美元）、可用工具列表
- **quality** — 质量门控阈值：最少文献数、最低评审分数、最大评审迭代次数
- **paper** — 论文参数：目标字数

---

## 技术亮点

### 1. CLAUDE.md 驱动的智能编排

Team Lead 读取 `CLAUDE.md` 获取完整的 pipeline 定义，自主决定何时创建 teammate、如何分配任务、何时推进到下一阶段。无需外部脚本控制流程。

### 2. Agent 间消息传递

Agent Teams 支持 teammate 之间的直接消息通信。Team Lead 可以向 teammate 发送指令、接收完成通知，teammate 之间也可以协调工作。

### 3. 并行 + 串行混合执行

- Phase 1: A1/A2/A3 **并行执行**（无依赖关系，同时启动）
- Phase 2-4: 串行执行（有明确的数据依赖链）
- Phase 4: D1/D2 **迭代循环**（评审-修订直到达标）

### 4. 动态调整能力

Team Lead 可以根据中间结果动态调整策略：
- 文献不足时要求 A1 补充搜索
- 评审分数不达标时启动额外修订轮次
- 某个 agent 失败时决定重试或跳过

### 5. 质量门控

每个阶段结束后自动验证输出文件完整性，结果记录到 `quality-gates/gate-{N}.json`，确保 pipeline 可靠推进。

### 6. 通用框架

不绑定特定论文主题。通过 `input-context.md` 提供任意项目的素材，系统自动适配。

---

## 项目适用性

论文工厂适用于为技术项目生成学术论文草稿：

1. 准备 `input-context.md` 描述项目背景和创新点
2. 系统自动完成文献调研、工程分析、理论构建
3. 设计实验方案和论文结构
4. 逐章撰写并组装完整论文
5. 多轮评审迭代提升质量

适合的场景：开源项目论文化、系统设计论文、技术架构论文、多智能体系统研究等。

---

## 已生成论文

| # | 标题 | 评分 | 日期 |
|---|------|------|------|
| 001 | Cognitive Hub: A Multi-Agent Architecture for Ontology-Driven Natural Language Data Querying at Enterprise Scale | 7.3/10 | 2025 |

详细内容请查看 [papers/](papers/) 目录。

---

**最后更新**: 2026-02-11
