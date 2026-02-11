# Innovation Formalization: Smart Query Academic Contributions

**Agent**: A4 Innovation Formalizer
**Phase**: 1 — Innovation Formalization
**Status**: Complete
**Date**: 2026-02-11

---

## Executive Summary

This document formalizes 13 engineering innovations from the Smart Query system into rigorous academic contribution statements suitable for a top-tier systems research paper. The innovations are clustered into **4 contribution themes**, with **5 core innovations** (ranked 1–5) forming the paper's main claims and **8 supporting innovations** (ranked 6–13) providing enabling contributions.

**Core Innovations**: (1) Cognitive Hub Layer Architecture, (2) Three-Strategy Serial Execution with Implicit Context Inheritance, (3) Semantic Cumulative Effect, (4) Evidence Pack Fusion with Cross-Validation Adjudication, (5) Three-Layer Ontology with Cross-Layer Associations.

**Contribution Themes**:
- **Theme A**: Cognitive Hub Architecture — Domain Ontology as Externalized Cognition
- **Theme B**: Multi-Strategy Evidence Fusion with Stigmergic Context Inheritance
- **Theme C**: Intelligent Search Space Reduction through Ontology-Guided Navigation
- **Theme D**: Extensible Multi-Scenario Ontology with Cross-Scenario Knowledge Flow

---

## 1. Contribution Themes

### Theme A: Cognitive Hub Architecture — Domain Ontology as Externalized Cognition for LLM-Based Reasoning

#### Included Innovations
- **Innovation 1**: Cognitive Hub Layer Architecture (Core, Rank 1)
- **Innovation 5**: Three-Layer Ontology with Cross-Layer Associations (Core, Rank 5)
- **Innovation 12**: Cognitive Modular Architecture with Instruction-Following Optimization (Supporting, Rank 6)

#### Theme Description

We propose a cognitive hub architecture that combines a multi-layer domain ontology (serving as externalized declarative memory) with specialized cognitive skills (serving as procedural memory), creating an activated cognitive system that bridges the gap between general-purpose LLMs and domain-specific data querying tasks. The ontology provides structured knowledge (indicator hierarchies, data asset topology, term-standard mappings) while skills provide systematic reasoning procedures. The architecture is formalized as: **Ontology Layer (declarative memory) + Skills (procedural memory) = Cognitive Hub (domain cognition capability)**. Each skill is optimized for LLM instruction-following constraints (~400 lines per skill), addressing the fundamental challenge of instruction compliance degradation in complex LLM-based systems.

#### Theoretical Basis

- **ACT-R** (Anderson 2007): The ontology maps to declarative memory (structured factual chunks with activation levels analogous to heat scores); skills map to procedural memory (production rules defining condition-action patterns); the LLM serves as the pattern-matching engine.
- **SOAR** (Laird et al. 1987): The ontology maps to semantic long-term memory; skills map to operators; evidence packs map to working memory elements; the three-strategy execution maps to the propose-decide-apply decision cycle.
- **CoALA** (Sumers et al. 2024): The most directly applicable framework — ontology = semantic long-term memory, skills = procedural long-term memory, conversation history = working memory, MCP tools = external action space.
- **Cognitive Load Theory**: The modular decomposition (~400 lines per skill) reduces cognitive load on the LLM, improving instruction compliance.

#### Novelty Argument

The cognitive hub architecture is distinct from all existing approaches to LLM-based data querying:

| Approach | Knowledge Representation | Reasoning | Update Cost | Limitation |
|----------|------------------------|-----------|-------------|------------|
| Direct Prompting | None (LLM built-in) | LLM only | Retrain | Hallucination, no domain structure |
| RAG | Unstructured text chunks | LLM + retrieval | Update docs | No knowledge structure, no systematic navigation |
| Fine-tuning | Model weights | Enhanced LLM | Retrain | Opaque, expensive updates |
| Traditional OBDA | Formal ontology | Rigid mapping | Update ontology | No LLM reasoning, inflexible |
| **Cognitive Hub (Ours)** | **Structured knowledge graph** | **LLM + cognitive skills** | **Update ontology or skills independently** | **Requires ontology construction** |

The key novelty is the **separation of knowledge storage (ontology) from reasoning patterns (skills)**, enabling independent evolution of both components. This is theoretically grounded in the declarative-procedural memory distinction from cognitive science, not merely an engineering convenience.

### Theme B: Multi-Strategy Evidence Fusion with Stigmergic Context Inheritance

#### Included Innovations
- **Innovation 2**: Three-Strategy Serial Execution with Implicit Context Inheritance (Core, Rank 2)
- **Innovation 3**: Semantic Cumulative Effect (Core, Rank 3)
- **Innovation 4**: Evidence Pack Fusion with Cross-Validation Adjudication (Core, Rank 4)

#### Theme Description

