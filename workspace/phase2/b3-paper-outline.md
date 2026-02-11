# B3: Paper Architecture — Cognitive Hub

**Agent**: b3-paper-architect | **Phase**: 2 | **Status**: Complete

---

## 1. Paper Metadata

**Primary Title**: Cognitive Hub: A Multi-Agent Architecture for Ontology-Driven Natural Language Data Querying at Enterprise Scale

**Alternative Titles**:
1. From Ontology to Cognition: Multi-Agent Serial Reasoning for Enterprise-Scale Data Querying
2. Smart Query: Ontology-Guided Multi-Strategy Evidence Fusion for Natural Language Data Access
3. Beyond NL2SQL: A Cognitive Hub Architecture for Navigating Enterprise Data Landscapes

**Authors**: [Placeholder — to be determined]

**Venue Recommendation**: AAAI (primary) | CIKM (secondary) | ACL Industry Track (tertiary)

**Target Length**: 8,200 words (body + abstract) | 9 figures | 7 tables | 35–45 references

---

## 2. Abstract Draft (250 words)

Natural language data querying over enterprise-scale databases remains a fundamental challenge: real-world banking environments contain 35,000+ tables across multiple schemas, far exceeding the capacity of existing NL2SQL systems designed for benchmarks with fewer than 200 tables. Traditional ontology-based data access (OBDA) systems provide structured mediation but require rigid formal query languages, while standalone LLMs hallucinate over complex data architectures they cannot systematically navigate.

We present **Cognitive Hub**, a multi-agent architecture that transforms a domain ontology from passive knowledge storage into an active cognitive layer for LLM-based reasoning. Our system employs three cognitively specialized agents — Indicator Expert, Scenario Navigator, and Term Analyst — executing serially over a three-layer ontology (163K indicator nodes, 35K data asset nodes, 40K term nodes connected by 623K relationships). Each agent explores an orthogonal knowledge dimension and produces a structured evidence pack; cross-validation fusion with graded confidence scoring selects the primary table, while lineage-driven analysis discovers JOIN conditions from actual ETL data flow.

We formalize the **semantic cumulative effect** — proving via information theory that serial execution with implicit context inheritance monotonically reduces information entropy about the target data. Experiments on [100 real banking queries / placeholder for results] against five baselines demonstrate [placeholder for key results].

To our knowledge, this is the first system to combine ontology-driven cognitive architecture with multi-agent evidence fusion for enterprise-scale natural language data querying.

---

## 3. Narrative Arc

### Problem (Why should the reader care?)
Enterprise-scale natural language data querying over 35,000+ tables across 9 schemas and 83 topics remains unsolved. Existing NL2SQL systems assume small schemas (<200 tables), OBDA systems require rigid formal query languages (SPARQL) and cannot handle ambiguous natural language, and standalone LLMs hallucinate over complex multi-layer data architectures they cannot systematically navigate.

### Insight (What is the "aha" moment?)
A domain ontology can serve as a **Cognitive Hub** — not passive knowledge storage, but an active cognitive layer that guides multi-agent reasoning. By separating declarative memory (ontology with 314K nodes) from procedural memory (specialized Skills), and connecting them through an LLM pattern-matching engine with 29+ MCP tools, we create a cognitive architecture that enables systematic domain reasoning at enterprise scale.

### Solution (How does Smart Query work?)
Three independent expert agents (Indicator, Scenario, Term) execute serially over a three-layer ontology. Each explores an orthogonal knowledge dimension via implicit context inheritance through shared conversation history (digital stigmergy). Each produces a structured evidence pack; cross-validation fusion selects the primary table with graded confidence; lineage analysis discovers JOIN conditions from actual ETL data flow; isolated table filtering excludes deprecated data assets.

### Validation (Why should the reader believe it works?)
Controlled experiments on 100 real banking queries (4 complexity categories) against 5 baselines, 6 ablation studies isolating each architectural component, and information entropy measurement of the semantic cumulative effect across strategy stages.

---

## 4. Detailed Section Outline

### Section 1: Introduction (1,150 words)

