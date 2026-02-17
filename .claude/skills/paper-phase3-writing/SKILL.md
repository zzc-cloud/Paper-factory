---
name: paper-phase3-writing
description: "执行 Phase 3（撰写阶段），串行执行：C1（逐章节）→ C2（图表）→ C3（格式化）。由 paper-generation 编排器调用。"
---

# Phase 3: 撰写阶段编排器

## 概述

你是 **Phase 3 撰写阶段编排器** — 负责章节撰写、可视化设计和最终论文格式化。

**调用方式：** `Skill(skill="paper-phase3-writing", args="{project}")`

**执行模式：** 串行 — C1 逐章节 → C2 → C3
- 每个组件依赖前一个组件的输出
- C1 可能被多次调用（每个章节一次）

**不要** 直接撰写论文内容 — 委托给章节撰写、可视化设计和学术格式化 Agent。

---

## 输入分析

### 步骤 1：读取论文大纲

读取 `workspace/{project}/phase2/b3-paper-outline.json` 并提取：
- 章节定义（section_id、section_name、section_type、required_inputs）
- 章节数量和顺序
- 图表需求

### 步骤 2：加载目标会议/期刊配置

**⚠️ 目标会议/期刊配置加载**

1. 读取 `workspace/{project}/phase1/input-context.md` 中的 `target_venue` 值
2. 读取 `config.json` 中的 `venues.{target_venue}` 配置：
   - `full_name` — 会议/期刊全称
   - `type` — "conference" 或 "journal"
   - `format` — "single-column" 或 "double-column"
   - `page_limit` — 页数限制（数字或 null）
   - `template` — 模板标识符
   - `deadline_note` — 截稿提示

3. 将 venue 配置传递给 C3 Academic Formatter Agent

这些配置将影响：
- C3 的格式化决策（单栏 vs 双栏）
- 页数控制（如果会议有页数限制）
- 参考文献格式（期刊通常更完整）

### 步骤 3：初始化 Phase 3 目录

确保目录存在：
- `workspace/{project}/phase3/sections/` — 用于章节草稿
- `workspace/{project}/phase3/figures/` — 用于可视化内容

如果缺失，使用 `Bash` 工具创建。

---

## 通过 C1 撰写章节

### C1: 章节撰写 Agent

**Skill：** `Skill(skill="c1-section-writer", args="{project}:{section_id}:{section_name}")`

**模型：** `config.models.writing`（通常为 sonnet）

**执行模式：**
对论文大纲中的每个章节：

1. 启动 C1：
```
Task(
    subagent_type="general-purpose",
    model=config.models.writing,
    name="C1-SectionWriter-{section_id}",
    prompt="""You are the C1 Section Writer agent for project "{project}".

Call Skill(skill="c1-section-writer", args="{project}:{section_id}:{section_name}") and follow its instructions completely.

Return a brief confirmation when complete."""
)
```
2. 等待完成
3. 验证输出文件存在：`workspace/{project}/phase3/sections/{section_id}-{section_name}.md`

**章节按顺序撰写** — 每个章节依赖前面章节的完成。

---

## 通过 C2 设计可视化

### C2: 可视化设计 Agent

**Skill：** `Skill(skill="c2-visualization-designer", args="{project}")`

**模型：** `config.models.writing`（通常为 sonnet）

**调用条件：** 所有 C1 章节撰写完成

**任务：**
- 读取 `b3-paper-outline.json`
- 输入：所有 Phase 1 和 Phase 2 的输出
- 设计图表（绘图、图示、架构可视化）
- 设计表格（实验结果、对比、统计数据）
- 输出：
  - `workspace/{project}/phase3/figures/all-figures.md`
  - `workspace/{project}/phase3/figures/all-tables.md`

**启动并等待** 完成，然后验证两个输出文件都存在。

---

## 通过 C3 格式化

### C3: 学术格式化 Agent

**Skill：** `Skill(skill="c3-academic-formatter", args="{project}")`

**模型：** `config.models.writing`（通常为 sonnet）

**调用条件：** C1（所有章节）和 C2（图表）完成