We introduce a multi-strategy evidence fusion mechanism where three cognitively specialized agents (Indicator Expert, Scenario Navigator, Semantic Analyst) execute serially with implicit context inheritance through shared conversation history — a form of digital stigmergy. Each agent explores an orthogonal knowledge dimension: business indicators (5-level hierarchy), data asset topology (Schema→Topic→Table), and business terminology (term-standard mappings). Independent evidence packs are cross-validated through structured adjudication with graded confidence scoring (3-strategy consensus = high, 2-strategy = medium-high, 1-strategy = cautious). The serial execution with implicit context inheritance produces a formally provable **semantic cumulative effect**: information entropy about the target data monotonically decreases as strategies execute.

#### Theoretical Basis

- **Information Theory** (Cover & Thomas 2006): The semantic cumulative effect is formalized as H(I|S₁,S₂,S₃) ≤ H(I|S₁,S₂) ≤ H(I|S₁) ≤ H(I), proved via the chain rule of conditional entropy and non-negativity of conditional mutual information.
- **Stigmergy** (Grassé 1959): Implicit context inheritance constitutes digital stigmergy — agents communicate indirectly by modifying the shared environment (conversation history) rather than through explicit message passing.
- **Blackboard Systems** (Hayes-Roth 1985): Evidence packs accumulate in a shared space with an orchestrator serving as the control component.
- **Dempster-Shafer Evidence Theory**: Independent evidence sources with different reliability levels are combined through structured fusion.
- **Multi-View Learning**: Each strategy provides a different "view" of the same query from an orthogonal knowledge dimension.

#### Novelty Argument

This theme introduces a novel architectural pattern: **Pipeline-Blackboard Hybrid with Stigmergic Context Inheritance**. This pattern has not been previously described in MAS literature and is uniquely suited to LLM-based multi-agent systems:

1. **vs. Classical Blackboard**: Uses deterministic serial scheduling (not opportunistic) to enable cumulative effects
2. **vs. Classical Pipeline**: Accumulates evidence cumulatively from orthogonal dimensions (not sequential data transformation)
3. **vs. Classical Stigmergy**: Stigmergic traces are rich semantic evidence packs interpreted by an LLM (not simple environmental markers)
4. **vs. AutoGen/CrewAI**: Uses implicit context inheritance through conversation history (not explicit parameter passing)
5. **vs. MetaGPT**: Agents produce parallel perspectives fused at the end (not sequential refinements of the same artifact)

The information-theoretic formalization transforms the engineering observation "serial execution works better" into a theoretically justified design principle with formal conditions for when it holds and when it fails.

### Theme C: Intelligent Search Space Reduction through Ontology-Guided Navigation

#### Included Innovations
- **Innovation 6**: Fixed-Ratio Hybrid Retrieval with Field-Level Vectorization (Supporting, Rank 10)
- **Innovation 7**: Dual Retrieval Mechanism (Supporting, Rank 8)
- **Innovation 8**: Progressive Degradation Search (Supporting, Rank 11)
- **Innovation 9**: Isolated Table Filtering via Lineage Heat Analysis (Supporting, Rank 9)
- **Innovation 10**: Lineage-Driven Related Table Discovery with Automatic JOIN (Supporting, Rank 7)
- **Innovation 11**: Pre-computed Indicator Field Mappings (Supporting, Rank 12)

#### Theme Description

We design an intelligent search space reduction framework that combines multiple complementary mechanisms to navigate from 35,000+ candidate tables to a precise set of target tables with verified JOIN conditions. The framework includes: convergent path navigation (Schema→Topic→Table hierarchical narrowing), dual retrieval (structural ontology navigation + semantic vector search with fusion scoring), progressive degradation search (precision-recall tradeoff across hierarchy levels), isolated table filtering (graph-theoretic quality assessment via lineage heat analysis), lineage-based JOIN discovery (structural facts over semantic guesses), and pre-computed indicator field mappings (O(1) graph lookup replacing O(n) runtime parsing).

#### Theoretical Basis

- **Information Retrieval Theory**: Precision-recall tradeoff, hybrid retrieval combining exact matching with semantic similarity, reciprocal rank fusion.
- **Graph Theory**: Node degree analysis for quality assessment, directed graph traversal for dependency discovery, connectivity-based filtering.
- **Data Lineage Theory**: Provenance tracking, dependency analysis, structural relationship derivation.
- **Hierarchical Search Space Decomposition**: Progressive narrowing through ontology hierarchy levels.
- **Compiler Theory**: Expression parsing with priority-based disambiguation for indicator field mapping.

#### Novelty Argument

While individual retrieval techniques (keyword search, vector search, graph traversal) are well-established, the novelty lies in their principled integration within an ontology-guided framework:

1. **Dual retrieval** demonstrates that structural navigation and semantic search are complementary, not substitutable
2. **Lineage-based JOIN** challenges the assumption that vector search is sufficient for table relationship discovery — structural facts outperform semantic guesses for relational operations
3. **Isolated table filtering** provides a zero-maintenance quality filter using graph topology, analogous to ACT-R's activation decay
4. The **collective framework** achieves search space reduction that no single mechanism could accomplish alone