#### 1.1 Motivation and Problem Statement (400 words)
**Key Arguments:**
- Enterprise databases contain 35,000+ tables across 9 schemas and 83 topics — orders of magnitude beyond benchmark NL2SQL systems
- Existing NL2SQL systems (DIN-SQL, MAC-SQL, CHESS) assume small schemas (<200 tables) and fail at enterprise scale
- LLMs alone cannot navigate complex multi-layer data architectures without structured guidance — hallucination on table/field names
- Traditional OBDA (Ontop, DL-Lite) provides ontology mediation but requires rigid SPARQL, not natural language

**Evidence Needed:**
- Statistics on enterprise schema scale (35,287 tables, 9 schemas, 163K indicators, 40K terms)
- Failure modes of NL2SQL on large schemas (Bird benchmark gap: 87% Spider vs 54% Bird)
- Examples of LLM hallucination on enterprise table/field names
- Comparison of OBDA rigidity vs NL flexibility requirements

**Figures:** Figure 1 (Enterprise Data Querying Challenge)

#### 1.2 Key Insight: Ontology as Cognitive Hub (350 words)
**Key Arguments:**
- Ontology is not just passive storage — it becomes an active cognitive layer when combined with specialized Skills
- Formalized as: Ontology (declarative memory) + Skills (procedural memory) = Cognitive Hub (domain cognition)
- Three orthogonal knowledge dimensions enable multi-perspective reasoning
- Serial execution with implicit context inheritance produces a semantic cumulative effect

**Evidence Needed:**
- Conceptual comparison with passive KG approaches (RAG, GraphRAG, Think-on-Graph)
- Cognitive architecture grounding (ACT-R declarative/procedural, SOAR, CoALA)

#### 1.3 Contributions (300 words)
1. **Cognitive Hub Architecture**: Domain ontology + specialized skills as declarative + procedural memory for LLM-based enterprise data querying (Sec 3)
2. **Multi-Strategy Serial Execution with Stigmergic Context Inheritance**: Three agents with implicit context inheritance through conversation history and evidence pack fusion with cross-validation adjudication (Sec 3.3–3.4)
3. **Semantic Cumulative Effect**: Information-theoretic proof that serial execution monotonically reduces entropy (Sec 4)
4. **Intelligent Search Space Reduction**: Lineage-driven JOIN discovery, isolated table filtering, dual retrieval (Sec 3.5–3.6)
5. **Comprehensive Evaluation**: 100 real banking queries, 5 baselines, 6 ablations, entropy measurement (Sec 5)

#### 1.4 Paper Organization (100 words)
Brief roadmap of remaining sections.

---

### Section 2: Related Work (1,100 words)

#### 2.1 NL2SQL: From Benchmarks to Enterprise Scale (300 words)
**Papers:** DIN-SQL, DAIL-SQL, C3, MAC-SQL, CHESS, RESDSQL, Spider, Bird, SParC, LLM-SQL Survey
**Narrative:** Evolution from fine-tuned models to LLM-based approaches (70% → 87%+ on Spider). Multi-agent NL2SQL (MAC-SQL) as current frontier. Pivot to enterprise scale gap: Bird reveals real-world performance lags (54-73%); no system addresses 35K+ tables.
**Transition:** While NL2SQL struggles with schema complexity, OBDA has long used ontologies — but with rigid formal methods.

#### 2.2 Ontology-Based Data Access (250 words)
**Papers:** Ontop, Lenzerini, DL-Lite, VKG Overview, Temporal OBDA
**Narrative:** OBDA tradition as intellectual ancestor. Formal correctness guarantees of DL-Lite and Ontop. Fundamental limitation: rigid formal mappings cannot handle ambiguous NL queries.
**Transition:** OBDA rigidity motivates LLM-based reasoning, requiring sophisticated multi-agent architectures.

