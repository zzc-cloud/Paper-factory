# All Tables for Smart Query Research Paper

This document contains all tables for the paper "Cognitive Hub: A Multi-Agent Architecture for Ontology-Driven Natural Language Data Querying at Enterprise Scale". Each table includes a specification block, the complete Markdown table, caption, and footnotes where applicable.

---

## Table 1: Ontology Layer Statistics

---
**Table 1: Ontology Layer Statistics**
**Section:** 3.2 (Ontology Layer Design)
**Purpose:** Quantify the ontology scale and demonstrate enterprise-grade knowledge graph complexity
**Data Source:** Engineering Analysis (a2-engineering-analysis.json)
---

| Layer | Node Types | Node Count | Hierarchy Levels | Key Relationships | Relationship Count |
|:------|:-----------|----------:|:-----------------|:------------------|------------------:|
| **Indicator Layer** | SECTOR → CATEGORY → THEME → SUBPATH → INDICATOR | 163,284 | 5 levels | HAS_CHILD | 163,283 |
| **Data Asset Layer** | SCHEMA → TABLE_TOPIC → TABLE | 35,379 | 3 levels | HAS_TOPIC, HAS_TABLE, UPSTREAM | 53,977 |
| **Term/Standard Layer** | TERM, DATA_STANDARD | 40,319 | 2 levels | BELONGS_TO_STANDARD | 7,167 |
| **Cross-Layer Associations** | HAS_INDICATOR, HAS_TERM | — | — | HAS_INDICATOR, HAS_TERM | 398,691 |
| **Total** | All node types | **314,680** | — | All relationship types | **623,118** |

**Caption:** Quantitative overview of the three-layer ontology structure. The Indicator Layer contains 163,284 nodes organized in a 5-level hierarchy (SECTOR→CATEGORY→THEME→SUBPATH→INDICATOR). The Data Asset Layer contains 35,379 nodes in a 3-level hierarchy (SCHEMA→TABLE_TOPIC→TABLE) with 50,509 UPSTREAM lineage edges capturing ETL data flow. The Term/Standard Layer contains 40,319 nodes (39,558 business terms + 761 data standards). Cross-layer associations (HAS_INDICATOR: 147,464 edges; HAS_TERM: 251,227 edges) enable multi-perspective navigation. Total: 314,680 nodes and 623,118 relationships, demonstrating enterprise-scale knowledge graph complexity.

**Footnotes:**
- Node counts extracted from Neo4j graph database after 21-step ETL pipeline execution
- UPSTREAM relationships (50,509 edges) include both direct lineage (TableDirectTable: 43,880) and indirect lineage (TableIndirectTable: 6,629)
- HAS_INDICATOR relationships (147,464) are pre-computed from c_expression field parsing during ETL
- HAS_TERM relationships (251,227) connect 28,851 tables to 39,558 matched business terms

---

## Table 2: Strategy Capability Comparison

---
**Table 2: Strategy Capability Comparison**
**Section:** 3.3 (Three-Strategy Serial Execution)
**Purpose:** Demonstrate that three strategies are complementary (not redundant) and cover different knowledge dimensions
**Data Source:** Engineering Analysis (a2-engineering-analysis.json), MAS Theory Analysis (a3-mas-theory.json)
---

