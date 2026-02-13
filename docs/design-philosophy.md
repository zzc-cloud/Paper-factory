# 设计理念

## 问题背景

学术论文写作是一项复杂的智力工程，需要多种截然不同的专业能力：

- **文献调研**：需要广泛检索、快速筛选、精准分类数十篇相关论文
- **工程分析**：需要深入理解代码架构、设计模式、技术创新点
- **理论建模**：需要将工程实践抽象为学术贡献，建立形式化框架
- **实验设计**：需要设计对比实验、选择评价指标、预测结果
- **学术写作**：需要遵循严格的论证逻辑、符合顶会规范、语言精炼准确
- **同行评审**：需要从多个维度批判性审视论文质量

传统的单人写作模式下，研究者需要在这些角色间频繁切换，认知负担极高。即使是单个 AI 助手，也难以在一次对话中同时保持"广度检索"与"深度分析"、"批判性思维"与"建设性写作"的平衡。

Paper Factory 的核心洞察是：**学术论文生成本质上是一个多角色协作的工作流，而非单一智能体的独角戏**。

---

## 五大设计原则

### 1. 专业化分工（Specialization）

**理念**：让每个 agent 只做一件事，并把它做到极致。

在真实的学术团队中，文献调研员、系统架构师、理论学家、实验设计师、论文写手、审稿人是不同的角色。Paper Factory 将这种分工映射到 12 个专业 agent：

- **A1 (Literature Surveyor)**：专注于文献检索，使用 Sonnet 模型快速处理大量论文元数据
- **A2 (Engineering Analyst)**：深度分析代码库，使用 Opus 模型进行复杂推理
- **A3 (MAS Theorist)**：研究多智能体系统理论，需要 Opus 的抽象能力
- **C1 (Section Writer)**：流畅撰写章节内容，Sonnet 的语言生成能力足够
- **D1 (Peer Reviewer)**：模拟三位独立审稿人，需要 Opus 的批判性思维

**技术实现**：
- 每个 agent 的系统提示（`agents/{phase}/{agent}.md`）精确定义其角色、输入、输出、评价标准
- 不同任务匹配不同模型：Opus 用于深度推理（$4-5 预算），Sonnet 用于高吞吐任务（$2-3 预算）
- 工具权限隔离：写作 agent 只能写文件，评审 agent 只能读文件

**收益**：
- 避免"万能 agent"的能力稀释
- 每个 agent 的提示词可以高度优化，无需兼顾其他任务
- 并行执行时不会互相干扰

---

### 2. 阶段化推进（Phased Pipeline）

**理念**：学术论文写作有天然的依赖顺序，不能"边调研边写作"。

Paper Factory 将流程分解为 4 个阶段：

```
Phase 1: Research（素材收集）
  ├─ 文献调研、工程分析、理论研究并行
  └─ 创新点形式化依赖工程分析结果

Phase 2: Design（论文设计）
  ├─ 相关工作分析 → 实验设计 → 论文架构
  └─ 严格串行，每步依赖前序输出

Phase 3: Writing（论文撰写）
  ├─ 逐章节写作 → 图表设计 → 格式化组装
  └─ 串行执行，确保一致性

Phase 4: Quality（质量保障）
  └─ 评审 → 修订 → 再评审（迭代循环）
```

**为什么不能跳过阶段**：
- 如果在文献调研完成前就开始写 Related Work，会导致引用不全、对比不充分
- 如果在实验设计完成前就写 Methodology，会导致方法描述与实验不匹配
- 如果在所有章节完成前就做格式化，会导致重复劳动

**技术实现**：
- 每个阶段结束后设置 **Quality Gate**，验证所有预期文件存在
- 只有当 `quality-gates/gate-{N}.json` 显示 `"status": "passed"` 时，才启动下一阶段
- Phase 内部的依赖通过 agent 生成顺序控制（如 A2 完成后才生成 A4）

**收益**：
- 防止"半成品"被后续 agent 使用
- 出错时可以精确定位到某个阶段，而非整个流程重来
- 人类可以在任意 Quality Gate 处介入检查

---

### 3. 质量门控（Quality Gates）

**理念**：自动化验证比人工检查更可靠。

每个阶段完成后，Team Lead 自动执行门控检查：