#### 2.3 LLM-Based Multi-Agent Systems (300 words)
**Papers:** AutoGen, MetaGPT, ChatDev, CAMEL, Multi-Agent Debate, LLM Agent Survey, Voyager, Toolformer, ReAct
**Narrative:** Coordination mechanisms: explicit messages (AutoGen), shared pools (MetaGPT), chat chains (ChatDev), debate (Du et al.). No framework uses implicit context inheritance. No formal justification for serial vs parallel execution.
**Transition:** MAS provides coordination infrastructure; the knowledge source agents reason over is equally critical.

#### 2.4 Knowledge Graph-Enhanced LLM Reasoning (250 words)
**Papers:** KG-LLM Roadmap, Think-on-Graph, GraphRAG, RAG, StructGPT, KG-Enhanced LLM Survey
**Narrative:** KG+LLM convergence reduces hallucination by 25-60%. Graph-guided reasoning (ToG) and hierarchical retrieval (GraphRAG). Gap: existing work uses general KGs, not purpose-built enterprise ontologies with multiple navigation strategies.

**Tables:** Table 7 (System Comparison with Related Work)

---

### Section 3: System Architecture (2,050 words)

#### 3.1 Overview: Cognitive Hub Architecture (350 words)
**Key Arguments:**
- Formalization: Ontology (declarative memory) + Skills (procedural memory) = Cognitive Hub
- Three-layer ontology as externalized long-term memory; Skills as cognitive procedures; LLM as pattern-matching engine
- 29+ MCP tools as retrieval mechanisms bridging LLM working memory with externalized knowledge
- Grounded in ACT-R/SOAR/CoALA cognitive architecture theory

**Figures:** Figure 2 (Cognitive Hub Architecture Overview)

#### 3.2 Ontology Layer Design (450 words)
**Key Arguments:**
- **Indicator Layer**: 163,284 nodes, 5-level hierarchy (SECTOR→CATEGORY→THEME→SUBPATH→INDICATOR)
- **Data Asset Layer**: 35,379 nodes, 3-level hierarchy (SCHEMA→TABLE_TOPIC→TABLE) + 50,509 UPSTREAM lineage edges
- **Term/Standard Layer**: 40,319 nodes (39,558 terms + 761 data standards)
- **Cross-Layer Associations**: HAS_INDICATOR (147,464), HAS_TERM (251,227), BELONGS_TO_STANDARD (7,167)
- **Total**: 314,680 nodes, 623,118 relationships

**Figures:** Figure 3 (Three-Layer Ontology Structure)
**Tables:** Table 1 (Ontology Layer Statistics)

#### 3.3 Three-Strategy Serial Execution (550 words)
**Key Arguments:**
- **Strategy 1 (Indicator Expert)**: Navigates indicator hierarchy via hybrid retrieval; maps business concepts to physical fields via pre-computed mappings (147,464 edges)
- **Strategy 2 (Scenario Navigator)**: Convergent path (Schema→Topic→Table) + dual retrieval (structural + semantic); fusion scoring
- **Strategy 3 (Term Analyst)**: Searches 39,558 business terms; field-level semantic enhancement via data standards
- Serial execution via synchronous Skill() calls; implicit context inheritance through shared conversation history (digital stigmergy)
- Each skill ~400 lines for near-100% instruction compliance (cognitive modular architecture)

**Figures:** Figure 4 (Three-Strategy Serial Execution Flow)
**Tables:** Table 2 (Strategy Capability Comparison)

#### 3.4 Evidence Pack Fusion and Adjudication (300 words)
**Key Arguments:**
- Three independent evidence packs cross-validated through structured adjudication
- Graded confidence: 3-strategy consensus = high, 2 = medium-high, 1 = cautious
- Preserves complete reasoning chains for transparent decision justification
- More rigorous than voting or averaging — operates on structured evidence

#### 3.5 Lineage-Driven JOIN Discovery (250 words)
**Key Arguments:**
- After primary table adjudication, discover upstream/downstream tables via pre-computed lineage (50,509 UPSTREAM edges)
- Key insight: lineage = structural facts about ETL data flow; vector search = semantic guesses
- Automatic JOIN condition inference via shared term_en_name across related tables

**Figures:** Figure 5 (Lineage-Driven JOIN Discovery Example)

