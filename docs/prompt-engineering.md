# Prompt 汇总

> 本文档记录 Paper Factory 项目构建过程中使用的关键 prompt 和架构演进历史。仅供项目维护参考。

---

## 项目构建篇

**1. Skills 清理**

> 这是一个论文生成项目，请探查 .claude/skills 下所有已安装的 Skills，评估哪些是本项目用不到的，直接剔除。

**2. Skills 安装**

> 从 https://github.com/anthropics/skills 、https://github.com/obra/superpowers 、https://github.com/affaan-m/everything-claude-code 三个仓库中筛选适合本项目的 Skill 并安装。项目使用 Python，目前处于迭代阶段，工程迭代类 Skill 也需要。obra/superpowers 下的 writing-skills 也要装。

**3. 文档模块构建**

> 构建一个 Markdown 格式的 docs/ 文档模块，包含多1. 设计理念 2. 已安装 Skill 列表 3. MCP 工具参考 4. 已生成论文索引。同时将 README.md 中的详细内容迁移到 docs/ 下，README 只保留精简入口。

**4. Prompt 汇总**

> 新增一个文档，将项目构建和论文生成过程中用到的所有 prompt 汇总留存。每条 prompt 合并多轮交互为一句最终版。

---

## 论文生成篇

> 我要生成一篇关于 [主题] 的学术论文，素材在 workspace/[project]/input-context.md，请按 pipeline 开始。

---

## 架构演进记录

### 领域知识架构重构

从"双层知识架构"（config.json + Web Search）重构为"单一数据源架构"（review-{domain}-domain Skill）。

**工作内容**多
- 删除 `references/` 和 `workspace/domain-knowledge/` 目录
- 创建 `domain-knowledge-update` Skill（通过 Web Search 直接更新 Skill 文件）
- 简化 `domain-knowledge-prep` Skill（直接读取 review-{domain}-domain/SKILL.md）
- 更新核心文档，移除"静态层/动态层"概念

**技术要点**多
- **单一数据源**多领域知识统一存储在 `review-{domain}-domain/SKILL.md`
- **读写分离**多`domain-knowledge-update` 写入，`domain-knowledge-prep` 读取
- **可自举系统**多通过 Web Search 自动更新 Skill 文件

---

### Phase 4 多视角评审机制

**工作内容**多
- 新增 5 个独立评审专家 Agent
- D2 Revision Specialist 支持与 5 个评审专家的多轮交互与辩论
- paper-phase4-quality Skill 整合专家辩论为评审-修订-辩论迭代循环
- 配置项 `quality.max_response_rounds` 控制每轮迭代的专家回复轮数

---

### Skill 层级架构重构

**工作内容**多
- 4 个 Phase Skill 统一命名为 `paper-phase*` 格式
- 创建主 Orchestrator Skill `paper-generation`（约 350 行）
- architecture.md 从纯 Agent 架构描述重写为 Skill + Agent 混合架构
- 创建完整的 Agent 目录文档（agents-catalog.md）

**技术要点**多
- Skill vs Agent 的分界线多理论分析等轻量任务用 Skill，文献检索等重量任务用 Agent
- Skill 在主会话中同步执行，Agent 作为独立进程异步执行

---

### Phase 4 架构扁平化

**工作内容**多
- 删除冗余的 reviewer 子目录和文件（已由 d1-peer-reviewer.md 内嵌 R1/R2/R3 覆盖）
- 领域评审专家 `d1-reviewer-domain-expert.md` 移至 `agents/phase4/` 根目录
- 更新所有引用路径

**最终结构**多
```
agents/phase4/
├── d1-peer-reviewer.md          # 通用评审（内嵌 R1/R2/R3）
├── d1-reviewer-domain-expert.md   # 领域评审专家（动态 Skill）
└── d2-revision-specialist.md      # 修订专家
```