**任务：**
- 读取所有章节文件：`workspace/{project}/phase3/sections/*.md`
- 读取图表文件：`workspace/{project}/phase3/figures/*.md`
- 读取文献数据：`workspace/{project}/phase1/a1-literature-survey.json`
- **⚠️ 从 `config.json.venues.{target_venue}` 读取会议/期刊配置**
- **⚠️ 应用会议/期刊特定格式：**
  - 单栏 vs 双栏格式
  - 页数限制执行（如适用）
  - 参考文献格式风格（会议 vs 期刊）
  - 模板特定要求
- 组装完整论文并应用学术格式
- 添加参考文献和引用
- 输出：`workspace/{project}/output/paper.md`

**启动并等待** 完成，然后验证最终论文存在。

---

## 通过 C4 编译 LaTeX

### C4: LaTeX 编译 Agent

**Skill：** `Skill(skill="c4-latex-compiler", args="{project}")`

**模型：** `config.models.writing`（通常为 sonnet）

**调用条件：** C3（格式化）完成，`output/paper.md` 存在

**任务：**
- 读取 `output/paper.md` 并转换为 LaTeX 源码
- 根据 `venue-analysis.json` 中的模板信息选择 LaTeX 模板
- 从 `templates/` 复制样式文件
- 生成 `references.bib`（从 `a1-literature-survey.json` 提取）
- 执行 LaTeX 编译（自动检测可用引擎）
- 如果编译失败，进入诊断修复循环（最多 5 轮）
- 输出：
  - `workspace/{project}/output/paper.tex` — LaTeX 源码
  - `workspace/{project}/output/references.bib` — BibTeX 文件
  - `workspace/{project}/output/paper.pdf` — PDF（如编译成功）
  - `workspace/{project}/output/compile-log.json` — 编译报告

**启动并等待** 完成，然后验证 `.tex` 文件存在（PDF 为可选，取决于编译环境）。

**注意**：如果系统未安装 LaTeX 引擎，C4 仍会生成 `.tex` 和 `.bib` 文件，用户可使用 Overleaf 或本地 TexLive 手动编译。

---

## Quality Gate 3

**预期文件（根据章节数量动态确定）：**
- 章节文件：`phase3/sections/*.md`（数量来自 b3-paper-outline.json）
- 图表文件：`phase3/figures/all-figures.md` + `all-tables.md`
- 最终论文：`output/paper.md`
- LaTeX 源码：`output/paper.tex`（C4 输出）
- BibTeX 文件：`output/references.bib`（C4 输出）
- PDF 文件：`output/paper.pdf`（可选，取决于编译环境）
- 编译报告：`output/compile-log.json`（C4 输出）

**验证：**
1. 使用 Glob 统计章节文件数量
2. 验证图表文件存在
3. 验证最终 paper.md 存在
4. 验证 paper.tex 存在（C4 核心输出）
5. 验证 references.bib 存在
6. 检查 compile-log.json 中的编译状态
7. 写入 `workspace/{project}/quality-gates/gate-3.json` 并记录状态

**如果 Gate 3 通过** → 向编排器返回成功，继续到 Phase 4。

---

## 错误处理

### C1 章节失败

如果任何章节失败：
1. 记录警告（章节级别失败不是致命的）
2. 继续处理剩余章节
3. 在 gate 记录中记录哪些章节失败

### C2 图表失败

如果 C2 失败：
1. 记录警告（论文可以没有图表）
2. 继续到 C3（格式化器可能仍然工作）
3. 在 gate 记录中记录

### C3 格式化器失败（关键）

如果 C3 失败：
1. **关键错误** — 无法生成最终论文
2. 立即通知用户
3. 选项：重试 C3 / 手动格式化 / 中止流水线
4. 更新 gate 状态为 "failed"

---

## 成功标准

Phase 3 **完成** 的条件：
1. 所有章节已撰写（或优雅跳过并记录警告）
2. 图表文件存在（或记录 C2 失败）
3. `output/paper.md` 存在
4. Quality Gate 3 状态为 "passed"

向编排器报告完成并返回到 Phase 4。