#### 3.6 Isolated Table Filtering (150 words)
**Key Arguments:**
- Graph-theoretic quality filter: upstream_count=0 AND downstream_count=0 → deprecated/orphan
- Zero-maintenance automated detection leveraging existing lineage graph topology
- Analogous to ACT-R base-level activation decay

---

### Section 4: Theoretical Analysis (950 words)

#### 4.1 Semantic Cumulative Effect (400 words)
**Key Arguments:**
- **Formal definition**: H(I|S₁,S₂,S₃) ≤ H(I|S₁,S₂) ≤ H(I|S₁) ≤ H(I)
- **Proof**: Chain rule of conditional entropy + non-negativity of mutual information
- **Strict inequality**: When strategies explore orthogonal knowledge dimensions (guaranteed by design)
- **Failure conditions**: Complete redundancy, noise introduction, context degradation
- **Serial vs parallel**: H(I|S₁,S₂(S₁),S₃(S₁,S₂)) ≤ H(I|S₁ⁱⁿᵈᵉᵖ,S₂ⁱⁿᵈᵉᵖ,S₃ⁱⁿᵈᵉᵖ)

**Figures:** Figure 6 (Semantic Cumulative Effect: Entropy Reduction)

#### 4.2 Multi-Agent Coordination Properties (300 words)
**Key Arguments:**
- Smart Query as **Pipeline-Blackboard Hybrid with Stigmergic Context Inheritance**
- Pipeline: deterministic serial scheduling; Blackboard: shared evidence accumulation; Stigmergy: implicit communication
- Comparison with ensemble methods: diversity from knowledge dimension variation (not model variation)
- Implicit context inheritance as digital stigmergy — novel to LLM-based cognitive architectures

#### 4.3 Cognitive Hub Formalization (250 words)
**Key Arguments:**
- ACT-R mapping: ontology = declarative memory, skills = procedural memory, LLM = pattern matcher
- SOAR mapping: ontology = semantic LTM, skills = operators, evidence packs = working memory
- CoALA mapping: ontology = semantic LTM, skills = procedural LTM, tools = external action space
- Novel aspects: externalized declarative memory, multi-dimensional evidence fusion, heat-based validity filtering

---

### Section 5: Experiments (1,750 words)

#### 5.1 Experimental Setup (350 words)
**Key Arguments:**
- **Dataset**: BankQuery-100 — 100 real banking queries (30 Simple, 40 Medium, 20 Complex, 10 Adversarial)
- **Metrics**: TLA@1/3, FCR, ECS, QRR, SCS, ONE, JA (7 metrics)
- **Baselines**: B0 (Direct LLM), B1 (RAG), B2a-c (Single-Strategy), B3 (Independent Agents), B4 (Parallel)
- **Statistical rigor**: Paired bootstrap (10K resamples, p<0.05), Bonferroni correction, Cohen's d

**Tables:** Table 3 (Dataset Statistics), Table 4 (Baseline Descriptions)

#### 5.2 Main Results (400 words)
**Key Arguments:**
- Smart Query vs all baselines across primary metrics
- Breakdown by query complexity showing widening gap for Complex/Adversarial
- Statistical significance of all pairwise comparisons

**Expected Results:**
| Comparison | Metric | Expected Gap |
|---|---|---|
| vs B0 (Direct LLM) | TLA@1 | +25-35% |
| vs B1 (RAG) | TLA@1 | +15-25% |
| vs Best B2 (Single Strategy) | TLA@1 | +10-20% |
| vs B3 (Independent Agents) | TLA@1 | +10-15% |
| vs B4 (Parallel) | TLA@1 | +5-10% |

**Tables:** Table 5 (Main Results)
**Figures:** Figure 7 (Performance Comparison Bar Chart)

#### 5.3 Ablation Study (350 words)
**Key Arguments:**

