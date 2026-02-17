---
name: domain-knowledge-update
description: "领域知识动态更新 — 通过 Web Search 获取前沿论文和技术进展，同时更新 docs/domain-knowledge/ 下领域知识文档的理论分析和评审认知两部分。"
---

# Domain Knowledge Update Skill

## 概述

你是 **领域知识动态更新工具** — 负责通过 Web Search 获取前沿研究，**同时更新** `docs/domain-knowledge/{domain}.md` 文档的理论分析和评审认知两部分。

**调用方式：** `Skill(skill="domain-knowledge-update", args="{domain}")`

**核心职责：**
- 搜索目标领域的前沿论文和技术进展（近 2 年）
- 从论文中提取**理论层**和**评审层**两类知识更新
- **直接更新**对应的 `docs/domain-knowledge/{domain}.md` 文档
- 生成变更摘要报告
- 通过 git 追踪所有更新

**不要**执行评审或理论分析 — 只做知识获取和文件更新。

---

## 输入参数

**args 格式**: `{domain}`

支持的领域标识符：

| 标识符 | 文档路径 | 全称 |
|--------|-----------|------|
| knowledge_graph | docs/domain-knowledge/kg.md | Knowledge Graphs and Ontology Engineering |
| multi_agent_systems | docs/domain-knowledge/mas.md | Multi-Agent Systems (MAS) |
| nl2sql | docs/domain-knowledge/nl2sql.md | Natural Language to SQL |
| bridge_engineering | docs/domain-knowledge/bridge.md | Bridge Engineering |
| data_analysis | docs/domain-knowledge/data.md | Data Analysis and Machine Learning |

**示例调用**:
```
Skill(skill="domain-knowledge-update", args="knowledge_graph")
Skill(skill="domain-knowledge-update", args="multi_agent_systems")
```

---

## 执行步骤

### Step 1: 验证领域并解析 Skill 路径

```python
SUPPORTED_DOMAINS = {
    "knowledge_graph": {"doc": "docs/domain-knowledge/kg.md", "full_name": "Knowledge Graphs and Ontology Engineering"},
    "multi_agent_systems": {"doc": "docs/domain-knowledge/mas.md", "full_name": "Multi-Agent Systems"},
    "nl2sql": {"doc": "docs/domain-knowledge/nl2sql.md", "full_name": "Natural Language to SQL"},
    "bridge_engineering": {"doc": "docs/domain-knowledge/bridge.md", "full_name": "Bridge Engineering"},
    "data_analysis": {"doc": "docs/domain-knowledge/data.md", "full_name": "Data Analysis and Machine Learning"}
}
```

### Step 2: 读取并理解当前领域知识文档结构

**关键原则：不要硬编码 section 名称。** 不同领域的文档结构不完全一致（例如 MAS 用"第一层：核心理论知识"，KG 用"Part 1: 理论分析"）。

1. 使用 `Read` 工具读取 `docs/domain-knowledge/{domain}.md` 的完整内容
2. **语义识别**文件的两大部分：
   - **理论分析部分**：包含范式、方法、形式化框架、技术组件等学术理论内容
   - **评审认知部分**：包含评审维度、核心概念评估、常见陷阱、经典文献等评审标准
3. 记录每个部分的起止位置和子 section 列表，用于后续精准插入

**输出：** 内部数据结构（不写文件），包含：
```json
{
  "theory_section": {
    "start_heading": "## Part 1: 理论分析",
    "subsections": ["核心研究范式", "关键技术组件", "评估维度"],
    "has_sota_tools": true,
    "has_paradigms": true,
    "has_methods": true
  },
  "review_section": {
    "start_heading": "## Part 2: 评审认知框架",
    "subsections": ["核心概念与评估维度", "经典文献对标", "SOTA 对比清单", "领域特定评审问题"],
    "has_classic_papers": true,
    "has_sota_checklist": true
  }
}
```

### Step 3: 多维度搜索前沿论文

**不要只用一条通用查询。** 分别搜索理论进展和工具/方法更新：

**搜索策略（3 轮）：**

**轮次 1 — 理论与方法进展：**
```
WebSearch("{domain_full_name} new method framework approach 2025 2026")
```
目标：发现新的理论范式、新的形式化方法、新的架构模式

**轮次 2 — 工具与系统更新：**
```
WebSearch("{domain_full_name} benchmark tool system state-of-the-art 2025 2026")
```
目标：发现新的 SOTA 工具、新的基准测试、新的系统实现

**轮次 3 — 综述与趋势：**
```
WebSearch("{domain_full_name} survey review trends challenges 2025 2026")
```
目标：发现领域趋势、新兴研究方向、未解决的挑战

**每轮搜索 5-10 条结果，总计 15-30 条候选。**

### Step 4: 论文分析与双层知识提取

对每篇可访问的论文，使用 `WebFetch` 获取内容，然后提取**两层**知识：

**理论层提取（服务于 Phase 1 理论分析）：**

| 提取类型 | 说明 | 插入位置 |
|---------|------|---------|
| `new_paradigm` | 新的研究范式或架构模式 | 理论部分 → 范式/架构 subsection |
| `new_method` | 新的方法、算法或技术 | 理论部分 → 方法/技术组件 subsection |
| `new_formalization` | 新的形式化框架或数学模型 | 理论部分 → 形式化 subsection |
| `sota_tool_update` | 新的 SOTA 工具、系统或基准 | 理论部分 → 评估维度 或 评审部分 → SOTA 清单 |

**评审层提取（服务于 Phase 4 领域评审）：**

