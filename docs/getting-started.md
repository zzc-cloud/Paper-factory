# 快速开始

本指南帮助你在 5 分钟内完成从准备素材到启动论文生成的全过程。

---

## 前置条件

| 条件 | 说明 |
|------|------|
| Claude Code | 已安装并可用 |
| Agent 执行 | 通过 Skill 调用管理 |
| API 预算度 | 完整 pipeline 约 $41（可通过 `config.json` 调整） |

Agent 执行配置多

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

---

## 第一步多准备项目素材

在 `workspace/{project-name}/` 下创建 `input-context.md`，包含以下内容多

```markdown
# 论文输入素材

## 论文主题
[你的研究主题，例如多基于知识图谱的智能数据查询系统]

## 工作标题
[论文的工作标题]

## 目标会议/期刊 (target_venue)
[目标投稿会议或期刊，例如多AAAI、IJCAI、ISWC、WWW、ACL、EMNLP 等]

## 目标系统/代码库路径
[如有目标代码库，提供绝对路径]

## 创新点列表
1. [创新点 1多简要描述]
2. [创新点 2多简要描述]
3. [创新点 3多简要描述]

## 系统架构概述
[用 2-3 段描述系统的整体架构和关键组件]

## 关键术语定义
- **术语 1**: 定义
- **术语 2**: 定义
```

> 素材越详细，生成的论文质量越高。特别是创新点列表和系统架构，直接影响 A4（创新形式化）和 B3（结构设计）的输出质量。

---

## 第二步多用户职责（推荐）

### 必需项（启动前必须完成）

- [ ] `input-context.md` 已创建且包含所有必填字段
- [ ] 项目目录 `workspace/{project}/` 已创建

### 推荐项（提升质量）

- [ ] 至少添加 3 篇相关论文到缓存
- [ ] 如有代码库，文档结构清晰
- [ ] 了解论文生成流程（阅读本指南）
- [ ] **如目标会议不在预定义列表中**，编辑根目录的 `venues.md` 添加自定义会议配置

### 可选项（根据项目情况）

- [ ] 准备系统图表或架构图
- [ ] 列出 3-5 篇希望引用的论文
- [ ] **查看完整会议列表** — 参考 [config.json](../config.json) 中的 `venues` 配置区

---

## 第三步多自定义会议/期刊配置（可选）

如果你的目标会议/期刊不在预定义列表中（AAAI、IJCAI、ACL 等），可以通过以下方式添加多

### 编辑 venues.md

在项目根目录有一个 `venues.md` 文件，专门用于用户自定义会议/期刊配置多

```bash
# 打开配置文件
open venues.md  # 或使用你喜欢的编辑器
```

按照文件中的模板添加你的会议配置多

```yaml
ICSE-2025:
  full_name: "International Conference on Software Engineering"
  type: "conference"
  format: "double-column"
  page_limit: 12
  template: "icse2025"
  keywords: ["software engineering", "ICSE", "software development"]
  deadline_note: "通常在 8-9 月截稿"
```

保存后，系统会自动识别你的自定义会议。

### 预定义会议配置模板

每个会议需要以下字段多

| 字段 | 说明 | 示例 |
|------|------|------|
| `full_name` | 会议/期刊全称 | International Conference on Software Engineering |
| `type` | 类型（conference 或 journal） | conference |
| `format` | 格式（single-column 或 double-column） | double-column |
| `page_limit` | 页数限制（数字或 null） | 12 或 null |
| `template` | 模板标识符 | icse2025 |
| `keywords` | 关键词列表（用于文献搜索） | ["software engineering", "ICSE"] |
| `deadline_note` | 截稿时间提示 | 通常在 8-9 月截稿 |

---

## 第四步多优化文献库（推荐）

### 手动添加论文

```bash
# 添加单篇 PDF
Skill(skill="paper-cacher", args="{project}", source_dir="/path/to/paper.pdf", domain="multi_agent_systems")

# 添加整个目录
Skill(skill="paper-cacher", args="{project}", source_dir="/path/to/papers/", domain="knowledge_graph")
```

### 验证缓存

```bash
# 查看已缓存的论文
ls workspace/{project}/.cache/papers/{domain}/

# 读取缓存内容
Skill(skill="cache-utils", action="read", args="{project}", domain="{domain}")
```

### 时间建议

| 任务 | 建议时间 |
|------|----------|
| 准备 `input-context.md` | 30-60 分钟 |
| 添加论文到缓存 | 15-30 分钟 |
| 检查/更新领域知识 | 15-30 分钟 |

**总计**多约 1-2 小时

---

## 第四步多启动论文生成

```bash
cd paper-factory
claude
```

在 Claude Code 中输入多

```
我要生成一篇关于 [你的主题] 的学术论文。
素材在 workspace/[project-name]/input-context.md。
请按 pipeline 开始。
```

**重要说明**多

系统会自动读取 `CLAUDE.md`，然后通过 **Skill 层级调用**管理完整的 4 阶段论文生成流程多

1. **Orchestrator Level** → 调用主 Skill多
   ```
   Skill(skill="paper-generation", args="{project-name}")
   ```

2. **Phase Level** → 主 Skill 自动按顺序调用 4 个 Phase Skill多
   - `paper-phase1-research` — 文献调研与理论分析
   - `paper-phase2-design` — 论文设计
   - `paper-phase3-writing` — 论文撰写
   - `paper-phase4-quality` — 质量评审

3. **Agent 层** → Phase Skill 内部根据需要启动独立 Agent 进程多
   - Phase 1: A1（文献）、A3（MAS 文献）、A4（聚合）
   - Phase 2: B1（相关工作）、B2（实验设计）、B3（架构设计）
   - Phase 3: C1（章节撰写）、C2（图表设计）、C3（格式整合）
   - Phase 4: D1（同行评审）、D2（修订执行）