### Theme D: Extensible Multi-Scenario Ontology with Cross-Scenario Knowledge Flow

#### Included Innovations
- **Innovation 13**: Multi-Scenario Unified Ontology (Supporting, Rank 13)

#### Theme Description

We demonstrate the extensibility of the cognitive hub architecture through a unified multi-scenario ontology design. A shared foundation layer (TABLE, FIELD, TERM, STANDARD, SCHEMA) supports scenario-specific extensions for data querying (Smart Query), data development, and data governance. Cross-scenario associations create a flywheel effect where improvements in one scenario cascade to others.

#### Theoretical Basis

Ontology modularization theory, enterprise architecture frameworks, knowledge management lifecycle theory, feedback loop dynamics.

#### Novelty Argument

The multi-scenario ontology fusion architecture with flywheel effects is a novel contribution to enterprise data management theory. However, this is currently a partially validated contribution: only the Smart Query scenario is fully implemented. Data Development and Data Governance are proposed extensions. This should be presented as architectural extensibility and future work rather than a fully validated contribution.

---

## 2. Formal Innovation Analysis

### Innovation 1: Cognitive Hub Layer Architecture
**Significance**: Core | **Rank**: 1

#### Problem Statement
General-purpose LLMs lack the structured domain knowledge required for accurate enterprise data querying across thousands of tables. Existing approaches face fundamental limitations: direct prompting suffers from hallucination and knowledge gaps; RAG retrieves unstructured text fragments without preserving knowledge structure or enabling systematic navigation; fine-tuning embeds knowledge in model weights, making updates expensive and reasoning opaque; traditional OBDA systems provide rigid ontology-to-database mappings without leveraging LLM reasoning capabilities. No existing approach combines structured domain knowledge with flexible LLM-based reasoning in a way that separates knowledge storage from reasoning patterns.

#### Approach
We propose a cognitive hub architecture formalized as: **Ontology Layer (externalized declarative memory) + Skills (procedural memory) = Cognitive Hub (domain cognition capability)**. The ontology layer is a multi-layer Neo4j knowledge graph (314,680 nodes, 623,118 relationships) organized into three semantic layers. Skills are modular cognitive frameworks (~400 lines each) that define systematic reasoning procedures for navigating the ontology. The LLM serves as the pattern-matching engine connecting declarative knowledge with procedural knowledge. 29+ MCP tools provide structured access to the knowledge graph.

#### Novelty Claim
Unlike traditional OBDA (rigid mapping, no LLM reasoning), pure RAG (unstructured retrieval, no knowledge structure), fine-tuning (opaque knowledge, expensive updates), or direct prompting (no domain structure), our cognitive hub separates knowledge storage (ontology, independently updatable) from reasoning patterns (skills, independently composable). The ontology is not merely a lookup resource but an active participant in the reasoning process through skill-mediated navigation. To the best of our knowledge, this is the first work to formalize the ontology-skill duality as a cognitive architecture for LLM-based natural language data querying.

#### Theoretical Basis
ACT-R (declarative/procedural memory), SOAR (semantic LTM/operators), CoALA (language agent cognitive architecture).

#### Code Evidence (from A2)
- Primary: `docs/knowledge/research-exploration.md`, lines 61–125
- Formula: `Ontology Layer (static knowledge) + Skills (cognitive framework) = Cognitive Hub Layer (domain cognition)`

### Innovation 2: Three-Strategy Serial Execution with Implicit Context Inheritance
**Significance**: Core | **Rank**: 2

#### Problem Statement
In LLM-based multi-agent systems, agents must coordinate to produce coherent results. Existing coordination mechanisms face a fundamental tension: explicit parameter passing (CrewAI, Swarm) requires predefined interfaces that limit flexibility; shared message pools (MetaGPT) require structured message formats; parallel independent execution loses the opportunity for progressive refinement. No existing framework exploits the LLM's native ability to extract information from conversation history as an implicit coordination mechanism.

#### Approach
Three cognitively specialized agents execute in fixed serial order via synchronous Skill() calls. Although only the user query is passed as an explicit parameter, each agent accesses the full conversation history, enabling implicit context inheritance. This constitutes digital stigmergy — agents communicate indirectly by modifying the shared environment (conversation history). The fixed ordering enables the semantic cumulative effect.

#### Novelty Claim
First formalization of implicit context inheritance through LLM conversation history as a coordination mechanism for multi-agent systems. We identify this as digital stigmergy — a concept from swarm intelligence applied to LLM-based agents — where the "environment" is semantically rich conversation history and the "perception" mechanism is LLM contextual understanding. The resulting architectural pattern (Pipeline-Blackboard Hybrid with Stigmergic Context Inheritance) has not been previously described in MAS literature.

