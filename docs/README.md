# 论文工厂 — 文档中心

论文工厂是一个基于 Claude Code Agent Teams 的多智能体学术论文生成系统。

---

## 新手入门

- [快速开始](getting-started.md) — 5 分钟上手，从准备素材到生成论文
- [设计理念](design-philosophy.md) — 理解系统的核心思想与设计原则

## 系统架构

- [架构详解](architecture.md) — 4 阶段 Pipeline、10 个 Agent、Quality Gates

## 工具与技能

- [配置参考](config-reference.md) — config.json 完整配置指南（模型、质量阈值、缓存策略、版本管理、用户确认、领域映射）
- [已安装技能目录](skills-catalog.md) — 专业技能的分类索引（含 5 个领域知识文档、版本管理器）
- [MCP 工具参考](mcp-tools.md) — Chrome MCP Server 工具集
- [Agent 目录](agents-catalog.md) — 10 个 Agent 的完整定义与配置
- [Prompt 工程历史](prompt-engineering.md) — 项目构建过程中的关键 prompt 汇总

## 论文成果

- [已生成论文索引](papers-index.md) — 历史论文列表与详细信息

---

## 核心文件速查

| 文件 | 说明 |
|------|------|
| `CLAUDE.md` | 系统 编排指令（系统核心） |
| `config.json` | 模型、预算、质量阈值、并行执行配置 |
| `.claude/skills/` | Skill 层 — 11 个 Agent Skill + 5 个编排器 + 31 个辅助/工具 Skill |
| `workspace/` | 运行时产物（按项目组织） |

---

## 快速导航

**想要生成论文？** → 从 [快速开始](getting-started.md) 开始

**想要理解系统？** → 阅读 [设计理念](design-philosophy.md) 和 [架构详解](architecture.md)

**想要查看成果？** → 浏览 [已生成论文索引](papers-index.md)

**想要扩展功能？** → 参考 [已安装技能目录](skills-catalog.md)、[MCP 工具参考](mcp-tools.md) 和 [Prompt 工程历史](prompt-engineering.md)
