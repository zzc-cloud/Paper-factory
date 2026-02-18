# 论文工厂：多智能体学术论文生成系统

> 基于 Claude Code Skill + Agent 混合架构的端到端学术论文自动生成框架

---

## 快速开始

1. **准备素材** — 在 `workspace/{project}/input-context.md` 描述项目背景和创新点
2. **启动 Claude Code** — `cd paper-factory && claude`
3. **下达指令** — `我要生成一篇关于 [主题] 的学术论文，素材在 workspace/[project]/input-context.md`

详细步骤请查看 [快速开始指南](docs/getting-started.md)。

---

## 系统架构

```
[前置工具] codebase-analyzer / research-ideation / research-interview → 生成 input-context.md（可选）
                                    ↓
[Pre-Phase 0] requirements-spec → 需求澄清（可选，当指令模糊时触发）
                                    ↓
Phase 0: Startup   →  期刊选择 → 题目确认 → 摘要框架确认（交互式）
                      ════ 用户确认 ════
Phase 1: Research  →  A1 文献调研 → B1 相关工作分析 → 创新聚合（内联）
                      ════ Quality Gate 1 (quality-scorer) ════
Phase 2: Design    →  B2 实验设计 → B3 结构设计 → 大纲确认 → devils-advocate
                      ════ Quality Gate 2 (quality-scorer) ════
Phase 3: Writing   →  C1 章节撰写 → C2 图表设计 → C3 格式整合 → C4 LaTeX编译（串行）
                      ════ Quality Gate 3 (quality-scorer) ════
Phase 4: Quality   →  D1 同行评审 ⇄ D2 修订执行（迭代循环）
                      ════ Quality Gate 4 (quality-scorer) ════
                              ▼
                    output/paper.md + paper.tex + paper.pdf
```

**串行执行** Phase 1 采用串行执行模式（A1 → B1 → 创新聚合），简化架构，提高可靠性。创新聚合不再作为独立 Agent，而是由编排器内联执行。

详细架构请查看 [架构详解](docs/architecture.md)。

---

## 10 个智能体

| Phase | Agent | 角色 | 模型 |
|-------|---------|-------|--------|
| Research | A1 | 文献调研（含 arXiv API） | Opus |
| Research | B1 | 相关工作分析 | Opus |
| Design  | B2 | 实验设计   | Opus   |
| Design  | B3 | 结构设计   | Opus   |
| Writing | C1 | 章节撰写   | Sonnet  |
| Writing | C2 | 图表设计   | Sonnet  |
| Writing | C3 | 格式整合   | Sonnet  |
| Writing | C4 | LaTeX 编译 | Sonnet  |
| Quality | D1 | 同行评审   | Opus   |
| Quality | D2 | 修订执行   | Opus   |

> **前置工具**：`codebase-analyzer` — 从代码库自动生成 input-context.md（独立 Skill，不计入流水线 Agent）
> **后置工具**：`template-transfer` — 将论文从一个会议格式转换为另一个格式（独立 Skill，按需调用）
> **研究增强**：`research-ideation` — 从模糊主题生成研究方向 | `research-interview` — 结构化访谈提炼研究规范 | `requirements-spec` — 需求澄清协议
> **质量增强**：`quality-scorer` — 量化评分引擎 | `devils-advocate` — 批判性审查 | `exploration-manager` — 探索沙箱

---

## 目录结构

