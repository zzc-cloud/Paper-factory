---
name: paper-phase1-parallel
description: "Phase 1 并行执行增强 — 使用 Task 工具实现真正的 Agent 并行执行。"
---

# Phase 1: Parallel Execution Enhancement

## Overview

你 **Phase 1 并行执行增强器** — 使用 `Task` 工具实现 A1、A3 Agent 的真正并行执行，替代当前的串行 Skill 调用模式。

`★ Insight ─────────────────────────────────────`
- **并行执行原理**多通过 `Task` 工具的 `run_in_background` 参数，多个 Agent 可以真正并发执行，而非顺序等待
- **调度模式**多Fan-out（并行分发独立任务）→ 等待完成 → Fan-in（聚合结果）→ 串行依赖（A4）
- **错误隔离**多每个 Agent 在独立进程中运行，单个失败不影响其他 Agent 的执行
`★ ────────────────────────────────────────────────`

**调用方式多** `Skill(skill="paper-phase1-parallel", args="{project}")`

**核心改进多**
- **真正的并行执行** — A1/A3 Agent 同时运行，而非顺序等待
- **状态监控** — 通过 `TaskOutput` 实时追踪每个 Agent 的进度
- **智能恢复** — 单个 Agent 失败时可以选择性重试，不影响已完成的工作
- **性能提升** — Phase 1 执行时间预计减少 40-60%

---

## Execution Flow

```
┌─────────────────────────────────────────────────────────┐
│              Phase 1: Parallel Enhancement              │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  Step 1: 分析项目上下文并确定激活策略                  │
│           └─ 读取 input-context.md                           │
│           └─ 决定 A1/A2/A3 激活条件                        │
│                                                           │
│  Step 2: 并行分发 (Fan-out)                               │
│           ┌─────────────────────────────────────┐              │
│           │  使用 Task 工具并行启动 Agent     │              │
│           │  - A1: 始终激活                          │              │
│           │  - A3: 条件激活 (MAS 领域)       │              │
│           │  每个使用 run_in_background=true │              │
│           └─────────────────────────────────────┘              │
│                     │                                       │
│  Step 3: 监控执行状态                                    │
│           └─ 使用 TaskOutput 等待所有 Agent 完成               │
│                                                           │
│  Step 4: 领域 Skill 分析 (串行)                          │
│           └─ research-*-theory Skills 按序执行                 │
│                                                           │
│  Step 5: 聚合 (Fan-in)                                   │
│           └─ A4 (Innovation Formalizer) 汇总所有输出              │
│                                                           │
│  Step 6: Quality Gate 1 验证                               │
│           └─ 验证所有预期输出文件存在                         │
└─────────────────────────────────────────────────────────┘
```

---

## Implementation Protocol

### Step 1: Read and Analyze Project Context

**Action:** Read `workspace/{project}/input-context.md`

**Extract:**
- `paper_title` — 用于确定研究领域
- `target_system` — 目标系统描述
- `codebase_path` — 代码库路径（仅供参考，不再用于 A2 激活）
- `innovations` — 创新点列表
- `system_architecture` — 系统架构描述
- `key_terminology` — 关键术语

**Determine Activation Strategy:**

```
A1 (Literature Surveyor): ALWAYS activate
A3 (MAS Literature): Activate IF project involves multi-agent systems
  - Keywords: "multi-agent", "agent communication", "coordination", "negotiation"
  - OR system_architecture mentions agent-based design
```

**Record Strategy:** Store activation decisions for Quality Gate 1 reporting.

---

### Step 2: Parallel Agent Dispatch (Fan-out)

**Critical:** Use `Task` tool with `run_in_background=true` for true parallel execution.

#### Agent 1: Literature Surveyor (Always)

```python
Task(
    subagent_type="general-purpose",
    model="haiku",  # Use haiku for faster literature search
    name="A1-LiteratureSurveyor",
    run_in_background=true,
    prompt="""You are the Literature Surveyor Agent for Phase 1 research.

READ: agents/phase1/a1-literature-surveyor.md for your full system prompt.

YOUR TASK:
1. Search and categorize 30+ academic papers relevant to: {paper_title}
2. Extract metadata: titles, authors, venues, years, citations
3. Organize by research theme (methodology, technique, application)

OUTPUT FILES:
- workspace/{project}/phase1/a1-literature-survey.json (metadata)
- workspace/{project}/phase1/a1-literature-survey.md (summary)

Return: brief confirmation when complete."""
)
```

**Expected Output:** `workspace/{project}/phase1/a1-literature-survey.json` + `.md`

#### Agent 2: MAS Literature Researcher (Conditional)

**Only dispatch if MAS domain condition is met.**

```python
Task(
    subagent_type="general-purpose",
    model="opus",
    name="A3-MASLiterature",
    run_in_background=true,
    prompt="""You are the MAS Literature Researcher Agent for Phase 1 research.

READ: agents/phase1/a3-mas-theorist.md for your full system prompt.

RESEARCH FOCUS: Latest MAS literature (AutoGen, CrewAI, MetaGPT, etc.)

YOUR TASK:
1. Research latest MAS literature and theoretical foundations
2. Analyze recent advances in multi-agent architectures
3. Identify relevant paradigms (BDI, Blackboard, Contract Net)

OUTPUT FILES:
- workspace/{project}/phase1/a3-mas-literature.json
- workspace/{project}/phase1/a3-mas-literature.md

Return: brief confirmation when complete."""
)
```

