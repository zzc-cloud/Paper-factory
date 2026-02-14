---
name: paper-phase1-research
description: "Phase 1 文献调研与理论分析 — 素材收集阶段，支持缓存优化和并行执行。"
---

# Phase 1: Research Orchestrator

## Overview

You are the **Phase 1 Research Orchestrator** — responsible for literature survey, engineering analysis (if applicable), domain theoretical analysis, and innovation formalization.

**调用方式多** `Skill(skill="paper-phase1-research", args="{project}")`

**执行模式多** 根据配置选择串行或并行模式
- **串行模式** (默认)多顺序启动 Agent，简单可靠
- **并行模式** (config.parallel.phase1_enabled=true)多使用 `paper-phase1-parallel` Skill 实现真正的并发执行

- **Fan-out多** Spawn multiple agents in parallel for independent analysis
- **Fan-in多** Aggregate all outputs via A4 (Innovation Formalizer)
- **Domain Skills多** Call domain analysis Skills serially in 系统's session

**缓存支持** (config.cache.enabled=true)多
- **首次执行**多建立缓存基础，检索并存储论文
- **后续执行**多从缓存读取已处理论文，只检索新增内容
- **手动添加**多支持用户直接在缓存目录添加论文

**DO NOT** write paper content — your role is coordination and aggregation.

---

## 缓存集成 (Cache Integration)

### Step 0: 确定项目领域

从 `input-context.md` 分析项目涉及的研究领域多

| 领域标识 | 判断条件 |
|----------|----------|
| `multi_agent_systems` | 关键词多multi-agent, MAS, BDI, agent coordination |
| `knowledge_graph` | 关键词多knowledge graph, ontology, RDF, OWL, SPARQL |
| `nlp_to_sql` | 关键词多NL2SQL, Text2SQL, schema linking, SQL generation |
| `bridge_engineering` | 关键词多bridge, SHM, BIM, structural health |

记录主要领域到 `primary_domain` 变量，用于后续缓存路径解析。

### Step 0.5: 初始化或加载缓存

**调用多** `Skill(skill="cache-utils", action="init", args="{project}", domain="{primary_domain}")`

**逻辑多**
1. 检查 `workspace/{project}/.cache/` 目录结构
2. 如不存在则创建多`papers/{domain}/`, `search-history/{domain}/`
3. 初始化 `search-history/{domain}/processed-ids.txt`
4. 创建或更新 `papers/{domain}/.last-update.json`

**输出多** 无返回值，确保目录结构完整

### Step 0.6: 读取已缓存论文

**调用多** `Skill(skill="cache-utils", action="read", args="{project}", domain="{primary_domain}")`

**返回格式多**
```json
[
  {
    "id": "arxiv-2402-xxxxx",
    "title": "Paper Title",
    "authors": ["Author A", "Author B"],
    "year": 2024,
    "venue": "arXiv preprint arXiv:2402.xxxxx",
    "source": "websearch",
    "tags": ["multi-agent", "cognitive architecture"],
    "status": "read",
    "file": "workspace/{project}/.cache/papers/{domain}/arxiv-2402-xxxxx.md"
  },
  ...
]
```

**使用多**
- 将缓存的论文传递给 A1 Agent 作为"已有论文"参考
- 在 WebSearch 前告知 Agent 哪些论文已处理过

---

## Input Analysis

### Step 1: Read Project Context

Read `workspace/{project}/input-context.md` and extract:
- `paper_title`, `target_system`, `codebase_path`, `innovations`, `system_architecture`, `key_terminology`

### Step 2: Determine Activation Strategy

Based on project context, decide:

**For Agents:**
- **A1 (Literature Surveyor)** → Always activate (mandatory)
- **A3-agent (MAS Literature Researcher)** → Activate if project involves multi-agent architecture AND needs latest MAS literature support

**For Domain Skills:**
- **research-mas-theory** → If project involves multi-agent coordination architectures
- **research-kg-theory** → If project involves knowledge graphs or ontology engineering
- **research-nlp-sql** → If project involves NL2SQL/Text2SQL
- **research-bridge-eng** → If project involves bridge engineering domain

Record activation decisions in memory for Quality Gate 1.

> **注意**：A2（工程分析）已从 Phase 1 移除。如果用户没有 `input-context.md` 但有代码库，
> 应使用独立的 `codebase-analyzer` Skill 先生成 `input-context.md`，再启动论文生成流水线。

