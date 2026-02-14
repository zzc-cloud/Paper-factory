# 论文工厂：多智能体学术论文生成系统

> 基于 Claude Code Skill + Agent 混合架构的端到端学术论文自动生成框架

---

## 一句话介绍

通过 **11 个专业化智能体** 分 **4 个阶段** 完成学术论文的全流程生成——从文献调研到同行评审。

---

## 快速开始

1. **准备素材** — 在 `workspace/{project}/input-context.md` 描述项目背景和创新点
2. **启动 Claude Code** — `cd paper-factory && claude`
3. **下达指令** — `我要生成一篇关于 [主题] 的学术论文，素材在 workspace/[project]/input-context.md`

详细步骤请查看 [快速开始指南](docs/getting-started.md)。

---

## 系统架构

```
[codebase-analyzer] → 生成 input-context.md（前置工具，可选）
                              ↓
Phase 0: Startup   →  期刊选择 → 题目确认 → 摘要框架确认（交互式）
                      ════ 用户确认 ════
Phase 1: Research  →  A1 文献调研 / A3 理论构建（并行）→ A4 创新形式化
                      ════ Quality Gate 1 ════
Phase 2: Design    →  B1 相关工作 → B2 实验设计 → B3 结构设计（串行）
                      ════ Quality Gate 2 ════ + 大纲确认
Phase 3: Writing   → C1 章节撰写 → C2 图表设计 → C3 格式整合（串行）
                      ════ Quality Gate 3 ════
Phase 4: Quality   → D1 同行评审 ⇄ D2 修订执行（迭代循环）
                      ════ Quality Gate 4 ════
                              ▼
                          output/paper.md
```

**并行执行优化**：Phase 1 支持真正的并行执行模式（通过 `config.json` 配置），预期能减少 40-60% 的执行时间。详见 [Phase 1 并行执行优化](docs/phase1-parallel-optimization.md)。

详细架构请查看 [架构详解](docs/architecture.md)。

---

## 11 个智能体

| Phase | Agent | 角色 | 模型 |
|-------|---------|-------|--------|
| Research | A1 | 文献调研 | Sonnet |
| Research | A3 | 理论构建 | Opus   |
| Research | A4 | 创新形式化 | Opus   |
| Design  | B1 | 相关工作分析 | Opus   |
| Design  | B2 | 实验设计 | Opus   |
| Design  | B3 | 结构设计 | Opus   |
| Writing | C1 | 章节撰写 | Sonnet  |
| Writing | C2 | 图表设计 | Sonnet  |
| Writing | C3 | 格式整合 | Sonnet  |
| Quality | D1 | 同行评审 | Opus   |
| Quality | D2 | 修订执行 | Opus   |

---

## 目录结构

```
paper-factory/
├── CLAUDE.md              # 系统 编排指令（系统核心）
├── config.json            # 配置：模型、质量阈值、领域映射
├── venues.md              # 会议/期刊配置（所有预定义和用户自定义会议/期刊）
├── .claude/
│   └── skills/           # 技能模块
│   ├── paper-generation/       # 主编排器
│   ├── paper-phase1-research/  # Phase 1 编排
│   ├── paper-phase2-design/     # Phase 2 编排
│   ├── paper-phase3-writing/    # Phase 3 编排
│   ├── paper-phase4-quality/     # Phase 4 编排
│   ├── venue-analyzer/            # 期刊配置解析器
│   ├── interaction-manager/       # 交互管理器
│   ├── feedback-collector/        # 反馈收集器
│   ├── version-manager/         # 版本快照与版本管理
│   ├── domain-knowledge-prep/    # 领域知识准备（引用 review-domain Skills）
│   ├── domain-knowledge-update/  # 领域知识动态更新
│   ├── review-kg-domain/         # KG 领域评审认知框架
│   ├── review-mas-domain/         # MAS 领域评审认知框架
│   ├── review-nl2sql-domain/      # NL2SQL 领域评审认知框架
│   ├── review-bridge-domain/     # Bridge Engineering 领域评审认知框架
│   ├── review-data-domain/       # Data Analysis 领域评审认知框架
│   ├── review-se-domain/         # Software Engineering 领域评审认知框架
│   ├── review-hci-domain/         # HCI 领域评审认知框架
│   ├── cache-utils/             # 论文缓存工具集
│   └── paper-cacher/           # 论文缓存管理
├── agents/                # Agent 系统提示
│   ├── phase1/             # A1, A3-A4
│   ├── phase2/             # B1-B3
│   ├── phase3/             # C1-C3
│   ├── phase4/             # D1（通用评审）+ D2（修订）+ 领域专家
│   ├── docs/                  # 完整文档
├── workspace/             # 运行时产物（按项目组织）
│   └── cache/                # 论文缓存系统
│       └── papers/          # 论文缓存（Markdown + Frontmatter）
│       └── search-history/  # 检索历史（增量更新）
```

使用 Bash 工具配合 `mkdir -p` 实现幂等目录创建。

---

## 技术亮点

- **CLAUDE.md 驱动** — 系统 自主编排，无需外部脚本
- **并行 + 串行混合** — Phase 1 并行，Phase 2-4 串行/迭代
- **质量门控** — 每阶段自动验证输出完整性
- **动态调整** — 根据中间结果调整策略（补充搜索、额外修订等）
- **通用框架** — 不绑定特定论文主题，通过 `input-context.md` 适配
- **论文缓存系统** — 支持增量检索和手动添加，第二次生成速度提升 60-80%
- **版本管理与用户确认** — Phase 4 支持版本快照（V1/V2/V3...）、里程碑确认和人类审稿员反馈注入
- **交互式启动** — Phase 0 支持期刊选择、题目确认、摘要框架确认，减少后期返工
- **期刊属性定位** — 根据目标期刊动态适配格式、风格和内容要求

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
| [用户职责](docs/user-responsibilities.md) | 论文生成前的必要准备 |
| [生成前检查](docs/pre-generation-checklist.md) | 论文生成前的检查清单和用户准备指南 |

---

## 核心技能调用

当用户请求"生成论文，project X"时：

1. **验证** `workspace/{project}/input-context.md` 存在且包含必填字段
2. **调用** `Skill(skill="paper-generation", args="{project}")`
3. **编排器** 自动按顺序执行 4 个 Phase，每个 Phase 完成后执行 Quality Gate

---

**最后更新**: 2026-02-14