#### Theoretical Basis
Stigmergy (Grassé 1959), blackboard systems (Hayes-Roth 1985), pipeline architecture, CoALA working memory model.

#### Code Evidence (from A2)
- Primary: `.claude/skills/smart-query/SKILL.md`, lines 98–147, 360–410
- Mechanism: Synchronous Skill() calls + conversation history as implicit context channel

### Innovation 3: Semantic Cumulative Effect
**Significance**: Core | **Rank**: 3

#### Problem Statement
When multiple specialized agents collaborate on a complex reasoning task, the question of whether serial or parallel execution yields better results lacks formal theoretical grounding. Practitioners choose execution patterns based on intuition rather than principled analysis. No formal framework exists for predicting when serial execution with shared context will outperform parallel independent execution in LLM-based multi-agent systems.

#### Approach
We formalize the semantic cumulative effect using information theory: H(I|S₁,S₂,S₃) ≤ H(I|S₁,S₂) ≤ H(I|S₁) ≤ H(I). The proof follows from the chain rule of conditional entropy and non-negativity of conditional mutual information. We establish conditions for strict inequality (knowledge dimension orthogonality) and failure (redundancy, noise, context degradation). We prove that serial execution with context inheritance achieves lower entropy than parallel independent execution.

#### Novelty Claim
First information-theoretic formalization of why serial shared-context execution outperforms parallel independent execution in LLM-based MAS. The key insight is that knowledge dimension orthogonality guarantees non-zero conditional mutual information, ensuring each strategy contributes unique evidence. This transforms an engineering observation into a theoretically justified design principle.

#### Theoretical Basis
Information theory (Shannon entropy, chain rule, conditional mutual information), multi-view learning, ensemble methods comparison.

#### Code Evidence (from A2)
- Primary: `docs/knowledge/research-exploration.md`, lines 654–783
- Formula: H(I|S₁,S₂,S₃) ≤ H(I|S₁,S₂) ≤ H(I|S₁) ≤ H(I)

### Innovation 4: Evidence Pack Fusion with Cross-Validation Adjudication
**Significance**: Core | **Rank**: 4

#### Problem Statement
When multiple agents independently analyze the same query from different perspectives, their outputs may agree, partially overlap, or conflict. Simple aggregation methods (majority voting, score averaging) discard reasoning chains and cannot resolve conflicts based on evidence quality.

#### Approach
Three strategies independently produce structured JSON evidence packs. Evidence strength is graded by cross-strategy consensus: 3-strategy agreement = high confidence (⭐⭐⭐), 2-strategy = medium-high (⭐⭐), 1-strategy = cautious (⭐). The orchestrator performs comprehensive adjudication: cross-validate table consistency, assess field coverage, resolve conflicts using evidence provenance, execute lineage analysis on the adjudicated primary table, and apply isolated table filtering.

#### Novelty Claim
More rigorous than simple voting or averaging — preserves complete multi-perspective reasoning chains while providing graded confidence scoring. The deferred lineage analysis ensures expensive graph traversal is applied only to the final primary table.

#### Theoretical Basis
Dempster-Shafer evidence theory, ensemble methods, blackboard systems, multi-sensory integration.

#### Code Evidence (from A2)
- Primary: `.claude/skills/smart-query/SKILL.md`, lines 453–605

### Innovation 5: Three-Layer Ontology with Cross-Layer Associations
**Significance**: Core | **Rank**: 5

#### Problem Statement
Enterprise data environments contain multiple types of semantic knowledge managed in separate silos. NL2SQL systems relying on flat metadata cannot capture rich cross-domain relationships. Building a unified knowledge representation supporting multiple navigation paths at enterprise scale remains an open challenge.

#### Approach
Three-layer ontology in Neo4j: Business Indicator Layer (163,284 nodes, 5-level hierarchy), Data Asset Layer (35,379 nodes, 3-level hierarchy + 50,509 lineage edges), Term/Standard Layer (40,319 nodes). Cross-layer associations: HAS_INDICATOR (147,464), HAS_TERM (251,227), BELONGS_TO_STANDARD (7,167). Total: 314,680 nodes, 623,118 relationships.

#### Novelty Claim
Three-layer separation enables three independent navigation strategies while cross-layer edges ensure multi-perspective validation. Scale (314K nodes, 623K relationships) demonstrates production feasibility.

#### Theoretical Basis
Ontology engineering, knowledge graph theory, OBDA, semantic web layered representation.

#### Code Evidence (from A2)
- Primary: `docs/knowledge/ontology-graph-building.md`, lines 1–16, 337–366

### Innovation 6: Fixed-Ratio Hybrid Retrieval with Field-Level Vectorization
**Significance**: Supporting | **Rank**: 10

#### Problem Statement
Keyword search misses semantically related tables; vector search may return contextually irrelevant tables. Standard table-level embeddings fail to capture column-level semantic information.