| Ablation | Component Removed | Expected TLA@1 Drop | Most Affected |
|---|---|---|---|
| A1 | Context Inheritance | -10-20% | Complex, Adversarial |
| A2 | Evidence Fusion | -5-15% | Complex |
| A3 | Isolated Table Filtering | -5-10% (precision) | Deprecated table queries |
| A4 | Lineage JOIN | -15-25% (JA) | Multi-table queries |
| A5 | Dual Retrieval | -10-15% (FCR) | Non-standard terminology |
| A6 | Ontology Hierarchy | Significant (ONE) | Ambiguous queries |

**Tables:** Table 6 (Ablation Results)
**Figures:** Figure 8 (Ablation Impact Visualization)

#### 5.4 Semantic Cumulative Effect Analysis (300 words)
**Key Arguments:**
- Empirical validation of H₀ > H₁ > H₂ > H₃ monotonic decrease (expected >80% of queries)
- Starting entropy: H₀ = log₂(35,287) ≈ 15.11 bits
- Cumulative reduction ratio CRR > 0.70 average
- Serial vs parallel: Smart Query achieves 5-15% lower final entropy than B4

**Figures:** Figure 9 (Entropy Reduction by Complexity)

#### 5.5 Case Studies (350 words)
- 2-3 representative query traces demonstrating context inheritance and evidence fusion
- Show candidate table set narrowing at each strategy stage
- Include one failure case for honest error analysis
- Compare with B3 (independent agents) on same queries

---

### Section 6: Discussion (600 words)

#### 6.1 Key Findings and Implications (200 words)
- Ontology as cognitive hub > passive KG or flat RAG for enterprise-scale querying
- Serial execution with implicit context inheritance outperforms parallel (theory + empirics)
- Evidence pack fusion provides calibrated confidence absent in single-strategy approaches
- Lineage-driven JOIN: structural facts > semantic guesses for relational operations

#### 6.2 Limitations (200 words)
- Domain specificity: banking ontology; 21-step ETL construction cost
- No formal correctness guarantees (unlike traditional OBDA)
- Serial execution latency overhead
- Implicit context inheritance depends on LLM contextual understanding quality
- Not evaluated on standard NL2SQL benchmarks (different problem scope)

#### 6.3 Generalizability (200 words)
- Cognitive Hub architecture is domain-agnostic (healthcare, manufacturing, finance)
- Multi-strategy serial execution pattern generalizable to any LLM-MAS
- Multi-scenario ontology extension (Data Development, Data Governance) as future direction

---

### Section 7: Conclusion (350 words)

#### 7.1 Summary and Future Work
- Summarize 5 contributions
- Future work: multi-scenario ontology, cross-domain transfer, formal verification, adaptive strategy ordering

---

## 5. Figure Specifications

| ID | Title | Type | Placement | Size | Purpose |
|---|---|---|---|---|---|
| Fig 1 | Enterprise Data Querying Challenge | Problem illustration | Sec 1.1 | Full width | Motivate the needle-in-haystack problem: user query vs 35K+ tables |
| Fig 2 | Cognitive Hub Architecture Overview | Architecture diagram | Sec 3.1 | Full width | Show three-layer ontology + skills + data flow + formula |
| Fig 3 | Three-Layer Ontology Structure | Ontology structure | Sec 3.2 | Full width | Detail three layers with node counts, hierarchy, cross-layer edges |
| Fig 4 | Three-Strategy Serial Execution Flow | Flow diagram | Sec 3.3 | Full width | Sequential flow with evidence packs, context inheritance, entropy bar |
| Fig 5 | Lineage-Driven JOIN Discovery | Example diagram | Sec 3.5 | Column | Concrete JOIN example: lineage (correct) vs vector search (wrong) |
| Fig 6 | Semantic Cumulative Effect | Theory chart | Sec 4.1 | Column | Entropy reduction curves by complexity with formal inequality |
| Fig 7 | Main Results Comparison | Bar chart | Sec 5.2 | Full width | Grouped bars: systems × metrics with significance stars |
| Fig 8 | Ablation Study Impact | Heatmap/bar | Sec 5.3 | Column | Component removal impact with severity color coding |
| Fig 9 | Entropy Reduction by Complexity | Multi-panel chart | Sec 5.4 | Full width | Per-category entropy curves + CRR vs TLA@1 scatter |

