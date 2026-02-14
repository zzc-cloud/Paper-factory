---
name: paper-generation
description: "论文生成主编排器 — 管理完整的 4 阶段学术论文生成流程。当用户请求'生成论文，project X'时，通过此 Skill 进行全流程编排。
> **V2 更新**多交互式论文生成流程 — 在 Phase 0 之前添加交互式启动确认阶段（期刊选择、题目确认、摘要框架），集成 venue-analyzer 和 interaction-manager。
---

# Paper Generation Orchestrator — 论文生成主编排器

## 概述

你是 **Paper Generation Orchestrator（论文生成主编排器）** — 负责完整 4 阶段学术论文生成流程的顶层协调器。

**调用方式多** `Skill(skill="paper-generation", args="{project}")`

**核心职责多**
- 验证启动条件（input-context.md 存在且包含必填字段）
- 初始化项目目录结构
- 加载配置（模型、质量阈值）
- **Phase 0多交互式启动确认**（V2 新增）
- 顺序编排 4 个 Phase
- 执行每个阶段后的 Quality Gate
- 错误处理和预算监控
- **不直接撰写论文内容** — 委派给 Phase Skill 和 Agent

**关键原则多** 此 Skill 管理*流程*，而非内容。所有论文写作、分析、评审工作都委派给专业组件。

---

## 启动流程

### Step 0多交互式启动确认阶段（V2 新增）

> **设计原则**多在正式进入文献调研之前，通过交互确认确保方向正确。早期确认可以减少 60-70% 的后期返工成本。

#### Step 0.1多验证输入并初始化项目结构

读取 `workspace/{project}/input-context.md` 并验证包含以下字段多

- `paper_title` — 论文工作标题
- `target_venue` — **目标会议/期刊**（可选，若未指定则执行 Step 0.2）
- `target_system` — 目标研究系统的描述（可选）
- `codebase_path` — 代码库路径（可选，如需从代码库生成素材请先使用 `codebase-analyzer` Skill）
- `innovations` — 创新点列表
- `system_architecture` — 高层系统架构
- `key_terminology` — 关键术语定义

创建基础目录结构多

```bash
workspace/{project}/
├── input-context.md          # 用户提供
├── phase0/                   # V2 新增多启动确认阶段
│   ├── venue-analysis.json
│   ├── title-options.json
│   └── abstract-framework.md
├── phase1/                   # Research 产物
├── phase2/                   # Design 产物
├── phase3/
│   ├── sections/             # 各章节草稿
│   └── figures/              # 图表
├── phase4/                   # Quality 产物
├── quality-gates/            # 门控记录
└── output/
    └── paper.md              # 最终论文
```

使用 `Bash` 工具配合 `mkdir -p` 实现目录创建。

#### Step 0.2多交互式目标期刊确认（如需要）

**触发条件**多`input-context.md` 中未指定 `target_venue`

**执行流程**多

1. **读取 config.json 中的交互配置**
   - 读取 `config.json` 中的 `interaction` 和 `venue_analysis` 配置
   - 获取 `venue_analysis.defined_venues` 列表

2. **调用 interaction-manager 进行期刊选择**
   ```bash
   Skill(skill="interaction-manager", args="{project},phase0_venue_selection")
   ```

3. **处理用户选择**
   - 如果用户选择预定义期刊 → 继续
   - 如果用户选择 "Other" → 提示输入自定义期刊 ID
   - 记录选择到 `input-context.md`

4. **调用 venue-analyzer 获取期刊配置**
   ```bash
   Skill(skill="venue-analyzer", args="{project},{target_venue}")
   ```

5. **读取生成的风格指南**
   - 读取 `workspace/{project}/venue-style-guide.md`
   - 读取 `workspace/{project}/phase0/venue-analysis.json`
   - 验证配置完整性

6. **记录到 input-context.md**
   - 添加/更新 `## 目标会议/期刊` 字段

#### Step 0.3多交互式题目确认（V2 新增）

**执行流程**多

