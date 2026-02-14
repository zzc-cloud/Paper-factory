# Prompt 汇总

> **历史记录**：本文档记录 Paper Factory 项目构建过程中使用的关键 prompt 和架构演进历史。仅供项目维护参考。

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

## 论文生成篇

> 我要生成一篇关于 [主题] 的学术论文，素材在 workspace/[project]/input-context.md，请按 pipeline 开始。

---

## v1.3 - 领域知识架构重构（2026-02-13）

**背景**：从"双层知识架构"（config.json + Web Search）重构为"单一数据源架构"（review-{domain}-domain Skill）。

**工作内容**：

1. **删除未使用的模块**：
   - 删除 `references/` 目录（早期设计遗留）
   - 删除 `workspace/domain-knowledge/` 目录（双重存储已不需要）

2. **创建 domain-knowledge-update Skill**：
   - 文件：`.claude/skills/domain-knowledge-update/SKILL.md`
   - 功能：通过 Web Search 搜索前沿论文，**直接更新** `review-{domain}-domain/SKILL.md`
   - 不再使用中间缓存，直接更新目标 Skill 文件

3. **简化 domain-knowledge-prep Skill**：
   - 移除与 workspace/domain-knowledge 的合并逻辑
   - 直接读取 `review-{domain}-domain/SKILL.md` 文件
   - 生成评审指南 JSON

4. **更新核心文档**：
   - `docs/architecture.md`：移除"静态层/动态层"概念，更新为"单一数据源"
   - `docs/design-philosophy.md`：重写"双层知识体系"为"单一数据源体系"
   - `docs/skills-catalog.md`：更新领域知识技能说明和版本历史
   - `docs/getting-started.md`：移除 config.json 扩展指南

5. **删除过时文档**：
   - 删除 `docs/domain-knowledge-injection-design.md`（设计文档，已完成使命）

**技术要点**：
- **单一数据源**：领域知识统一存储在 `review-{domain}-domain/SKILL.md`
- **读写分离**：`domain-knowledge-update` 写入，`domain-knowledge-prep` 读取
- **可自举系统**：通过 Web Search 自动更新 Skill 文件，实现知识库的前沿性维护
- **Git 追踪**：所有知识更新通过 git commit 追踪历史

**成果**：
- 知识管理架构从"双层存储"简化为"单一数据源"
- 支持自动更新（Web Search）和手动编辑两种方式
- 文档与实现完全一致，无冗余信息

---

## v1.2 - Phase 4 增强专家辩论协作（2026-02-13）

**工作内容**：

1. **新增 5 个独立评审专家 Agent**
2. **D2 Revision Specialist** 支持与 5 个评审专家的多轮交互与辩论
3. **paper-phase4-quality Skill** 整合专家辩论为评审-修订-辩论迭代循环
4. **配置项**：`quality.max_response_rounds` 控制每轮迭代的专家回复轮数
5. 移除 `enable_individual_responses` 开关，专家辩论功能始终启用

---

## v1.1 - Skill 层级架构重构（2026-02-13）

**工作内容**：

1. **Skill 命名统一**：
   - 4 个 Phase Skill 重命名为 `paper-phase*-re/design/writing/quality` 格式
   - 创建 backup 目录保留原版本，验证后清理

2. **主 Orchestrator Skill 创建**：
   - 创建 `.claude/skills/paper-generation/SKILL.md`（约 350 行中文内容）
   - 定义完整的 4-Phase 编排流程、Quality Gate 协议、Agent 生成协议

3. **architecture.md 完全重写**：
   - 从纯 Agent 架构描述 → Skill + Agent 混合架构（约 500 行）
   - 新增：分层架构设计原则、Skill 层详解、Agent 层详解、两种通信模式对比

4. **agents-catalog.md 新建**：
   - 创建完整的 12 个 Agent 目录文档
   - 包含每个 Agent 的：角色、Prompt 文件路径、模型、预算、输入/输出、激活条件

