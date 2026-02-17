# Prompt 汇总

> 本文档记录 Paper Factory 项目构建过程中使用的关键 prompt。按迭代阶段组织，每条 prompt 合并多轮交互为最终版。仅供项目维护参考。

---

## 第一阶段：系统初始化（8b37e03）

**1. 项目创建**

> 我有一个 NL2SQL 项目（Smart Query），需要生成一篇学术论文。请设计一个多智能体论文生成系统：12 个专业化 Agent 分 4 阶段（Research → Design → Writing → Quality）协作，用 Bash 编排器 + claude -p 管道模式实现。每个 Agent 有独立的系统提示和输出格式。

**2. 首篇论文生成**

> 基于 workspace/smart-query/ 下的素材，按 pipeline 生成论文。主题：Cognitive Hub - Multi-Agent Architecture for Ontology-Driven NL Data Querying。

---

## 第二阶段：Agent Teams 架构迁移（c5007ca）

**3. 架构迁移**

> 将系统从 Bash 编排器迁移到 Claude Code Agent Teams 架构。用 CLAUDE.md 作为 Team Lead 编排指令取代 orchestrator.sh，用 config.json 取代 config.env。通用化所有 12 个 Agent 的系统提示，去除 Smart Query 硬编码，支持任意论文主题。重组 workspace 为多项目结构。删除所有 bash 脚本。

---

## 第三阶段：Skill 体系构建（ec71d51）

**4. Skill 模块化**

> 将 12 个 Agent 迁移为 paper-* Skill 模块（4 个 Phase Skill + 8 个领域 Skill）。新增通用评审模块（Technical/Novelty/Clarity/Significance/Experimental Rigor 五维度）和 domain-knowledge-prep 技能。构建完整的 docs/ 文档体系。清理过时的技能模块。

**5. Skills 清理**

> 这是一个论文生成项目，请探查 .claude/skills 下所有已安装的 Skills，评估哪些是本项目用不到的，直接剔除。

**6. Skills 安装**

> 从 https://github.com/anthropics/skills 、https://github.com/obra/superpowers 、https://github.com/affaan-m/everything-claude-code 三个仓库中筛选适合本项目的 Skill 并安装。项目使用 Python，目前处于迭代阶段，工程迭代类 Skill 也需要。obra/superpowers 下的 writing-skills 也要装。

**7. 文档模块构建**

> 构建一个 Markdown 格式的 docs/ 文档模块，包含：1. 设计理念 2. 已安装 Skill 列表 3. MCP 工具参考 4. 已生成论文索引。同时将 README.md 中的详细内容迁移到 docs/ 下，README 只保留精简入口。

---
## 第三阶段补充：文档清理（1a8fddc）

**8. 论文目录清理**

> 移除 papers/ 目录，论文历史通过 Git 管理。更新 papers-index.md 添加 Git 历史查询指南，清理 CLAUDE.md 和 README.md 中的 papers/ 引用。

---

## 第四阶段：交互式启动与领域知识系统（9393e13）

**9. Phase 0 交互式启动**

> 新增 Phase 0 交互式启动阶段：期刊选择（venue-analyzer 解析 venues.md）、题目确认（生成 3 个候选）、摘要框架确认。用 AskUserQuestion 实现关键节点的用户确认，减少后期返工。

**10. 期刊配置系统**

> 创建 venues.md 作为会议/期刊配置中心，包含预定义期刊（AAAI、ACL、VLDB 等）的格式要求、写作风格、评审标准。新增 venue-analyzer Skill 解析配置并生成 venue-style-guide.md。

**11. 交互管理组件**

> 新增三个交互管理 Skill：interaction-manager（管理关键交互节点确认）、feedback-collector（结构化存储用户反馈并自动应用到策略）、version-manager（版本快照 V01/V02...、元数据管理、变更日志、版本回滚）。

**12. 领域知识体系**

> 创建 5 个领域知识文档（docs/domain-knowledge/）：KG、MAS、NL2SQL、Bridge、Data。每个文档包含理论分析和评审认知两部分。新增 domain-knowledge-update Skill 通过 Web Search 获取前沿论文并更新领域知识。

**13. 领域评审认知框架**

> 新增 5 个领域评审认知框架 Skill（review-kg-domain、review-mas-domain 等），为 D1 领域评审专家提供特定领域的评审标准和知识注入。

**14. 论文缓存系统**