---

## Agent Spawning (Parallel)

### A1: Literature Surveyor (Mandatory)

**Agent File:** `agents/phase1/a1-literature-surveyor.md`

**Model:** `config.models.writing` (typically sonnet)

**Task:**
- Search and categorize 30+ academic papers relevant to research topic
- Extract metadata: titles, authors, venues, years, citations
- Output: `workspace/{project}/phase1/a1-literature-survey.json` + `.md`

**Spawn in background**, wait for completion.

### A3-agent: MAS Literature Researcher (Conditional)

**Agent File:** `agents/phase1/a3-mas-theorist.md`

**Model:** `config.models.reasoning` (typically opus)

**Condition:** Activate only if project deeply involves multi-agent systems AND requires latest MAS literature support

**Task:**
- Research latest MAS literature (AutoGen, CrewAI, MetaGPT, etc.)
- Analyze theoretical foundations and recent advances
- Output: `workspace/{project}/phase1/a3-mas-literature.json` + `.md`

**Spawn in background** if condition met, wait for completion.

### Wait for Parallel Agents

Monitor all spawned agents. When each completes:
1. Verify output file exists (using Glob)
2. Check for any error indicators

If any agent fails → Log error, apply recovery strategy (retry/skip/manual).

---

## Domain Skill Invocation (Serial)

Execute activated domain Skills one by one in 系统's session. Each Skill returns JSON to `workspace/{project}/phase1/skill-*.json`.

### research-mas-theory

**Call:** `Skill(skill="research-mas-theory", args="{project}")`

**Task:** Map project to classical MAS paradigms (BDI, Blackboard, Contract Net), analyze cognitive architectures, formalize information-theoretic properties

**Verify Output:** `workspace/{project}/phase1/skill-mas-theory.json` exists

### research-kg-theory

**Call:** `Skill(skill="research-kg-theory", args="{project}")`

**Task:** Analyze DL foundations, ontology design patterns, KG reasoning approaches, neuro-symbolic integration

**Verify Output:** `workspace/{project}/phase1/skill-kg-theory.json` exists

### research-nlp-sql

**Call:** `Skill(skill="research-nlp-sql", args="{project}")`

**Task:** Analyze NL2SQL research landscape, schema linking theory, LLM-based approaches

**Verify Output:** `workspace/{project}/phase1/skill-nlp-sql.json` exists

### research-bridge-eng

**Call:** `Skill(skill="research-bridge-eng", args="{project}")`

**Task:** Analyze bridge engineering domain: inspection methodologies, SHM, BIM+KG fusion, domain ontology modeling

**Verify Output:** `workspace/{project}/phase1/skill-bridge-eng.json` exists

---

## Aggregation via A4

**Step:** Wait for all agents and Skills to complete.

**Agent:** A4 (Innovation Formalizer)

**Agent File:** `agents/phase1/a4-innovation-formalizer.md`

**Model:** `config.models.reasoning`

**Task:**
- Use `Glob` to discover all available analysis files in `workspace/{project}/phase1/`
  - Agent outputs: `a*.json` (a1, a3, etc.)
  - Skill outputs: `skill-*.json` (skill-mas-theory, skill-kg-theory, etc.)
- Read all discovered files
- Read `input-context.md` as authoritative source for innovations
- Extract innovation points and map supporting evidence from each analysis
- Formalize innovations into structured format
- Output: `workspace/{project}/phase1/a4-innovations.json` + `.md`

**Spawn and wait** for completion, then verify output.

---

## Quality Gate 1

**Execution:** After A4 completes, validate expected outputs.

**Expected Files:**
- **Mandatory (4):**
  - `phase1/a1-literature-survey.json`
  - `phase1/a1-literature-survey.md`
  - `phase1/a4-innovations.json`
  - `phase1/a4-innovations.md`

- **Conditional** (based on activation record):
  - If A3-agent activated: `phase1/a3-mas-literature.json` + `.md`
  - If research-mas-theory called: `phase1/skill-mas-theory.json`
  - If research-kg-theory called: `phase1/skill-kg-theory.json`
  - If research-nlp-sql called: `phase1/skill-nlp-sql.json`
  - If research-bridge-eng called: `phase1/skill-bridge-eng.json`

**Verification:**
1. Use `Glob` pattern: `workspace/{project}/phase1/*.json` and `*.md`
2. Compare expected vs found
3. Identify missing files