#### Approach
Field-level vectorization: embedding_text = table_description + all column name:description pairs. Fixed 50/50 hybrid: 15 keyword + 15 vector results. Fusion_score=1.0 for both-recalled, 0.5 for single-source. Model: paraphrase-multilingual-MiniLM-L12-v2 (384-dim, bilingual).

#### Novelty Claim
Field-level vectorization enables column-level semantic matching. Fixed-ratio treats keyword and vector as complementary, not competing.

#### Theoretical Basis
Information retrieval, dense retrieval, fusion methods.

#### Code Evidence (from A2)
- Primary: `docs/knowledge/smart-query-design.md`, lines 204–297

### Innovation 7: Dual Retrieval Mechanism
**Significance**: Supporting | **Rank**: 8

#### Problem Statement
Neither structural ontology navigation nor semantic vector search alone provides sufficient coverage for table discovery in enterprise NL2SQL.

#### Approach
Strategy 2 mandates simultaneous execution of convergent path navigation (Schema→Topic→Table) and hybrid search (keyword_limit=50, vector_limit=10), with result fusion and deduplication.

#### Novelty Claim
Demonstrates structural navigation and semantic search are complementary, not substitutable. Mandatory dual execution ensures both precision and recall.

#### Theoretical Basis
Complementary retrieval strategies, ontology-based IR, data fusion.

#### Code Evidence (from A2)
- Primary: `docs/knowledge/smart-query-design.md`, lines 454–489

### Innovation 8: Progressive Degradation Search
**Significance**: Supporting | **Rank**: 11

#### Problem Statement
Exact matching at the most specific hierarchy level frequently fails. Rigid search strategies fail silently, providing no useful results.

#### Approach
Progressive degradation across 5-level indicator hierarchy: INDICATOR → THEME → SUBPATH → CATEGORY → SECTOR, trading precision for recall. Each strategy can partially fail without blocking the system.

#### Novelty Claim
Maps to SOAR's impasse resolution mechanism. Multi-strategy redundancy ensures system-level robustness.

#### Theoretical Basis
SOAR impasse resolution, fault tolerance, precision-recall tradeoff.

#### Code Evidence (from A2)
- Primary: `.claude/skills/smart-query-indicator/SKILL.md`, lines 84–100

### Innovation 9: Isolated Table Filtering via Lineage Heat Analysis
**Significance**: Supporting | **Rank**: 9

#### Problem Statement
Deprecated/orphan tables pollute search results. Manual curation is expensive at scale (35,000+ tables).

#### Approach
Graph-theoretic quality filter: tables with upstream_count=0 AND total_downstream_count=0 are classified as isolated and excluded. Source tables and normal downstream tables are preserved. Filtering deferred to adjudication phase.

#### Novelty Claim
Zero-maintenance quality filter using lineage graph topology. Analogous to ACT-R's base-level activation decay.

#### Theoretical Basis
Graph theory (node degree analysis), ACT-R activation decay, data quality management.

#### Code Evidence (from A2)
- Primary: `.claude/skills/smart-query/SKILL.md`, lines 486–519

### Innovation 10: Lineage-Driven Related Table Discovery with Automatic JOIN
**Significance**: Supporting | **Rank**: 7

#### Problem Statement
JOIN discovery through foreign keys is limited to explicit constraints; vector similarity provides semantic guesses that may not reflect actual data relationships.

#### Approach
After primary table adjudication, discover upstream/downstream tables via pre-computed lineage (50,509 UPSTREAM edges). For each candidate: check isolation, retrieve terms/columns, identify matching fields via shared term_en_name, determine JOIN type.

#### Novelty Claim
Fundamental insight: pre-computed data lineage (structural facts about ETL data flow) provides more reliable JOIN discovery than semantic similarity (semantic guesses). Challenges the assumption that vector search is universal for table relationships.

#### Theoretical Basis
Data lineage theory, graph traversal, database JOIN theory.

#### Code Evidence (from A2)
- Primary: `.claude/skills/smart-query/SKILL.md`, lines 473–555

### Innovation 11: Pre-computed Indicator Field Mappings
**Significance**: Supporting | **Rank**: 12

#### Problem Statement
Business indicators are defined through complex expressions in 8 format types. Runtime parsing at scale (147,464 mappings) creates a performance bottleneck.

#### Approach
ETL-time pre-computation using 7-step priority parser chain handling 8 expression formats. Mappings stored as HAS_INDICATOR relationships in Neo4j. Query-time O(1) graph lookup.

#### Novelty Claim
Systematic handling of 8 real-world expression formats with pre-computation converting O(n) runtime to O(1) lookup.

#### Theoretical Basis
Compiler theory (expression parsing), materialized views, ETL design patterns.

#### Code Evidence (from A2)
- Primary: `docs/knowledge/ontology-graph-building.md`, lines 199–312

### Innovation 12: Cognitive Modular Architecture with Instruction-Following Optimization
**Significance**: Supporting | **Rank**: 6