> 新增 paper-cacher Skill 实现论文缓存系统，支持增量检索和手动添加。缓存格式为 Markdown + Frontmatter，存储在 workspace/{project}/.cache/papers/。第二次生成速度提升 60-80%。

**15. config.json 扩展**

> 扩展 config.json 新增配置项：interaction（交互节点配置）、venue_analysis（期刊分析配置）、versioning（版本管理配置）、confirmation（用户确认模式和阈值）、domain_skills（5 个领域映射含文档路径和关键词）。

---

## 第五阶段：架构精简与统一（97b5cc3）

**16. A2 独立化**

> 将 A2（Engineering Analyst）从 Phase 1 流水线 Agent 移至独立的 codebase-analyzer Skill，作为前置工具。Agent 数量从 12 减至 11。更新所有文档中的 Agent 计数和 A2 相关引用。

**17. 去版本标记**

> 清除所有文档中的版本标记（V2 新增、v1.x、本次更新等），版本历史统一由 git 管理。将 V2 交互式组件（Phase 0、venue-analyzer、interaction-manager、feedback-collector）合并到主文档内容，不再标注为"新增"。

---

## 第六阶段：持续优化

**18. CLAUDE.md 评估与精简**

> 评估 CLAUDE.md 是否内容过多。结论：在迭代开发阶段保留全局架构信息（架构图、Agent 表格、目录结构）有助于每次新对话的即时认知，仅删除营销性质的"技术亮点"和冗余的"一句话介绍"。

**19. 领域评审合并**

> 将 5 个独立的领域评审 Skill（review-kg-domain 等）合并到领域知识文档中，评审认知框架作为文档的一部分而非独立 Skill。D1 领域评审专家直接读取 docs/domain-knowledge/ 下的对应文档。

**20. D1 评审拆分**

> 将 D1 同行评审拆分为 d1-general-reviewer（通用评审：技术、新颖性、清晰度、重要性、实验严谨性五维度）和 d1-reviewer-domain-expert（领域评审：基于特定领域知识深度评审）。Phase 4 动态选择领域专家。

**21. Phase 1 串行化**

> Phase 1 从并行执行改为串行执行（A1 → B1 → 创新聚合）。创新聚合不再作为独立 Agent（原 A4），改由编排器内联执行。简化架构，提高可靠性。

---

## 第七阶段：LaTeX 模板系统与编译流水线

**22. LaTeX 模板系统**

> 研究 OpenPrism 项目的模板系统设计，为 paper-factory 引入 LaTeX 模板库。创建 templates/ 目录，包含 8 个模板（acl, cvpr, neurips, icml, lncs, aaai, acm, arxiv），通过 manifest.json 的 targetVenues 字段实现多对一映射（一个模板服务多个会议）。

**23. C4 LaTeX 编译 Agent**

> 新增 C4 LaTeX 编译专家（c4-latex-compiler Skill），将 Markdown 论文转换为 LaTeX 源码并编译 PDF。支持多引擎（pdflatex/xelatex/lualatex）、自动诊断修复、模板自动选择。Agent 数量从 9 增至 10。

**24. 模板转换工具**

> 新增 template-transfer Skill，支持论文在不同会议/期刊格式间一键转换（如 ACL→AAAI）。

**25. KG 领域模板补全**

> 为知识图谱领域补全 LaTeX 模板：Springer LNCS（ISWC/ESWC/K-CAP）、AAAI Press（AAAI/IJCAI/KR）、ACM（WWW/KDD/TOIS/TKDE/SIGMOD）。venues.md 移除冗余的 template 字段，manifest.json 成为模板查找的唯一数据源。

**26. targetVenues 命名统一**

> 将 manifest.json 中的 venueMapping 字段重命名为 targetVenues，全项目统一更新引用。

---

## 论文生成篇

**标准生成指令**

> 我要生成一篇关于 [主题] 的学术论文，素材在 workspace/[project]/input-context.md，请按 pipeline 开始。

**从代码库生成**

> 我有一个代码库在 [路径]，请先用 codebase-analyzer 生成 input-context.md，然后按 pipeline 生成论文。

**指定期刊生成**

> 生成论文，project: [project]，目标期刊：[期刊名]。

**领域知识更新**

> 更新 [领域] 的领域知识文档，搜索最新的研究进展和前沿论文。

---

## Prompt 汇总

> 新增一个文档，将项目构建和论文生成过程中用到的所有 prompt 汇总留存。每条 prompt 合并多轮交互为一句最终版。

---

**最后更新**: 2026-02-18