5. **getting-started.md 更新**：
   - 更新启动方式：从 "Claude Code 直接执行" → "通过 Skill 层级调用"

6. **skills-catalog.md 重构**：
   - 反映新命名规范和架构

**技术要点**：
- Skill vs Agent 的分界线：理论分析等轻量任务用 Skill，文献检索等重量任务用 Agent
- Skill 在 系统 主会话中同步执行，Agent 作为独立进程异步执行
- 所有路径使用绝对路径，避免工作目录问题

---

## v1.4 - Phase 4 架构扁平化重构（2026-02-13）

**背景**：Phase 4 reviewers/ 子目录引入了冗余，5 个独立专家文件与 d1-peer-reviewer.md 中的 R1/R2/R3 定义重复。

**工作内容**：

1. **删除冗余的 reviewer 文件**：
   - `agents/phase4/reviewers/d1-reviewer-technical-expert.md`（已由 d1-peer-reviewer.md R1 覆盖）
   - `agents/phase4/reviewers/d1-reviewer-clarity-expert.md`（已由 d1-peer-reviewer.md R3 覆盖）
   - `agents/phase4/reviewers/d1-reviewer-significance-expert.md`（已由 d1-peer-reviewer.md R2 覆盖）
   - `agents/phase4/reviewers/d1-reviewer-writing-quality-expert.md`（已由 d1-peer-reviewer.md R3 覆盖）
   - `agents/phase4/d1-reviewer-domain.md`（旧版本，已被 -expert 版本替代）

2. **移动领域评审专家**：
   - `reviewers/d1-reviewer-domain-expert.md` → `agents/phase4/` 根目录
   - 理由：唯一与 Skill 集成的动态专家，应与其他文件平级

3. **删除空子目录**：
   - `agents/phase4/reviewers/`（已清空）

4. **更新引用路径**：
   - `.claude/skills/paper-phase4-quality/SKILL.md`：两处路径更新
   - `CLAUDE.md`：目录结构说明
   - `docs/domain-knowledge-injection-design.md`：路径引用（2 处）
   - `docs/architecture.md`：专家表格更新
   - `docs/agents-catalog.md`：模式 A 说明更新

5. **最终结构**：
   ```
   agents/phase4/
   ├── d1-peer-reviewer.md          # 通用评审（内嵌 R1/R2/R3）
   ├── d1-reviewer-domain-expert.md   # 领域评审专家（动态 Skill）
   └── d2-revision-specialist.md      # 修订专家
   ```

**技术要点**：
- **扁平化**：减少不必要的子目录层级，提高可维护性
- **消除冗余**：同一功能只在一个文件中定义
- **职责分离**：通用评审（d1-peer-reviewer.md）与领域评审（d1-reviewer-domain-expert.md）清晰分离
- **动态 vs 静态**：领域专家通过 Skill 动态加载，通用专家静态内嵌

---

**最后���新**: 2026-02-14

---

## v1.7 - 论文缓存系统实现（2026-02-14）

**背景**：架构分析报告指出 Phase 1 每次都执行完整的文献检索，存在大量重复 WebSearch 调用。需要实现缓存机制优化性能。

**工作内容**：

1. **创建 cache-utils Skill**：
   - 文件：`.claude/skills/cache-utils/SKILL.md`
   - 功能：提供完整的缓存管理功能
   - 核心函数：
     - `initCache()` — 初始化缓存目录结构
     - `readPaperCache(domain)` — 读取领域缓存论文
     - `writePaperCache(domain, paperData)` — 写入论文缓存
     - `getProcessedIds(domain)` — 获取已处理论文 ID 列表
     - `searchWithCache(domain, query)` — 增量检索（核心）
   - 输出格式：Markdown + Frontmatter（人类可读可编辑）