#### Problem Statement
LLM instruction-following quality degrades as instruction complexity increases — a fundamental constraint not present in classical architectures. Monolithic skills with 2000+ lines suffer from attention dilution.

#### Approach
Each strategy is an independent skill of ~400 lines focused on a single cognitive task. Formalized as: Intelligence ≈ Modularity × Context_Inheritance_Efficiency × Task_Focus.

#### Novelty Claim
Identifies instruction-following degradation as a fundamental LLM constraint and addresses it through principled modular decomposition. The ~400 line guideline has broad implications for LLM-based system design.

#### Theoretical Basis
Cognitive load theory, software modularity, LLM attention mechanisms, ACT-R production specificity.

#### Code Evidence (from A2)
- Primary: `docs/knowledge/smart-query-design.md`, lines 131–187

### Innovation 13: Multi-Scenario Unified Ontology
**Significance**: Supporting | **Rank**: 13

#### Problem Statement
Enterprise data platforms serve multiple scenarios with separate knowledge bases, leading to duplication, inconsistency, and missed cross-scenario synergy.

#### Approach
Shared foundation layer + scenario-specific extensions for querying, development, and governance. Cross-scenario flywheel effect.

#### Novelty Claim
Multi-scenario ontology fusion with flywheel effects. **Note**: Only Smart Query is implemented; others are proposed extensions.

#### Theoretical Basis
Ontology modularization, enterprise architecture, feedback loop dynamics.

#### Code Evidence (from A2)
- Primary: `docs/knowledge/research-exploration.md`, lines 979–1411

---

## 3. Innovation Ranking

| Rank | ID | Innovation | Significance | Justification |
|------|-----|-----------|-------------|---------------|
| 1 | 1 | Cognitive Hub Layer Architecture | Core | Central contribution — new architecture paradigm bridging ontology engineering and LLM reasoning. Highly novel, generalizable, theoretically grounded (ACT-R, SOAR, CoALA). |
| 2 | 2 | Three-Strategy Serial Execution with Implicit Context Inheritance | Core | Novel coordination mechanism (digital stigmergy) for LLM-based MAS. New architectural pattern (Pipeline-Blackboard Hybrid). Highly generalizable. |
| 3 | 3 | Semantic Cumulative Effect | Core | Rigorous information-theoretic formalization. Proof via chain rule of conditional entropy. Conditions for strict inequality and failure. Transforms engineering observation into theoretical principle. |
| 4 | 4 | Evidence Pack Fusion with Cross-Validation Adjudication | Core | Structured evidence fusion more rigorous than voting/averaging. Preserves reasoning chains. Graded confidence scoring. Generalizable to any multi-agent evidence aggregation. |
| 5 | 5 | Three-Layer Ontology with Cross-Layer Associations | Core | Scalable multi-layer ontology at production scale (314K nodes). Enables orthogonal navigation strategies. Meaningful contribution to ontology-based NL2SQL. |
| 6 | 12 | Cognitive Modular Architecture | Supporting | Identifies fundamental LLM constraint (instruction-following degradation). Broad implications for LLM system design. Heuristic rather than rigorous formalization. |
| 7 | 10 | Lineage-Driven JOIN Discovery | Supporting | Valuable insight: structural facts > semantic guesses for JOINs. Generalizable principle. Relies on pre-computed lineage availability. |
| 8 | 7 | Dual Retrieval Mechanism | Supporting | Demonstrates complementarity of structural and semantic retrieval. Sound engineering. Hybrid retrieval is well-studied in IR. |
| 9 | 9 | Isolated Table Filtering | Supporting | Graph-theoretic quality filter. Zero-maintenance. ACT-R activation decay analogy. Relatively simple mechanism. |
| 10 | 6 | Fixed-Ratio Hybrid Retrieval | Supporting | Field-level vectorization is practical. Fixed ratio is pragmatic. Incremental novelty over established techniques. |
| 11 | 8 | Progressive Degradation Search | Supporting | Important robustness property. Maps to SOAR impasse resolution. Well-known pattern in systems engineering. |
| 12 | 11 | Pre-computed Indicator Field Mappings | Supporting | O(n) to O(1) optimization. 8-format parser is practically valuable. Standard pre-computation technique. Domain-specific. |
| 13 | 13 | Multi-Scenario Unified Ontology | Supporting | Interesting vision with flywheel effects. Only partially implemented. Should be presented as future work. |

---

## 4. Contribution Statements (Draft for Introduction)

The main contributions of this paper are:

**(1)** We propose a **Cognitive Hub architecture** that combines a multi-layer domain ontology (314,680 nodes across three semantic layers) with specialized cognitive skills to bridge the gap between general-purpose LLMs and domain-specific data querying. Drawing on the declarative-procedural memory distinction from cognitive architecture theory (ACT-R, SOAR), the ontology serves as externalized declarative memory while skills serve as procedural memory, with the LLM acting as the pattern-matching engine. Unlike RAG (unstructured retrieval), fine-tuning (opaque knowledge), or traditional OBDA (rigid mappings), our architecture separates knowledge storage from reasoning patterns, enabling independent evolution of both components. To the best of our knowledge, this is the first work to formalize the ontology-skill duality as a cognitive architecture for LLM-based natural language data querying.