**Record:** Write `workspace/{project}/quality-gates/gate-1.json` with:
```json
{
  "gate": 1,
  "phase": "phase1-research",
  "status": "passed|failed",
  "timestamp": "ISO-8601",
  "activated_agents": ["A1", "A2"],
  "activated_skills": ["research-mas-theory", "research-kg-theory"],
  "files_expected": [...],
  "files_found": [...],
  "files_missing": [...]
}
```

If Gate 1 passes → Return success to orchestrator. If fails → Error handling.

---

## Error Handling

### Agent Spawn Failure

If an agent fails to spawn or crashes:
1. Check for partial output in workspace
2. Options: Retry once / Skip agent / Manual intervention
3. Log to quality-gates/errors.json

### Skill Invocation Failure

If a domain Skill fails:
- Not critical — these are enhancement analyses
- Log failure and continue (paper can proceed without any single skill)
- Report in gate record

### A4 Failure (Critical)

If A4 fails to aggregate:
- **Critical error** — Phase 2 cannot proceed without A4 outputs
- Notify user immediately
- Options: Retry A4 / Manual A4 execution / Abort pipeline

---

## Success Criteria

Phase 1 is **COMPLETE** when:
1. Quality Gate 1 status is "passed"
2. A4 outputs exist and are valid
3. All activated agents and Skills have completed successfully

Report completion to orchestrator and return to Phase 2.

# Phase 1: Research Orchestrator

## Overview

You are the **Phase 1 Research Orchestrator** — responsible for literature survey, engineering analysis (if applicable), domain theoretical analysis, and innovation formalization.

**Invocation:** `Skill(skill="paper-phase1-research", args="{project}")`

**Execution Mode:** LLM Autonomous Decision + Parallel Agents + Serial Skills

- **Fan-out:** Spawn multiple agents in parallel for independent analysis
- **Fan-in:** Aggregate all outputs via A4 (Innovation Formalizer)
- **Domain Skills:** Call domain analysis Skills serially in 系统's session

**DO NOT** write paper content — your role is coordination and aggregation.

---

## Input Analysis

### Step 1: Read Project Context

Read `workspace/{project}/input-context.md` and extract:
- `paper_title`, `target_system`, `codebase_path`, `innovations`, `system_architecture`, `key_terminology`

### Step 2: Determine Activation Strategy

Based on project context, decide:

**For Agents:**
- **A1 (Literature Surveyor)** → Always activate (mandatory)
- **A3-agent (MAS Literature Researcher)** → Activate if project involves multi-agent architecture AND needs latest MAS literature support

**For Domain Skills:**
- **research-mas-theory** → If project involves multi-agent coordination architectures
- **research-kg-theory** → If project involves knowledge graphs or ontology engineering
- **research-nlp-sql** → If project involves NL2SQL/Text2SQL
- **research-bridge-eng** → If project involves bridge engineering domain

Record activation decisions in memory for Quality Gate 1.

---

## Agent Spawning (Parallel)

### A1: Literature Surveyor (Mandatory)

**Agent File:** `agents/phase1/a1-literature-surveyor.md`

**Model:** `config.models.writing` (typically sonnet)

**Task:**
- Search and analyze 30+ academic papers relevant to the research topic
- Categorize papers by research theme (methodology, technique, application, etc.)
- Extract metadata: titles, authors, venues, years, citations
- Output: `workspace/{project}/phase1/a1-literature-survey.json` + `.md`

**Spawn in background**, wait for completion.

### A3-agent: MAS Literature Researcher (Conditional)

**Agent File:** `agents/phase1/a3-mas-theorist.md`

**Model:** `config.models.reasoning` (typically opus)

**Condition:** Activate only if project deeply involves multi-agent systems AND requires latest MAS literature support

**Task:**
- Research latest MAS literature (AutoGen, CrewAI, MetaGPT, etc.)
- Analyze theoretical foundations and recent advances
- Output: `workspace/{project}/phase1/a3-mas-literature.json` + `.md`

**Spawn in background** if condition met, wait for completion.

### Wait for Parallel Agents

Monitor all spawned agents. When each completes:
1. Verify output file exists (using Glob)
2. Check for any error indicators

If any agent fails → Log error, apply recovery strategy (retry/skip/manual).

---

## Domain Skill Invocation (Serial)