| 提取类型 | 说明 | 插入位置 |
|---------|------|---------|
| `new_concept` | 新的核心概念及其评审要点 | 评审部分 → 核心概念 subsection |
| `new_paper` | 重要的新经典文献 | 评审部分 → 经典文献 subsection |
| `new_pitfall` | 新发现的常见问题或陷阱 | 评审部分 → 常见陷阱/评审问题 subsection |
| `sota_update` | SOTA 对比清单的更新 | 评审部分 → SOTA 对比清单 |

### Step 5: 语义定位与精准插入

**核心原则：使用 LLM 语义理解定位插入位置，不硬编码 section 名称。**

对于每条提取的知识更新，执行以下流程：

1. **判断归属层**：该知识属于理论层还是评审层？
2. **语义匹配 subsection**：在对应层中，找到语义最匹配的 subsection
3. **去重检查**：该知识是否已存在于文件中（语义相似度判断）
4. **格式适配**：按照该 subsection 的现有格式生成插入内容
5. **使用 Edit 工具精准插入**：在匹配的 subsection 末尾追加

**理论层插入格式示例：**

新范式/方法：
```markdown
#### {N+1}. {新范式名称}

**核心理论**：{作者} ({年份})。{一句话描述}。

**关键特征**：
- {特征 1}
- {特征 2}
- {特征 3}

**映射指导**：{如何将目标系统映射到此范式}
```

新工具/系统（追加到 SOTA 清单）：
```markdown
- **{类别}**：在现有列表末尾追加新工具名称
```

**评审层插入格式示例：**

新核心概念：
```markdown
#### {概念名称}
- **期望用法**：{正确使用方式}
- **常见问题**：{常见误用}
- **评审要点**：{评审时应检查什么}
```

新经典文献（追加到表格）：
```markdown
| {作者} ({年份}) | {为什么重要} | {应在何处引用} |
```

### Step 6: 执行文件更新

1. 对所有待插入的更新按 section 位置排序（从文件末尾向前插入，避免行号偏移）
2. 使用 `Edit` 工具逐条插入
3. 每次插入后验证文件结构完整性

**去重规则：**
- 如果新范式/方法与现有内容语义重复 → 跳过，记录到摘要
- 如果新工具已在 SOTA 清单中 → 跳过
- 如果新文献已在经典文献表中 → 跳过
- 如果新概念与现有概念高度相似 → 考虑更新现有条目而非新增

### Step 7: 生成变更摘要

写入摘要到控制台输出（不写文件）：

```markdown
# 领域知识更新摘要

## 领域：{domain_full_name}
**更新时间**：{current_date}
**Skill 文件**：docs/domain-knowledge/{domain}.md

## 理论层更新

### 新增范式/架构 ({count})
{paradigm_list}

### 新增方法/技术 ({count})
{method_list}

### SOTA 工具更新 ({count})
{tool_list}

## 评审层更新

### 新增核心概念 ({count})
{concept_list}

### 新增经典文献 ({count})
{paper_list}

### 新增评审陷阱 ({count})
{pitfall_list}

### SOTA 对比清单更新 ({count})
{sota_list}

## 跳过的重复项 ({count})
{skipped_list}

## 分析的论文来源 ({count})
{source_papers}
```

### Step 8: Git 提交

```bash
git add docs/domain-knowledge/{domain}.md
git commit -m "knowledge: update {domain} domain knowledge (theory + review)

Theory updates:
- {n} new paradigms/methods
- {n} SOTA tool updates

Review updates:
- {n} new concepts
- {n} new classic papers
- {n} new pitfalls

Source: Web Search {date}"
```

---

## 领域知识文件的双层结构

每个 `docs/domain-knowledge/{domain}.md` 文档包含两层内容：

```
docs/domain-knowledge/{domain}.md
├── 概述 + 调用方式
├── 【理论分析层】← Phase 1 DK-Agent 读取，用于理论创新
│   ├── 核心研究范式 / 范式映射
│   ├── 关键技术组件 / 方法
│   ├── 形式化框架（部分领域）
│   └── 评估维度
└── 【评审认知层】← Phase 4 评审专家读取，用于领域评审
    ├── 核心概念与评估维度
    ├── 经典文献对标
    ├── SOTA 对比清单
    └── 领域特定评审问题 / 常见陷阱
```

**本 Skill 同时更新两层**，确保理论分析和评审认知始终保持同步。

---

## 与流水线的协作关系

| 阶段 | 消费者 | 读取内容 | 用途 |
|------|--------|---------|------|
| Phase 1 | DK-Agent（理论分析） | 理论分析层 | 将目标系统映射到领域理论框架 |
| Phase 4 | 评审专家 | 评审认知层 | 提供领域评审标准和评估维度 |
| 维护期 | **本 Skill** | 两层都更新 | 通过 WebSearch 保持知识前沿性 |

---

## 错误处理

### 搜索错误
- 某轮搜索无结果 → 跳过该轮，继续其他轮次
- 搜索完全失败 → 使用备选关键词重试一次
- 结果过少（< 5 条） → 放宽搜索条件（扩大时间范围到 3 年）

### 论文分析错误
- 论文内容不可读 → 跳过，记录到摘要
- WebFetch 失败 → 跳过，记录 URL
- 提取结果为空 → 跳过

### 文件更新错误
- 领域知识文档不存在 → 报错并终止
- Edit 操作失败 → 报错，保持原文件不变
- 更新后文件结构异常 → 回滚（git checkout）

---

## 使用建议

1. **定期更新**：每 1-2 个月执行一次，保持领域知识前沿性
2. **审查更新**：更新后检查领域知识文档，确保新增内容准确
3. **Git 提交**：每次更新后通过 git commit 追踪变更历史
4. **手动补充**：对于特别重要的新概念，可以手动编辑领域知识文档
5. **理论层优先**：如果论文同时包含理论贡献和工具更新，优先提取理论贡献