2. **创建 paper-cacher Skill**：
   - 文件：`.claude/skills/paper-cacher/SKILL.md`
   - 功能：用户手动添加论文的接口
   - 支持：读取 PDF 文件或目录、生成 Markdown + Frontmatter 格式
   - 自动集成：与 cache-utils 和领域知识框架集成

3. **扩展 config.json 配置**：
   ```json
   "cache": {
     "enabled": true,
     "max_papers_per_domain": 500,
     "purge_after_days": 365,
     "auto_generate_index": true,
     "domains": {
       "multi_agent_systems": "MAS",
       "knowledge_graph": "KG",
       "nlp_to_sql": "NL2SQL",
       "bridge_engineering": "Bridge"
     }
   }
   ```

4. **更新 paper-phase1-research Skill**：
   - 添加缓存集成步骤（Step 0, 0.5, 0.6）
   - 文档领域判定逻辑
   - 文档缓存读取和写入操作
   - 集成 searchWithCache 增量检索

5. **创建缓存目录结构文档**：
   - 文件：`workspace/.cache/papers/README.md`
   - 用户指南：目录结构、Markdown 格式、增量更新策略

6. **创建用户准备文档**：
   - 文件：`docs/user-responsibilities.md`
   - 文件：`docs/pre-generation-checklist.md`
   - 完整的用户职责说明和检查清单

**技术要点**：
- **Markdown + Frontmatter 格式**：机器可解析 + 人类可读可编辑
- **增量更新策略**：通过 `processed-ids.txt` 追踪已处理论文，避免重复 WebSearch
- **手动添加支持**：用户可直接在缓存目录添加 `.md` 文件
- **领域映射**：通过 `config.cache.domains` 管理不同领域的缓存

**预期收益**：

| 场景 | 无缓存 | 有缓存 |
|------|--------|--------|
| 首次生成 | 100% | 100% (建立缓存) |
| 第二次生成 (同领域) | 100% | **20-40%** (减少重复检索) |
| 第三次生成 (同领域) | 100% | **10-30%** (大部分已缓存) |

**综合收益**：
- 第二次生成速度提升 **60-80%**
- WebSearch API 调用减少 **70-90%**
- 支持用户干预增强文献库
- 保持人类可读的缓存格式

**成果**：
- 完整的缓存系统架构（cache-utils + paper-cacher）
- 用户准备文档（整合到 getting-started.md）
- 增量检索优化（searchWithCache）
- Markdown + Frontmatter 缓存格式规范
---

## v1.5 - 文档术语一致性更新（2026-02-14）

**背景**：系统未实际使用 Claude Code 的 `TeamCreate` 功能，但文档中大量使用"Agent 层s"、"Agent"、"系统"等术语，造成误解。

**工作内容**：
1. **移除误导性术语**：
   - "Agent 层s" → "Skill + Agent 混合架构" 或 "Agent 层"
   - "Agent" → "Agent 组件" 或直接使用 "Agent"
   - "系统" → "系统（主会话）" 或直接使用 "系统"

2. **更新核心文档**：
   - `docs/architecture.md` — 更新架构图和描述
   - `CLAUDE.md` — 更新项目简介
   - `README.md` — 更新主 README
   - `.claude/skills/paper-generation/SKILL.md` — 移除"Agent生成协议"
   - `.claude/skills/paper-phase2-design/SKILL.md` — 更新说明
   - `.claude/skills/paper-phase3-writing/SKILL.md` — 更新说明
   - `docs/skills-catalog.md` — 更新术语引用
   - `docs/getting-started.md` — 移除 Agent 层s 配置说明
   - `docs/prompt-engineering.md` — 移除 `.claude/teams/` 引用

3. **术语对照表**：
   | 旧术语 | 新术语 |
   |---------|---------|
   | "Agent 层s" | "Skill + Agent 混合架构" |
   | "Agent" | "Agent 组件" |
   | "系统" | "系统" / "主会话" |
   | "并行启动 4 个独立 Agent 进程" | "并行启动多个 Agent" |
   | "独立进程，异步执行" | "独立执行，异步执行" |

