# 论文工厂：多智能体学术论文生成系统

> 基于 Claude Code Agent Teams 的端到端学术论文自动生成框架

---

## 一句话介绍

通过 **12 个专业化智能体** 分 **4 个阶段** 完成学术论文的全流程生成——从文献调研到同行评审。

---

## 快速开始

1. **准备素材** — 在 `workspace/{project}/input-context.md` 描述项目背景和创新点
2. **启动 Claude Code** — `cd paper-factory && claude`
3. **下达指令** — `我要生成一篇关于 [主题] 的学术论文，素材在 workspace/[project]/input-context.md`

详细步骤请查看 [快速开始指南](docs/getting-started.md)。

---

## 系统架构

```
Phase 1: Research  →  A1 文献调研 / A2 工程分析 / A3 理论构建（并行）→ A4 创新形式化
                      ════ Quality Gate 1 ════
Phase 2: Design    →  B1 相关工作 → B2 实验设计 → B3 结构设计（串行）
                      ════ Quality Gate 2 ════
Phase 3: Writing   →  C1 章节撰写 → C2 图表设计 → C3 格式整合（串行）
                      ════ Quality Gate 3 ════
Phase 4: Quality   →  D1 同行评审 ⇄ D2 修订执行（迭代循环）
                      ════ Quality Gate 4 ════
                              ▼
                          output/paper.md
```

详细架构请查看 [架构详解](docs/architecture.md)。

---

## 目录结构

```
paper-factory/
├── CLAUDE.md              # Team Lead 编排指令（系统核心）
├── config.json            # 配置：模型、预算、质量阈值
├── agents/                # 12 个 Agent 系统提示
│   ├── phase1/            # A1-A4
│   ├── phase2/            # B1-B3
│   ├── phase3/            # C1-C3
│   └── phase4/            # D1-D2
├── docs/                  # 完整文档
├── workspace/             # 运行时产物（按项目组织）
│   └── {project}/
│       ├── input-context.md
│       ├── phase1/
│       ├── phase2/
│       ├── phase3/
│       ├── phase4/
│       ├── quality-gates/
│       └── output/
│           └── paper.md
└── references/            # 参考资料
```

---

## 技术亮点

- **CLAUDE.md 驱动** — Team Lead 自主编排，无需外部脚本
- **并行 + 串行混合** — Phase 1 并行，Phase 2-4 串行/迭代
- **质量门控** — 每阶段自动验证输出完整性
- **动态调整** — 根据中间结果调整策略（补充搜索、额外修订等）
- **通用框架** — 不绑定特定论文主题，通过 `input-context.md` 适配

---

## 文档导航

| 文档 | 说明 |
|------|------|
| [文档中心](docs/README.md) | 完整文档导航枢纽 |
| [设计理念](docs/design-philosophy.md) | 系统核心思想与设计原则 |
| [快速开始](docs/getting-started.md) | 从准备素材到生成论文 |
| [架构详解](docs/architecture.md) | Pipeline、Agent、Quality Gates |
| [技能目录](docs/skills-catalog.md) | 17 个已安装技能的分类索引 |
| [MCP 工具](docs/mcp-tools.md) | Chrome MCP Server 工具集 |
| [论文索引](docs/papers-index.md) | 历史论文列表与详细信息 |

---

## 核心技能调用

当用户请求"生成论文，project X"时：

1. **验证** `workspace/{project}/input-context.md` 存在且包含必填字段
2. **调用** `Skill(skill="paper-generation", args="{project}")`
3. **编排器** 自动按顺序执行 4 个 Phase，每个 Phase 完成后执行 Quality Gate

---

**最后更新**: 2026-02-13