---

## 6. Table Specifications

| ID | Title | Placement | Rows | Purpose |
|---|---|---|---|---|
| Tab 1 | Ontology Layer Statistics | Sec 3.2 | 5 | Quantify ontology scale (314K nodes, 623K relationships) |
| Tab 2 | Strategy Capability Comparison | Sec 3.3 | 8 | Show complementary coverage across three strategies |
| Tab 3 | BankQuery-100 Dataset Statistics | Sec 5.1 | 5 | Describe evaluation dataset by complexity category |
| Tab 4 | Baseline System Descriptions | Sec 5.1 | 7 | Define baselines with what each tests |
| Tab 5 | Main Experimental Results | Sec 5.2 | 8 | Core results: 8 systems × 6 metrics (central evidence table) |
| Tab 6 | Ablation Study Results | Sec 5.3 | 6 | Component contribution validation with Δ values |
| Tab 7 | System Comparison with Related Work | Sec 2 | 8 | Position Smart Query at intersection of 4 research areas |

---

## 7. Word Count Budget

| Section | Words | % of Total |
|---|---|---|
| Abstract | 250 | 3.0% |
| 1. Introduction | 1,150 | 14.0% |
| 2. Related Work | 1,100 | 13.4% |
| 3. System Architecture | 2,050 | 25.0% |
| 4. Theoretical Analysis | 950 | 11.6% |
| 5. Experiments | 1,750 | 21.3% |
| 6. Discussion | 600 | 7.3% |
| 7. Conclusion | 350 | 4.3% |
| **Total** | **8,200** | **100%** |

**Budget Flexibility**: ±500 words. Can expand Sec 3 (architecture) or Sec 5 (experiments) if needed.
**References Target**: 35–45 references across NL2SQL (10), OBDA (5), MAS (9), KG+LLM (6), CogArch (5+).

---

## 8. Connecting Narrative

Enterprise data environments present a fundamental challenge that no existing approach adequately addresses. With 35,287 tables across 9 schemas, 163,284 business indicators, and 39,558 standardized terms, a banking data warehouse exemplifies the complexity that renders current NL2SQL systems ineffective — they are designed for benchmarks with fewer than 200 tables. Traditional OBDA systems like Ontop provide ontology-mediated access but demand rigid SPARQL queries, while standalone LLMs hallucinate when confronted with enterprise-scale schema complexity.

Our key insight is that a domain ontology can be more than passive knowledge storage — it can serve as a **Cognitive Hub**. By formalizing the ontology as externalized declarative memory and specialized Skills as procedural memory (grounded in ACT-R and SOAR cognitive architecture theory), we create an active cognitive layer that enables systematic domain reasoning. This reframes the NL2SQL problem from retrieval augmentation to cognitive architecture design.

The Cognitive Hub activates through three independent expert agents, each exploring an orthogonal knowledge dimension: business indicators (163K nodes), data asset topology (35K nodes), and business terminology (40K nodes). These agents execute serially — not in parallel — because serial execution with implicit context inheritance through shared conversation history (a form of digital stigmergy) produces a **semantic cumulative effect**. We prove via information theory that each successive strategy monotonically reduces information entropy about the target data: H(I|S₁,S₂,S₃) ≤ H(I|S₁,S₂) ≤ H(I|S₁) ≤ H(I).

The three strategies are complementary by design: the Indicator Expert maps business concepts to physical fields through a 5-level hierarchy; the Scenario Navigator follows convergent paths (Schema→Topic→Table) augmented by dual retrieval combining structural navigation with semantic vector search; the Term Analyst discovers field-level mappings through 39,558 business terms and 761 data standards. Each produces a structured evidence pack; cross-validation fusion with graded confidence scoring (3-strategy consensus = high, 2 = medium-high, 1 = cautious) selects the primary table.