```json
{
  "gate": 1,
  "phase": "Research",
  "status": "passed",
  "timestamp": "2026-02-13T10:30:00Z",
  "files_expected": [
    "phase1/a1-literature-survey.json",
    "phase1/a1-literature-survey.md",
    "phase1/a2-engineering-analysis.json",
    "phase1/a2-engineering-analysis.md",
    "phase1/a3-mas-theory.json",
    "phase1/a3-mas-theory.md",
    "phase1/a4-innovations.json",
    "phase1/a4-innovations.md"
  ],
  "files_found": [...],
  "files_missing": []
}
```

**检查内容**：
- 文件存在性（使用 Glob 工具）
- 文件数量是否符合预期
- 关键 JSON 文件的结构完整性（可选）

**失败处理**：
- 若有文件缺失，记录到 `files_missing`
- Team Lead 通知用户，提供选项：
  - 重新生成失败的 agent
  - 跳过该文件（如果非关键）
  - 手动补充文件后继续

**收益**：
- 早期发现问题，避免错误传播到后续阶段
- 提供可审计的执行记录
- 支持断点续传（可以从任意 gate 后重启）

---

### 4. 迭代优化（Review-Revision Loop）

**理念**：一次写作很难完美，需要模拟真实的同行评审流程。

Phase 4 实现了一个闭环优化机制：

```
for iteration in 1..3:
  1. D1 (Peer Reviewer) 评审 paper.md
     - 模拟 3 位独立审稿人
     - 从 Novelty、Soundness、Clarity、Significance 四个维度打分
     - 输出 average_score 和详细意见

  2. 检查 average_score
     - 若 >= 7.0 → 通过，结束循环
     - 若 < 7.0 且 iteration < 3 → 进入修订

  3. D2 (Revision Specialist) 修订论文
     - 读取 D1 的评审意见
     - 针对性修改 paper.md
     - 记录修订日志

  4. 回到步骤 1，重新评审
```

**为什么是 3 次迭代**：
- 第 1 次：修正明显错误（逻辑漏洞、实验缺失）
- 第 2 次：优化表达（语言精炼、结构调整）
- 第 3 次：细节打磨（术语统一、引用完善）
- 超过 3 次通常收益递减

**技术实现**：
- D1 输出结构化的 `d1-review-report.json`，包含量化分数
- D2 读取 JSON 中的 `issues` 数组，逐条修复
- 每次迭代的评审报告和修订日志都保存，便于追溯

**收益**：
- 自动发现论文中的弱点（如相关工作对比不足、实验设计不严谨）
- 避免"一次性写作"的质量不稳定
- 模拟真实审稿流程，提高论文接受率

---

### 5. CLAUDE.md 驱动编排（Orchestration as Code）

**理念**：编排逻辑应该是人类可读、可修改、可版本控制的。

传统的多智能体系统通常需要：
- Python/JavaScript 脚本定义工作流
- 外部调度器（如 Airflow、Temporal）
- 复杂的状态管理和错误处理代码

Paper Factory 的创新在于：**整个 pipeline 由 `CLAUDE.md` 文件驱动，Team Lead 读取后自主执行**。

**CLAUDE.md 的内容**：
- Agent 定义表（12 个 agent 的角色、模型、预算）
- Pipeline 定义（4 个阶段的执行顺序、依赖关系）
- Quality Gate 协议（检查规则、失败处理）
- Teammate 生成协议（如何读取 agent 提示、如何传递任务）

**Team Lead 的工作流程**：
```
1. 读取 CLAUDE.md，理解整个 pipeline
2. 读取 config.json，获取模型和预算配置
3. 读取 workspace/{project}/input-context.md，获取项目信息
4. 按阶段执行：
   - 生成 teammate（读取 agents/{phase}/{agent}.md 作为系统提示）
   - 等待 teammate 完成
   - 执行 Quality Gate
   - 决定下一步行动（继续/重试/通知用户）
```

**为什么这样设计**：
- **无需外部依赖**：Claude Code + Agent Teams 原生支持
- **人类可理解**：CLAUDE.md 是自然语言，不是代码
- **易于调试**：修改 CLAUDE.md 即可调整流程，无需重新部署
- **版本控制**：CLAUDE.md 随项目一起提交到 Git

**收益**：
- 降低系统复杂度（无需学习 Airflow/Temporal）
- 提高透明度（用户可以直接阅读 CLAUDE.md 理解流程）
- 支持动态调整（Team Lead 可以根据实际情况决定是否重试某个 agent）

---

## 核心概念

### Team Lead 模式

