# 论文工厂 — 文档中心

论文工厂是一个基于 Claude Code Agent Teams 的多智能体学术论文生成系统。

---

## 新手入门

- [快速开始](getting-started.md) — 5 分钟上手，从准备素材到生成论文
- [设计理念](design-philosophy.md) — 理解系统的核心思想与设计原则

## 系统架构

- [架构详解](architecture.md) — 4 阶段 Pipeline、12 个 Agent、Quality Gates

## 工具与技能

- [已安装技能目录](skills-catalog.md) — 17 个专业技能的分类索引
- [MCP 工具参考](mcp-tools.md) — Chrome MCP Server 工具集

## 论文成果

- [已生成论文索引](papers-index.md) — 历史论文列表与详细信息

---

## 核心文件速查

| 文件 | 说明 |
|------|------|
| `CLAUDE.md` | Team Lead 编排指令（系统核心） |
| `config.json` | 模型、预算、质量阈值配置 |
| `agents/` | 12 个 Agent 系统提示定义 |
| `workspace/` | 运行时产物（按项目组织） |
| `papers/` | 历史论文存档 |

---

## 快速导航

**想要生成论文？** → 从 [快速开始](getting-started.md) 开始

**想要理解系统？** → 阅读 [设计理念](design-philosophy.md) 和 [架构详解](architecture.md)

**想要查看成果？** → 浏览 [已生成论文索引](papers-index.md)

**想要扩展功能？** → 参考 [已安装技能目录](skills-catalog.md) 和 [MCP 工具参考](mcp-tools.md)
