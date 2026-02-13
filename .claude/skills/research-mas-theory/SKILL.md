---
name: research-mas-theory
description: Performs Multi-Agent Systems (MAS) theoretical analysis — maps a target system to classical MAS paradigms, cognitive architectures, and information-theoretic formalisms. Runs synchronously using LLM knowledge only (no WebSearch).
---

# MAS Theory Research Skill

## Overview

This skill performs a comprehensive Multi-Agent Systems (MAS) theoretical analysis for a target system described in `workspace/{project}/phase1/input-context.md`. It maps the system to classical MAS paradigms, cognitive architectures, and formal theoretical frameworks, producing structured findings for downstream paper writing agents.

This skill is extracted from the A3 MAS Theorist agent, focusing on the theory mapping and formalization work that can be performed purely from LLM knowledge — no WebSearch required.

## Invocation

```
Skill(skill="research-mas-theory", args="{project}")
```

Where `{project}` is the project directory name under `workspace/`.

## Constraints

- **No WebSearch**: This skill runs synchronously in the Team Lead's session. All analysis is based on LLM knowledge of MAS theory, cognitive science, and information theory. Do NOT attempt to use WebSearch or WebFetch.
- **Tools available**: Read, Write, Glob, Grep only.
- **Single output file**: Write exactly one JSON file to `workspace/{project}/phase1/skill-mas-theory.json`.
- **Input dependency**: Requires `workspace/{project}/phase1/input-context.md` to exist.
- **Scope boundary**: Do NOT analyze source code (that is A2's job), do NOT search for papers (that is A1's job), do NOT formalize engineering innovations into paper contributions (that is A4's job). Focus exclusively on MAS theory mapping and formalization.

---

## Execution Steps

### Step 1: Read Input Context

Read `workspace/{project}/phase1/input-context.md` to understand the target system. Extract:

- System name and purpose
- Agent/component architecture (how many agents, what roles)
- Execution model (serial, parallel, hierarchical, pipeline, hybrid)
- Communication mechanism (explicit messages, shared context, file-based, implicit)
- Evidence/artifact accumulation approach (if any)
- Theoretical claims made by the system designers (information-theoretic, convergence, etc.)
- Whether the system uses ontologies or knowledge graphs

If `input-context.md` does not exist or is empty, STOP and write the output JSON with `"status": "error"` and a descriptive `"summary"`.

### Step 2: Perform MAS Paradigm Mapping

For each of the six classical MAS paradigms below, assess its relevance to the target system. For each paradigm, produce a `similarity_score` (0.0 to 1.0), `matching_aspects`, `diverging_aspects`, and a `relevance_assessment`. After assessing all six, determine the `primary_paradigm`, `secondary_paradigms`, and `novel_elements`.

#### 2.1 BDI (Belief-Desire-Intention) Architecture

Core theory: Rao & Georgeff (1995). Agents maintain beliefs about the world, desires (goals), and intentions (committed plans). A plan library maps belief-desire pairs to action sequences. The deliberation cycle selects intentions from desires based on current beliefs. Key characteristics: explicit mental attitudes (beliefs, desires, intentions), plan library with context-sensitive plan selection, means-end reasoning to decompose goals into subgoals, and commitment strategies (blind, single-minded, open-minded). Mapping guidance: Look for whether the target system's agents have explicit goal representations, maintain beliefs about task state, and select from alternative plans. LLM-based agents often have implicit BDI — the prompt encodes beliefs and desires, the LLM's reasoning acts as the deliberation cycle.

#### 2.2 Blackboard Architecture

Core theory: Nii (1986), Hayes-Roth (1985). A shared data structure (the blackboard) is incrementally built by multiple specialist knowledge sources (KSs). A control shell schedules which KS acts next based on the current blackboard state. Key characteristics: central shared solution space, independent knowledge sources that read/write the blackboard, opportunistic problem solving, and control shell for scheduling. Mapping guidance: Look for shared artifacts, shared context, or shared state that multiple agents contribute to. File-based coordination (agents writing to a shared workspace) is a modern form of blackboard. If the target system accumulates evidence or artifacts from multiple agents into a shared structure, this paradigm is highly relevant.

#### 2.3 Contract Net Protocol

Core theory: Smith (1980). A manager agent announces tasks; contractor agents evaluate and bid; the manager awards contracts to the best bidders. Key characteristics: task announcement/bid/award cycle, decentralized task allocation, agents self-assess capability. Mapping guidance: Look for dynamic task assignment or capability-based routing. Most LLM-based MAS use static role assignment rather than Contract Net, so this paradigm often has low relevance — but note it if the target system has any dynamic dispatch.

#### 2.4 Shared Memory / Tuple Space

Core theory: Gelernter (1985), Linda coordination language. Agents coordinate through a shared associative memory (tuple space) with operations: out (write), in (read and remove), rd (read without removing). Key characteristics: decoupled communication, temporal decoupling, associative access by pattern. Mapping guidance: Look for shared data stores or file systems that agents use for coordination. If agents write structured outputs that other agents later read by pattern (e.g., reading all phase-1 outputs), this resembles tuple space coordination.

#### 2.5 Pipeline / Assembly Line Architecture

Sequential processing where each stage performs a specialized transformation. Output of stage N becomes input of stage N+1. Key characteristics: linear flow, stage specialization, intermediate representations between stages, throughput limited by bottleneck. Mapping guidance: Look for sequential phase execution where agents run in a defined order and each agent's output feeds the next. If the target system has numbered phases or stages, this paradigm is likely relevant.

#### 2.6 Stigmergy

Core theory: Grasse (1959), Theraulaz & Bonabeau (1999). Agents coordinate indirectly by modifying the shared environment. Other agents perceive these modifications and adjust behavior accordingly. Key characteristics: indirect communication through environment modification, self-organizing behavior from local rules, no central coordinator required, scalable. Mapping guidance: Look for implicit context inheritance where an agent's output modifies the shared environment and subsequent agents adapt based on what they find. LLM conversation history is a form of stigmergic medium.

### Step 3: Perform Cognitive Architecture Analysis

Map the target system to three established cognitive architectures. For each, produce `component_mappings`, `match_quality` (low/moderate/high), and `gaps`.

#### 3.1 ACT-R (Adaptive Control of Thought — Rational)

Core theory: Anderson (1993, 2007). A hybrid cognitive architecture with declarative memory (chunks of factual knowledge accessed by spreading activation), procedural memory (production rules: IF condition THEN action), goal buffer (current goal stack), perceptual-motor modules (environment interface), and subsymbolic layer (activation levels, utility values). Mapping guidance: Map knowledge stores to declarative memory, agent prompts/decision logic to production rules, task queue/phase progression to goal buffer, tool use to perceptual-motor modules, and any learning/adaptation to subsymbolic activation.

#### 3.2 SOAR (State, Operator, And Result)

Core theory: Laird, Newell & Rosenbloom (1987). A unified cognitive architecture with working memory (current situation), long-term memory (procedural, semantic, episodic), decision cycle (Input, Elaborate, Propose, Decide, Apply, Output), impasse resolution (subgoal creation when stalled), and chunking (learning new rules from impasse resolution). Mapping guidance: Map shared context/workspace to working memory, agent knowledge bases to LTM types, orchestration loop to decision cycle, error handling/retry to impasse resolution, and review-revise cycles to chunking.

#### 3.3 Global Workspace Theory (GWT)

Core theory: Baars (1988, 2005). A theory of consciousness: global workspace (shared broadcast medium), specialist processors (unconscious, parallel, domain-specific), conscious broadcast (winning coalition's content broadcast globally), attention (competitive selection for workspace access). Mapping guidance: Map shared state to global workspace, individual agents to specialist processors, coordinator logic to attention mechanism, and agent output availability to conscious broadcast. GWT is particularly relevant for systems with central coordinators mediating shared resources.

#### 3.4 Novel Aspects

After mapping to all three architectures, identify aspects NOT captured by any existing cognitive architecture. Common novel aspects in LLM-based MAS: natural language as inter-module communication medium, prompt-based specialization rather than hardcoded modules, emergent reasoning from foundation models, dynamic context window as working memory with unique properties.

### Step 4: Information-Theoretic Formalization (If Applicable)

Only if input-context.md explicitly mentions information-theoretic properties, entropy reduction, or information gain across agents. If no such claims exist, skip and set formalization to null.

Formalization framework:
1. Define the information space: Let X be the random variable representing the task output space. H(X) is Shannon entropy before processing.
2. Model sequential processing: For pipeline agents A_1...A_n, define H(X | A_1,...,A_k) as remaining uncertainty after k agents.
3. Monotonic entropy decrease: If claimed, formalize conditions — shared context access, competent specialists, decomposable task.
4. Mutual information: Express gain of A_{k+1} as I(X; A_{k+1} | A_1,...,A_k).
5. Serial vs parallel comparison: Show I_serial >= I_parallel when agents have complementary expertise.
6. Failure conditions: systematic bias, zero mutual information, context overflow.

### Step 5: Evidence/Artifact Fusion Formalization (If Applicable)

Only if the target system combines evidence/artifacts from multiple agents. If not applicable, skip.

Options (choose most appropriate):
1. Dempster-Shafer Theory: For belief mass combination. Assess independence assumption.
2. Bayesian Evidence Combination: For probabilistic assessments with sequential updating.
3. Weighted Voting / Ensemble Theory: For discrete output aggregation. Analyze Condorcet conditions.
4. Structured Artifact Accumulation: For composed structured artifacts (JSON, documents). Formalize as partial solution lattice with join operation — novel for LLM-based MAS.

### Step 6: Synthesize Findings

Combine all analyses into a coherent theoretical narrative:
1. Identify the primary paradigm and justify why it is the best fit
2. Identify secondary paradigms that capture additional aspects
3. Articulate the novel combination — what no single paradigm captures
4. Summarize the cognitive architecture position — closest architecture and what is missing
5. Summarize formal theoretical claims with conditions and limitations
6. Identify open theoretical questions the target system raises

### Step 7: Write Output JSON

Write to `workspace/{project}/phase1/skill-mas-theory.json` following the schema below.

---

## Output Format

```json
{
  "skill_id": "research-mas-theory",
  "domain": "multi_agent_systems",
  "status": "complete",
  "summary": "Analyzed target system against 6 classical MAS paradigms and 3 cognitive architectures. Primary paradigm: [name]. Key novel elements: [brief list]. Formalization: [present/absent].",
  "findings": [
    {
      "finding_id": "F1",
      "type": "theory|method|comparison|architecture",
      "title": "Short descriptive title",
      "description": "Detailed description of the finding (2-5 sentences).",
      "evidence": "What in the target system's architecture supports this finding.",
      "related_innovations": [1, 3],
      "academic_significance": "Why this finding matters for the paper."
    }
  ],
  "domain_specific_data": {
    "paradigm_mapping": {
      "paradigms": [
        {
          "name": "BDI Architecture",
          "type": "classical_mas",
          "key_references": ["Rao & Georgeff 1995"],
          "similarity_score": 0.35,
          "matching_aspects": ["..."],
          "diverging_aspects": ["..."],
          "relevance_assessment": "..."
        }
      ],
      "primary_paradigm": "Name of the best-fitting paradigm",
      "secondary_paradigms": ["Paradigm 2", "Paradigm 3"],
      "justification": "Detailed justification (3-5 sentences).",
      "novel_elements": ["Novel element 1", "Novel element 2"]
    },
    "cognitive_architecture_analysis": {
      "act_r_mapping": {
        "component_mappings": {
          "declarative_memory": "...",
          "procedural_memory": "...",
          "goal_buffer": "...",
          "perceptual_motor": "..."
        },
        "match_quality": "low|moderate|high",
        "gaps": ["..."]
      },
      "soar_mapping": {
        "component_mappings": {
          "working_memory": "...",
          "long_term_memory": "...",
          "decision_cycle": "...",
          "impasse_resolution": "..."
        },
        "match_quality": "low|moderate|high",
        "gaps": ["..."]
      },
      "gwt_mapping": {
        "component_mappings": {
          "global_workspace": "...",
          "specialist_processors": "...",
          "conscious_broadcast": "...",
          "attention": "..."
        },
        "match_quality": "low|moderate|high",
        "gaps": ["..."]
      },
      "novel_aspects": ["..."]
    },
    "formalization": {
      "information_theoretic": {
        "present": true,
        "claims": [
          {
            "claim_name": "...",
            "formal_statement": "...",
            "assumptions": ["..."],
            "proof_sketch": "...",
            "conditions_for_failure": ["..."]
          }
        ]
      },
      "fusion_formalization": {
        "present": false,
        "method": "dempster_shafer|bayesian|voting|structured_accumulation|null",
        "description": "..."
      }
    }
  }
}
```

Notes on the output schema:
- The `paradigms` array MUST contain all 6 paradigms with actual scores computed from the target system.
- The `findings` array should contain 5-12 findings, each a distinct theoretical insight.
- `finding.type` must be one of: `"theory"`, `"method"`, `"comparison"`, `"architecture"`.
- `finding.related_innovations` references innovation IDs from input-context.md. Use `[]` if no direct mapping.
- If information-theoretic formalization is not applicable: `"information_theoretic": { "present": false, "claims": [] }`.
- If fusion formalization is not applicable: `"fusion_formalization": { "present": false, "method": null, "description": null }`.

---

## Quality Criteria

1. **All 6 paradigms assessed** — no paradigm skipped, each has a concrete similarity score and mapping
2. **All 3 cognitive architectures mapped** — ACT-R, SOAR, and GWT each have component-level mappings
3. **Paradigm mapping is justified** — grounded in the target system's architecture, not just assertion
4. **Cognitive mappings are specific** — concrete component-to-component mappings, not vague analogies
5. **Novel aspects identified** — what the target system does that no existing framework captures
6. **Formalizations are mathematically sound** (if present) — correct use of entropy, conditional entropy, mutual information
7. **Findings are actionable** — each provides theoretical ammunition for downstream paper agents
8. **Honest about limitations** — imperfect mappings and strong assumptions stated explicitly

---

## Example Findings

For a hypothetical pipeline-based LLM multi-agent system that writes academic papers:

```json
{
  "finding_id": "F1",
  "type": "theory",
  "title": "Hybrid Blackboard-Pipeline Architecture",
  "description": "The target system combines pipeline execution (sequential phases) with blackboard-style shared artifacts (workspace files). This hybrid is not captured by either paradigm alone. The pipeline provides deterministic ordering while the blackboard provides flexible inter-agent communication.",
  "evidence": "Phase 1 agents write to workspace/phase1/, Phase 2 agents read from phase1/ and write to phase2/. The workspace acts as a blackboard while phase ordering acts as a pipeline.",
  "related_innovations": [1, 2],
  "academic_significance": "This hybrid can be formalized as a Phased Blackboard — a novel MAS pattern where the blackboard is partitioned into temporal phases, combining benefits of both paradigms."
}
```

```json
{
  "finding_id": "F2",
  "type": "architecture",
  "title": "GWT Mapping: Workspace as Global Workspace",
  "description": "The shared workspace maps to GWT's global workspace. Each agent acts as a specialist processor. The Team Lead's orchestration maps to the attention/selection mechanism determining which specialist accesses the workspace next.",
  "evidence": "All agents read from and write to the shared workspace. The Team Lead selects which agent runs based on phase dependencies and quality gate results.",
  "related_innovations": [3],
  "academic_significance": "This mapping provides cognitive science grounding, connecting the architecture to theories of consciousness and attention. It highlights the novel use of natural language artifacts (rather than symbolic tokens) as workspace content."
}
```