| Capability | Strategy 1 (Indicator Expert) | Strategy 2 (Scenario Navigator) | Strategy 3 (Term Analyst) |
|:-----------|:------------------------------|:--------------------------------|:--------------------------|
| **Knowledge Dimension** | Business indicator hierarchy (163K nodes) | Data asset topology (35K nodes) | Business terminology (40K terms) |
| **Entry Point** | Business concept keywords | Schema/Topic structure | Business term search |
| **Navigation Method** | 5-level hierarchy traversal (SECTOR→INDICATOR) | Convergent path (SCHEMA→TOPIC→TABLE) | Term-to-table associations |
| **Retrieval Type** | Hybrid (layered keyword + vector) | Dual retrieval (convergent + hybrid) | Keyword search + standard lookup |
| **Coverage Scope** | Tables with indicator mappings (147K edges) | All tables within Schema/Topic structure | Tables with term associations (251K edges) |
| **Output Type** | Indicator paths + field mappings | Schema/Topic context + table candidates | Term matches + field distributions |
| **Unique Strength** | Maps business concepts to physical fields via pre-computed expressions | Provides structural context; dual retrieval ensures complementary coverage | Discovers field-level semantics via data standards |
| **Weakness** | Limited to tables with indicator mappings (~28K of 35K tables) | Requires Schema/Topic knowledge; may miss cross-schema tables | Limited to tables with term associations; no structural context |

**Caption:** Comparison of the three independent strategies demonstrating orthogonal knowledge dimension coverage. Strategy 1 (Indicator Expert) navigates the 5-level business indicator hierarchy to map business concepts to physical fields. Strategy 2 (Scenario Navigator) uses convergent path navigation (SCHEMA→TOPIC→TABLE) augmented by dual retrieval (structural + semantic) to provide comprehensive table discovery. Strategy 3 (Term Analyst) searches 39,558 business terms and 761 data standards for field-level semantic matching. Each strategy has unique strengths and complementary weaknesses, justifying the multi-strategy fusion architecture.

**Footnotes:**
- Hybrid retrieval uses fixed 50/50 ratio: keyword and vector search results are fused with equal weight
- Dual retrieval in Strategy 2 executes convergent path navigation AND hybrid search simultaneously, then fuses results
- Pre-computed indicator-field mappings (147,464 edges) support 8 expression format types parsed during ETL
- Coverage scope indicates which subset of the 35,287 total tables each strategy can discover

---

## Table 3: BankQuery-100 Dataset Statistics

---
**Table 3: BankQuery-100 Dataset Statistics**
**Section:** 5.1 (Experimental Setup)
**Purpose:** Describe the evaluation dataset with clear complexity categorization
**Data Source:** Experiment Design (b2-experiment-design.json)
---

| Category | Count | Tables Required | Fields Required | JOINs | Key Challenge |
|:---------|------:|:----------------|:----------------|:------|:--------------|
| **Simple** | 30 | Single table | 1–3 fields | None | Direct mapping from query terms to table/field names |
| **Medium** | 40 | Single table | 3–6 fields | None or self-JOIN | Disambiguation between similar tables; multiple field discovery |
| **Complex** | 20 | 2–4 tables | 5+ fields | Multi-table JOINs | Cross-schema queries; aggregation; lineage-driven JOIN discovery |
| **Adversarial** | 10 | Varies | Varies | Varies | Ambiguous terms; deprecated table references; non-standard terminology |
| **Total** | **100** | — | — | — | — |

**Caption:** BankQuery-100 dataset composition across four complexity categories. Simple queries (30) test basic table localization with direct terminology matching. Medium queries (40) require disambiguation and comprehensive field discovery. Complex queries (20) involve multi-table JOINs and cross-schema navigation, testing lineage-driven JOIN discovery. Adversarial queries (10) contain ambiguous terminology, deprecated table references, or cross-schema homonyms, testing robustness mechanisms (isolated table filtering, progressive degradation). All queries are real user queries from banking Smart Query system logs, anonymized and annotated by two independent domain experts with Cohen's kappa ≥ 0.80 inter-annotator agreement.

**Footnotes:**
- Dataset source: Real user queries from production banking Smart Query system (anonymized and de-identified)
- Annotation protocol: Two independent domain experts with 5+ years banking data experience; disagreements resolved through consensus discussion
- Ground truth includes: primary table, required fields, optional fields, JOIN conditions (for Complex queries), complexity category, ambiguity notes (for Adversarial queries)
- Dataset split: 20 queries for development (system tuning), 80 queries for test (final evaluation with no tuning)