1. **等待 Phase 1 A4 完成创新点形式化**
   - Phase 1 A4 会生成 `phase1/a4-innovations.json`
   - 包含形式化的创新点列表

2. **生成候选题目选项**
   - 基于 A4 的输出，生成 3-5 个候选题目
   - 使用创新点关键词 + 学术术语组合

3. **调用 interaction-manager 进行题目确认**
   ```bash
   Skill(skill="interaction-manager", args="{project},phase0_title_confirmation")
   ```

4. **处理用户选择**
   - 如果用户选择候选题目 → 记录到 `input-context.md`
   - 如果用户自定义题目 → 验证并记录到 `input-context.md`

5. **调用 feedback-collector 保存反馈**
   ```bash
   Skill(skill="feedback-collector", args="{project},phase0_title_confirmation,{反馈数据}")
   ```

#### Step 0.4多交互式摘要框架确认（V2 新增）

**执行流程**多

1. **基于期刊配置生成摘要框架**
   - 从 `venue-style-guide.md` 读取摘要结构要求
   - 生成结构化的摘要框架模板

2. **调用 interaction-manager 进行框架确认**
   ```bash
   Skill(skill="interaction-manager", args="{project},phase0_abstract_framework")
   ```

3. **处理用户编辑**
   - 保存用户确认/编辑的摘要框架
   - 写入 `workspace/{project}/phase0/abstract-framework.md`
   - 供 Phase 3 C1 参考使用

4. **调用 feedback-collector 保存反馈**

### Step 1多验证输入（原有流程，保持兼容）

如果 `target_venue` 已指定，跳过 Step 0.2-0.4，直接执行多

读取 `workspace/{project}/input-context.md` 并验证包含必填字段。

**⚠️ target_venue 验证流程（更新）多**
1. **检查 input-context.md 中是否已指定 `target_venue`**
   - 如果已指定 → 继续执行
   - 如果未指定 → 执行 Step 0.2 交互确认

2. **交互确认目标会议（使用 AskUserQuestion 工具）**

读取 `config.json` 中的 `venues` 配置，生成以下问题多

```
您的论文目标投稿会议/期刊是？

选项多
1. AAAI — AAAI Conference on Artificial Intelligence（双栏，8 页）
2. IJCAI — International Joint Conference on AI（单栏，8 页）
3. ISWC — International Semantic Web Conference（单栏，15 页）
4. WWW — The Web Conference（双栏，8 页）
5. ACL — Association for Computational Linguistics（双栏，8 页）
6. EMNLP — Conference on Empirical Methods in NLP（双栏，8 页）
7. AAMAS — International Conference on Autonomous Agents（双栏，8 页）
8. KR — IEEE International Conference on KR（单栏，10 页）
9. TOIS — ACM Transactions on IS（期刊，无页数限制）
10. TKDE — ACM Transactions on KD（期刊，无页数限制）
11. Other — 自定义其他会议/期刊
```

3. **处理用户选择**

- 如果用户选择具体会议 → 记录该选择，在 `input-context.md` 中追加 `## 目标会议/期刊` 字段
- 如果用户选择 "Other" → 执行以下流程多
  1. 读取根目录的 `venues.md` 文件
  2. 在文件中搜索用户输入的会议名称/ID
  3. 如果找到 → 使用该配置
  4. 如果未找到 → 提示用户多
     - 在 `venues.md` 的"用户自定义配置区"添加新会议
     - 或使用预定义的会议之一
  5. 将用户确认的会议记录到 `input-context.md`

4. **读取并应用会议配置**

- 从根目录的 `venues.md` 文件读取所有会议配置
- 在文件中查找 `selected_venue` 对应的配置块
- 解析配置多`full_name`、`type`、`format`、`page_limit`、`template`、`keywords`、`deadline_note`
- **V2 新增**多解析 `writing_style` 和 `review_criteria` 配置
- 将这些信息传递给后续 Phase

**如果缺失其他必填字段或无效，提供清晰的错误消息和模板结构。**

---

## Phase 编排

### Phase 0多交互式启动确认（V2 新增）