**架构模式**多Skill 层同步执行（共享会话上下文），Agent 层异步执行（通过文件通信）

---

## 第五步多等待与监控

完整 pipeline 通常需要 2-4 小时。你可以通过以下方式监控进度多

```bash
# 查看当前阶段的输出文件
ls workspace/{project-name}/phase*/

# 查看质量门控状态
cat workspace/{project-name}/quality-gates/gate-*.json

# 查看最终论文（Phase 3 完成后）
cat workspace/{project-name}/output/paper.md
```

---

## 配置调优

`config.json` 含系统的核心配置多

```json
{
  "models": {
    "reasoning": "opus",    // 深度分析任务（A3, A4, B1-B3, D1, D2）
    "writing": "sonnet"      // 内容生成任务（A1, C1-C3）
  },
  "quality": {
    "min_papers": 30,           // A1 最少搜索论文数
    "min_review_score": 7,      // D1 最低通过评分
    "max_review_iterations": 3  // D1-D2 最大迭代次数
  },
  "paper": {
    "target_word_count": 10000  // 目标字数（长文）
  }
}
```

| 配置项 | 说明 | 调优建议 |
|--------|------|----------|
| `models.reasoning` | 深度分析模型 | 保持 opus，推理质量关键 |
| `models.writing` | 内容生成模型 | sonnet 性价比最优 |
| `quality.min_papers` | 最少文献数 | 降低可加速，但影响文献覆盖度 |
| `quality.min_review_score` | 最低评审分 | 7 分是合理阈值，降低可减少迭代 |
| `quality.max_review_iterations` | 最大评审轮次 | 3 轮通常足够，增加会提高成本 |
| `paper.target_word_count` | 目标字数 | 10000 适合长文，短文可降至 6000 |

每个 Agent 的预算也可单独调整，详见 [Agent 目录](agents-catalog.md)。

---

## 产出结构

生成完成后，工作空间的目录结构如下多

```
workspace/{project-name}/
├── input-context.md          # 你提供的输入素材
├── phase1/                       # Research 产物（Agent + Skill 输出）
│   ├── a1-literature-survey.json
│   ├── a1-literature-survey.md
│   ├── a3-mas-literature.json (条件)
│   ├── a3-mas-literature.md (条件)
│   ├── skill-mas-theory.json (条件)
│   ├── skill-kg-theory.json (条件)
│   ├── skill-nlp-sql.json (条件)
│   ├── skill-bridge-eng.json (条件)
│   ├── a4-innovations.json
│   └── a4-innovations.md
├── phase2/                       # Design 产物
│   ├── b1-related-work.json
│   ├── b1-related-work.md
│   ├── b2-experiment-design.json
│   ├── b2-experiment-design.md
│   ├── b3-paper-outline.json
│   └── b3-paper-outline.md
├── phase3/                       # Writing 产物
│   ├── sections/             # 各章节 Markdown
│   └── figures/              # 图表描述
├── phase4/                       # Quality 产物
│   ├── d1-review-report.json
│   ├── d1-review-report.md
│   ├── d2-revision-log.json (条件)
│   └── d2-revision-log.md (条件)
├── quality-gates/            # 4 个门控记录
│   ├── gate-1.json
│   ├── gate-2.json
│   ├── gate-3.json
│   └── gate-4.json
└── output/
    └── paper.md              # 最终论文
```

---

## 常见问题

**Q: Pipeline 途中失败怎么办？**

系统会检测失败的 Agent 或 Skill，提供选项多重试该 Agent/Skill / 跳过 / 手动补充。

**Q: 如何只重新运行某个阶段？**

目前需要手动删除该阶段的输出文件，然后重新启动 pipeline。系统会检测到缺失文件并重新生成。

**Q: 生成的论文质量不满意？**

检查 `phase4/d1-review-report.md` 中的评审意见，手动修改 `output/paper.md`，或调高 `min_review_score` 后重新运行 Phase 4。

**Q: 如何适配非知识图谱领域的论文？**

修改 `CLAUDE.md` 中的领域专长描述，以及相关 Agent 的系统提示（`agents/` 目录下的 `.md` 文件）。如需添加新的领域 Skill，参考 [技能目录](skills-catalog.md) 创建新的 Skill。

**Q: Skill 调用方式是什么？**

通过 `Skill(skill="skill-name", args="project")` 方式调用。主 Skill 是 `paper-generation`，Phase Skills 是 `paper-phase1-search` 到 `paper-phase4-quality`，领域 Skills 是 `research-mas-theory`、`research-kg-theory` 等。详见 [完整技能目录](skills-catalog.md)。

**Q: `input-context.md` 必填哪些字段？**

必填字段多
```markdown
- paper_title — 论文标题
- target_system — 目标系统描述
- codebase_path — 代码库路径（可选）
- innovations — 创新点列表（至少 3 个）
- system_architecture — 系统架构概述
- key_terminology — 关键术语定义
```

**Q: 可以跳过缓存直接生成？**

可以，但不推荐。缓存后的第二次生成速度提升 **60-80%**。

**Q: 需要多少篇论文？**

建议 30-50 篇。数量过少会导致文献综述薄弱，数量过多则难以深入分析。

**Q: 可以中断生成过程吗？**

可以按 Ctrl+C 停止，或直接关闭终端。下次运行时可以从断点继续。

---

> 更多架构细节请参阅 [系统架构](architecture.md)，技能和工具参考请查看 [技能目录](skills-catalog.md) 和 [MCP 工具](mcp-tools.md)。