---

## Table 4: Baseline System Descriptions

---
**Table 4: Baseline System Descriptions**
**Section:** 5.1 (Experimental Setup)
**Purpose:** Define baselines with clear justification for what each tests
**Data Source:** Experiment Design (b2-experiment-design.json)
---

| ID | Name | Description | What It Tests | Key Difference from Smart Query |
|:---|:-----|:------------|:--------------|:--------------------------------|
| **B0** | Direct LLM Prompting | Feed user query + top-100 table descriptions to LLM without ontology structure or MCP tools | Whether ontology layer provides value beyond raw LLM reasoning over flat table metadata | No ontology, no structured navigation, no skills, no evidence packs |
| **B1** | RAG-Based Approach | Embed all tables using same embedding model; retrieve top-30 by vector similarity; feed to LLM for selection | Whether ontology structure adds value beyond vector similarity retrieval | No hierarchical navigation, no cross-layer associations, no lineage |
| **B2a** | Indicator-Only (Single Strategy) | Execute only Strategy 1 (Indicator Expert) with full ontology access; use its evidence pack as final output | Whether multi-strategy fusion outperforms single best strategy | Only one knowledge dimension; no cross-validation; no evidence fusion |
| **B2b** | Scenario-Only (Single Strategy) | Execute only Strategy 2 (Scenario Navigator) with full ontology access; use its evidence pack as final output | Individual contribution of scenario-based navigation | Cannot leverage indicator hierarchy; no term-level field discovery |
| **B2c** | Term-Only (Single Strategy) | Execute only Strategy 3 (Term Analyst) with full ontology access; use its evidence pack as final output | Individual contribution of term-based discovery | No structural context from Schema/Topic; limited to term associations |
| **B3** | Independent Agents | Run all three strategies in isolated contexts (no shared conversation history); merge evidence packs with same adjudication | Whether implicit context inheritance provides value beyond independent evidence collection | No context sharing between strategies; no semantic cumulative effect |
| **B4** | Parallel Execution | Run all three strategies simultaneously in parallel; merge results with same adjudication | Whether serial execution order matters for semantic cumulative effect | No serial ordering; no progressive refinement; concurrent execution |

**Caption:** Baseline system descriptions and experimental controls. B0 (Direct LLM) tests the value of the ontology layer. B1 (RAG) tests the value of ontology structure beyond vector retrieval. B2a-c (Single-Strategy variants) test the value of multi-strategy fusion by running each strategy in isolation. B3 (Independent Agents) tests the value of implicit context inheritance by removing shared conversation history. B4 (Parallel Execution) tests the value of serial ordering by executing strategies concurrently. All baselines use the same base LLM, same embedding model (where applicable), and same table metadata as Smart Query, ensuring fair comparison that isolates specific architectural contributions.

**Footnotes:**
- All systems use identical LLM configuration (same model, temperature=0 for reproducibility)
- B1 uses same embedding model as Smart Query: paraphrase-multilingual-MiniLM-L12-v2 (384-dim, bilingual CN/EN)
- B2a-c have full ontology access and MCP tools; only the number of strategies differs
- B3 and B4 use the same adjudication logic as Smart Query; only the execution pattern differs

---

## Table 5: Main Experimental Results

---
**Table 5: Main Experimental Results**
**Section:** 5.2 (Main Results)
**Purpose:** Present core experimental results — the central evidence table of the paper
**Data Source:** Experiment Design (b2-experiment-design.json) — expected ranges provided; actual results [TBD]
---