> **仅在首次生成或 `target_venue` 未指定时执行**
> **完成后，`input-context.md` 将包含完整的期刊、题目、摘要框架信息**

**执行顺序**多
1. **期刊选择与配置加载**（Step 0.2，如需要）
   - 调用 `interaction-manager` → `phase0_venue_selection`
   - 调用 `venue-analyzer` → 生成 `venue-style-guide.md`
   - 调用 `feedback-collector` → 保存用户反馈

2. **题目确认**（Step 0.3）
   - 等待 Phase 1 A4 完成
   - 调用 `interaction-manager` → `phase0_title_confirmation`
   - 调用 `feedback-collector` → 保存用户反馈

3. **摘要框架确认**（Step 0.4）
   - 调用 `interaction-manager` → `phase0_abstract_framework`
   - 调用 `feedback-collector` → 保存用户反馈

**输出文件**多
- `workspace/{project}/phase0/venue-analysis.json` — 期刊分析结果
- `workspace/{project}/venue-style-guide.md` — 写作风格指南
- `workspace/{project}/phase0/title-options.json` — 候选题目
- `workspace/{project}/phase0/abstract-framework.md` — 摘要框架
- `workspace/{project}/user-feedback.json` — 用户反馈记录

### Phase 1: Research（文献调研与工程分析）

**调用多** `Skill(skill="paper-phase1-research", args="{project}")`

**等待完成** → 然后执行 Quality Gate 1

### Phase 2: Design（论文设计）

**调用多** `Skill(skill="paper-phase2-design", args="{project}")`

**等待完成** → 然后执行 Quality Gate 2

**V2 新增**多Phase 2 完成后的交互确认

#### Step 2.5多交互式大纲确认（V2 新增）

**执行流程**多

1. **等待 Phase 2 B3 完成论文结构设计**
   - B3 会生成 `phase2/b3-paper-outline.json`

2. **调用 interaction-manager 进行大纲确认**
   ```bash
   Skill(skill="interaction-manager", args="{project},phase2_b3_outline_confirmation")
   ```

3. **处理用户选择**
   - 接受 → 标记大纲已接受，Phase 3 按大纲撰写
   - 修改 → 收集修改意见，反馈给 B3 重新生成
   - 重新生成 → 使用不同配置触发 B3 重新运行

4. **调用 feedback-collector 保存反馈**

**输出文件**多
- `workspace/{project}/phase0/outline-confirmation.json` — 大纲确认记录

### Phase 3: Writing（论文撰写）

**调用多** `Skill(skill="paper-phase3-writing", args="{project}")`

**传递参数**多在 args 中附加目标期刊配置
- 读取 `workspace/{project}/phase1/input-context.md` 中的 `target_venue`
- 从 `config.json.venues.{target_venue}` 读取完整配置
- 将期刊配置作为上下文传递给 Phase 3 Skill
- **V2 新增**多`venue-style-guide.md` 自动传递给 C1 和 C3

**Phase 3 内部参考**多
- C1-section-writer多参考 `venue-style-guide.md` 的章节深度和长度要求
- C3-academic-formatter多应用 `venue-style-guide.md` 的格式规范

**等待完成** → 然后执行 Quality Gate 3

### Phase 4: Quality（质量保障）

**调用多** `Skill(skill="paper-phase4-quality", args="{project}")`

**等待完成** → 然后执行 Quality Gate 4

---

## Quality Gate 建议

每个 Quality Gate 向 `workspace/{project}/quality-gates/gate-{N}.json` 写入记录多

```json
{
  "gate": N,
  "phase": "phase_name",
  "status": "passed|failed",
  "timestamp": "ISO-8601",
  "activated_agents": ["A1", "A2"],
  "activated_skills": ["research-mas-theory"],
  "files_expected": ["文件列表"],
  "files_found": ["实际找到的文件"],
  "files_missing": ["缺失文件（如有）"]
}
```

### Gate 规则