Two additional innovations complete the system: **lineage-driven JOIN discovery** uses 50,509 pre-computed UPSTREAM relationships (reflecting actual ETL data flow) to infer JOIN conditions — structural facts rather than semantic guesses. **Isolated table filtering** automatically detects deprecated tables through graph-theoretic analysis (in-degree + out-degree = 0), providing zero-maintenance data quality assurance.

We validate this architecture through controlled experiments on 100 real banking queries against 5 baselines spanning the design space, 6 ablation studies isolating each component's contribution, and direct measurement of the semantic cumulative effect through Shannon entropy reduction across strategy stages.

---

## 9. Venue Analysis

| Venue | Type | Fit | Pros | Cons |
|---|---|---|---|---|
| **AAAI** ⭐ | General AI | **High** | Multi-agent track; broad audience; theory-friendly | Highly competitive |
| **CIKM** ⭐ | Info Management | **High** | Knowledge management focus; enterprise systems valued | Lower tier than AAAI |
| **ACL Industry** | NLP | **Medium-High** | NL2SQL relevant; deployed systems valued | Industry track only |
| VLDB/SIGMOD | Database | Medium | Enterprise data focus | Less LLM/agent focus |
| KDD | Data Mining | Medium | Applied ML track | Less theoretical |
| EMNLP | NLP | Medium | NL2SQL track | Needs NLP-specific contribution |

**Recommendation**: **AAAI** as primary venue. The paper's core contributions span architecture (Cognitive Hub), theory (semantic cumulative effect via information theory), and application (enterprise NL2SQL). AAAI's broad scope, multi-agent systems track, and theoretical orientation make it the best fit. The information-theoretic formalization and cognitive architecture grounding (ACT-R, SOAR, CoALA) appeal to AAAI reviewers.

**Backup**: **CIKM** as secondary. Its focus on information and knowledge management directly aligns with ontology-driven querying. The enterprise deployment context and practical innovations are valued.

---

## 10. Cross-Reference Map

| Paper Section | Phase 1/2 Sources | Key Data Used |
|---|---|---|
| Sec 1 (Introduction) | A1 (gaps), A4 (contributions), B1 (positioning) | Enterprise scale stats (A2); gap analysis (A1/B1); contribution themes (A4) |
| Sec 2 (Related Work) | A1 (35 papers), B1 (comparison matrix, outline) | Paper categorization (A1); comparison tables (B1); gap analysis (B1) |
| Sec 3 (Architecture) | A2 (engineering analysis), A4 (innovations 1-12) | Architecture layers (A2); ontology metrics (A2); design patterns (A2); formalizations (A4) |
| Sec 4 (Theory) | A3 (MAS theory), A4 (innovations 2, 3) | Paradigm mapping (A3); entropy formalization (A3/A4); cognitive mappings (A3) |
| Sec 5 (Experiments) | B2 (experiment design) | Metrics M1-M7; baselines B0-B4; ablations A1-A6; dataset spec; protocols P1-P5; entropy methodology |
| Sec 6 (Discussion) | A4 (innovation 13), B1 (limitations) | Multi-scenario ontology (A4); limitation analysis (B1) |
| Sec 7 (Conclusion) | A4 (themes A-D, innovation 13) | Contribution summary; future directions |

---

## 11. Input File Status

| File | Status | Key Extractions |
|---|---|---|
| A1 (Literature Survey) | ✅ Read | 35 papers across 5 categories; 5 key gaps identified |
| A2 (Engineering Analysis) | ✅ Read | 13 innovations mapped to code; 314K nodes, 623K relationships; 29 MCP tools |
| A3 (MAS Theory) | ✅ Read | Pipeline-Blackboard Hybrid paradigm; ACT-R/SOAR/CoALA mappings; entropy formalization |
| A4 (Innovations) | ✅ Read | 13 innovations in 4 themes; 5 core + 8 supporting; formal contribution statements |
| B1 (Related Work) | ✅ Read | 8 unique contributions; 5 strongest competitors; comparison matrix; related work outline |
| B2 (Experiment Design) | ✅ Read | 7 metrics; 5 baselines; 6 ablations; 100-query dataset; 5 protocols; entropy methodology |