| System | TLA@1 (%) | TLA@3 (%) | FCR (%) | ECS | QRR (%) | ONE |
|:-------|----------:|----------:|--------:|----:|--------:|----:|
| **Smart Query (Full)** | **[TBD]** | **[TBD]** | **[TBD]** | **[TBD]** | **[TBD]** | **[TBD]** |
| B0 (Direct LLM) | [TBD] | [TBD] | [TBD] | — | [TBD] | — |
| B1 (RAG) | [TBD] | [TBD] | [TBD] | — | [TBD] | [TBD] |
| B2a (Indicator-Only) | [TBD] | [TBD] | [TBD] | — | [TBD] | [TBD] |
| B2b (Scenario-Only) | [TBD] | [TBD] | [TBD] | — | [TBD] | [TBD] |
| B2c (Term-Only) | [TBD] | [TBD] | [TBD] | — | [TBD] | [TBD] |
| B3 (Independent Agents) | [TBD] | [TBD] | [TBD] | [TBD] | [TBD] | [TBD] |
| B4 (Parallel Execution) | [TBD] | [TBD] | [TBD] | [TBD] | [TBD] | [TBD] |

**Caption:** Main experimental results comparing Smart Query against five baseline approaches across six primary metrics. Values shown as mean ± standard error. **Bold** indicates best result per metric. Statistical significance tested using paired bootstrap test (10,000 resamples, p < 0.05) with Bonferroni correction for multiple comparisons. Expected results: Smart Query (full) significantly outperforms all baselines on TLA@1 (table localization accuracy), FCR (field coverage rate), and QRR (query resolution rate). ECS (evidence consensus score) and ONE (ontology navigation efficiency) are only applicable to systems with ontology access and multiple strategies. [TBD: Actual experimental results to be filled after running Protocol P1 on BankQuery-100 dataset.]

**Footnotes:**
- TLA@1: Table Localization Accuracy at rank 1 (strict accuracy — correct table must be top recommendation)
- TLA@3: Table Localization Accuracy at rank 3 (correct table in top 3 recommendations)
- FCR: Field Coverage Rate (percentage of ground-truth fields discovered)
- ECS: Evidence Consensus Score (agreement across three strategies; only applicable to Smart Query, B3, B4)
- QRR: Query Resolution Rate (percentage resolved without clarification dialog)
- ONE: Ontology Navigation Efficiency (ratio of useful tool calls to total tool calls; not applicable to B0 which has no ontology)
- "—" indicates metric not applicable to that system
- Statistical significance: * p<0.05, ** p<0.01, *** p<0.001 (to be added after experimental runs)

---

## Table 6: Ablation Study Results

---
**Table 6: Ablation Study Results**
**Section:** 5.3 (Ablation Study)
**Purpose:** Validate that each architectural component contributes measurably to system performance
**Data Source:** Experiment Design (b2-experiment-design.json) — expected ranges provided; actual results [TBD]
---

| Ablation | Component Removed | TLA@1 Δ (%) | FCR Δ (%) | Primary Affected Category | Significance |
|:---------|:------------------|------------:|----------:|:--------------------------|:-------------|
| **A1** | Implicit Context Inheritance | [TBD] ↓ | [TBD] ↓ | Complex, Adversarial | [TBD] |
| **A2** | Evidence Pack Fusion | [TBD] ↓ | [TBD] ↓ | Complex, Adversarial | [TBD] |
| **A3** | Isolated Table Filtering | [TBD] ↓ | [TBD] ↓ | Queries with deprecated tables | [TBD] |
| **A4** | Lineage-Driven JOIN Discovery | — | — | Complex (multi-table queries) | [TBD] |
| **A5** | Dual Retrieval Mechanism | [TBD] ↓ | [TBD] ↓ | Medium, Adversarial | [TBD] |
| **A6** | Ontology Hierarchy | [TBD] ↓ | [TBD] ↓ | Medium, Complex | [TBD] |