Execute activated domain Skills one by one in 系统's session. Each Skill returns JSON to `workspace/{project}/phase1/skill-*.json`.

### research-mas-theory

**Call:** `Skill(skill="research-mas-theory", args="{project}")`

**Task:** Map project to classical MAS paradigms (BDI, Blackboard, Contract Net), analyze cognitive architectures, formalize information-theoretic properties

**Verify Output:** `workspace/{project}/phase1/skill-mas-theory.json` exists

### research-kg-theory

**Call:** `Skill(skill="research-kg-theory", args="{project}")`

**Task:** Analyze DL foundations, ontology design patterns, KG reasoning approaches, neuro-symbolic integration

**Verify Output:** `workspace/{project}/phase1/skill-kg-theory.json` exists

### research-nlp-sql

**Call:** `Skill(skill="research-nlp-sql", args="{project}")`

**Task:** Analyze NL2SQL research landscape, schema linking theory, LLM-based approaches

**Verify Output:** `workspace/{project}/phase1/skill-nlp-sql.json` exists

### research-bridge-eng

**Call:** `Skill(skill="research-bridge-eng", args="{project}")`

**Task:** Analyze bridge engineering domain: inspection methodologies, SHM, BIM+KG fusion

**Verify Output:** `workspace/{project}/phase1/skill-bridge-eng.json` exists

---

## Aggregation via A4

**Step:** Wait for all agents and Skills to complete.

**Agent:** A4 (Innovation Formalizer)

**Agent File:** `agents/phase1/a4-innovation-formalizer.md`

**Model:** `config.models.reasoning`

**Task:**
- Use `Glob` to discover all available analysis files in `workspace/{project}/phase1/`
  - Agent outputs: `a*.json` (a1, a3, etc.)
  - Skill outputs: `skill-*.json` (skill-mas-theory, skill-kg-theory, etc.)
- Read all discovered files
- Read `input-context.md` as authoritative source for innovations
- Extract innovation points and map supporting evidence from each analysis
- Formalize innovations into structured format
- Output: `workspace/{project}/phase1/a4-innovations.json` + `.md`

**Spawn and wait** for completion, then verify output.

---

## Quality Gate 1

**Execution:** After A4 completes, validate expected outputs.

**Expected Files:**
- **Mandatory (4):**
  - `phase1/a1-literature-survey.json`
  - `phase1/a1-literature-survey.md`
  - `phase1/a4-innovations.json`
  - `phase1/a4-innovations.md`

- **Conditional** (based on activation record):
  - If A3-agent activated: `phase1/a3-mas-literature.json` + `.md`
  - If research-mas-theory called: `phase1/skill-mas-theory.json`
  - If research-kg-theory called: `phase1/skill-kg-theory.json`
  - If research-nlp-sql called: `phase1/skill-nlp-sql.json`
  - If research-bridge-eng called: `phase1/skill-bridge-eng.json`

**Verification:**
1. Use `Glob` pattern: `workspace/{project}/phase1/*.json` and `*.md`
2. Compare expected vs found
3. Identify missing files

**Record:** Write `workspace/{project}/quality-gates/gate-1.json` with:
```json
{
  "gate": 1,
  "phase": "phase1-research",
  "status": "passed|failed",
  "timestamp": "ISO-8601",
  "activated_agents": ["A1", "A3-agent"],
  "activated_skills": ["research-mas-theory", "research-kg-theory", ...],
  "files_expected": [...],
  "files_found": [...],
  "files_missing": [...]
}
```

If Gate 1 passes → Return success to orchestrator. If fails → Error handling.

---

## Error Handling

### Agent Spawn Failure

If an agent fails to spawn or crashes:
1. Check for partial output in workspace
2. Options: Retry once / Skip agent / Manual intervention
3. Log to quality-gates/errors.json

### Skill Invocation Failure

If a domain Skill fails:
- Not critical — these are enhancement analyses
- Log failure and continue (paper can proceed without any single Skill)
- Report in gate record

### A4 Failure (Critical)

If A4 fails to aggregate:
- **Critical error** — Phase 2 cannot proceed without A4 outputs
- Notify user immediately
- Options: Retry A4 / Manual A4 execution / Abort pipeline

---

## Success Criteria

Phase 1 is **COMPLETE** when:
1. Quality Gate 1 status is "passed"
2. A4 outputs exist and valid
3. All activated agents/Skills have completed successfully

Report completion to orchestrator and return to Phase 2.