```
paper-factory/
├── CLAUDE.md              # 系统 编排指令（系统核心）
├── config.json            # 配置多模型、质量阈值、领域映射
├── venues.md              # 会议/期刊配置（所有预定义和用户自定义会议/期刊）
├── templates/             # LaTeX 模板库
│   ├── manifest.json      # 模板清单（含 targetVenues）
│   ├── acl/               # ACL/EMNLP/NAACL 模板
│   ├── cvpr/              # CVPR/ICCV/ECCV 模板
│   ├── neurips/           # NeurIPS 模板
│   ├── icml/              # ICML 模板
│   ├── lncs/              # Springer LNCS 模板（ISWC/ESWC/K-CAP）
│   ├── aaai/              # AAAI Press 模板（AAAI/IJCAI/KR）
│   ├── acm/               # ACM 模板（WWW/KDD/TOIS/TKDE/SIGMOD）
│   └── arxiv/             # arXiv 通用模板（默认）
├── .claude/
│   └── skills/           # 技能模块
│       ├── paper-generation/      # 主编排器
│       ├── paper-phase1-research/
│       ├── paper-phase2-design/
│       ├── paper-phase3-writing/
│       ├── paper-phase4-quality/
│       ├── codebase-analyzer/         # 代码库分析工具（前置工具）
│       ├── venue-analyzer/            # 期刊配置解析器（含模板关联）
│       ├── interaction-manager/       # 交互管理器
│       ├── feedback-collector/        # 反馈收集器（人类审稿员）
│       ├── version-manager/         # 版本快照与版本管理
│       ├── domain-knowledge-update/  # 领域知识动态更新
│       ├── template-transfer/         # 模板转换（会议格式一键切换）
│       ├── a1-literature-surveyor/    # A1 文献调研专家（含 arXiv API）
│       ├── b1-related-work-analyst/   # B1 相关工作分析专家
│       ├── b2-experiment-designer/    # B2 实验设计专家
│       ├── b3-paper-architect/        # B3 论文架构设计专家
│       ├── c1-section-writer/         # C1 章节撰写专家
│       ├── c2-visualization-designer/ # C2 可视化设计专家
│       ├── c3-academic-formatter/     # C3 学术格式化专家
│       ├── c4-latex-compiler/         # C4 LaTeX 编译专家（含诊断修复）
│       ├── d1-general-reviewer/          # D1 通用评审专家
│       ├── d1-reviewer-domain-expert/ # D1 领域评审专家
│       ├── d2-revision-specialist/    # D2 修订执行专家
│       └── ...其他技能
├── docs/                  # 完整文档
│   └── domain-knowledge/  # 领域知识文档（5 个领域，纯 Markdown）
│       ├── mas.md         # MAS 领域知识（理论 + 评审）
│       ├── kg.md          # KG 领域知识（理论 + 评审）
│       ├── nl2sql.md      # NL2SQL 领域知识（理论 + 评审）
│       ├── bridge.md      # Bridge 领域知识（理论 + 评审）
│       └── data.md        # Data 领域知识（理论 + 评审）
├── workspace/             # 运行时产物（按项目组织）
│   └── {project}/
│       ├── input-context.md
│       ├── phase0/
│       │   ├── venue-analysis.json
│       │   ├── title-options.json
│       │   └── abstract-framework.md
│       ├── venue-style-guide.md
│       ├── user-feedback.json
│       ├── phase1/
│       ├── phase2/
│       ├── phase3/
│       ├── phase4/
│       ├── quality-gates/
│       ├── .cache/            # 论文缓存系统
│       │   ├── papers/          # 论文缓存（Markdown + Frontmatter）
│       │   └── search-history/  # 检索历史（增量更新）
│       ├── versions/          # 版本管理目录
│       │   ├── meta.json      # 版本索引
│       │   ├── V01/            # 版本快照
│       │   ├── V02/            # 版本快照
│       │   └── ...
│       └── output/
│           ├── paper.md       # Markdown 论文
│           ├── paper.tex      # LaTeX 源码（C4 输出）
│           ├── references.bib # BibTeX 参考文献（C4 输出）
│           ├── paper.pdf      # PDF（如编译成功）
│           └── compile-log.json # 编译报告
```

使用 Bash 工具配合 `mkdir -p` 实现幂等目录创建。

---

## 文档导航

| 文档 | 说明 |
|------|------|
| [文档中心](docs/README.md) | 完整文档导航枢纽 |
| [配置参考](docs/config-reference.md) | config.json 完整配置指南 |
| [设计理念](docs/design-philosophy.md) | 系统核心思想与设计原则 |
| [快速开始](docs/getting-started.md) | 从准备素材到生成论文 |
| [架构详解](docs/architecture.md) | Pipeline、Agent、Quality Gates |
| [技能目录](docs/skills-catalog.md) | 已安装技能的分类索引 |
| [MCP 工具](docs/mcp-tools.md) | Chrome MCP Server 工具集 |
| [论文索引](docs/papers-index.md) | 历史论文列表与详细信息 |

---

## 核心技能调用

当用户请求"生成论文，project X"时：

1. **验证** `workspace/{project}/input-context.md` 存在且包含必填字段
2. **调用** `Skill(skill="paper-generation", args="{project}")`
3. **编排器** 自动按顺序执行 4 个 Phase，每个 Phase 完成后执行 Quality Gate

---

**最后更新**: 2026-02-18