**Caption:** Ablation study results showing performance degradation when each architectural component is removed. Δ values represent the drop from the full Smart Query system (negative values indicate degradation). A1 (Remove Context Inheritance): Expected TLA@1 drop of 10-20%, largest for Complex/Adversarial queries where progressive refinement is most valuable. A2 (Remove Evidence Fusion): Expected TLA@1 drop of 5-15%, largest for queries requiring cross-validation. A3 (Remove Isolated Filtering): Expected precision drop of 5-10% due to deprecated tables. A4 (Remove Lineage JOIN): Expected JOIN Accuracy drop of 15-25% on Complex queries (measured separately as JA metric, not shown in this table). A5 (Remove Dual Retrieval): Expected FCR drop of 10-15% due to missed synonym tables. A6 (Remove Ontology Hierarchy): Expected ONE drop and TLA@1 drop for ambiguous queries. [TBD: Actual ablation results to be filled after running Protocol P2.]

**Footnotes:**
- Δ values computed as: Δ_metric = metric(full system) - metric(ablated system)
- ↓ indicates performance degradation (negative Δ)
- Statistical significance tested using paired bootstrap test (p < 0.05) and McNemar's test for binary outcomes
- A4 (Lineage-Driven JOIN) affects JA (JOIN Accuracy) metric, measured separately on Complex query subset (20 queries)
- "—" indicates metric not applicable or measured separately
- Primary Affected Category indicates which query complexity category shows the largest degradation
- Significance column will show: * p<0.05, ** p<0.01, *** p<0.001 after experimental runs

---

## Table 7: System Comparison with Related Work

---
**Table 7: System Comparison with Related Work**
**Section:** 2 (Related Work, end of section)
**Purpose:** Position Smart Query at the intersection of four research areas, showing unique capability combination
**Data Source:** Literature Survey (a1), Experiment Design (b2), Paper Outline (b3)
---

| System | Category | Ontology Integration | Multi-Agent | Serial Execution | Evidence Fusion | Schema Scale | NL Input |
|:-------|:---------|:---------------------|:------------|:-----------------|:----------------|:-------------|:---------|
| **Smart Query** | Ontology + MAS + NL2SQL | ✓ Three-layer (314K nodes) | ✓ Three strategies | ✓ With context inheritance | ✓ Cross-validation | 35K+ tables | ✓ Natural language |
| MAC-SQL | Multi-Agent NL2SQL | ✗ No ontology | ✓ Decomposer + Refiner + Selector | ✗ Parallel | ✓ Voting | <200 tables (Spider) | ✓ Natural language |
| DIN-SQL | LLM-based NL2SQL | ✗ No ontology | ✗ Single agent | — | — | <200 tables (Spider) | ✓ Natural language |
| CHESS | NL2SQL with schema linking | ✗ No ontology | ✗ Single agent | — | — | <200 tables (Bird) | ✓ Natural language |
| Ontop | OBDA (VKG) | ✓ OWL2QL ontology | ✗ No agents | — | — | Enterprise scale | ✗ SPARQL only |
| MetaGPT | Multi-Agent Software Dev | ✗ No domain ontology | ✓ Multiple roles | ✗ Parallel | ✓ Shared message pool | N/A | ✓ Natural language |
| Think-on-Graph | KG-enhanced LLM | ✓ General KG (Freebase, etc.) | ✗ Single agent | — | — | N/A (QA task) | ✓ Natural language |
| GraphRAG | Hierarchical KG RAG | ✓ Auto-generated KG | ✗ Single agent | — | — | Document corpus | ✓ Natural language |

**Caption:** Comparison of Smart Query with related systems across seven dimensions. Smart Query uniquely combines: (1) enterprise-scale domain ontology (314,680 nodes, 623,118 relationships), (2) multi-agent architecture with three specialized strategies, (3) serial execution with implicit context inheritance (digital stigmergy), (4) evidence pack fusion with cross-validation adjudication, (5) enterprise schema scale (35,287 tables), and (6) natural language input. Existing NL2SQL systems (MAC-SQL, DIN-SQL, CHESS) lack ontology integration and target small-scale benchmarks (<200 tables). Traditional OBDA systems (Ontop) provide ontology mediation but require rigid SPARQL queries. Multi-agent frameworks (MetaGPT) lack domain ontologies. KG-enhanced LLM systems (Think-on-Graph, GraphRAG) use general-purpose or auto-generated KGs, not purpose-built enterprise ontologies with multiple navigation strategies.