**(2)** We introduce a **multi-strategy evidence fusion mechanism** where three cognitively specialized agents execute serially with implicit context inheritance through shared conversation history — a form of digital stigmergy. We formalize the resulting **semantic cumulative effect** using information theory, proving that H(I|S₁,S₂,S₃) ≤ H(I|S₁,S₂) ≤ H(I|S₁) ≤ H(I) via the chain rule of conditional entropy, and establish that knowledge dimension orthogonality guarantees strict inequality. We further prove that serial execution with context inheritance achieves lower entropy than parallel independent execution. Independent evidence packs are cross-validated through structured adjudication with graded confidence scoring.

**(3)** We design an **intelligent search space reduction framework** combining convergent path navigation (Schema→Topic→Table hierarchical narrowing), dual retrieval (structural ontology navigation + semantic vector search with fusion scoring), progressive degradation search, isolated table filtering (graph-theoretic quality assessment via lineage heat analysis), and lineage-based JOIN discovery (leveraging pre-computed data lineage as structural facts rather than semantic guesses). These mechanisms collectively reduce the candidate space from 35,000+ tables to a precise set of target tables with verified JOIN conditions.

**(4)** We demonstrate the **extensibility and practical viability** of the cognitive hub architecture through: (a) a cognitive modular design where each agent skill is optimized for LLM instruction-following constraints (~400 lines per skill for near-100% compliance), (b) a 21-step reproducible ETL pipeline for systematic ontology construction from enterprise metadata, and (c) deployment in a production banking environment with 238,982 ontology nodes serving real-world natural language data querying.

---

## 5. Core vs Supporting Analysis

### 5.1 Core Innovations (Paper's Main Claims)

| ID | Innovation | Why Core |
|----|-----------|----------|
| 1 | Cognitive Hub Layer Architecture | Central paradigm — reframes NL2SQL from retrieval augmentation to cognitive architecture design |
| 2 | Serial Execution + Implicit Context Inheritance | Novel MAS coordination mechanism (digital stigmergy) with new architectural pattern |
| 3 | Semantic Cumulative Effect | Rigorous information-theoretic formalization with proof and conditions |
| 4 | Evidence Pack Fusion | Structured multi-perspective fusion more rigorous than existing aggregation methods |
| 5 | Three-Layer Ontology | Production-scale knowledge graph enabling the multi-strategy approach |

### 5.2 Supporting Innovations (Enabling Contributions)

| ID | Innovation | Why Supporting |
|----|-----------|---------------|
| 6 | Hybrid Retrieval + Field Vectorization | Applies established IR techniques to ontology context; incremental novelty |
| 7 | Dual Retrieval Mechanism | Sound engineering demonstrating complementarity; hybrid retrieval is well-studied |
| 8 | Progressive Degradation | Well-known robustness pattern; maps to SOAR but not novel per se |
| 9 | Isolated Table Filtering | Simple graph-theoretic mechanism; domain-specific application |
| 10 | Lineage-Driven JOIN | Valuable insight but relies on pre-computed lineage availability |
| 11 | Pre-computed Mappings | Standard optimization technique; domain-specific parser |
| 12 | Cognitive Modularity | Important empirical finding about LLM constraints; heuristic formalization |
| 13 | Multi-Scenario Ontology | Partially implemented; vision rather than validated contribution |

### 5.3 Rationale for Classification

Core innovations are distinguished by three criteria: **(a) novelty** — they introduce concepts or formalizations not found in existing literature; **(b) generalizability** — they apply beyond the banking domain to any LLM-based system with structured knowledge; **(c) theoretical grounding** — they are supported by established theories from cognitive science, information theory, or MAS research. Supporting innovations are important engineering contributions that enable the core innovations but are individually less novel (applying known techniques) or more domain-specific (banking-specific mechanisms).

---

## 6. Positioning Notes for Paper Authors

### 6.1 Strongest Novelty Claims

1. **Cognitive Hub as cognitive architecture** (Innovation 1): The formalization of ontology + skills as declarative + procedural memory, grounded in ACT-R/SOAR/CoALA, is the paper's strongest and most defensible claim. No existing NL2SQL system frames the problem this way.

2. **Digital stigmergy for LLM-based MAS** (Innovation 2): The identification of implicit context inheritance as stigmergy is novel and theoretically grounded. The Pipeline-Blackboard Hybrid pattern is a genuine contribution to MAS theory.

3. **Information-theoretic formalization** (Innovation 3): The proof via chain rule of conditional entropy is mathematically rigorous. The conditions for strict inequality (orthogonality) and failure (redundancy, noise, context degradation) provide actionable design guidance.

### 6.2 Claims Requiring Careful Framing

