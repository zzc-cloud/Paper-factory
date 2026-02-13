---
name: paper-phase1-research
description: "Phase 1 文献调研与工程分析 — 素材收集阶段。"
---

# Phase 1: Research Orchestrator

## Overview

You are the **Phase 1 Research Orchestrator** — responsible for literature survey, engineering analysis (if applicable), domain theoretical analysis, and innovation formalization.

**调用方式：** `Skill(skill="paper-phase1-research", args="{project}")`

**执行模式：** LLM 自主决策 + 并行 Agent + 串行 Skill

- **Fan-out：** Spawn multiple agents in parallel for independent analysis
- **Fan-in：** Aggregate all outputs via A4 (Innovation Formalizer)
- **Domain Skills：** Call domain analysis Skills serially in Team Lead's session

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
- **A2 (Engineering Analyst)** → Activate if `codebase_path` exists and points to valid directory
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

**Budget:** `config.agents.a1.budget`

**Task:**
- Search and categorize 30+ academic papers relevant to research topic
- Extract metadata: titles, authors, venues, years, citations
- Output: `workspace/{project}/phase1/a1-literature-survey.json` + `.md`

**Spawn in background**, wait for completion.

### A2: Engineering Analyst (Conditional)

**Agent File:** `agents/phase1/a2-engineering-analyst.md`

**Model:** `config.models.reasoning` (typically opus)

**Budget:** `config.agents.a2.budget`

**Condition:** Activate only if `codebase_path` exists in input-context.md and points to valid directory

**Task:**
- Analyze codebase architecture, design patterns, and technical stack
- Identify engineering innovations and technical trade-offs
- Output: `workspace/{project}/phase1/a2-engineering-analysis.json` + `.md`

**Spawn in background** if condition met, wait for completion.

### A3-agent: MAS Literature Researcher (Conditional)

**Agent File:** `agents/phase1/a3-mas-theorist.md`

**Model:** `config.models.reasoning` (typically opus)

**Budget:** `config.agents.a3.budget`

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

Execute activated domain Skills one by one in Team Lead's session. Each Skill returns JSON to `workspace/{project}/phase1/skill-*.json`.

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

**Budget:** `config.agents.a4.budget`

**Task:**
- Use `Glob` to discover all available analysis files in `workspace/{project}/phase1/`
  - Agent outputs: `a*.json` (a1, a2, a3, etc.)
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
  - If A2 activated: `phase1/a2-engineering-analysis.json` + `.md`
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
- **Domain Skills:** Call domain analysis Skills serially in Team Lead's session

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
- **A2 (Engineering Analyst)** → Activate if `codebase_path` exists and points to valid directory
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

**Budget:** `config.agents.a1.budget`

**Task:**
- Search and analyze 30+ academic papers relevant to the research topic
- Categorize papers by research theme (methodology, technique, application, etc.)
- Extract metadata: titles, authors, venues, years, citations
- Output: `workspace/{project}/phase1/a1-literature-survey.json` + `.md`

**Spawn in background**, wait for completion.

### A2: Engineering Analyst (Conditional)

**Agent File:** `agents/phase1/a2-engineering-analyst.md`

**Model:** `config.models.reasoning` (typically opus)

**Budget:** `config.agents.a2.budget`

**Condition:** Activate only if `codebase_path` exists in input-context.md and points to valid directory

**Task:**
- Analyze codebase architecture
- Extract engineering patterns and design decisions
- Identify novel technical contributions
- Output: `workspace/{project}/phase1/a2-engineering-analysis.json` + `.md`

**Spawn in background** if condition met, wait for completion.

### A3-agent: MAS Literature Researcher (Conditional)

**Agent File:** `agents/phase1/a3-mas-theorist.md`

**Model:** `config.models.reasoning` (typically opus)

**Budget:** `config.agents.a3.budget`

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

Execute activated domain Skills one by one in Team Lead's session. Each Skill returns JSON to `workspace/{project}/phase1/skill-*.json`.

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

**Budget:** `config.agents.a4.budget`

**Task:**
- Use `Glob` to discover all available analysis files in `workspace/{project}/phase1/`
  - Agent outputs: `a*.json` (a1, a2, a3, etc.)
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
  - If A2 activated: `phase1/a2-engineering-analysis.json` + `.md`
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
  "activated_agents": ["A1", "A2", "A3-agent"],
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