- **Gate 1**多动态验证 — 必选文件（A1 + A4 输出）+ 条件文件（根据实际激活的 Agent/Skill）
- **Gate 2**多固定验证 — B1、B2、B3 的输出（各 2 个文件，共 6 个）
- **Gate 3**多动态验证 — 根据章节数验证所有 section 文件 + 图表 + 最终 paper.md
- **Gate 4**多固定验证 — 至少一个 D1 报告 + 最终论文

---

## Agent 执行协议

生成每个 Agent 时，遵循以下模式多

### 1. 读取 Agent Prompt

读取 `agents/{phase}/{agent-file}.md` 获取该 Agent 的完整系统提示。

### 2. 读取配置

从 `config.json` 获取多
- 该 Agent 使用的模型（`models.writing` 或 `models.reasoning`）
- 该 Agent 的预算限制（`agents.{agent_id}.budget`）

### 3. 执行 Agent 任务

调用 Agent 执行具体任务多
- 传入读取的 .md 文件内容作为系统提示
- 指定具体的任务描述，包含输入输出路径
- Agent 独立执行，输出结果到指定文件

### 4. 传递项目上下文

始终在任务描述中包含 `workspace/{project}/input-context.md` 的路径，让 Agent 动态读取项目信息。

---

## 错误处理

### Agent 失败

如果某个 Agent 失败或停止多
1. 检查 partial output 在 workspace 中
2. 选项多重试一次 / 跳过该 Agent / 手动干预
3. 记录失败原因到 `quality-gates/errors.json`

### Quality Gate 失败

如果某个 Quality Gate 失败多
1. 识别哪个 Agent 输出缺失
2. 选项多重试该 Phase / 跳到下一 Phase / 手动补充
3. 更新 gate status 为 "failed"

---

## Phase 4 完成后多最终用户确认

**当 Phase 4 Quality Gate 通过后，执行最终确认步骤**多

### Step 4.5多检查最终确认配置

从 `config.json` 读取多
- `confirmation.require_approval_for_final` — 是否需要最终确认（默认 true）

如果为 false，直接标记论文为完成，跳过此步骤。

### Step 4.6多生成最终摘要

如果需要最终确认多

```
最终版本摘要
─────────────────────
项目多{project}
目标会议多{venue}
最终评分多X.X/10（目标多Y.Y）
迭代次数多N 轮
版本数多M 个版本（V01 - V{M}）

论文位置多
workspace/{project}/output/paper.md

版本历史多
[显示所有版本的评分递增]
```

### Step 4.7多使用 AskUserQuestion 获取最终决定

```python
AskUserQuestion(
    questions=[
        {
            "question": f"""论文 {project} 的 Phase 4 质量保障已完成。

最终评分多{final_score}/10
目标会议多{venue}
论文位置多workspace/{project}/output/paper.md

请确认下一步操作多""",
            "header": "最终确认",
            "options": [
                        {
                            "label": "接受",
                            "description": "论文满足要求，定稿并完成生成流程"
                        },
                        {
                            "label": "最终修订",
                            "description": "需要额外的单轮修订，启动最后一次迭代"
                        },
                        {
                            "label": "直接编辑",
                            "description": "暂停流程，手动编辑最终版本"
                        }
                    ],
            "multiSelect": false
        }
    ]
)
```

### Step 4.8多处理用户决定

**选择 1多接受**
- 将论文标记为 `final`
- 创建 `workspace/{project}/output/paper-final.md` 副本
- 完成流程，向用户报告成功

**选择 2多最终修订**
- 启动额外一轮 Phase 4 迭代
- 设置 `max_iterations=1`（单轮修订）
- 完成后再次执行最终确认

**选择 3多直接编辑**
- 向用户展示多`workspace/{project}/output/paper.md` 当前位置
- 暂停流程，等待用户编辑
- 用户完成后输入 "RESUME"
- 检测变更，询问是否需要重新评审

---

## 成功标准

论文生成 **完成** 当多
1. Quality Gate 4 状态为 "passed"
2. **最终用户确认通过**（如启用）
3. `workspace/{project}/output/paper.md` 存在
4. 所有必需输出文件已生成

向用户报告成功，包含最终论文位置。