4. **技术要点**：
   - **术语一致性原则**：术语替换应遵循"一对多"或"多对一"原则
   - **批量替换效率**：使用 `replace_all=true` 参数
   - **文档清理边界**：测试文件和脚本中的引用可作为"非关键引用"暂不处理

**成果**：
- 所有核心文档已更新为准确描述系统实际架构的术语
- 消除了"Agent 层s"功能存在的误导性印象
- 保持了文档与实现的一致性

---

## v1.5 - 会议配置 Markdown 化（2026-02-14）

**背景**：所有会议/期刊配置从 `config.json` 的 `venues` 区块移至根目录的 `venues.md` 文件，实现更用户友好的配置方式。

**工作内容**：
- 创建根目录的 `venues.md` 文件
- 包含 10 个预定义会议/期刊配置（AAAI、IJCAI、ACL、EMNLP、ISWC、WWW、KR、AAMAS、TOIS、TKDE）
- 用户可直接在文件中添加自定义会议/期刊
- 使用 YAML + Markdown 格式，支持���释和模板
- 所有 Agent（paper-generation、paper-phase3-writing、c3-academic-formatter）改为从 `venues.md` 读取配置

**核心变化**：
- **移除** `config.json` 中的 `venues` 配置区
- **更新** `.claude/skills/paper-generation/SKILL.md`：从 `venues.md` 读取会议配置
- **更新** `.claude/skills/paper-phase3-writing/SKILL.md`：从 `venues.md` 读取会议配置
- **更新** `agents/phase3/c3-academic-formatter.md`：从 `venues.md` 读取会议配置

**技术要点**：
- **Markdown + Frontmatter**：`---` 分隔 YAML 配置块与 Markdown 内容
- **人类可读**：相比 JSON 更易编辑，避免语法错误
- **Git 友好**：用户配置修改与系统配置分离，diff 更清晰
- **单一真相源**：所有会议配置统一管理

**后续更新**：
- **v1.4**：更新缓存系统文档，反映 `venues.md` 作为配置源

**背景**：架构分析报告指出 Phase 1 虽然声明并行执行，但实际上是串行 Skill 调用。通过使用 `Task` 工具的 `run_in_background` 参数实现真正的并发执行。

**工作内容**：

1. **创建 paper-phase1-parallel Skill**：
   - 文件：`.claude/skills/paper-phase1-parallel/SKILL.md`
   - 功能：使用 Task 工具实现 A1/A2/A3 Agent 的真正并行执行
   - 包含完整的错误处理和状态监控逻辑

2. **扩展 config.json 配置**：
   ```json
   "parallel": {
     "phase1_enabled": true,      // 并行模式开关
     "use_task_tool": true,         // 是否使用 Task 工具
     "timeout_per_agent": 300,        // 单个 Agent 超时
     "retry_on_failure": true,         // 失败重试
     "max_retries": 1
   }
   ```

3. **更新 paper-phase1-research Skill**：
   - 添加并行模式路由逻辑
   - 支持根据配置委托给 `paper-phase1-parallel` Skill

4. **创建优化文档**：
   - 文件：`docs/phase1-parallel-optimization.md`
   - 包含技术方案、架构设计、预期收益分析

**技术要点**：
- **真正的并行**：`Task` 工具的 `run_in_background=true` 参数是关键
- **配置驱动**：通过 `config.parallel.phase1_enabled` 控制是否启用
- **错误隔离**：单个 Agent 失败不影响其他 Agent 的执行
- **性能监控**：记录每个 Agent 的执行时间和完成状态

**预期收益**：
- Phase 1 执行时间减少 **40-60%**
- A1+A2+A3 从串行 15-20 分钟降至并行 8-12 分钟

**成果**：
- 实现了 Phase 1 的真正并行执行
- 通过配置开关保持回退能力
- 创建了可复用的并行执行模式

