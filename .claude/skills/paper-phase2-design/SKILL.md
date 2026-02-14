---
name: paper-phase2-design
description: "Executes Phase 2 (Design) with strict serial execution: B1 → B2 → B3. Invoked by paper-generation orchestrator."
---

# Phase 2: Design Orchestrator

## Overview

You are the **Phase 2 Design Orchestrator** — responsible for related work analysis, experiment design, and paper architecture design.

**Invocation:** `Skill(skill="paper-phase2-design", args="{project}")`

**Execution Mode:** Strict serial — B1 → B2 → B3
- Each agent depends on previous agent's output
- No skipping — all three agents must complete successfully

**DO NOT** write paper content — delegate to specialist Agents.

---

## Agent Execution (Serial)

### B1: Related Work Analyst

**Agent File:** `agents/phase2/b1-related-work-analyst.md`

**Model:** `config.models.reasoning`

**Inputs:**
- `workspace/{project}/phase1/a1-literature-survey.json`
- `workspace/{project}/phase1/a4-innovations.json`

**Task:**
- Analyze related work from literature survey
- Position project's innovations within existing research landscape
- Identify research gaps and opportunities
- Output: `workspace/{project}/phase2/b1-related-work.json` + `.md`

**Spawn and wait** for completion, then verify output files exist.

### B2: Experiment Designer

**Agent File:** `agents/phase2/b2-experiment-designer.md`

**Model:** `config.models.reasoning`

**Inputs:**
- `workspace/{project}/phase1/a4-innovations.json` (required)
- `workspace/{project}/input-context.md` (required)
- **All available Phase 1 files** — use Glob to discover:
  - `workspace/{project}/phase1/*.json` (all agent outputs)
  - `workspace/{project}/phase1/skill-*.json` (all skill outputs)

**Task:**
- Design rigorous experiments to validate each innovation
- Define evaluation metrics and baselines
- Specify datasets, parameters, and procedures
- Output: `workspace/{project}/phase2/b2-experiment-design.json` + `.md`

**Spawn and wait** for completion, then verify output files exist.

### B3: Paper Architect

**Agent File:** `agents/phase2/b3-paper-architect.md`

**Model:** `config.models.reasoning`

**Inputs:**
- **All Phase 1 outputs** — use Glob to discover:
  - `workspace/{project}/phase1/*.json`
- **All Phase 2 outputs so far** — use Glob to discover:
  - `workspace/{project}/phase2/b1-related-work.json`
  - `workspace/{project}/phase2/b2-experiment-design.json`

**Task:**
- Design complete paper structure with sections
- Define section titles, content flow, and dependencies
- Specify figures, tables, and their placement
- Output: `workspace/{project}/phase2/b3-paper-outline.json` + `.md`

**Spawn and wait** for completion, then verify output files exist.

---

## Quality Gate 2

**Expected Files (6 total):**
- `phase2/b1-related-work.json` + `.md`
- `phase2/b2-experiment-design.json` + `.md`
- `phase2/b3-paper-outline.json` + `.md`

**Verification:**
1. Use Glob: `workspace/{project}/phase2/*.json` and `*.md`
2. Compare expected vs found
3. Write `workspace/{project}/quality-gates/gate-2.json`

If all files present → Status: "passed", continue to Phase 3.
If any missing → Status: "failed", error handling.

---

## Error Handling

### Agent Failure

If any agent (B1, B2, B3) fails:
1. Log failure details
2. Options: Retry once / Skip to Phase 3 / Manual intervention
3. Update gate status to "failed"

**Note:** Phase 2 has strict serial dependencies — cannot skip agents. A failure in B1 blocks B2 and B3.

### B2 Special Case

If B2 lacks Phase 1 inputs (e.g., skill outputs missing):
- Proceed with available inputs only
- Log limitation in gate record
- May affect experiment design quality

---

## Success Criteria

Phase 2 is **COMPLETE** when:
1. Quality Gate 2 status is "passed"
2. All three agent outputs exist
3. B3 paper outline exists and is valid

Report completion to orchestrator and return to Phase 3.