**技术要点**多
- 扁平化减少不必要的子目录层级
- 领域专家通过 Skill 动态加载，通用专家静态内嵌

---

**最后更新**: 2026-02-14

---

### 论文缓存系统

**工作内容**多
- 创建 `cache-utils` Skill（缓存管理核心：initCache、readPaperCache、writePaperCache、searchWithCache）
- 创建 `paper-cacher` Skill（用户手动添加论文接口）
- 扩展 config.json 的 cache 配置节
- 更新 paper-phase1-research Skill 集成缓存步骤
- 创建用户准备文档（user-responsibilities.md、pre-generation-checklist.md）

**技术要点**多
- **Markdown + Frontmatter 格式**多机器可解析 + 人类可读可编辑
- **增量更新策略**多通过 `processed-ids.txt` 追踪已处理论文
- 第二次生成速度提升 60-80%，WebSearch API 调用减少 70-90%

---

### 文档术语一致性更新

**工作内容**多
- 移除误导性术语："Agent 层s" → "Skill + Agent 混合架构"
- 更新所有核心文档的术语引用
- 术语一致性原则：术语替换遵循"一对多"或"多对一"原则

---

### 会议配置 Markdown 化

**工作内容**多
- 所有会议/期刊配置从 `config.json` 迁移至根目录 `venues.md`
- 包含 10 个预定义会议/期刊配置（AAAI、IJCAI、ACL、EMNLP、ISWC、WWW、KR、AAMAS、TOIS、TKDE）
- 使用 YAML + Markdown 格式，支持用户自定义添加

**技术要点**多
- **单一真相源**多所有会议配置统一管理在 venues.md
- **人类可读**多相比 JSON 更易编辑
- **Git 友好**多用户配置修改与系统配置分离

---

### Phase 1 并行执行优化

**工作内容**多
- 创建 `paper-phase1-parallel` Skill（使用 Task 工具的 `run_in_background` 实现真正并发）
- 扩展 config.json 的 parallel 配置节
- 更新 paper-phase1-research Skill 添加并行模式路由

**技术要点**多
- 通过配置开关 `config.parallel.phase1_enabled` 控制
- 错误隔离：单个 Agent 失败不影响其他 Agent
- Phase 1 执行时间减少 40-60%

---

### 版本管理与用户确认机制

**工作内容**多
- 扩展 config.json 新增 versioning、confirmation、feedback 三个配置节
- 创建 `version-manager` Skill（版本快照创建、比较、回滚、历史显示）
- 修改 Phase 4 Skill 集成版本快照和用户确认
- 增强 D2 修订专家支持用户反馈优先处理

**技术要点**多
- **版本模式**多all / milestones / smart / off
- **确认模式**多full / threshold / skip
- **反馈优先级**多用户反馈高于评审意见

---

### 交互式论文生成流程

**工作内容**多
- 扩展 venues.md 添加 writing_style、review_criteria、historical_data
- 创建 3 个交互式组件 Skill：venue-analyzer、interaction-manager、feedback-collector
- 设计 4 个关键交互节点（Phase 0.1 期刊选择、0.2 题目确认、0.3 摘要框架、2.5 大纲确认）
- 扩展 config.json 新增 interaction、venue_analysis 配置节

**技术要点**多
- **人类在环设计**多通过 AskUserQuestion 工具实现关键节点确认
- **增量架构演进**多Phase 0 插入不影响现有 Phases 1-4
- 早期确认可减少 60-70% 的后期返工成本

---

### A2 重构为独立前置工具

**工作内容**多
- A2（Engineering Analyst）从 Phase 1 流水线 Agent 移至独立 `codebase-analyzer` Skill
- 系统从 12 个 Agent 精简为 11 个
- 更新所有文档中的 Agent 计数和 A2 引用

**技术要点**多
- A2 仅在用户没有 `input-context.md` 但有代码库时使用
- 作为前置工具不计入流水线 Agent
