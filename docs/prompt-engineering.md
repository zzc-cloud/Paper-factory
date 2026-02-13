# Prompt 汇总

Paper Factory 项目构建过程中使用的 prompt，每条都是将多轮交互合并后的最终版。

---

## 项目构建篇

**1. Skills 清理**

> 这是一个论文生成项目，请探查 .claude/skills 下所有已安装的 Skills，评估哪些是本项目用不到的，直接剔除。

**2. Skills 安装**

> 从 https://github.com/anthropics/skills 、https://github.com/obra/superpowers 、https://github.com/affaan-m/everything-claude-code 三个仓库中筛选适合本项目的 Skill 并安装。项目使用 Python，目前处于迭代阶段，工程迭代类 Skill 也需要。obra/superpowers 下的 writing-skills 也要装。

**3. 文档模块构建**

> 构建一个 Markdown 格式的 docs/ 文档模块，包含：1. 设计理念 2. 已安装 Skill 列表 3. MCP 工具参考 4. 已生成论文索引。同时将 README.md 中的详细内容迁移到 docs/ 下，README 只保留精简入口。

**4. Prompt 汇总**

> 新增一个文档，将项目构建和论文生成过程中用到的所有 prompt 汇总留存。每条 prompt 合并多轮交互为一句最终版。

---

## 论文生成篇（待补充）

> 我要生成一篇关于 [主题] 的学术论文，素材在 workspace/[project]/input-context.md，请按 pipeline 开始。

---

> 每完成一个阶段，在此追加对应的 prompt。

**最后更新**: 2026-02-13

---

## 知识库更新篇

> Skill 层级架构重构 + 知识库文档全面更新

**背景**：继 v1.1 统一 Phase Skill 命名后，进行更全面的知识库同步更新。

**工作内容**：

1. **Skill 命名统一**：
   - 4 个 Phase Skill 重命名为 `paper-phase*-re/design/writing/quality` 格式
   - 创建 backup 目录保留原版本，验证后清理

2. **主 Orchestrator Skill 创建**：
   - 创��� `.claude/skills/paper-generation/SKILL.md`（约 350 行中文内容）
   - 定义完整的 4-Phase 编排流程、Quality Gate 协议、Teammate 生成协议

3. **architecture.md 完全重写**：
   - 从纯 Agent 架构描述（427 行）→ Skill + Agent 混合架构（约 500 行）
   - 新增：分层架构设计原则、Skill 层详解、Agent 层详解、两种通信模式对比、架构优势总结

4. **agents-catalog.md 新建**：
   - 创建完整的 12 个 Agent 目录文档
   - 包含每个 Agent 的：角色、Prompt 文件路径、模型、预算、输入/输出、激活条件

5. **getting-started.md 更新**：
   - 更新启动方式说明：从 "Claude Code 直接执行 pipeline" → "通过 Skill 层级调用管理流程"

6. **skills-catalog.md 重构**：
   - 新建 4 个领域 Skill 目录和 SKILL.md 文件
   - 更新 Skill 注册表，反映新命名规范

**技术要点**：
- Skill vs Agent 的分界线：理论分析等轻量任务用 Skill，文献检索等重量任务用 Agent
- Skill 在 Team Lead 主会话中同步执行，Agent 作为独立进程异步执行
- 所有路径使用绝对路径，避免工作目录问题

---

## 知识库更新篇

> Skill 层级架构重构 + 知识库文档全面更新

**背景**：继 v1.1 统一 Phase Skill 命名后，进行更全面的知识库同步更新。

**工作内容**：

1. **Skill 命名统一**：
   - 4 个 Phase Skill 重命名为 `paper-phase*-re/design/writing/quality` 格式
   - 创建 backup 目录保留原版本，验证后清理
   - 新建 4 个 Phase Skill 目录和 SKILL.md 文件
   - 更新 [skills-catalog.md](skills-catalog.md) 反映新架构

2. **主 Orchestrator Skill 创建**：
   - 创��� `.claude/skills/paper-generation/SKILL.md`（约 350 行中文内容）
   - 定义完整的 4-Phase 编排流程、Quality Gate 协议、Teammate 生成协议
   - 作为主编排器，管理论文生成的完整生命周期

3. **architecture.md 完全重写**：
   - 从纯 Agent 架构描述（427 行）→ Skill + Agent 混合架构（约 500 行）
   - 新增内容：
     - 分层架构��计原则（Orchestrator / Phase / Domain Skills / Agent Teams）
     - Skill 层详解（paper-generation + 4 个 paper-phase* + 4 个 research-*）
     - Agent 层详解（12 个 Agent 的完整列表、工具权限、激活条件）
     - 两种通信模式对比（Skill 同步 vs Agent 异步）
     - 架构优势总结（任务分类、执行效率、扩展性、LLM 自主决策）
   - ASCII 流程图展示完整调用链路

4. **agents-catalog.md ��建**：
   - 创建完整的 12 个 Agent 目录文档
   - 包含每个 Agent 的：角色、Prompt 文件路径、模型、预算、输入/输出
   - 工具权限汇总表
   - 激活条件说明
   - 输出文件命名规范
   - 扩展指南

5. **getting-started.md 更新**：
   - 更新启动方式说明：从 "Claude Code 直接执行 pipeline" → "通过 Skill 层级调用管理流程"
   - 强调 Skill 调用方式：`Skill(skill="paper-generation", args="{project}")`
   - 更新架构模式说明：Skill 同步执行（共享会话上下文）+ Agent 异步执行（文件通信）
   - 新增：混合架构的核心优势说明

6. **docs README.md 验证**：
   - 确认所有交叉引用正确
   - 文档边界清晰

**技术要点**：
- Skill vs Agent 的分界线：理论分析等轻量任务用 Skill，文献检索等重量任务用 Agent
- Skill 在 Team Lead 主会话中同步执行，减少 API 调用开销
- Agent 间通过文件系统异步通信，保持多智能体协作特性

**成果**：
- 知识库文档全面反映 Skill + Agent 混合架构
- 所有文档交叉引用一致
- 版本信息完整（skills-catalog.md v1.1 记录）