**定位**：Team Lead 是指挥家，不是演奏家。

在 Paper Factory 中，Team Lead 的职责是：
- **编排**：决定何时生成哪个 teammate
- **协调**：管理 agent 间的依赖关系（如 A4 依赖 A2）
- **质量把控**：执行 Quality Gate，决定是否进入下一阶段
- **异常处理**：当 agent 失败时，决定重试还是通知用户

Team Lead **不做**的事情：
- 不直接写论文内容（委派给 C1）
- 不直接分析代码（委派给 A2）
- 不直接评审论文（委派给 D1）

**为什么这样设计**：
- **专业化**：Team Lead 专注于流程管理，写作质量由专业 agent 保证
- **可扩展**：增加新 agent 只需修改 CLAUDE.md，Team Lead 逻辑不变
- **避免上下文污染**：Team Lead 的对话历史不会混入大量论文内容

### 文件系统通信

**理念**：Agent 间通过文件交换信息，而非对话历史。

每个 agent 的输入输出都是明确的文件路径：
- A1 输出 `phase1/a1-literature-survey.json`
- B1 读取 `phase1/a1-literature-survey.json` 和 `phase1/a4-innovations.json`
- B1 输出 `phase2/b1-related-work.json`

**为什么不用消息传递**：
- **持久化**：文件可以被人类检查、修改、备份
- **解耦**：Agent 不需要知道谁生成了输入文件
- **可恢复**：如果某个 agent 失败，可以手动补充文件后继续
- **并行友好**：多个 agent 可以同时读取同一个文件

**文件格式约定**：
- **JSON**：结构化数据（如文献列表、实验设计、评审分数）
- **Markdown**：人类可读的报告（如工程分析报告、论文章节）

### Delegation 原则

**核心思想**：永远委派给最合适的专家。

错误示例：
```
Team Lead: "我来写 Introduction 章节..."  ❌
```

正确示例：
```
Team Lead: "生成 C1 (Section Writer) teammate，任务是写 Introduction..."  ✓
```

**收益**：
- 每个任务都由最擅长的 agent 完成
- Team Lead 保持"元认知"层面，不陷入具体任务
- 系统可以轻松扩展到 20、30 个 agent

---

## 技术选型

### 为什么选 Agent Teams

Claude Code 的 Agent Teams 提供了以下关键能力：

1. **并行执行**：Phase 1 中 A1/A2/A3 可以同时运行，节省时间
2. **消息传递**：Agent 间可以通过 `SendMessage` 工具通信（虽然 Paper Factory 主要用文件）
3. **预算控制**：每个 agent 可以设置独立的预算上限
4. **原生集成**：无需外部 API 调用或进程管理

**对比其他方案**：
- **LangGraph**：需要 Python 代码定义图结构，不如 CLAUDE.md 直观
- **AutoGen**：需要编写 agent 类，部署复杂
- **手动调用 API**：需要自己实现并行、重试、状态管理

### 为什么用 CLAUDE.md 驱动

**单一事实来源（Single Source of Truth）**：
- 所有 agent 定义、pipeline 逻辑、质量标准都在 CLAUDE.md 中
- 修改流程只需编辑一个文件
- 不会出现"代码与文档不一致"的问题

**人类可读性**：
- 研究者可以直接阅读 CLAUDE.md 理解系统如何工作
- 不需要懂编程也能理解 pipeline 逻辑
- 便于学术论文中描述系统设计

**版本控制**：
- CLAUDE.md 随项目一起提交到 Git
- 可以追溯每次修改（如"增加了第 5 个 agent"）
- 支持分支实验（如"尝试不同的 Phase 2 顺序"）

**动态适应**：
- Team Lead 不是机械执行脚本，而是理解 CLAUDE.md 后自主决策
- 可以根据实际情况调整（如某个 agent 失败后，决定是重试还是跳过）
- 支持用户在运行时介入（如"Phase 1 完成后，我想手动检查文献列表"）

---

## 总结

Paper Factory 的设计哲学可以概括为：

**将学术论文生成视为一个多角色协作的工作流，通过专业化分工、阶段化推进、质量门控、迭代优化，以及 CLAUDE.md 驱动的编排，实现高质量论文的自动化生成。**

这不是简单的"AI 写论文"，而是**模拟一个完整的学术研究团队**，让每个 agent 扮演其最擅长的角色，通过严格的流程管理和质量控制，产出接近人类专家水平的学术论文。