1. **Three-layer ontology** (Innovation 5): Multi-layer ontologies exist in literature. Frame the novelty as the *specific three-layer design optimized for multi-agent NL2SQL with cross-layer associations enabling orthogonal navigation strategies*, not as "multi-layer ontology" in general.

2. **Evidence pack fusion** (Innovation 4): Ensemble methods and evidence fusion are well-studied. Frame the novelty as *structured evidence fusion preserving reasoning chains with graded confidence scoring in an LLM-based multi-agent context*, not as "evidence fusion" in general.

3. **Cognitive modularity** (Innovation 12): The ~400 line guideline is empirical, not theoretically derived. Frame as *an empirical finding about LLM instruction-following constraints with implications for system design*, not as a proven theoretical result.

4. **Multi-scenario ontology** (Innovation 13): Only partially implemented. Frame as *architectural extensibility demonstration and future work*, not as a validated contribution.

### 6.3 Potential Reviewer Concerns and Preemptive Arguments

**Concern 1: "This is just RAG with extra steps"**

*Counter-argument*: RAG retrieves unstructured text chunks and relies on the LLM to extract relevant information from flat documents. Our cognitive hub provides *structured* knowledge (typed nodes, typed relationships, hierarchical organization) accessed through *systematic reasoning procedures* (skills defining multi-step navigation strategies). The ontology preserves knowledge structure (indicator hierarchies, data lineage, term-standard mappings) that RAG fundamentally cannot represent. Furthermore, our three-strategy approach with cross-validation adjudication provides a principled evidence fusion mechanism that RAG's single-retrieval-then-generate pattern lacks. The cognitive architecture framing (declarative + procedural memory) provides theoretical justification for why structured knowledge + systematic reasoning outperforms unstructured retrieval + ad-hoc generation.

**Concern 2: "The ontology is domain-specific and not generalizable"**

*Counter-argument*: While the *content* of the ontology is banking-specific, the *architecture* is domain-general. The three-layer pattern (business concepts + physical assets + terminology) applies to any enterprise domain: healthcare (diagnoses + medical records + clinical terms), manufacturing (products + production data + specifications), finance (instruments + market data + regulatory terms). The cognitive hub architecture (ontology + skills = domain cognition) is a general design pattern; only the ontology content and skill instructions need domain adaptation. We provide a 21-step reproducible ETL pipeline that demonstrates how to construct the ontology from standard enterprise metadata sources.

**Concern 3: "Serial execution is slower than parallel"**

*Counter-argument*: We formally prove that serial execution with context inheritance achieves *lower information entropy* (higher accuracy) than parallel independent execution, via the chain rule of conditional entropy. The latency cost of serial execution is a deliberate tradeoff for accuracy in a domain where incorrect table/field selection has significant business consequences. Furthermore, the total latency is bounded by 3× single-strategy latency (not unbounded), and each strategy typically completes in seconds. For enterprise NL2SQL where accuracy is paramount and queries are not latency-critical (users wait for SQL generation), this tradeoff is well-justified.

**Concern 4: "Implicit context inheritance is unreliable"**

*Counter-argument*: We acknowledge this risk explicitly in our theoretical analysis (Section 6.4.3 of the formalization: "Context Degradation"). When the LLM fails to extract relevant information from conversation history, the system degrades to the parallel (non-cumulative) case — it does not produce worse results than parallel execution, only fails to achieve the cumulative benefit. Furthermore, the evidence pack fusion mechanism provides a safety net: even if context inheritance fails completely, the three independent evidence packs still provide multi-perspective coverage through cross-validation adjudication. The implicit mechanism trades guaranteed completeness for flexibility and reduced coupling — a tradeoff that is favorable in practice given modern LLMs' strong contextual understanding capabilities.

**Concern 5: "The evaluation is limited to a single domain (banking)"**

*Counter-argument*: We evaluate on a production-scale banking system (314,680 ontology nodes, 35,287 tables, 29+ tools) that represents real-world complexity. While single-domain evaluation is a limitation, the scale and complexity of the deployment provide strong evidence of practical viability. We discuss generalizability through the domain-general architecture design and the reproducible ETL pipeline. Future work includes cross-domain evaluation.

**Concern 6: "The comparison with existing MAS frameworks is unfair"**

*Counter-argument*: We provide a systematic comparison with 6 LLM-based MAS frameworks (AutoGen, MetaGPT, CrewAI, CAMEL, ChatDev, Swarm) and 6 classical MAS paradigms (BDI, Blackboard, Contract Net, Linda, Pipeline, Stigmergy). The comparison is structural (architecture patterns, communication mechanisms, knowledge representation) rather than performance-based, which is appropriate given that these frameworks serve different purposes. We position Smart Query as a domain-specific instantiation of general MAS principles, not as a replacement for general-purpose frameworks.

---

*Document generated by A4 Innovation Formalizer Agent, Phase 1 Research*
*Date: 2026-02-11*