**Expected Output:** `workspace/{project}/phase1/a3-mas-literature.json` + `.md`

---

### Step 3: Monitor Execution

**For each dispatched agent:**

```python
# Store returned task_id for each agent
task_ids = {
    "A1": a1_task_id,
    "A3": a3_task_id   # if dispatched
}

# Monitor completion
for agent_name, task_id in task_ids.items():
    result = TaskOutput(task_id=task_id, block=true, timeout=300000)
    if result["status"] == "completed":
        log(f"{agent_name} completed successfully")
    else:
        handle_failure(agent_name, result)
```

**Failure Handling:**
- If A1 fails → **Critical** (mandatory agent), retry once
- If A3 fails → **Non-critical** (conditional agent), log and continue
- Verify partial outputs in workspace before retry

---

### Step 4: Domain Skills (Serial)

After all agents complete, execute domain-specific theory Skills:

**For each applicable domain Skill:**

```python
Skill(skill="research-mas-theory", args="{project}")  # if MAS domain
Skill(skill="research-kg-theory", args="{project}")   # if KG domain
Skill(skill="research-nlp-sql", args="{project}")  # if NL2SQL domain
Skill(skill="research-bridge-eng", args="{project}") # if Bridge domain
```

**Verify outputs:** `workspace/{project}/phase1/skill-*.json`

---

### Step 5: Aggregation (Fan-in)

**Agent 4: Innovation Formalizer**

```python
Task(
    subagent_type="general-purpose",
    model="opus",
    name="A4-InnovationFormalizer",
    prompt="""You are the Innovation Formalizer Agent for Phase 1 research.

READ: agents/phase1/a4-innovation-formalizer.md for your full system prompt.

YOUR TASK:
1. Use Glob to discover all analysis files in workspace/{project}/phase1/
2. Read all discovered files (agent outputs: a*.json, skill outputs: skill-*.json)
3. Read input-context.md as authoritative source
4. Extract innovation points and map supporting evidence
5. Formalize into structured format

OUTPUT FILES:
- workspace/{project}/phase1/a4-innovations.json
- workspace/{project}/phase1/a4-innovations.md

Return: confirmation when complete."""
)
```

**Wait for completion** and verify outputs.

---

### Step 6: Quality Gate 1

**Validation:**

1. Use `Glob` to find all files in `workspace/{project}/phase1/`
2. Compare expected vs found
3. Write gate record to `workspace/{project}/quality-gates/gate-1.json`

```json
{
  "gate": 1,
  "phase": "phase1-parallel",
  "status": "passed|failed",
  "timestamp": "ISO-8601",
  "parallel_mode": true,
  "dispatched_agents": ["A1", "A3"],
  "activation_strategy": {
    "A1": "always",
    "A3": "conditional: mas_domain"
  },
  "execution_time_seconds": 123,
  "files_expected": [...],
  "files_found": [...],
  "files_missing": [...]
}
```

---

## Performance Monitoring

**Track and report:**

| Metric | Measurement |
|--------|-------------|
| **Agent start time** | Timestamp when first Task dispatched |
| **Agent completion times** | Individual completion timestamps |
| **Total Phase 1 duration** | From first dispatch to A4 completion |
| **Parallel efficiency** | (sum of agent times) / (actual elapsed time) |

**Expected Improvement:**
- **Sequential execution:** ~15-20 minutes
- **Parallel execution:** ~8-12 minutes
- **Speedup:** 40-60% reduction

---

## Error Handling Strategy

### Agent Spawn Failure
- Check for partial output in workspace
- Options: Retry once / Skip agent / Manual intervention
- Log to `quality-gates/errors.json`

### Individual Agent Failure
- **A1 Failure:** Critical — retry once, then abort if fails
- **A3 Failure:** Non-critical — log and continue

### A4 Failure (Critical)
- **Critical error** — Phase 2 cannot proceed
- Notify user immediately
- Options: Retry A4 / Manual execution / Abort pipeline

---

## Success Criteria

Phase 1 Parallel is **COMPLETE** when:
1. Quality Gate 1 status is "passed"
2. A4 outputs exist and are valid
3. All activated agents have completed successfully
4. Execution time shows improvement over sequential mode

**Report completion** with performance metrics to orchestrator.

---

## Integration Notes

**This Skill replaces:**
- The sequential agent spawning in `paper-phase1-research`

**Called by:**
- `paper-generation` orchestrator (when parallel mode enabled)

**Configuration:**
- Respects `config.json` for model selection and agent settings
- Uses `haiku` for A1 (faster literature search) where appropriate
- Falls back to configured models if haiku unavailable

---

# Version History
- v1.0 (2026-02-14): Initial parallel execution enhancement using Task tool