**Footnotes:**
- ✓ indicates the system has this capability; ✗ indicates it does not; — indicates not applicable or not a distinguishing feature
- Schema scale refers to the number of database tables the system is designed to handle
- Serial execution specifically refers to deterministic serial ordering with context inheritance between agents
- Evidence fusion refers to structured multi-perspective evidence combination, not simple voting or ranking
- Ontology integration distinguishes between purpose-built domain ontologies (Smart Query, Ontop) and general KGs (Think-on-Graph) or auto-generated KGs (GraphRAG)
- MAC-SQL reported 87.6% accuracy on Spider benchmark; DIN-SQL reported 85.3%; CHESS reported 73.2% on Bird benchmark
- Smart Query targets a fundamentally different problem scope: enterprise-scale (35K+ tables) vs. benchmark-scale (<200 tables)

---

## Additional Tables (If Needed)

The paper outline specifies 7 tables total. The following additional tables may be included based on experimental results:

### Table A: Entropy Reduction by Query Complexity (Optional)

This table would present the semantic cumulative effect measurement results from Protocol P3, showing:
- Mean entropy at each stage (H0, H1, H2, H3) by complexity category
- Entropy reduction (ΔH) at each stage
- Cumulative reduction ratio (CRR)
- Percentage of queries showing monotonic decrease

**Note:** This may be better presented as Figure 9 (line chart) rather than a table, as specified in the paper outline.

### Table B: Efficiency Comparison (Optional)

This table would present efficiency metrics from Protocol P4:
- Mean wall-clock time (ms)
- Mean token usage (input + output)
- Mean tool call count
- Ontology Navigation Efficiency (ONE)

**Note:** This may be integrated into Table 5 (Main Results) or presented separately if space permits.

### Table C: JOIN Accuracy Results (Optional)

This table would present JOIN discovery results for Complex queries:
- JA-recall (fraction of required JOINs discovered)
- JA-precision (fraction of proposed JOINs that are correct)
- JA-F1 (harmonic mean)
- Comparison: Smart Query (lineage-driven) vs. A4 (schema-based column matching)

**Note:** This validates Innovation 10 (Lineage-Driven JOIN Discovery) and may be included in Section 5.3 (Ablation Study) or as a separate subsection in Section 5.2 (Main Results).

---

## Data Integrity Notes

All tables marked with [TBD] require actual experimental data from running the evaluation protocols on the BankQuery-100 dataset. The expected ranges and hypotheses are documented in the Experiment Design (b2-experiment-design.json) and should guide the experimental execution.

**Required experimental runs:**
1. Protocol P1: Main Comparison (Smart Query vs. 5 baselines on 100 queries) → fills Table 5
2. Protocol P2: Ablation Study (6 ablations on 100 queries) → fills Table 6
3. Protocol P3: Semantic Cumulative Effect Measurement → fills entropy reduction data (Figure 9 or optional Table A)
4. Protocol P4: Efficiency Analysis → fills efficiency data (optional Table B or integrated into Table 5)
5. Protocol P5: Case Study Analysis → provides qualitative evidence for Section 5.5

**Statistical rigor requirements:**
- Paired bootstrap test (10,000 resamples, p < 0.05) for all pairwise comparisons
- Bonferroni correction for multiple comparisons
- Cohen's d effect sizes for magnitude of differences
- Inter-annotator agreement (Cohen's kappa ≥ 0.80) for dataset annotations

---

## End of Tables Document

All tables designed according to specifications in b3-paper-outline.json. Data sources: a2-engineering-analysis.json (Tables 1-2), b2-experiment-design.json (Tables 3-6), literature survey (Table 7). Actual experimental results to be filled after running evaluation protocols P1-P5 on BankQuery-100 dataset.