## v1.4 - 会议配置 Markdown 化（2026-02-14）

**背景**：所有会议/期刊配置从 `config.json` 的 `venues` 区块移至根目录的 `venues.md` 文件，实现更用户友好的配置方式。

**工作内容**：
- 创建根目录的 `venues.md` 文件
- 包含 10 个预定义会议/期刊配置（AAAI、IJCAI、ACL、EMNLP、ISWC、WWW、KR、AAMAS、TOIS、TKDE）
- 使用 YAML + Markdown 格式
- 支持用户在文件底部添加自定义会议/期刊

**核心变化**：
- **移除** `config.json` 中的 `venues` 配置区
- **更新** `.claude/skills/paper-generation/SKILL.md`：从 `venues.md` 读取会议配置
- **更新** `.claude/skills/paper-phase3-writing/SKILL.md`：从 `venues.md` 读取会议配置
- **更新** `agents/phase3/c3-academic-formatter.md`：从 `venues.md` 读取会议配置

**技术要点**：
- **Markdown + Frontmatter**：---` 分隔的 YAML 配置块与 Markdown 内容
- **人类可读**：相比 JSON 更易编辑，避免语法错误
- **Git 友好**：用户配置修改与系统配置分离，diff 更清晰
- **单一真相源**：所有会议配置统一管理

**后续更新**：
- **v1.5**：更新缓存系统文档，反映 `venues.md` 作为配置源

---

## v1.8 - 版本管理与用户确认机制（2026-02-14）

**背景**：论文生成系统需要完整的版本历史追踪和人类审稿员交互能力，实现真正的人机协作式学术写作工作流。

**工作内容**：

1. **扩展配置文件**：
   - `config.json` 新增 3 个配置节：
     - `versioning` — 版本管理配置（enabled, mode, max_versions_to_keep）
     - `confirmation` — 用户确认配置（mode, threshold_score, require_approval_for_final）
     - `feedback` — 反馈回路配置（enabled, priority_over_reviewer, track_status）

2. **创建 version-manager Skill**：
   - 文件：`.claude/skills/version-manager/SKILL.md`
   - 功能：版本快照创建、版本比较、版本回滚、版本历史显示
   - 核心函数：
     - `create` — 创建新版本快照（包括论文、元数据、评审摘要、变更日志）
     - `compare` — 比较两个版本之间的差异
     - `rollback` — 回滚到指定历史版本
     - `history` — 显示版本历史表格

3. **修改 Phase 4 技能**：
   - 文件：`.claude/skills/paper-phase4-quality/SKILL.md`
   - 添加 Step 7.5：版本快照创建（根据 versioning 配置）
   - 添加 Step 7.6：用户确认检查（根据 confirmation 配置）
   - 集成 AskUserQuestion 工具实现人类审稿员交互

4. **增强 D2 修订专家**：
   - 文件：`agents/phase4/d2-revision-specialist.md`
   - 添加步骤 1：读取用户反馈（user-feedback.json）
   - 用户反馈优先级设为"critical"（高于评审意见）
   - 在修订日志中特别标注用户反馈的解决情况

5. **修改主编排器**：
   - 文件：`.claude/skills/paper-generation/SKILL.md`
   - 添加 Step 4.5-4.8：最终用户确认流程
   - 支持三种用户选择：接受定稿 / 提供反馈继续 / 手动编辑

6. **目录结构变化**：
   ```
   workspace/{project}/
   ├── versions/                        # 新增：版本管理目录
   │   ├── meta.json                    # 版本索引
   │   ├── V01/                        # 版本 1
   │   │   ├── paper.md
   │   │   ├── metadata.json
   │   │   ├── review-summary.json
   │   │   └── change-log.md
   │   ├── V02/                        # 版本 2
   │   └── ...
   ├── phase4/
   │   ├── user-feedback.json            # 新增：用户反馈
   │   └── user-decision.json            # 新增：用户决策记录
   └── output/
       └── paper.md                    # 当前版本（始终是最新）
   ```

**技术要点**：
- **版本命名规范**：V01/V02/V03...（常规版本）、M01/M02...（里程碑版本）
- **版本模式**：all（每次创建）/milestones（达标时）/smart（提升时）/off（关闭）
- **确认模式**：full（每次确认）/threshold（达标确认）/skip（跳过确认）
- **反馈优先级**：用户反馈高于评审意见，优先处理
- **人类可读格式**：变更日志采用 Markdown 格式，便于阅读和追溯

**预期收益**：

| 场景 | 无版本管理 | 有版本管理 |
|------|------------|------------|
| 版本历史 | 中间版本全部丢失 | 完整历史可追溯 |
| 人工审查 | 无审查点，自动通过 | 里程碑暂停，人类审稿员可审查 |
| 反馈回路 | 无法注入用户意见 | 用户反馈可注入下一轮迭代 |
| 修订追溯 | 不知道改了什么 | 每个版本有变更日志 |

**成果**：
- 完整的版本管理能力（version-manager Skill）
- 人类审稿员交互机制（AskUserQuestion 集成）
- 用户反馈回路（user-feedback.json）
- 目录结构扩展（versions/ 目录）
- 配置驱动行为（config.json 控制）

---

## v2.0 - 交互式论文生成流程（2024-02-14）

**背景**：系统之前完全自动化，忽略了"人类在环"(Human-in-the-Loop)的价值。用户提出两个核心改进：
1. **环节化确认与调整**：在生成论文题目、摘要等关键环节让用户进行确认和调整
2. **期刊属性定位**：根据用户投稿的具体期刊，动态适配格式、风格和内容要求

**核心价值**：早期确认可以减少 60-70% 的后期返工成本（IEEE Software 调研）

**工作内容**：

1. **扩展 venues.md 结构**
   - 为 10 个预定义期刊添加 writing_style、review_criteria、historical_data 配置
   - 支持用户在 venues.md 中添加自定义期刊

2. **创建交互式组件 Skills**
   - **venue-analyzer**：期刊配置解析器，生成 workspace/{project}/venue-style-guide.md
   - **interaction-manager**：交互管理器（简化版），管理 4 个关键交互节点
   - **feedback-collector**：反馈收集器，结构化存储用户反馈

3. **关键交互节点设计**
   - Phase 0.1：期刊选择（如未指定 target_venue）
   - Phase 0.2：题目确认（等待 A4 完成）
   - Phase 0.3：摘要框架确认
   - Phase 2.5：大纲确认（等待 B3 完成）

4. **设计决策**
   - **仅关键节点**：不在 Agent 级别打断流程
   - **自动应用反馈**：系统自动解析用户反馈并调整策略
   - **混合期刊支持**：区分预定义期刊和自定义期刊

5. **更新核心文档**
   - CLAUDE.md：添加 V2 更新说明和新增组件
   - README.md：添加 V2 更新说明和新组件介绍
   - docs/architecture.md：添加 Phase 0 交互式启动确认流程
   - docs/skills-catalog.md：添加 3 个新 Skill 分类
   - docs/prompt-engineering.md：本文档版本记录

6. **扩展 config.json 配置**
   - 新增 interaction 配置节（mode, required_checkpoints, auto_apply_feedback）
   - 新增 venue_analysis 配置节（enabled, predefined_venues）

**技术要点**：
- **人类在环设计**：通过 AskUserQuestion 工具实现关键节点确认
- **增量架构演进**：Phase 0 插入不影响现有 Phases 1-4
- **自动化反馈应用**：系统智能解析用户反馈，无需手动干预

**成果**：
- 完整的交互式论文生成流程（3 个新 Skill + Phase 0 集成）
- 期刊属性定位系统（10 个预定义期刊完整配置）
- 用户反馈自动应用机制
- 与 V1 版本管理独立的并行增强功能
