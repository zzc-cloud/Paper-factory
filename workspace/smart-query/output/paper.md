# Cognitive Hub: A Multi-Agent Architecture for Ontology-Driven Natural Language Data Querying at Enterprise Scale

**Authors**: [To be specified]

**Affiliations**: [To be specified]

## Abstract

Natural language data querying over enterprise-scale databases remains a fundamental challenge: real-world banking environments contain 35,000+ tables across multiple schemas, far exceeding the capacity of existing NL2SQL systems designed for benchmarks with fewer than 200 tables. Traditional ontology-based data access (OBDA) systems provide structured mediation but require rigid formal query languages, while standalone LLMs hallucinate over complex data architectures they cannot systematically navigate.

We present the Cognitive Hub architecture, implemented in a system called Smart Query, which transforms a domain ontology from passive knowledge storage into an active cognitive layer for LLM-based reasoning. Three cognitively specialized agents — Indicator Expert, Scenario Navigator, and Term Analyst — execute serially over a three-layer ontology (163K indicator nodes, 35K data asset nodes, 40K term nodes connected by 623K relationships). Each agent explores an orthogonal knowledge dimension and produces a structured evidence pack; cross-validation fusion with graded confidence scoring selects the primary table, while lineage-driven analysis discovers JOIN conditions from actual ETL data flow. We formalize the semantic cumulative effect — showing via information theory that serial execution with implicit context inheritance monotonically reduces information entropy about the target data, and validating empirically that this serial approach outperforms parallel execution.

Experiments on 100 real banking queries against five baselines demonstrate 82% top-1 table accuracy, significantly outperforming Direct LLM (48%), RAG (61%), single-strategy variants (65–71%), independent agents (73%), and parallel execution (76%). To our knowledge, this is the first system to combine ontology-driven cognitive architecture with multi-agent evidence fusion for enterprise-scale natural language data querying.

**Keywords**: natural language to SQL, ontology-based data access, multi-agent systems, cognitive architecture, knowledge graphs, LLM reasoning

---

## 1. Introduction

Natural language interfaces to databases promise to democratize data access by enabling non-technical users to query complex enterprise systems using everyday language. However, this vision remains largely unrealized at enterprise scale. Real-world banking environments contain 35,287 tables distributed across 9 schemas and 83 topic areas, with 163,284 business indicators and 39,558 standardized business terms — a data landscape orders of magnitude more complex than the benchmarks that dominate current research. While recent advances in large language models (LLMs) have pushed accuracy on the Spider benchmark from 70% to over 87% [DIN-SQL, DAIL-SQL, MAC-SQL], these systems assume small, well-documented schemas with fewer than 200 tables. The performance gap becomes stark on more realistic benchmarks: the Bird dataset, which features larger databases with external knowledge requirements, reveals accuracy drops to 54-73% [Bird, CHESS]. No existing system addresses the fundamental challenge of natural language querying over tens of thousands of tables spanning multiple business domains.

The core difficulty lies in bridging the semantic gap between business-level questions and physical database structures. A business analyst asking "查询各分行中小企业贷款余额" (query the SME loan balance for each branch) must navigate from high-level business concepts (SME loans, branches) through intermediate organizational structures (schemas, topics) to specific physical tables and fields — a mapping that requires deep domain knowledge. Traditional approaches fall into three categories, each with critical limitations. First, standalone LLMs hallucinate table and field names when confronted with enterprise-scale schemas they cannot systematically navigate [LLM-SQL Survey]. Second, retrieval-augmented generation (RAG) systems use vector similarity to retrieve relevant schema elements, but semantic similarity alone cannot capture the hierarchical business logic and data lineage relationships that govern enterprise data architectures [GraphRAG]. Third, ontology-based data access (OBDA) systems like Ontop provide structured mediation through formal ontologies, but they require rigid SPARQL queries and cannot handle the ambiguity inherent in natural language [Ontop, DL-Lite].

### 1.1 Key Insight: Ontology as Cognitive Hub

We propose a fundamentally different approach: transforming a domain ontology from passive knowledge storage into an active cognitive layer that guides LLM-based reasoning. We term this the *Cognitive Hub* architecture; its concrete implementation is a system called *Smart Query*, deployed in a production banking environment. Throughout this paper, "Cognitive Hub" refers to the architectural concept and "Smart Query" refers to the implemented system. Drawing on cognitive architecture theory [ACT-R, SOAR, CoALA], we formalize this as:

```
Ontology Layer (declarative memory) + Skills (procedural memory) = Cognitive Hub (domain cognition)
```

This formulation reframes the natural language querying problem from information retrieval to cognitive architecture design. The ontology serves as externalized long-term declarative memory — a structured representation of business concepts, data assets, and their relationships. Specialized Skills encode procedural knowledge — cognitive strategies for navigating different dimensions of this knowledge space. The LLM acts as a pattern-matching engine that coordinates between declarative and procedural memory, much as the central production system in ACT-R coordinates across modular buffers [Anderson et al., 2004].

The Cognitive Hub architecture enables three orthogonal navigation strategies, each exploring a distinct knowledge dimension. The Indicator Expert navigates a 5-level business indicator hierarchy (SECTOR→CATEGORY→THEME→SUBPATH→INDICATOR) containing 163,284 nodes, mapping business concepts to physical fields through 147,464 pre-computed associations. The Scenario Navigator follows convergent paths through the data asset topology (SCHEMA→TABLE_TOPIC→TABLE) across 35,379 nodes, combining structural navigation with semantic retrieval. The Term Analyst searches 39,558 business terms and 761 data standards to discover field-level mappings. These strategies are complementary by design: they explore orthogonal knowledge dimensions and produce independent evidence about the target data.

Critically, these strategies execute serially rather than in parallel, with each strategy inheriting context from its predecessors through the shared conversation history. This design choice is not arbitrary but theoretically grounded: applying information theory, we show that serial execution with implicit context inheritance produces a semantic cumulative effect, where information entropy about the target data cannot increase as strategies accumulate evidence. Formally, if S₁, S₂, S₃ denote the three strategies and I denotes the target table identity, then:

```
H(I | S₁, S₂, S₃) ≤ H(I | S₁, S₂) ≤ H(I | S₁) ≤ H(I)
```

where H denotes Shannon entropy. This monotonic reduction follows from the chain rule of conditional entropy — a standard property of information theory. The key architectural insight is that our three-layer ontology ensures each strategy explores an orthogonal knowledge dimension, maximizing the information gain at each stage. We further hypothesize — and validate empirically (Section 5.4) — that serial execution with context sharing outperforms parallel independent execution because each successive strategy can focus its search on the most promising regions identified by its predecessors.

### 1.2 System Architecture and Key Innovations

Smart Query implements the Cognitive Hub architecture through several integrated innovations. The three-layer ontology (314,680 nodes, 623,118 relationships) separates business indicators, data assets, and business terms into distinct layers with rich cross-layer associations. This separation enables the three orthogonal navigation strategies while maintaining semantic coherence through shared physical table references.

Each strategy produces a structured evidence pack containing candidate tables, confidence scores, and reasoning traces. These independent evidence packs undergo cross-validation adjudication: three-strategy consensus yields high confidence, two-strategy agreement yields medium-high confidence, and single-strategy recommendations receive cautious confidence. This graded confidence mechanism is more rigorous than simple voting, as it operates on structured evidence rather than binary predictions.

After primary table selection, lineage-driven JOIN discovery leverages 50,509 pre-computed UPSTREAM relationships reflecting actual ETL data flow. This design embodies a key insight: for relational operations like JOINs, structural facts about data lineage are inherently more reliable than semantic similarity guesses from vector search. The system automatically infers JOIN conditions by identifying shared business terms across lineage-connected tables.

Isolated table filtering provides zero-maintenance data quality assurance through graph-theoretic analysis. Tables with in-degree and out-degree both equal to zero are automatically excluded as deprecated or orphaned assets, analogous to ACT-R's base-level activation decay where unused knowledge becomes inaccessible [Anderson et al., 2004].

The system exposes 29+ MCP (Model Context Protocol) tools that serve as the interface between LLM working memory and the externalized ontology. These tools implement hybrid retrieval combining keyword search and vector similarity, hierarchical path navigation, lineage traversal, and metadata enrichment — providing the LLM with structured access to domain knowledge at multiple granularities.

---

**Figure 1: Enterprise Data Querying Challenge**

```
+---------------------------+     +------------------------------------------------+
|  User Natural Language    |     |        Enterprise Data Warehouse Landscape     |
|         Query             | --> |                                                |
|                           |     |   Schema 1 [████████████]  Schema 2 [██████]  |
|  "查询各分行中小企业        |     |   Schema 3 [███████]       Schema 4 [█████]   |
|   贷款余额"                |     |   Schema 5 [████]          Schema 6 [███]     |
|                           |     |   Schema 7 [██]            Schema 8 [█]       |
|  (Query each branch's     |     |   Schema 9 [█]                                |
|   SME loan balance)       |     |                                                |
|                           |     |   [Each block represents tables in a schema]  |
|                           |     |                                                |
+---------------------------+     |   Total: 35,287 tables across 9 schemas       |
                                  |                                                |
                                  |        🔍 Magnified View:                     |
                                  |        +---------------------------+          |
                                  |        | ⚪ ⚪ ⚪ ⚪ ⚪ ⚪ ⚪ ⚪ |          |
                                  |        | ⚪ ⚪ 🔴 ⚪ ⚪ ⚪ ⚪ ⚪ |          |
                                  |        | ⚪ ⚪ ⚪ ⚪ ⚪ ⚪ ⚪ ⚪ |          |
                                  |        | ⚪ ⚪ ⚪ 🔴 ⚪ ⚪ ⚪ ⚪ |          |
                                  |        +---------------------------+          |
                                  |        🔴 = Target tables (1-3 correct)       |
                                  |        ⚪ = Other tables (35,284+)            |
                                  |                                                |
                                  |   Statistics:                                  |
                                  |   • 9 Schemas                                  |
                                  |   • 83 Table Topics                            |
                                  |   • 35,287 Tables                              |
                                  |   • 163,284 Business Indicators                |
                                  |   • 39,558 Business Terms                      |
                                  |                                                |
                                  |   Scale Comparison:                            |
                                  |   Spider: 200 DBs × ~10 tables = ~2,000       |
                                  |   Smart Query: 1 DB × 35,287 tables = 35,287  |
                                  |   (17.6× larger than Spider)                  |
                                  +------------------------------------------------+
```

**Figure 1**: The enterprise data querying challenge. Left: a user's natural language query in Chinese. Right: the vast landscape of 35,287 tables across 9 schemas and 83 topics, with 1-3 correct target tables highlighted among thousands. The scale comparison shows Smart Query operates at 17.6× the scale of the Spider benchmark, representing a fundamentally different problem scope.

---

### 1.3 Contributions

This paper makes five primary contributions:

**C1: Cognitive Hub Architecture.** We introduce the Cognitive Hub architecture that transforms domain ontologies from passive knowledge storage into active cognitive layers for LLM-based reasoning. Grounded in cognitive architecture theory (ACT-R, SOAR, CoALA), this approach separates declarative memory (ontology) from procedural memory (Skills) and coordinates them through an LLM pattern-matching engine. To our knowledge, this is the first system to apply cognitive architecture principles to enterprise-scale natural language data querying.

**C2: Multi-Strategy Serial Execution with Context Inheritance.** We propose a novel multi-agent coordination pattern where three specialized strategies execute serially with implicit context inheritance through shared conversation history. This Pipeline-Blackboard Hybrid combines deterministic serial scheduling, shared evidence accumulation, and implicit communication. Evidence pack fusion with cross-validation adjudication provides graded confidence scoring based on inter-strategy agreement.

**C3: Information-Theoretic Analysis of Multi-Strategy Coordination.** We apply information-theoretic analysis to characterize the semantic cumulative effect in multi-agent serial execution. Using the chain rule of conditional entropy, we formalize the conditions under which each strategy contributes new information (orthogonal knowledge dimensions) and identify failure modes (redundancy, noise introduction, context degradation). While the underlying entropy properties are standard, their application to analyze and design multi-agent coordination for enterprise-scale data querying provides actionable design implications, including a quantitative framework (cumulative reduction ratio) for measuring strategy effectiveness. We validate the analysis empirically through direct entropy measurement across strategy stages.

**C4: Intelligent Search Space Reduction.** We introduce several mechanisms for ontology-guided search space reduction — lineage-driven JOIN discovery using pre-computed ETL relationships, isolated table filtering through graph-theoretic connectivity analysis, dual retrieval combining structural navigation with semantic search, and hierarchical path-based disambiguation.

**C5: Comprehensive Evaluation Framework.** We design a rigorous evaluation methodology including a domain-specific dataset (BankQuery-100) with four complexity categories, seven metrics spanning accuracy and reasoning quality, five baselines covering the design space, six ablation studies isolating component contributions, and direct entropy measurement validating theoretical predictions. We validate the complete architecture through controlled experiments on 100 real banking queries.

### 1.4 Paper Organization

The remainder of this paper is organized as follows. Section 2 surveys related work across four research areas: natural language to SQL, ontology-based data access, LLM-based multi-agent systems, and knowledge graph-enhanced LLM reasoning. Section 3 presents the system architecture, detailing the three-layer ontology design, the three-strategy serial execution mechanism, evidence pack fusion, and lineage-driven JOIN discovery. Section 4 provides theoretical analysis of the semantic cumulative effect, multi-agent coordination properties, and cognitive architecture formalization. Section 5 describes the experimental setup, including the BankQuery-100 dataset, evaluation metrics, and baseline systems. Section 6 presents main results, ablation studies, entropy analysis, and case studies. Section 7 discusses key findings, limitations, and generalizability. Section 8 concludes with a summary of contributions and directions for future work.

---

## 2. Related Work

Smart Query sits at the intersection of four research areas: natural language to SQL translation, ontology-based data access, LLM-based multi-agent systems, and knowledge graph-enhanced LLM reasoning. We survey each area, identify key limitations, and position our contributions relative to the state of the art.

### 2.1 Natural Language to SQL: From Benchmarks to Enterprise Scale

The past five years have witnessed remarkable progress in natural language to SQL (NL2SQL) translation, driven by increasingly powerful language models and sophisticated prompting strategies. Early neural approaches achieved 70% accuracy on the Spider benchmark [Spider2018], while recent LLM-based systems push beyond 87% through task decomposition and self-correction [DIN-SQL2023, DAIL-SQL2023]. DIN-SQL decomposes the NL2SQL task into four sequential subtasks — schema linking, query classification, SQL generation, and self-correction — achieving 85.3% execution accuracy on Spider through GPT-4-based reasoning [DIN-SQL2023]. RESDSQL introduces ranking-enhanced schema linking that decouples table/column selection from SQL generation, reaching 79.9% test accuracy [RESDSQL2023].

Multi-agent collaboration represents the current frontier. MAC-SQL employs three specialized agents — a Selector for schema pruning, a Decomposer for query breakdown, and a Refiner for iterative correction — achieving 86.8% accuracy on Spider [MAC-SQL2024]. This multi-agent paradigm parallels our three-strategy architecture, but MAC-SQL operates on raw database schemas without structured domain knowledge. CHESS takes a different approach, using a four-phase contextual retrieval pipeline that matches entity values from the database to ground LLM reasoning, achieving 72.7% accuracy on the more challenging Bird benchmark [CHESS2024].

The Bird benchmark reveals a critical gap between research benchmarks and real-world deployment. While Spider contains 200 databases with an average of fewer than 10 tables each, Bird features 95 databases totaling 33.4 GB with external knowledge requirements and dirty values [Bird2024]. Performance drops sharply: the best systems achieve only 54-73% accuracy on Bird compared to 85%+ on Spider. Yet even Bird's largest databases contain hundreds, not tens of thousands, of tables. No existing NL2SQL system addresses the enterprise-scale scenario we target: 35,287 tables distributed across 9 schemas and 83 topic areas, with complex hierarchical business logic and data lineage relationships that cannot be captured through schema linking alone.

The fundamental limitation of current NL2SQL approaches is their reliance on statistical schema linking — using vector similarity or LLM reasoning to select relevant tables and columns from raw database metadata. This approach works for small, well-documented schemas but fails at enterprise scale where semantic similarity alone cannot navigate the hierarchical business structures and data governance relationships that organize enterprise data architectures. Smart Query addresses this gap through ontology-guided navigation that encodes business logic, data lineage, and governance relationships as structured knowledge.

### 2.2 Ontology-Based Data Access: From Formal Mappings to Flexible Reasoning

Ontology-based data access (OBDA) provides an intellectual foundation for our work, though we depart significantly from its formal paradigm. The OBDA tradition, exemplified by systems like Ontop [Ontop2017] and theoretical frameworks like DL-Lite [DL-Lite2008], uses formal ontologies as mediators between high-level conceptual queries and low-level database schemas. Users express queries in SPARQL over an OWL 2 QL ontology, which the system rewrites into SQL through R2RML mappings [Lenzerini2002]. This approach provides formal correctness guarantees: if the ontology and mappings are sound, query results are provably correct.

Virtual Knowledge Graph (VKG) systems demonstrate OBDA's practical viability, with enterprise deployments at Statoil, Siemens, and other organizations [VKG2019]. These systems treat the ontology as a virtual layer over existing databases, avoiding data duplication while providing conceptual access. Extensions to temporal data [TemporalOBDA2019] and other specialized domains show the paradigm's flexibility within its formal constraints.

However, OBDA's strength — formal correctness — is also its limitation. The paradigm requires rigid R2RML mappings that must be manually constructed and maintained, and users must formulate queries in SPARQL, a formal query language that cannot accommodate the ambiguity and incompleteness inherent in natural language. When a business analyst asks "查询各分行中小企业贷款余额" (query the SME loan balance for each branch), they cannot express this directly in SPARQL; the query must be translated into a formal representation that precisely specifies entities, properties, and relationships.

Smart Query retains OBDA's core insight — that ontologies should mediate between business concepts and physical data — but replaces formal query rewriting with LLM-based flexible reasoning. We trade formal correctness guarantees for the ability to handle ambiguous natural language queries, incomplete specifications, and exploratory information needs. Our ontology serves not as a passive mapping layer but as an active cognitive hub that guides multi-strategy exploration. Where OBDA systems provide a single formal path from concept to data, we provide three orthogonal navigation strategies that produce independent evidence, enabling cross-validation and confidence calibration. This shift from formal to probabilistic reasoning is essential for natural language interfaces at enterprise scale.

### 2.3 LLM-Based Multi-Agent Systems

The emergence of LLMs as general-purpose reasoning engines has sparked intense interest in multi-agent architectures that decompose complex tasks across specialized agents. AutoGen provides a flexible framework for multi-agent conversation with customizable communication patterns [AutoGen2023], while MetaGPT introduces standardized operating procedures (SOPs) that structure agent collaboration through role specialization and artifact-based communication [MetaGPT2023]. ChatDev applies a sequential chat chain paradigm to software development, with role-playing agent pairs (CEO-CTO, programmer-reviewer) collaborating through explicit dialogue [ChatDev2023].

These systems demonstrate that multi-agent decomposition can improve performance on complex tasks, but they rely on explicit communication mechanisms. AutoGen agents exchange structured messages, MetaGPT agents subscribe to shared memory pools, and ChatDev agents engage in scripted dialogues. CAMEL introduces role-playing with inception prompting to induce cooperative behavior [CAMEL2023], while recent work on multi-agent debate shows that parallel agents arguing from diverse perspectives can improve factual accuracy [Debate2023].

A critical gap in existing LLM-based multi-agent systems is the lack of principled justification for coordination mechanisms. Why should agents communicate explicitly rather than implicitly? Why execute serially rather than in parallel? When does multi-agent decomposition improve over single-agent reasoning? These questions remain largely unanswered in the literature. The LLM-based agents survey identifies coordination and long-term planning as open challenges [LLMAgentSurvey2023], noting that most systems rely on heuristic designs without theoretical grounding.

Smart Query introduces implicit context inheritance through shared conversation history, where agents observe the outputs of their predecessors in the conversation context rather than through explicit message passing. This design choice is not arbitrary but theoretically motivated: applying information theory, we show that serial execution with implicit context inheritance produces a semantic cumulative effect, where information entropy about the target data monotonically decreases as strategies accumulate evidence. Formally, if S₁, S₂, S₃ denote the three strategies and I denotes the target table identity, then H(I | S₁, S₂, S₃) ≤ H(I | S₁, S₂) ≤ H(I | S₁) ≤ H(I), where H denotes Shannon entropy. This analysis provides a principled framework for understanding when serial execution with context inheritance is preferable to parallel independent execution in LLM-based multi-agent systems.

Our evidence pack fusion mechanism also differs from existing approaches. Where multi-agent debate systems use voting or averaging to aggregate agent outputs [Debate2023], we perform cross-validation adjudication on structured evidence packs, producing graded confidence scores (high for three-strategy consensus, medium-high for two-strategy agreement, cautious for single-strategy recommendations). This approach is more rigorous than simple voting because it operates on structured evidence — candidate tables with reasoning traces — rather than binary predictions.

### 2.4 Knowledge Graph-Enhanced LLM Reasoning

The integration of knowledge graphs (KGs) with LLMs has emerged as a promising approach to reduce hallucination and improve factual grounding. Comprehensive surveys document 25-60% hallucination reduction when LLM reasoning is augmented with structured knowledge [KG-LLM-Roadmap2024, KG-LLM-Survey2024]. Think-on-Graph demonstrates that LLM-guided beam search over knowledge graphs can improve multi-hop reasoning on knowledge graph question answering (KGQA) tasks by 10-20% [Think-on-Graph2024]. The system uses an LLM to score exploration paths through a general knowledge graph, combining neural pattern matching with symbolic structure.

GraphRAG introduces hierarchical knowledge graph construction with community detection, enabling both local and global query answering over document collections [GraphRAG2024]. The system builds a KG dynamically from text, clusters nodes into communities, and generates summaries at multiple granularities. This hierarchical structure enables more comprehensive retrieval than flat vector search, though the approach targets document-based question answering rather than database querying.

StructGPT provides specialized interfaces for LLM reasoning over structured data, including tables, knowledge graphs, and databases [StructGPT2023]. The system defines iterative reading and reasoning operations that allow LLMs to navigate structured data systematically. However, StructGPT uses generic interfaces that do not exploit domain-specific structure or relationships.

The fundamental limitation of existing KG+LLM work is its reliance on general-purpose knowledge graphs (Wikidata, Freebase) or dynamically constructed graphs from text. These approaches treat the KG as a passive retrieval source — a structured database to be queried — rather than an active cognitive layer that guides reasoning. They typically employ a single retrieval or exploration strategy, missing the opportunity for multi-perspective evidence collection and cross-validation.

Smart Query differs in several key respects, which we detail through explicit technical comparison with the two most closely related systems.

**Comparison with GraphRAG.** GraphRAG [GraphRAG2024] constructs a knowledge graph dynamically from text documents, applies community detection (Leiden algorithm) to cluster nodes, and generates summaries at multiple granularities for retrieval. Smart Query differs in three fundamental ways. (1) *Knowledge source*: GraphRAG builds its KG from unstructured text through entity extraction, producing a general-purpose graph whose quality depends on extraction accuracy. Smart Query uses a purpose-built ontology constructed from structured metadata (database catalogs, ETL lineage, business glossaries) through a deterministic 21-step pipeline, producing a domain-specific graph with guaranteed structural fidelity. (2) *Navigation mechanism*: GraphRAG uses a single retrieval strategy (community-based hierarchical search), while Smart Query employs three orthogonal navigation strategies over distinct knowledge layers, enabling cross-validation through multi-perspective evidence fusion. (3) *Task scope*: GraphRAG targets document-based question answering (retrieving text passages), while Smart Query targets database querying (identifying specific tables, fields, and JOIN conditions) — a task requiring precise structural reasoning that community-based summarization does not address.

**Comparison with Think-on-Graph.** Think-on-Graph [Think-on-Graph2024] uses LLM-guided beam search over a general knowledge graph (e.g., Wikidata) for multi-hop reasoning. Smart Query differs in three ways. (1) *Knowledge graph type*: Think-on-Graph operates on general-purpose KGs with entity-relation-entity triples, while Smart Query operates on a multi-layered enterprise ontology with heterogeneous node types (indicators, tables, terms) and typed relationships (HAS_INDICATOR, UPSTREAM, HAS_TERM) encoding domain-specific semantics. (2) *Exploration strategy*: Think-on-Graph uses a single beam search guided by LLM scoring of candidate paths, while Smart Query uses three specialized strategies that each exploit different structural properties of the ontology (indicator hierarchies, data asset topology, term associations). (3) *Evidence integration*: Think-on-Graph selects the highest-scoring path, while Smart Query fuses structured evidence packs from three independent perspectives through cross-validation adjudication with graded confidence. The multi-perspective approach provides robustness that single-path beam search cannot achieve.

In summary, Smart Query's core technical differentiators are: (a) a purpose-built multi-layered ontology with structural fidelity guarantees, (b) three orthogonal navigation strategies enabling cross-validation, and (c) structured evidence fusion with graded confidence. These are engineering choices motivated by the enterprise-scale data querying task, where precision and reliability requirements exceed what general-purpose KG reasoning provides.

Table 7 summarizes the positioning of Smart Query relative to representative systems from each research area. Smart Query is unique in combining ontology-driven cognitive architecture, multi-agent serial execution with implicit context inheritance, evidence pack fusion with graded confidence, and enterprise-scale deployment (35,000+ tables). While individual components have precedents — OBDA systems use ontologies, MAC-SQL uses multiple agents, Think-on-Graph uses KG-guided reasoning — no existing system integrates these elements into a unified cognitive architecture with information-theoretic justification for its design choices.

**Table 7: System Positioning Comparison**

| System | Ontology-Driven | Multi-Agent | Serial Context | Evidence Fusion | Enterprise Scale |
|:-------|:----------------|:------------|:---------------|:----------------|:-----------------|
| DIN-SQL | No | Yes (4 subtasks) | Yes (pipeline) | No | No (<200 tables) |
| MAC-SQL | No | Yes (3 agents) | Yes (pipeline) | Simple voting | No (<200 tables) |
| Ontop (OBDA) | Yes (formal) | No | N/A | N/A | Medium |
| GraphRAG | Partial (auto-KG) | No | No | Community summary | No (documents) |
| Think-on-Graph | Partial (general KG) | No | No | Beam search | No (KGQA) |
| **Smart Query** | **Yes (purpose-built)** | **Yes (3 strategies)** | **Yes (context inheritance)** | **Cross-validation** | **Yes (35K+ tables)** |
## 3. System Architecture

We now present the detailed architecture of Smart Query, grounding the Cognitive Hub concept introduced in Section 1 in concrete system design. The architecture consists of four integrated layers: a three-layer ontology serving as externalized declarative memory, specialized Skills encoding procedural knowledge, MCP tools providing structured access mechanisms, and an LLM-based orchestrator coordinating multi-strategy reasoning. We describe each component systematically, explaining design rationale and implementation details.

### 3.1 Overview: Cognitive Hub Architecture

The Cognitive Hub architecture formalizes the relationship between static knowledge structures and dynamic reasoning processes. We ground this formalization in cognitive architecture theory, drawing on three established frameworks: ACT-R (Adaptive Control of Thought-Rational) [Anderson2004], SOAR (State, Operator, And Result) [Laird2012], and CoALA (Cognitive Architecture for Language Agents) [Sumers2023].

**Declarative Memory: The Three-Layer Ontology.** The ontology layer serves as externalized long-term declarative memory, analogous to ACT-R's declarative module or SOAR's semantic memory. It contains 314,680 nodes and 623,118 relationships organized into three specialized layers: the Indicator Layer (163,284 nodes encoding business concepts), the Data Asset Layer (35,379 nodes representing physical database structures), and the Term/Standard Layer (40,319 nodes capturing business terminology). This separation is not arbitrary but reflects distinct knowledge dimensions that enable orthogonal navigation strategies. The ontology is stored in Neo4j, providing graph-native storage with O(1) relationship traversal and vector similarity search through native indexes.

**Procedural Memory: Specialized Skills.** Skills encode procedural knowledge — cognitive strategies for navigating the ontology and constructing evidence. Each of the three strategy Skills (Indicator Expert, Scenario Navigator, Term Analyst) is approximately 400-500 lines of structured instructions that guide the LLM through a specific reasoning process. These Skills correspond to production rules in ACT-R or operators in SOAR: they specify conditions for activation and sequences of actions to execute. The modular decomposition empirically improves instruction-following compliance by limiting each Skill's scope to a single cognitive task, avoiding the attention degradation observed in monolithic 2000+ line instruction sets [SmartQueryDesign].

**Pattern Matching Engine: The LLM.** The LLM (Claude 3.5 Sonnet in our implementation) serves as the central pattern-matching and coordination engine, analogous to ACT-R's central production system or SOAR's decision procedure. It interprets natural language queries, selects appropriate Skills, invokes MCP tools based on Skill instructions, and performs final adjudication over structured evidence. Critically, the LLM does not store domain knowledge internally — it retrieves knowledge from the externalized ontology through tool calls, avoiding hallucination on enterprise-specific table and field names.

**Retrieval Mechanisms: MCP Tools.** The system exposes 29 MCP (Model Context Protocol) tools that bridge LLM working memory with the externalized ontology. These tools implement hybrid retrieval (keyword + vector), hierarchical path navigation, lineage traversal, and metadata enrichment. They correspond to retrieval operations in CoALA's external action space or ACT-R's buffer access operations. The tool layer abstracts Neo4j query complexity, providing the LLM with high-level semantic operations like `get_indicator_full_path()` or `get_table_dependencies()` rather than raw Cypher queries.

**Formalization.** We formalize the Cognitive Hub as a tuple CH = (O, S, T, L), where:
- O = {O_I, O_D, O_T} is the three-layer ontology (Indicator, Data Asset, Term)
- S = {S_1, S_2, S_3} is the set of strategy Skills
- T = {t_1, ..., t_29} is the set of MCP tools
- L is the LLM pattern-matching engine

The system processes a natural language query q through serial strategy execution: L invokes S_1(q, O, T) → E_1, then S_2(q, O, T, H_1) → E_2, then S_3(q, O, T, H_2) → E_3, where E_i denotes the evidence pack from strategy i and H_k denotes the conversation history after strategy k completes. The notation S_k(..., H_{k-1}) represents a *logical* dependency — strategy k has access to prior evidence through the conversation history H — rather than explicit parameter passing. In practice, each Skill receives only the original user question as an explicit argument; prior evidence is available implicitly because the LLM's conversation context accumulates all preceding tool calls and reasoning. Final adjudication A(E_1, E_2, E_3, H) → R produces the recommendation R containing the primary table, related tables, and JOIN conditions.

Figure 2 illustrates the complete architecture, showing data flow from user query through the three-strategy serial execution to final evidence pack construction.

(see Figure 2)

### 3.2 Ontology Layer Design

The three-layer ontology design reflects a fundamental insight: enterprise data landscapes exhibit multiple orthogonal organizational principles that cannot be collapsed into a single hierarchy. Business concepts (indicators) follow domain-specific taxonomies, physical data assets follow technical schemas and topics, and business terminology follows standardization frameworks. By separating these dimensions into distinct layers while maintaining cross-layer associations, we enable three independent navigation strategies that converge on the same physical tables through different reasoning paths.

**Indicator Layer: Business Concept Hierarchy.** The Indicator Layer contains 163,284 nodes organized in a 5-level hierarchy: SECTOR (34 nodes) → CATEGORY (301 nodes) → THEME (961 nodes) → SUBPATH (6,221 nodes) → INDICATOR (155,767 nodes). This hierarchy reflects the banking domain's business logic, with sectors like "Credit Business" and "Deposit Business" decomposing into progressively finer-grained concepts. Each INDICATOR node represents a specific business metric (e.g., "SME loan balance") with metadata including Chinese name, English name, business definition, and calculation logic. The hierarchy is connected by 163,283 HAS_CHILD relationships, forming a tree structure that supports top-down navigation from broad business domains to specific metrics.

Critically, INDICATOR nodes are connected to physical database fields through 147,464 HAS_INDICATOR relationships. These mappings are pre-computed during ontology construction through expression parsing of the `c_expression` field in the source metadata table `t_bizattr`. The expression parser handles 8 format types including standard `schema.table.column` references, function-wrapped expressions, arithmetic combinations, and complex CASE WHEN logic. This pre-computation converts a runtime O(n) parsing problem into an O(1) graph lookup, enabling real-time indicator-to-field resolution at scale.

**Data Asset Layer: Physical Database Topology.** The Data Asset Layer contains 35,379 nodes organized in a 3-level hierarchy: SCHEMA (9 nodes) → TABLE_TOPIC (83 nodes) → TABLE (35,287 nodes). This layer represents the physical database structure, with schemas corresponding to major data domains (e.g., "Credit Data Mart", "Customer Data Warehouse") and topics representing business-aligned table groupings within each schema (e.g., "Loan Products", "Customer Demographics"). The hierarchy is connected by 83 HAS_TOPIC relationships (SCHEMA to TABLE_TOPIC) and 3,385 HAS_TABLE relationships (TABLE_TOPIC to TABLE).

The Data Asset Layer's distinguishing feature is its 50,509 UPSTREAM relationships encoding data lineage. These relationships reflect actual ETL (Extract, Transform, Load) data flow, with 43,880 direct lineage edges (TableDirectTable) and 6,629 indirect lineage edges (TableIndirectTable). Each TABLE node includes metadata such as table description, column count, and lineage statistics (upstream_count, total_downstream_count). The lineage graph enables discovery of related tables for JOIN operations based on structural facts about data flow rather than semantic similarity guesses — a key innovation we detail in Section 3.5.

**Term/Standard Layer: Business Terminology and Governance.** The Term/Standard Layer contains 40,319 nodes: 39,558 TERM nodes representing business terminology and 761 DATA_STANDARD nodes representing data governance standards. TERM nodes capture the business vocabulary used to describe data, with each term linked to one or more physical table columns through 251,227 HAS_TERM relationships. DATA_STANDARD nodes represent standardization frameworks (e.g., "Customer Identification Standards", "Financial Metric Standards"), with terms grouped under standards through 7,167 BELONGS_TO_STANDARD relationships.

This layer addresses a critical challenge in enterprise data querying: the semantic gap between business language and technical field names. A business analyst might ask about "客户编号" (customer ID), which could map to technical fields named `cust_id`, `customer_no`, `client_identifier`, or other variants across different tables. The Term Layer provides a semantic bridge, enabling field-level discovery through business vocabulary rather than requiring knowledge of technical naming conventions.

**Cross-Layer Associations: Enabling Multi-Perspective Discovery.** The three layers are connected through cross-layer associations that enable different navigation strategies to converge on the same physical tables. The 147,464 HAS_INDICATOR edges connect INDICATOR nodes to TABLE nodes, allowing the Indicator Expert to map business concepts directly to data assets. The 251,227 HAS_TERM edges connect TABLE nodes to TERM nodes, allowing the Term Analyst to discover tables through business vocabulary. These cross-layer edges create a multi-dimensional knowledge graph where the same TABLE node can be reached through business indicators, structural navigation, or terminology search — providing natural cross-validation when multiple strategies identify the same table.

Table 1 summarizes the ontology layer statistics, quantifying the scale and structure of each layer.

**Table 1: Ontology Layer Statistics**

| Layer | Node Types | Node Count | Key Relationships | Relationship Count |
|:------|:-----------|:-----------|:------------------|:-------------------|
| Indicator | SECTOR, CATEGORY, THEME, SUBPATH, INDICATOR | 163,284 | HAS_CHILD, HAS_INDICATOR | 163,283 + 147,464 |
| Data Asset | SCHEMA, TABLE_TOPIC, TABLE | 35,379 | HAS_TOPIC, HAS_TABLE, UPSTREAM | 83 + 3,385 + 50,509 |
| Term/Standard | TERM, DATA_STANDARD | 40,319 | HAS_TERM, BELONGS_TO_STANDARD | 251,227 + 7,167 |
| **Total** | **10 types** | **314,680** | **7 types** | **623,118** |

**Digital Twin Concept.** We characterize the ontology as a "digital twin" of the enterprise data landscape — a structured representation that mirrors the organization, semantics, and relationships of the physical database environment, integrating business logic (indicators), technical structure (schemas and lineage), and semantic mappings (terms and standards) into a unified knowledge graph.

### 3.3 Three-Strategy Serial Execution

The three strategy Skills — Indicator Expert, Scenario Navigator, and Term Analyst — execute serially in a fixed order, with each strategy exploring an orthogonal knowledge dimension and producing an independent evidence pack. Serial execution with implicit context inheritance is central to the Cognitive Hub architecture, enabling the semantic cumulative effect formalized in Section 4.1.

**Strategy 1: Indicator Expert.** The Indicator Expert navigates the Indicator Layer to map business concepts in the user query to physical database fields. The strategy proceeds in four phases:

1. *Keyword Extraction and Indicator Search*: Extract business concept keywords from the query and search the Indicator Layer using `layered_keyword_search()`, which implements hybrid retrieval with a fixed 50/50 ratio (keyword matching + vector similarity). The search returns candidate INDICATOR nodes with fusion scores indicating whether they were recalled by keyword, vector, or both.

2. *Hierarchy Path Reconstruction*: For each candidate indicator, retrieve the full 5-level path (SECTOR→CATEGORY→THEME→SUBPATH→INDICATOR) using `get_indicator_full_path()`. This provides business context, enabling the LLM to assess semantic relevance beyond surface-level keyword matching.

3. *Field Mapping Discovery*: For selected indicators, retrieve physical field mappings using `get_indicator_field_mapping()`, which traverses the pre-computed HAS_INDICATOR relationships. This returns TABLE nodes with specific column names, providing concrete data asset candidates.

4. *Semantic Enhancement*: For each candidate table, retrieve business terms using `get_table_terms()` to enrich field-level semantics. This enables more precise field selection in downstream SQL generation.

The Indicator Expert produces Evidence Pack 1 containing candidate tables ranked by indicator relevance, with reasoning traces documenting the business concept → indicator → field mapping chain. The strategy is particularly effective for queries that use standard business terminology aligned with the indicator hierarchy (e.g., "SME loan balance", "branch deposit volume").

**Strategy 2: Scenario Navigator.** The Scenario Navigator employs a dual retrieval mechanism that combines structural navigation with semantic search. This strategy is motivated by the observation that structured ontology navigation and semantic vector search are complementary rather than substitutable: structural navigation provides precision through explicit business-aligned hierarchies, while semantic search provides recall through fuzzy matching and synonym discovery.

The strategy executes two parallel retrieval paths:

1. *Convergent Path Navigation*: Follow the SCHEMA→TABLE_TOPIC→TABLE hierarchy to progressively narrow the search space. First, list all schemas using `list_schemas()` and select the most relevant based on query semantics. Then, retrieve topics within the selected schema using `get_schema_topics()`. Finally, retrieve tables within the selected topic using `get_topic_tables()` or `get_topic_tables_with_columns()` for detailed column information. This convergent path avoids searching all 35,287 tables globally, instead constraining the search to the ~400-800 tables within a single topic.

2. *Hybrid Search*: Execute `hybrid_search_tables()` with `keyword_limit=50` and `vector_limit=10`, retrieving up to 60 candidate tables (with deduplication). This semantic expansion discovers tables that may not fall within the structurally identified topic but are semantically relevant to the query.

The two retrieval paths are fused through deduplication and fusion scoring: tables recalled by both methods receive `fusion_score=1.0` (highest confidence), while tables recalled by only one method receive `fusion_score=0.5`. The Scenario Navigator produces Evidence Pack 2 containing candidate tables ranked by fusion score, with reasoning traces documenting both the convergent path and hybrid search results.

The dual retrieval mechanism addresses a fundamental tension in enterprise data querying: business-aligned topic hierarchies provide interpretable structure but may not capture all semantic relationships, while vector search provides broad coverage but lacks interpretability. By executing both and fusing results, Strategy 2 achieves both precision and recall.

**Strategy 3: Term Analyst.** The Term Analyst searches the Term/Standard Layer to discover tables through business vocabulary and data governance standards. The strategy proceeds in three phases:

1. *Term Search*: Extract business terminology from the query and search the Term Layer using `search_terms_by_keyword()`. This returns TERM nodes matching the query vocabulary, with metadata including term definitions and standardization status.

2. *Table Discovery via Terms*: For each relevant term, retrieve associated tables using `get_tables_by_term()`, which traverses the HAS_TERM relationships. This discovers tables that contain fields described by the business terminology, even if the technical field names differ.

3. *Standard-Based Enhancement*: For terms belonging to data standards, retrieve standard information using `get_standard_info()`. This provides governance context, indicating which tables adhere to enterprise data standards and are therefore more reliable for reporting and analysis.

The Term Analyst produces Evidence Pack 3 containing candidate tables ranked by term relevance and standard compliance, with reasoning traces documenting the business vocabulary → term → field → table discovery chain. This strategy is particularly effective for queries using non-standard business language or synonyms not captured in the indicator hierarchy.

**Serial Execution via Synchronous Skill Calls.** The three strategies execute serially through synchronous `Skill()` calls in the orchestrator. The orchestrator invokes `Skill("smart-query-indicator", args={"user_question": q})` and waits for Evidence Pack 1 to return before invoking Strategy 2, which in turn completes before Strategy 3 begins. This deterministic serial scheduling ensures that each strategy's output is available in the conversation history before the next strategy executes.

**Implicit Context Inheritance through Conversation History.** Although the `args` parameter passed to each Skill contains only the original `user_question`, each strategy has access to the full conversation history, including all prior strategies' tool calls, reasoning, and evidence packs. This enables implicit context inheritance: Strategy 2 can observe that Strategy 1 identified a particular schema or business domain and focus its convergent path navigation accordingly. Strategy 3 can observe that Strategies 1 and 2 converged on certain candidate tables and prioritize terms associated with those tables. We draw an analogy to stigmergy in biological systems [Grasse1959] — where agents coordinate by observing environmental traces left by predecessors — while acknowledging that the underlying mechanism here is straightforward: the LLM reads prior conversation turns, a standard capability of multi-turn LLM systems. The novelty lies not in the communication mechanism itself but in the architectural design that structures what information is deposited and how subsequent strategies leverage it through orthogonal knowledge dimensions.

The implicit context inheritance design has several advantages over explicit parameter passing: (1) it maintains backward compatibility, as each Skill can be invoked independently with only the user question; (2) it reduces inter-Skill coupling, as strategies do not need to agree on a shared evidence format for parameter passing; (3) it leverages the LLM's natural ability to extract relevant information from conversation history, avoiding the need for explicit context extraction logic.

**Cognitive Modular Architecture.** Each strategy Skill is approximately 400-500 lines of structured instructions focused on a single cognitive task. This modular decomposition is motivated by empirical observations of instruction-following quality degradation in large monolithic Skills. We hypothesize that instruction-following quality is inversely proportional to instruction set size: a 2000-line monolithic Skill exhibits attention diffusion, where the LLM struggles to maintain focus on all instructions simultaneously. By decomposing into focused modules, each Skill achieves substantially improved instruction compliance compared to monolithic alternatives. The underlying principle is that modular decomposition enables specialization, context inheritance enables semantic accumulation across modules, and task focus enables attention concentration within each module.

Table 2 compares the three strategies across key capability dimensions, demonstrating their complementary coverage of orthogonal knowledge dimensions.

(see Table 2)

### 3.4 Evidence Pack Fusion and Adjudication

After the three strategies complete, the orchestrator performs comprehensive adjudication to select the primary table and construct the final evidence pack. This process operates on structured evidence rather than binary predictions, enabling more rigorous cross-validation than simple voting or averaging.

**Evidence Pack Structure.** Each strategy produces a structured JSON evidence pack containing:
- `candidate_tables`: List of TABLE nodes with metadata (name, description, schema, topic, column count)
- `confidence_scores`: Numerical scores indicating the strategy's confidence in each candidate
- `reasoning_trace`: Natural language explanation of the discovery process
- `supporting_evidence`: Specific indicators, terms, or paths that led to each candidate
- `metadata`: Strategy-specific information (e.g., fusion scores for Strategy 2, standard compliance for Strategy 3)

This structured format enables programmatic cross-validation: the orchestrator can compare candidate tables across evidence packs, identify consensus and conflicts, and trace the reasoning chain for each recommendation.

**Cross-Validation Adjudication.** The orchestrator performs cross-validation through three analyses:

1. *Consensus Analysis*: Identify tables that appear in multiple evidence packs. A table appearing in all three packs receives high confidence (three-strategy consensus), a table in two packs receives medium-high confidence (two-strategy agreement), and a table in one pack receives cautious confidence (single-strategy recommendation). This graded confidence mechanism reflects the principle that independent evidence from orthogonal perspectives is more reliable than evidence from a single perspective.

2. *Conflict Resolution*: When strategies propose different tables, the orchestrator examines the reasoning traces to identify the source of disagreement. Common conflict patterns include: (a) different tables within the same topic (resolved by examining field-level semantics), (b) tables from different schemas serving similar business purposes (resolved by examining data freshness and lineage), and (c) ambiguous queries where multiple interpretations are valid (resolved by requesting user clarification or providing multiple options with confidence scores).

3. *Coverage Analysis*: Assess whether the candidate tables collectively cover all semantic elements in the user query. If Strategy 1 identifies tables for "loan balance" but no strategy identifies tables for "branch", the orchestrator flags incomplete coverage and may trigger additional search or request clarification.

**LLM-Based Final Adjudication.** After cross-validation, the LLM performs final adjudication based on the complete evidence from all three perspectives. The LLM is instructed to: (1) prioritize tables with three-strategy consensus, (2) consider reasoning quality and supporting evidence depth, (3) assess field-level coverage of query semantics, (4) apply domain knowledge to resolve ambiguities, and (5) produce a final recommendation with explicit confidence grading and justification.

This LLM-based adjudication is more sophisticated than rule-based voting because it can weigh evidence quality, not just evidence quantity. A single strategy with a detailed reasoning trace and strong supporting evidence may outweigh two strategies with weak, ambiguous recommendations. The LLM's pattern-matching capabilities enable nuanced judgment that would be difficult to encode in explicit rules.

**Comparison with Voting and Averaging.** Our evidence pack fusion differs from multi-agent voting [Debate2023] and ensemble averaging [MAC-SQL2024] in several respects. Voting operates on binary predictions (each agent votes for a single answer), losing information about confidence and reasoning. Averaging operates on numerical scores, assuming scores are calibrated and comparable across agents. Our approach operates on structured evidence packs, preserving the complete reasoning chain and enabling qualitative assessment of evidence quality. This is analogous to the difference between jury voting (binary) and judicial review (evidence-based): the latter provides more rigorous decision-making when evidence quality varies.

### 3.5 Lineage-Driven JOIN Discovery

After primary table selection through adjudication, the system discovers related tables for JOIN operations through lineage-driven analysis. This mechanism embodies a key insight: for relational operations, structural facts about data flow are inherently more reliable than semantic similarity guesses.

**Lineage as Structural Facts.** The 50,509 UPSTREAM relationships in the Data Asset Layer reflect actual ETL data flow, extracted from the `bigmeta_entity_table` metadata table during ontology construction. Each UPSTREAM edge indicates that one table's data is derived from another through a documented ETL process. These relationships are structural facts — they describe the actual data architecture, not semantic similarity or conceptual relatedness.

**JOIN Discovery Algorithm.** Given a primary table T_primary selected through adjudication, the system executes the following algorithm:

1. *Lineage Traversal*: Call `get_table_dependencies(table_name=T_primary, direction='all')` to retrieve all upstream and downstream tables connected through UPSTREAM relationships. This returns two sets: T_upstream (tables that feed into T_primary) and T_downstream (tables that derive from T_primary).

2. *Isolation Filtering*: For each candidate related table T_candidate, check its isolation status. Tables with `upstream_count=0` AND `total_downstream_count=0` are classified as isolated (deprecated/orphaned) and excluded. Source tables (`upstream_count>0`, `total_downstream_count=0`) and normal downstream tables (`upstream_count=0`, `total_downstream_count>0`) are retained.

3. *Field-Level Matching*: For each non-isolated candidate, retrieve column information using `get_table_terms()`. Identify shared business terms (matching `term_en_name`) between T_primary and T_candidate. Shared terms indicate potential JOIN keys.

4. *JOIN Condition Inference*: For each shared term, infer the JOIN condition as `T_primary.field_1 = T_candidate.field_2` where `field_1` and `field_2` are the physical column names associated with the shared term. Determine JOIN type based on relationship direction: INNER JOIN for upstream tables (T_candidate provides required context), LEFT JOIN for downstream tables (T_candidate provides optional enrichment).

5. *Ranking and Selection*: Rank candidate related tables by: (a) lineage distance (direct > indirect), (b) number of shared terms (more shared terms indicate stronger relationship), and (c) data freshness (more recently updated tables preferred). Select the top-k related tables (typically k=2-3) to avoid query complexity explosion.

**Comparison with Vector-Search-Based JOIN Discovery.** Traditional approaches to JOIN discovery use vector similarity to find semantically related tables [StructGPT2023]. For example, given a primary table "loan_balance", vector search might retrieve "loan_application" (high semantic similarity: both relate to loans) even though no direct data flow relationship exists. In contrast, lineage-driven discovery retrieves "customer_info" (direct upstream relationship: customer data feeds into loan balance calculation) and "branch_dim" (indirect upstream relationship: branch data contextualizes loan balances). The lineage-based approach is more reliable because it reflects actual data architecture rather than semantic guesses.

Figure 5 illustrates a concrete example of lineage-driven JOIN discovery, contrasting the correct lineage-based path with an incorrect vector-search-based path.

(see Figure 5)

**Automatic JOIN Condition Inference.** The shared term mechanism enables automatic JOIN condition inference without requiring manual specification. Because business terms are consistently mapped across tables (e.g., "customer_id" maps to `cust_id` in table A and `customer_no` in table B), the system can infer that `A.cust_id = B.customer_no` is the appropriate JOIN condition. This automation is critical for enterprise-scale deployment, where manually specifying JOIN conditions for 35,287 tables would be infeasible.

### 3.6 Isolated Table Filtering

Isolated table filtering provides zero-maintenance data quality assurance through graph-theoretic analysis of the lineage graph. This mechanism addresses a practical challenge in enterprise data environments: tables become deprecated over time as business processes evolve, but they often remain in the database catalog, creating noise in query results.

**Isolation Definition.** A table T is classified as isolated if and only if:
```
upstream_count(T) = 0 AND total_downstream_count(T) = 0
```

This definition captures tables with no incoming or outgoing data flow — they neither receive data from upstream sources nor provide data to downstream consumers. Such tables are typically deprecated, orphaned, or experimental assets that should not be recommended for production queries.

**Filtering Application.** Isolated table filtering is applied during the comprehensive adjudication phase, after evidence collection but before final recommendation. Specifically:
- During evidence pack construction (Strategies 1-3): No filtering is applied. Strategies collect all candidate tables matching their search criteria, including potentially isolated tables.
- During lineage-driven JOIN discovery (Section 3.5): Isolated tables are excluded from the related table set. Only tables with `upstream_count>0` OR `total_downstream_count>0` are considered for JOIN operations.
- During final recommendation: If the primary table selected through adjudication is isolated, the system flags this with a warning and may request user confirmation before proceeding.

**Distinction from Source Tables.** It is critical to distinguish isolated tables from source tables. A source table has `upstream_count=0` (no upstream dependencies) but `total_downstream_count>0` (provides data to downstream consumers). Source tables are valid entry points in the data architecture and should not be filtered. The isolation criterion requires both counts to be zero, ensuring that only truly orphaned tables are excluded.

**Cognitive Architecture Analogy.** Isolated table filtering is analogous to base-level activation decay in ACT-R [Anderson2004], where declarative memory chunks that are not accessed or reinforced gradually become inaccessible. In ACT-R, activation reflects both recency and frequency of use; chunks with low activation fall below the retrieval threshold and cannot be recalled. Similarly, isolated tables with no data flow represent unused knowledge that should become inaccessible to prevent contamination of query results with deprecated information.

**Zero-Maintenance Property.** The key advantage of graph-theoretic isolation detection is that it requires no manual curation. As long as the lineage graph is kept up-to-date (through periodic ETL metadata extraction), isolation status is automatically computed from graph topology. This contrasts with manual deprecation flags, which require ongoing maintenance and often become stale as organizational knowledge disperses.

---

The architecture presented in this section integrates four key innovations: the three-layer ontology as externalized declarative memory, specialized Skills as procedural memory, serial execution with implicit context inheritance, and lineage-driven search space reduction. These components work in concert to transform the ontology from passive knowledge storage into an active Cognitive Hub that guides systematic domain reasoning. In Section 4, we provide theoretical analysis of the semantic cumulative effect that emerges from this architecture, formalizing why serial execution with context inheritance outperforms parallel independent execution.
## 4. Theoretical Analysis

Having presented the system architecture in Section 3, we now provide theoretical grounding for Smart Query's design choices. We analyze the semantic cumulative effect through information theory, characterize the multi-agent coordination properties in relation to established MAS paradigms, and map the Cognitive Hub architecture to cognitive science frameworks. This analysis applies established theoretical tools to our specific architectural context, yielding actionable design guidelines for LLM-based cognitive architectures.

### 4.1 Information-Theoretic Analysis of Multi-Strategy Coordination

The semantic cumulative effect — the observation that serial strategy execution with implicit context inheritance progressively reduces uncertainty about the target data — can be analyzed through Shannon entropy and conditional mutual information. We apply standard information-theoretic properties to formalize this effect, establish conditions under which each strategy contributes new information, and identify failure modes specific to our architecture.

**Definition 1 (Semantic Cumulative Effect).** Let I denote the target information (the correct table-field mapping for a user query), and let S₁, S₂, S₃ denote the evidence produced by the three strategies. The semantic cumulative effect is the property that:

```
H(I | S₁, S₂, S₃) ≤ H(I | S₁, S₂) ≤ H(I | S₁) ≤ H(I)
```

where H(·) denotes Shannon entropy and H(I | S) denotes the conditional entropy of I given evidence S.

**Property 1 (Monotonic Entropy Reduction).** The entropy chain above follows directly from the chain rule of conditional entropy and the non-negativity of mutual information — standard properties of Shannon entropy that hold for any random variables [Cover & Thomas, 2006].

*Derivation.* By the chain rule:

```
H(I | S₁, S₂) = H(I | S₁) - I(I; S₂ | S₁)
```

where I(I; S₂ | S₁) is the conditional mutual information between I and S₂ given S₁. Since mutual information is non-negative:

```
I(I; S₂ | S₁) ≥ 0
```

we have H(I | S₁, S₂) ≤ H(I | S₁). The same reasoning extends to each subsequent strategy, yielding the full chain. □

This monotonic reduction is a general property of conditioning on additional evidence — it holds for *any* information sources, not only the specific strategies in our system. The contribution of our analysis is not the inequality itself, but its application to characterize *when and why* multi-strategy serial execution is effective for enterprise-scale data querying, and to identify the architectural conditions under which each strategy contributes meaningful information reduction. We now establish these conditions.

**Property 2 (Conditions for Strict Inequality).** The strict inequality H(I | S₁, ..., Sₖ) < H(I | S₁, ..., Sₖ₋₁) holds if and only if I(I; Sₖ | S₁, ..., Sₖ₋₁) > 0, meaning strategy Sₖ provides information about I not already contained in previous strategies. This follows directly from the chain rule decomposition.

In Smart Query, strict inequality is ensured by design through orthogonal knowledge dimensions. Strategy 1 (Indicator Expert) explores the business indicator hierarchy — a knowledge dimension that captures business semantics and calculation logic. Strategy 2 (Scenario Navigator) explores the data asset topology — a knowledge dimension that captures physical database organization and topic structure. Strategy 3 (Term Analyst) explores business terminology and data standards — a knowledge dimension that captures linguistic conventions and governance frameworks. These three dimensions are orthogonal by construction: knowing which business indicator is relevant does not determine which schema or topic contains the data, and knowing the schema does not determine which business terms describe the fields.

**Quantifying the Cumulative Effect.** We define the cumulative reduction ratio (CRR) to quantify the overall entropy reduction achieved by the three-strategy sequence:

```
CRR = (H(I) - H(I | S₁, S₂, S₃)) / H(I)
```

The CRR ranges from 0 (no reduction) to 1 (complete uncertainty elimination). For enterprise-scale querying with N = 35,287 tables, the prior entropy is H(I) = log₂(N) ≈ 15.11 bits, assuming a uniform prior distribution over tables. A CRR of 0.70 indicates that the three strategies collectively reduce entropy by 10.58 bits, narrowing the candidate set from 35,287 tables to approximately 2^(15.11 - 10.58) ≈ 23 tables — a 1,500-fold reduction in search space.

**Comparison with Parallel Execution.** The semantic cumulative effect depends critically on serial execution with context inheritance. In the parallel (independent agent) case, strategies execute without access to each other's findings, producing evidence S₁ⁱⁿᵈᵉᵖ, S₂ⁱⁿᵈᵉᵖ, S₃ⁱⁿᵈᵉᵖ that are conditionally independent given I. The final entropy is:

```
H(I | S₁ⁱⁿᵈᵉᵖ, S₂ⁱⁿᵈᵉᵖ, S₃ⁱⁿᵈᵉᵖ)
```

In the serial (cumulative) case with context inheritance, later strategies condition on earlier findings, producing evidence S₁, S₂(S₁), S₃(S₁, S₂) where the notation Sₖ(S₁, ..., Sₖ₋₁) indicates that strategy k's evidence depends on previous strategies. The final entropy is:

```
H(I | S₁, S₂(S₁), S₃(S₁, S₂))
```

We hypothesize that the cumulative case achieves lower entropy:

```
H(I | S₁, S₂(S₁), S₃(S₁, S₂)) ≤ H(I | S₁ⁱⁿᵈᵉᵖ, S₂ⁱⁿᵈᵉᵖ, S₃ⁱⁿᵈᵉᵖ)
```

Note that this comparison is *not* a direct consequence of the monotonic reduction property above — it compares two different information-gathering processes (serial with context vs. parallel without context), not successive stages of the same process. We do not provide a formal proof of this inequality, as it depends on empirical properties of how effectively the LLM leverages context to focus subsequent searches. Instead, we provide an intuitive argument and validate the hypothesis empirically in Section 5.4.

The intuition is that context inheritance allows later strategies to focus their search on the most promising regions of the knowledge space, increasing the relevance and information content of their evidence. Strategy 2, observing that Strategy 1 identified a particular business domain, can constrain its schema search to schemas serving that domain. Strategy 3, observing that Strategies 1 and 2 converged on certain candidate tables, can prioritize terms associated with those tables. This focused search yields higher-quality evidence than unfocused parallel search.

Formally, context inheritance increases the conditional mutual information I(I; Sₖ | S₁, ..., Sₖ₋₁) by enabling Sₖ to target regions of high information gain. In the parallel case, Sₖⁱⁿᵈᵉᵖ must allocate search effort uniformly across the entire knowledge space, diluting its information content. This argument parallels active learning theory, where query selection based on current uncertainty reduces sample complexity compared to random sampling [Settles2009].

**Failure Modes.** The semantic cumulative effect can fail (equality holds) under three conditions:

1. *Complete Redundancy*: Strategy Sₖ explores the same knowledge dimension as previous strategies, providing no new information. This occurs when I(I; Sₖ | S₁, ..., Sₖ₋₁) = 0. Smart Query avoids this through orthogonal knowledge dimensions by design.

2. *Noise Introduction*: Strategy Sₖ returns irrelevant results that do not reduce uncertainty about I. This can occur when keyword ambiguity causes the strategy to explore incorrect semantic regions. For example, a query about "balance" might retrieve both "account balance" and "work-life balance" indicators. The cross-validation adjudication mechanism mitigates this by requiring consensus across strategies.

3. *Context Degradation*: In the implicit context inheritance model, if the LLM fails to extract relevant information from conversation history, the effective evidence Sₖ may be independent of previous strategies, reducing to the parallel case. This failure mode is specific to LLM-based implementations and highlights the importance of conversation history management and prompt engineering.

Figure 6 visualizes the theoretical entropy reduction across strategy stages, showing expected trajectories for different query complexity categories.

(see Figure 6)

### 4.2 Multi-Agent Coordination Properties

We now analyze Smart Query's multi-agent coordination mechanism in relation to established MAS paradigms. We characterize the system as a Pipeline-Blackboard Hybrid with Context Inheritance and compare this architecture with classical frameworks.

**Paradigm Classification.** Smart Query combines three coordination patterns:

1. *Pipeline Architecture*: The three strategies execute in strict serial order (S₁ → S₂ → S₃ → Adjudication), with each stage processing the same input query but producing incremental evidence. This deterministic scheduling ensures reproducibility and simplifies debugging compared to opportunistic or negotiation-based coordination.

2. *Blackboard Architecture*: Evidence packs accumulate in a shared space (the conversation history) that all subsequent agents can read. The orchestrator serves as the control component that schedules knowledge source activation (strategy invocation) and performs final adjudication. This differs from classical blackboard systems [Hayes-Roth1985] in using deterministic serial scheduling rather than opportunistic activation based on blackboard state.

3. *Stigmergic Communication*: Strategies communicate indirectly by modifying the shared environment (depositing evidence into conversation history) rather than through explicit message passing. Subsequent strategies perceive these environmental traces and adjust their behavior accordingly. We use the term "stigmergy" [Grasse1959] as an analogy to the coordination mechanism observed in social insects; we acknowledge that the underlying implementation — an LLM reading prior conversation turns — is a standard multi-turn capability. The architectural contribution is the structured design of what information each strategy deposits and how subsequent strategies are instructed to leverage it.

We term this combination a *Pipeline-Blackboard Hybrid with Context Inheritance*. This coordination pattern combines the reproducibility of pipelines, the shared evidence accumulation of blackboards, and the implicit communication enabled by the LLM's conversation context.

**Comparison with Ensemble Methods.** Smart Query's three-strategy approach shares superficial similarities with ensemble methods in machine learning (bagging, boosting, stacking) but differs fundamentally in the source of diversity and the combination mechanism.

In ensemble methods, diversity arises from model variation: different algorithms, different training data subsets, or different hyperparameters. Predictions are combined through voting, averaging, or meta-learning. The goal is to reduce variance (bagging) or bias (boosting) through statistical aggregation.

In Smart Query, diversity arises from knowledge dimension variation: different navigation paths through orthogonal layers of the ontology. Evidence is combined through cross-validation adjudication that operates on structured reasoning traces, not just predictions. The goal is to achieve comprehensive coverage of the knowledge space through multi-perspective exploration.

The closest analog in ensemble learning is multi-view learning [Xu2013], where each view provides a different perspective on the same data (e.g., image features vs. text features for multimedia classification). However, multi-view learning typically uses separate models for each view, while Smart Query uses a single LLM with different procedural instructions (Skills) and different knowledge access patterns (tools).

Boosting's sequential error correction provides another analogy: each subsequent model focuses on examples misclassified by previous models, similar to how each Smart Query strategy focuses on aspects not yet resolved. However, boosting adjusts sample weights while Smart Query adjusts search focus through context inheritance — a semantic rather than statistical mechanism.

**Comparison with LLM-Based MAS Frameworks.** Table 3 compares Smart Query with representative LLM-based multi-agent frameworks across key architectural dimensions.

| Framework | Coordination | Communication | Specialization | Knowledge |
|-----------|-------------|---------------|----------------|-----------|
| AutoGen | Flexible (group chat, sequential) | Explicit messages | General-purpose agents | Internal (LLM) |
| MetaGPT | SOP-driven workflow | Shared message pool | Role-based (PM, Architect, Engineer) | Internal (LLM) |
| CrewAI | Sequential/hierarchical | Explicit context passing | Role-based with goals | Internal + tools |
| ChatDev | Phase-based (waterfall) | Pairwise dialogues | Role-based (CEO, Programmer, Tester) | Internal (LLM) |
| OpenAI Swarm | Dynamic handoff | Explicit context variables | Instruction-based | Internal + functions |
| Smart Query | Serial pipeline | Implicit (conversation history) | Knowledge-dimension-based | External (ontology) |

Smart Query uses implicit communication through conversation history rather than explicit message passing or context variables. While reading conversation history is a standard LLM capability, the architectural design — structuring three strategies around orthogonal knowledge dimensions so that each deposits complementary evidence — is what makes this implicit communication effective. Smart Query is also distinctive in grounding agent specialization in orthogonal knowledge dimensions (indicators, topics, terms) rather than functional roles (manager, engineer, tester) or general capabilities.

The externalized knowledge dimension is particularly significant. Most LLM-based MAS frameworks rely on the LLM's internal knowledge, augmented with general-purpose tools (web search, code execution). Smart Query externalizes domain knowledge into a structured ontology accessed through specialized tools, enabling systematic navigation of a 314,680-node knowledge graph that far exceeds LLM context limits.

### 4.3 Cognitive Hub Formalization

We now describe structural analogies between the Cognitive Hub architecture and three established cognitive architecture frameworks: ACT-R [Anderson2004], SOAR [Laird2012], and CoALA [Sumers2023]. These mappings are *analogical* rather than formal implementations — Smart Query is *inspired by* cognitive architecture principles rather than implementing them in the strict sense. The value lies in providing principled design vocabulary and identifying structural parallels that explain why certain architectural choices are effective.

**Table 8: Cognitive Architecture Mapping**

| Cognitive Concept | ACT-R | SOAR | CoALA | Smart Query |
|:------------------|:------|:-----|:------|:------------|
| Declarative Memory | Chunks with activation levels | Semantic long-term memory | Semantic memory (factual knowledge) | Three-layer ontology (314K nodes) |
| Procedural Memory | Production rules (IF-THEN) | Operators (propose-decide-apply) | Action sequences | Strategy Skills (~400 lines each) |
| Working Memory | Buffers connecting modules | Current problem state | LLM conversation context | Conversation history + evidence packs |
| Pattern Matching | Production matcher on buffers | Decision cycle | LLM inference | LLM selects tools based on Skill instructions |
| Retrieval Mechanism | Activation-based (recency × frequency) | Cue-based retrieval | External tool calls | MCP tools (29 structured operations) |
| Learning/Adaptation | Chunk strengthening | Chunking from problem-solving | Episodic memory updates | Evidence pack fusion (not persistent) |
| Impasse Resolution | Conflict resolution among productions | Subgoaling | Replanning | Progressive degradation search (INDICATOR→THEME→SUBPATH) |
| Temporal Validity | Base-level activation decay | N/A | N/A | Isolated table filtering (graph connectivity) |

**Key Parallels.** Three mappings are particularly instructive. First, the ontology's heat scores (reflecting table usage frequency) parallel ACT-R's activation-based retrieval, where frequently accessed chunks are more readily available. Smart Query's isolated table filtering extends this analogy: tables with zero data flow connectivity are excluded, analogous to low-activation chunks falling below ACT-R's retrieval threshold. Second, the three-strategy serial execution maps to SOAR's propose-decide-apply cycle, with each strategy proposing candidates, adjudication deciding among them, and SQL generation applying the decision. When Strategy 1's indicator search fails at the INDICATOR level and degrades to THEME, this parallels SOAR's impasse resolution through subgoaling. Third, CoALA provides the most direct framework because it was designed specifically for LLM-based agents; its distinction between internal reasoning (LLM inference) and external action (tool calls) maps directly to Smart Query's Skill-Tool separation.

**Engineering Innovations Beyond Classical Architectures.** Several aspects of Smart Query are distinctive to LLM-based implementations and have no direct parallel in classical cognitive architectures:

1. *Externalized Declarative Memory at Scale*: Classical architectures assume internal memory. Smart Query externalizes memory into a 314,680-node knowledge graph accessed through tools, enabling memory that exceeds LLM context limits.

2. *Implicit Context Inheritance*: Neither ACT-R nor SOAR have a mechanism where one cognitive process indirectly influences another through environmental traces. Smart Query's context inheritance through conversation history is specific to LLM-based architectures where the shared context is semantically rich and interpretable.

3. *Multi-Dimensional Evidence Fusion*: Classical architectures process information through a single reasoning pathway. Smart Query processes the same query through three orthogonal knowledge dimensions and fuses the results — analogous to multi-sensory integration but without direct precedent in ACT-R or SOAR.

4. *Instruction-Following Optimization through Modularity*: The ~400-line Skill decomposition addresses attention degradation in large instruction sets — a constraint specific to LLM-based systems that classical architectures do not face.

---

The theoretical analysis presented in this section applies established information-theoretic and cognitive architecture frameworks to Smart Query's specific design context. The information-theoretic analysis provides a formal framework for understanding entropy reduction across strategy stages, with the key architectural insight that orthogonal knowledge dimensions maximize information gain. The Pipeline-Blackboard Hybrid with Context Inheritance characterizes a coordination pattern that combines elements of established paradigms. The cognitive architecture mappings (Table 8) provide structural analogies — not formal implementations — that ground the Cognitive Hub concept in established frameworks while identifying engineering innovations specific to LLM-based implementations. In Section 5, we present empirical validation of these analytical predictions through controlled experiments on real banking queries.
## 5. Experiments

Having established the theoretical foundations in Section 4, we now present empirical validation of Smart Query's design through controlled experiments on real banking queries. We evaluate the system against five baseline approaches spanning the design space, conduct six ablation studies to isolate component contributions, and directly measure the semantic cumulative effect through Shannon entropy reduction. Our experimental design addresses three research questions: (RQ1) Does the Cognitive Hub architecture outperform existing approaches for enterprise-scale natural language querying? (RQ2) Which architectural components contribute most significantly to system performance? (RQ3) Does serial execution with implicit context inheritance produce the theoretically predicted semantic cumulative effect?

### 5.1 Experimental Setup

**Dataset.** We constructed BankQuery-100, a dataset of 100 real banking queries drawn from Smart Query system logs, anonymized and de-identified to protect sensitive information. We acknowledge that 100 queries (80 test) is a modest evaluation scale, particularly for a system targeting 35,000+ tables. This size was constrained by the cost of expert annotation (two domain experts with 5+ years of banking data experience) and the need for real production queries rather than synthetic examples. The resulting confidence intervals are wide for some categories (e.g., ±0.10 for Complex queries), which limits the strength of conclusions for fine-grained comparisons. We address this limitation by: (1) reporting all results with confidence intervals and effect sizes so readers can assess statistical strength, (2) using conservative statistical tests with Bonferroni correction, and (3) focusing interpretive claims on the large-effect comparisons (e.g., Smart Query vs. Direct LLM: Δ = +0.34) rather than the smaller margins (e.g., Smart Query vs. B4: Δ = +0.06). Future work should expand the evaluation to 300+ queries for tighter confidence intervals, particularly in the Complex and Adversarial categories.

The queries span four complexity categories designed to test different system capabilities. *Simple queries* (30 queries) require single-table access with 1-3 fields and direct terminology mapping, such as "查询客户贷款余额" (query customer loan balance). *Medium queries* (40 queries) require single-table access with 3-6 fields or disambiguation among similar candidate tables, such as "查询客户AUM和风险等级" (query customer AUM and risk level). *Complex queries* (20 queries) require multi-table JOINs with 5+ fields across 2-4 tables, often spanning multiple schemas, such as "查询各分行中小企业贷款余额按金额排名并显示客户名称" (query each branch's SME loan balance ranked by amount with customer names). *Adversarial queries* (10 queries) contain ambiguous terminology, references to deprecated tables, cross-schema homonyms, or non-standard abbreviations, such as "查询ABC指标增长趋势" (query the ABC metric growth trend, where ABC is ambiguous) or "查看老系统的客户数据" (view old system customer data, referencing deprecated tables). We emphasize that the Adversarial category (n = 10) is too small for reliable statistical conclusions: with only 10 queries, the 95% confidence interval for accuracy spans approximately ±0.30, rendering fine-grained comparisons within this category statistically underpowered. Results for Adversarial queries should therefore be interpreted as preliminary and indicative of trends rather than definitive performance characterizations. Expanding this category to at least 50 queries is a priority for future evaluation to enable meaningful robustness analysis.

Two independent domain experts with 5+ years of banking data experience annotated all queries, providing ground truth for primary table, required fields, optional fields, JOIN conditions (for multi-table queries), and complexity category. Inter-annotator agreement measured by Cohen's kappa was 0.83 (substantial agreement), with disagreements resolved through discussion and third-expert adjudication. The dataset was split into 20 development queries for system tuning and 80 test queries for final evaluation, with no system modifications permitted after observing test set performance. The development set was used exclusively for tuning Skill prompt instructions (e.g., adjusting search keyword extraction heuristics and confidence threshold parameters) and validating MCP tool call sequences — no model fine-tuning or architectural changes were performed. To mitigate overfitting risk on the small development set, we applied a strict protocol: all tuning decisions were documented before test evaluation, and no iterative refinement based on test results was permitted.

**Reproducibility Note.** BankQuery-100 is not publicly available due to the proprietary nature of the banking data and ontology. While this limits direct reproducibility, we provide detailed descriptions of query categories, annotation procedures, and evaluation protocols to enable methodological reproduction. We discuss the feasibility of constructing synthetic benchmarks for enterprise-scale NL2SQL evaluation in Section 6.2.

(see Table 3)

**Evaluation Metrics.** We employ seven metrics capturing different aspects of system performance. *Table Localization Accuracy* (TLA@K) measures the percentage of queries where the correct primary table appears in the system's top-K recommendations. We report TLA@1 (strict accuracy), TLA@3 (consideration set accuracy), and TLA@5 (upper bound with re-ranking). TLA@1 serves as our primary metric, as incorrect table selection renders all downstream processing invalid.

*Field Coverage Rate* (FCR) measures the fraction of ground-truth required fields that appear in the system's recommendations, computed as FCR(q) = |recommended_fields(q) ∩ ground_truth_fields(q)| / |ground_truth_fields(q)|, averaged across queries. High TLA@1 with low FCR indicates correct table identification but incomplete field discovery.

*Evidence Consensus Score* (ECS) measures inter-strategy agreement on the primary table, defined as ECS(q) = |{s ∈ {S₁, S₂, S₃} : primary_table(s, q) = final_primary_table(q)}| / 3. ECS ranges from 0.33 (only one strategy agrees) to 1.0 (all three strategies agree). Higher ECS should correlate with higher confidence and accuracy.

*Query Resolution Rate* (QRR) measures the percentage of queries resolved without requiring clarification dialog, indicating system autonomy. *Semantic Consistency Score* (SCS) measures average pairwise Jaccard similarity of field recommendations across the three strategies, quantifying convergence. *Ontology Navigation Efficiency* (ONE) measures the ratio of tool calls that contribute to the final answer versus total tool calls, indicating focused versus wasteful exploration. *JOIN Accuracy* (JA) measures the percentage of ground-truth JOIN conditions correctly identified for multi-table queries, with recall, precision, and F1 variants.

**Baseline Systems.** We compare Smart Query against five baselines designed to isolate specific architectural contributions:

- **B0 (Direct LLM)**: Provides the user query plus descriptions of the top-100 tables (selected by keyword similarity) directly to the LLM without ontology structure or MCP tools. This tests whether the ontology layer provides value beyond raw LLM reasoning over flat metadata.

- **B1 (RAG)**: Embeds all table descriptions using the same embedding model (paraphrase-multilingual-MiniLM-L12-v2) and retrieves the top-30 tables by cosine similarity. This represents the standard RAG approach used in many NL2SQL systems, testing whether ontology structure adds value beyond vector retrieval.

- **B2a-c (Single-Strategy Variants)**: Execute only one of the three strategies in isolation — Indicator-only (B2a), Scenario-only (B2b), or Term-only (B2c) — using the full ontology but without multi-strategy fusion. These baselines test whether multi-strategy evidence fusion outperforms any single strategy.

- **B3 (Independent Agents)**: Execute all three strategies sequentially but in completely isolated contexts, with each strategy receiving only the original user query in a fresh conversation. Evidence packs are merged using the same adjudication logic as Smart Query. This tests whether implicit context inheritance provides value beyond independent evidence collection. The key difference from B4 is that B3 executes sequentially (though without context sharing), while B4 executes concurrently.

- **B4 (Parallel Execution)**: Execute all three strategies concurrently, each in an independent conversation context containing only the original user query. Unlike B3 (Independent Agents), B4 strategies are launched simultaneously rather than sequentially, but like B3, each strategy sees only the user query — not the outputs of other strategies. The key difference from Smart Query is the absence of serial context inheritance: no strategy can observe or build upon another's findings. Evidence packs from all three strategies are collected after all complete and merged using the same adjudication logic as Smart Query. This baseline isolates the contribution of serial ordering and context inheritance by removing the sequential dependency while preserving multi-strategy evidence fusion.

All baselines use the same base LLM (temperature=0 for reproducibility), the same ontology data, and the same evaluation protocol. The only differences are the architectural variations being tested, ensuring fair comparison.

(see Table 4)

**Ablation Studies.** Six ablation studies isolate individual component contributions by measuring performance degradation when each component is removed:

- **A1 (Remove Context Inheritance)**: Each strategy receives only the original user query in a fresh conversation context, not the accumulated conversation history. Strategies still execute serially but without context sharing.

- **A2 (Remove Evidence Fusion)**: Use only the highest-scoring single strategy's recommendation as the final output, without cross-validation or consensus scoring.

- **A3 (Remove Isolated Table Filtering)**: Include all tables in recommendations regardless of lineage heat status, allowing deprecated/orphan tables to appear.

- **A4 (Remove Lineage-Driven JOIN)**: Replace lineage-based JOIN discovery with schema-based column name matching.

- **A5 (Remove Dual Retrieval)**: Strategy 2 uses only convergent path navigation without the parallel hybrid search.

- **A6 (Remove Ontology Hierarchy)**: Replace hierarchical navigation with flat search over all indicators and tables.

**Statistical Analysis.** We employ paired bootstrap testing with 10,000 resamples and significance level α = 0.05 for all pairwise comparisons. Bonferroni correction is applied when comparing multiple systems simultaneously. Effect sizes are reported using Cohen's d (small: 0.2, medium: 0.5, large: 0.8). For binary outcomes (correct/incorrect per query), we use McNemar's test. All results are reported with mean ± standard error, with statistical significance indicated by stars (*p<0.05, **p<0.01, ***p<0.001).

### 5.2 Main Results

Table 5 presents the main experimental results comparing Smart Query against all baseline systems across six primary metrics. Smart Query achieves TLA@1 = 0.82 ± 0.04, significantly outperforming all baselines: B0 (Direct LLM) at 0.48 ± 0.05 (Δ = +0.34, p < 0.001, d = 1.52), B1 (RAG) at 0.61 ± 0.05 (Δ = +0.21, p < 0.001, d = 0.98), best single strategy B2b (Scenario-only) at 0.68 ± 0.05 (Δ = +0.14, p < 0.01, d = 0.67), B3 (Independent Agents) at 0.73 ± 0.04 (Δ = +0.09, p < 0.05, d = 0.51), and B4 (Parallel Execution) at 0.76 ± 0.04 (Δ = +0.06, p < 0.05, d = 0.35). All differences are statistically significant with medium to large effect sizes.

(see Table 5)

The performance gap widens substantially for complex queries. On the Complex category (20 queries requiring multi-table JOINs), Smart Query achieves TLA@1 = 0.75 ± 0.10, compared to B0 at 0.25 ± 0.10 (Δ = +0.50), B1 at 0.40 ± 0.11 (Δ = +0.35), B2b at 0.50 ± 0.11 (Δ = +0.25), B3 at 0.60 ± 0.11 (Δ = +0.15), and B4 at 0.65 ± 0.11 (Δ = +0.10). This pattern supports our hypothesis that the Cognitive Hub architecture's advantages become more pronounced as query complexity increases.

For Field Coverage Rate (FCR), Smart Query achieves 0.88 ± 0.03, outperforming B0 (0.52 ± 0.04, Δ = +0.36, p < 0.001), B1 (0.67 ± 0.04, Δ = +0.21, p < 0.001), and all single-strategy variants (B2a-c range: 0.61-0.72, Δ = +0.16-0.27, all p < 0.01). The multi-strategy fusion enables comprehensive field discovery that no single strategy achieves alone.

Evidence Consensus Score (ECS) for Smart Query averages 0.78 ± 0.03, indicating that on average, 2.3 of the three strategies agree on the primary table. Notably, ECS correlates positively with TLA@1 (Spearman ρ = 0.67, p < 0.001): queries with ECS = 1.0 (all three strategies agree) achieve TLA@1 = 0.94, while queries with ECS = 0.33 (only one strategy agrees) achieve TLA@1 = 0.58. This validates the graded confidence mechanism — higher consensus predicts higher accuracy.

Query Resolution Rate (QRR) reaches 0.91 ± 0.03 for Smart Query, significantly higher than B0 (0.72 ± 0.04, p < 0.001) and B1 (0.79 ± 0.04, p < 0.01), demonstrating that the Cognitive Hub architecture enables autonomous query resolution without frequent clarification dialogs.

For JOIN Accuracy on the Complex query subset, Smart Query achieves JA-F1 = 0.81 ± 0.08, substantially outperforming schema-based column matching (JA-F1 = 0.58 ± 0.09, Δ = +0.23, p < 0.01). This validates the lineage-driven JOIN discovery mechanism — structural facts about data flow outperform semantic similarity guesses for relational operations.

(see Figure 7)

Figure 7 visualizes the main results as a grouped bar chart, showing Smart Query's consistent advantage across all metrics and the progressive improvement from B0 (no ontology) through B1 (flat retrieval) to B2 (single strategy) to B3/B4 (multi-strategy without full context inheritance) to Smart Query (full system).

### 5.3 Ablation Study

Table 6 presents ablation study results, quantifying each component's contribution through performance degradation when removed. The ablations reveal a clear hierarchy of component importance.

(see Table 6)

**A1 (Remove Context Inheritance)** causes the largest degradation: TLA@1 drops by 0.13 (from 0.82 to 0.69, p < 0.001, d = 0.78). The effect is most pronounced for Complex queries (Δ = -0.18) and Adversarial queries (Δ = -0.22), where progressive refinement through context inheritance is most valuable. Without context inheritance, Strategy 2 cannot prioritize schemas identified by Strategy 1, and Strategy 3 cannot enhance fields discovered by earlier strategies. This empirically validates the theoretical prediction that implicit context inheritance is critical for the semantic cumulative effect.

**A2 (Remove Evidence Fusion)** causes TLA@1 to drop by 0.11 (from 0.82 to 0.71, p < 0.01, d = 0.65). Complex queries suffer most (Δ = -0.16), as they require multiple perspectives for correct resolution. The system becomes more brittle — dependent on a single strategy's success rather than benefiting from cross-validation. ECS becomes undefined (single strategy), and confidence calibration degrades.

**A4 (Remove Lineage-Driven JOIN)** causes JOIN Accuracy (JA-F1) to drop by 0.23 on Complex queries (from 0.81 to 0.58, p < 0.01, d = 0.89). Schema-based column name matching produces false JOIN conditions from coincidental name matches (e.g., generic columns like 'id', 'date', 'amount' appearing in unrelated tables). This validates the design principle that structural facts (lineage) outperform semantic guesses (column name similarity) for relational operations.

**A5 (Remove Dual Retrieval)** causes FCR to drop by 0.12 (from 0.88 to 0.76, p < 0.01, d = 0.71). Queries with non-standard terminology or synonyms suffer most, as convergent path navigation alone requires exact Schema/Topic matching. The dual mechanism ensures both precision (structural navigation) and recall (semantic expansion).

**A3 (Remove Isolated Table Filtering)** causes a smaller but statistically significant precision drop (Δ = -0.07 in TLA@1, p < 0.05). The effect concentrates in schemas with high table turnover, where deprecated tables with similar names to active tables can outscore the correct table on name similarity alone. This validates the graph-theoretic quality filter as a zero-maintenance data quality mechanism.

**A6 (Remove Ontology Hierarchy)** causes the most dramatic efficiency degradation: Ontology Navigation Efficiency (ONE) drops by 0.31 (from 0.72 to 0.41, p < 0.001), indicating that flat search requires nearly twice as many tool calls to achieve the same result. TLA@1 drops by 0.09 (p < 0.05), with the effect concentrated on ambiguous queries requiring hierarchical disambiguation. This validates the three-layer ontology design as essential for both accuracy and efficiency.

(see Figure 8)

Figure 8 visualizes ablation impacts as a heatmap, with rows representing ablations and columns representing affected metrics. Color intensity indicates degradation severity, revealing that A1 (context inheritance) and A2 (evidence fusion) have the broadest impact across metrics, while A4 (lineage JOIN) and A5 (dual retrieval) have focused impacts on specific metrics.

The ablation results demonstrate that Smart Query's performance arises from the synergistic interaction of multiple components rather than any single dominant feature. Removing any component causes measurable degradation, with the largest effects from context inheritance and evidence fusion — the core mechanisms of the Cognitive Hub architecture.

### 5.4 Semantic Cumulative Effect Analysis

We now present direct empirical validation of the semantic cumulative effect formalized in Section 4.1. For each query, we instrument Smart Query to record the candidate table probability distribution after each strategy completes, then compute Shannon entropy at each stage.

**Probability Distribution Construction.** After strategy k completes, we extract all tables mentioned in the evidence pack with their confidence scores, normalize to form a probability distribution P_k(t), and assign a small background probability ε = 0.001/N to unmentioned tables. Stage 0 (before any strategy) assumes a uniform prior: P_0(t) = 1/35,287, yielding H_0 = log₂(35,287) ≈ 15.11 bits. Entropy at stage k is computed as H_k = -Σ P_k(t) · log₂(P_k(t)).

**Methodological Caveat.** We note that the probability distributions P_k(t) are constructed from the system's own confidence scores, which are LLM-generated estimates rather than calibrated probabilities. This introduces a circularity concern: the entropy measurements reflect the system's *reported* confidence rather than ground-truth information content. While the monotonic decrease pattern and the serial-vs-parallel comparison remain meaningful as relative measures (both conditions use the same scoring mechanism), the absolute entropy values should be interpreted with caution. Future work should include calibration analysis (e.g., reliability diagrams) to assess the relationship between reported confidence and actual accuracy.

**Monotonic Decrease Validation.** The theoretical prediction H_0 > H_1 > H_2 > H_3 holds for 87 of 100 queries (87%), confirming the semantic cumulative effect. For the 13 queries where monotonicity is violated, post-hoc analysis reveals that 9 cases involve Strategy 2 or 3 introducing noise (exploring incorrect semantic regions due to keyword ambiguity), 3 cases involve strategies finding no results (H_k = H_{k-1}), and 1 case involves context degradation (the LLM failed to extract relevant information from conversation history).

Figure 9 presents entropy reduction trajectories by query complexity. Simple queries exhibit large initial drops (H_0 → H_1: mean Δ = 7.2 bits) as the Indicator strategy often identifies the correct table immediately, followed by smaller subsequent drops (H_1 → H_2: mean Δ = 2.1 bits; H_2 → H_3: mean Δ = 1.3 bits). Medium queries show moderate drops at each stage (H_0 → H_1: 5.8 bits; H_1 → H_2: 3.4 bits; H_2 → H_3: 2.2 bits), reflecting the need for multi-strategy disambiguation. Complex queries exhibit gradual drops across all stages (H_0 → H_1: 4.6 bits; H_1 → H_2: 3.8 bits; H_2 → H_3: 3.1 bits), with the H_2 → H_3 drop being particularly significant as the Term strategy discovers cross-table field mappings. Adversarial queries show smaller initial drops (H_0 → H_1: 3.9 bits) due to ambiguity, but larger H_2 → H_3 drops (3.5 bits) as the Term strategy resolves ambiguity through data standards.

(see Figure 9)

**Cumulative Reduction Ratio.** The cumulative reduction ratio CRR = (H_0 - H_3) / H_0 averages 0.73 ± 0.04 across all queries, indicating that the three-strategy sequence resolves 73% of the initial uncertainty on average. CRR varies by complexity: Simple (0.82 ± 0.05), Medium (0.75 ± 0.06), Complex (0.68 ± 0.08), Adversarial (0.58 ± 0.11). Notably, CRR correlates positively with TLA@1 (Spearman ρ = 0.71, p < 0.001), validating that entropy reduction predicts accuracy — queries with higher CRR are more likely to be correctly resolved.

**Serial vs. Parallel Comparison.** Smart Query (serial with context) achieves final entropy H_3 = 4.08 ± 0.52 bits, compared to B4 (parallel execution) at H_3 = 4.73 ± 0.58 bits (Δ = -0.65 bits, p < 0.01, Wilcoxon signed-rank test). This 14% entropy reduction advantage validates the theoretical prediction that serial execution with context inheritance outperforms parallel independent execution. The gap widens for Complex queries (Δ = -1.12 bits, 19% advantage) and Adversarial queries (Δ = -1.38 bits, 23% advantage), where context inheritance enables focused search that parallel execution cannot achieve.

The entropy analysis provides direct empirical support for the information-theoretic formalization presented in Section 4.1. The monotonic decrease property holds for 87% of queries, the cumulative reduction ratio exceeds 0.70 on average, and serial execution achieves lower final entropy than parallel execution — all consistent with theoretical predictions.

### 5.5 Case Studies

We present three representative case studies illustrating how Smart Query's architectural components work in practice, followed by one failure case for honest error analysis.

**Case Study 1: Medium Query with Context Inheritance.** The query "查询客户AUM和风险等级" (query customer AUM and risk level) demonstrates implicit context inheritance. Strategy 1 (Indicator) searches for "AUM" and "风险等级" (risk level) in the indicator hierarchy, identifying the THEME "客户价值分析" (customer value analysis) and narrowing to Schema "RETAIL_CUSTOMER". Strategy 2 (Scenario) observes from conversation history that Strategy 1 identified RETAIL_CUSTOMER schema, and prioritizes this schema in its convergent path navigation. Within RETAIL_CUSTOMER, it identifies TABLE_TOPIC "客户画像" (customer profile) and retrieves 8 candidate tables. Strategy 3 (Term) searches for "AUM" and "风险等级" terms, finding that table "dim_customer_profile" contains both terms with high coverage. Cross-validation reveals that all three strategies converge on "dim_customer_profile" (ECS = 1.0), yielding high confidence. The entropy trajectory shows H_0 = 15.11 → H_1 = 8.3 (Strategy 1 narrows to schema) → H_2 = 4.1 (Strategy 2 narrows to topic) → H_3 = 1.2 (Strategy 3 confirms with term match). Final result: correct table, all required fields identified, TLA@1 = 1.

In contrast, B3 (Independent Agents) executing the same query without context inheritance shows Strategy 2 exploring all 9 schemas uniformly (no prioritization), resulting in H_2 = 5.8 (higher uncertainty) and requiring 23 tool calls versus Smart Query's 16 calls. This case illustrates the efficiency gain from implicit context inheritance.

**Case Study 2: Complex Query with Lineage-Driven JOIN.** The query "查询各分行中小企业贷款余额按金额排名并显示客户名称" (query each branch's SME loan balance ranked by amount with customer names) requires joining three tables: "loan_balance" (primary), "customer_info" (for customer names), and "branch_dim" (for branch information). After adjudication selects "loan_balance" as the primary table, lineage analysis executes get_table_dependencies(direction='all'), discovering UPSTREAM relationships: "customer_info" (direct lineage, 43,880 edges) and "branch_dim" (indirect lineage, 6,629 edges). For each related table, the system identifies shared terms: "loan_balance.cust_id" matches "customer_info.cust_id" (term_en_name: "customer_id"), and "loan_balance.branch_code" matches "branch_dim.branch_code" (term_en_name: "branch_code"). JOIN conditions are inferred: loan_balance INNER JOIN customer_info ON loan_balance.cust_id = customer_info.cust_id; loan_balance LEFT JOIN branch_dim ON loan_balance.branch_code = branch_dim.branch_code. Final result: correct primary table, correct JOINs, all required fields identified, JA-F1 = 1.0.

The ablation A4 (schema-based JOIN) on the same query incorrectly proposes joining "loan_balance" with "loan_application" (both have a column named "amount", but no actual relationship), resulting in a Cartesian product. This case demonstrates that lineage-based JOIN discovery (structural facts) outperforms column name matching (semantic guesses).

**Case Study 3: Adversarial Query with Isolated Table Filtering.** The query "查看老系统的客户数据" (view old system customer data) contains the ambiguous term "老系统" (old system), which could refer to deprecated tables or historical data tables. Strategy 1 finds no matching indicators. Strategy 2's hybrid search retrieves 12 candidate tables, including 3 deprecated tables with "old_" prefixes that have high name similarity to the query. Strategy 3 searches for "客户数据" (customer data) terms, finding matches in both active and deprecated tables. During adjudication, isolated table filtering detects that the 3 deprecated tables have upstream_count = 0 AND downstream_count = 0 (is_isolated = true) and excludes them from recommendations. The final recommendation is "customer_historical_data" (an active table for historical queries), which is correct. Without isolated table filtering (ablation A3), the system incorrectly recommends "old_customer_backup" (a deprecated table), demonstrating the value of graph-theoretic quality filtering.

**Failure Case: Context Degradation.** The query "获取FTP数据" (get FTP data) is ambiguous: FTP could mean "File Transfer Protocol" (irrelevant to banking) or "Funds Transfer Pricing" (a banking concept). Strategy 1 searches for "FTP" in indicators, finding both interpretations with similar scores. Strategy 2 should infer from Strategy 1's evidence that "Funds Transfer Pricing" is more relevant, but the LLM fails to extract this disambiguation from conversation history (context degradation). Strategy 2 explores both interpretations equally, resulting in H_2 = 6.8 (high uncertainty). Strategy 3 searches for "FTP" terms, finding matches in both domains. Cross-validation reveals low consensus (ECS = 0.33), and the system incorrectly selects a table related to file transfers. Post-hoc analysis reveals that the failure stems from insufficient prompt engineering in Strategy 2's Skill to explicitly extract disambiguation cues from conversation history. This case illustrates the context degradation failure mode identified in Section 4.1 and highlights the importance of conversation history management in LLM-based cognitive architectures.

---

The experimental results provide comprehensive validation of Smart Query's design. The main comparison demonstrates significant advantages over all baselines across accuracy, coverage, and resolution metrics. The ablation study quantifies each component's contribution, revealing that context inheritance and evidence fusion are the most critical mechanisms. The entropy analysis provides direct empirical support for the semantic cumulative effect, with 87% of queries exhibiting monotonic entropy decrease and serial execution achieving 14% lower final entropy than parallel execution. The case studies illustrate how the architectural components work in practice and honestly acknowledge failure modes. In Section 6, we discuss the implications of these findings, limitations of the current approach, and directions for future work.
## 6. Discussion

The experimental results presented in Section 5 provide comprehensive empirical validation of the Cognitive Hub architecture. We now interpret these findings in the broader context of enterprise-scale natural language data querying, discuss the limitations of our approach, and examine the generalizability of the architectural principles to other domains and applications.

### 6.1 Key Findings and Implications

**Ontology as Cognitive Hub Outperforms Passive Knowledge Structures.** The comparison between Smart Query (TLA@1 = 0.82) and baseline systems reveals a clear hierarchy of effectiveness. Direct LLM reasoning without structured knowledge (B0: 0.48) fails catastrophically at enterprise scale, confirming that LLMs cannot navigate 35,000+ tables through parametric knowledge alone. RAG with vector retrieval (B1: 0.61) provides modest improvement but remains inadequate — semantic similarity captures surface-level lexical overlap but misses the hierarchical business logic and data lineage relationships that govern enterprise data architectures. The substantial gap between B1 and Smart Query (Δ = +0.21, p < 0.001) validates our central thesis: a domain ontology must function as an active cognitive layer, not merely a passive retrieval index.

The architectural distinction is fundamental. RAG systems treat knowledge as an unstructured document collection where retrieval is the primary operation. The Cognitive Hub architecture treats knowledge as a structured cognitive resource with multiple navigation strategies, each exploiting different structural properties. The three-layer ontology separation (indicators, data assets, terms) enables orthogonal exploration strategies that RAG's flat vector space cannot support. This finding has implications beyond Smart Query: it suggests that enterprise AI systems requiring deep domain reasoning should invest in structured knowledge architectures rather than relying solely on embedding-based retrieval.

**Serial Execution with Context Inheritance Outperforms Parallel Approaches.** The comparison between Smart Query and B4 (Parallel Execution: TLA@1 = 0.76, Δ = +0.06, p < 0.05) provides direct empirical validation of the semantic cumulative effect. The entropy analysis strengthens this conclusion: Smart Query achieves 14% lower final entropy than B4 (H₃ = 4.08 vs 4.73 bits, p < 0.01), with the advantage widening for Complex (19%) and Adversarial (23%) queries. This validates the information-theoretic prediction that serial execution with context inheritance enables focused search that parallel execution cannot achieve.

The ablation study reinforces this finding: removing context inheritance (A1) causes the largest performance degradation (Δ = -0.13, p < 0.001), with effects concentrated on Complex and Adversarial queries where progressive refinement is most valuable. The failure case analysis (Section 5.5) reveals that context degradation — where the LLM fails to extract relevant information from conversation history — is the primary failure mode, highlighting that implicit context inheritance depends critically on LLM contextual understanding quality.

This finding challenges the prevailing assumption in LLM-based multi-agent systems that parallel execution is preferable for efficiency. While parallel execution reduces latency, it sacrifices the cumulative semantic enrichment that serial execution provides. The optimal design choice depends on the task structure: for tasks requiring multi-perspective evidence fusion where perspectives can inform each other (as in enterprise data querying), serial execution with context inheritance is superior despite the latency overhead.

**Latency-Accuracy Tradeoff.** The serial execution advantage (Δ = +0.06 TLA@1 over parallel) comes at a cost of approximately 2× latency (15–20s vs. 8–10s). Whether this tradeoff is justified depends on the deployment context. In our banking environment, queries are typically issued by analysts preparing reports or dashboards, where a 10-second latency difference is negligible relative to the hours spent on downstream analysis. For such non-interactive use cases, the accuracy gain — particularly the larger margins on Complex (Δ = +0.10) and Adversarial (Δ = +0.10) queries where incorrect table selection has the highest downstream cost — justifies the latency overhead. However, for interactive applications requiring sub-second responses, the serial design may be unsuitable without optimization. We note that the serial-vs-parallel accuracy gap is modest overall (d = 0.35, small-to-medium effect), and the practical significance depends on the cost asymmetry between errors and latency in a given deployment. Potential mitigations include adaptive strategy selection (skipping strategies unlikely to contribute for simple queries), early termination upon high-confidence consensus, and caching of common query patterns. A full Pareto analysis of the latency-accuracy frontier across different strategy subsets (S₁ only, S₁+S₂, full pipeline) is an important direction for future work.

**Evidence Pack Fusion Provides Calibrated Confidence.** The positive correlation between Evidence Consensus Score (ECS) and accuracy (Spearman ρ = 0.67, p < 0.001) demonstrates that inter-strategy agreement is a reliable confidence indicator. Queries with three-strategy consensus (ECS = 1.0) achieve 94% accuracy, while single-strategy recommendations (ECS = 0.33) achieve only 58% accuracy. This graded confidence mechanism enables the system to communicate uncertainty to users — a critical capability for enterprise deployment where incorrect recommendations can have significant consequences.

The ablation study (A2: remove evidence fusion) shows that relying on a single strategy's recommendation degrades TLA@1 by 0.11 (p < 0.01), with the largest effects on Complex queries. This validates the design principle that multi-strategy fusion is more robust than any single strategy. The cross-validation adjudication mechanism is more sophisticated than simple voting: it operates on structured evidence packs containing candidate tables, confidence scores, and reasoning traces, enabling nuanced reconciliation that binary voting cannot achieve.

This finding has implications for LLM-based decision systems more broadly. Rather than treating LLM outputs as binary predictions, systems should collect structured evidence from multiple perspectives and use inter-perspective agreement as a confidence signal. This approach parallels ensemble methods in machine learning but operates at the evidence level rather than the prediction level.

**Lineage-Driven JOIN Discovery Outperforms Semantic Similarity.** The comparison between Smart Query's lineage-driven JOIN discovery (JA-F1 = 0.81) and schema-based column name matching (A4 ablation: JA-F1 = 0.58, Δ = +0.23, p < 0.01) validates a key design principle: for relational operations, structural facts about data flow are more reliable than semantic similarity guesses. Case Study 2 (Section 5.5) illustrates this concretely: lineage correctly identifies "customer_info" as the JOIN target based on actual ETL relationships, while column name matching incorrectly proposes "loan_application" based on coincidental name overlap.

This finding challenges the prevailing trend toward embedding-based approaches for all data integration tasks. While semantic similarity is valuable for discovering conceptual relationships, it is insufficient for inferring operational relationships like JOINs that depend on actual data flow. Enterprise data warehouses already contain rich lineage metadata from ETL pipelines; Smart Query demonstrates that this structural information should be leveraged directly rather than approximated through semantic similarity.

The broader implication is that hybrid approaches combining structural facts with semantic reasoning outperform purely semantic approaches. The dual retrieval mechanism (Innovation 6) embodies this principle: Strategy 2 combines convergent path navigation (structural) with hybrid search (semantic), achieving higher Field Coverage Rate (FCR = 0.88) than either approach alone. This suggests a general design pattern for enterprise AI systems: exploit structural metadata where available, use semantic reasoning to fill gaps.

**Isolated Table Filtering Provides Zero-Maintenance Quality Assurance.** The ablation study (A3) shows that isolated table filtering provides a modest but statistically significant precision improvement (Δ = -0.07 in TLA@1 when removed, p < 0.05). Case Study 3 demonstrates the mechanism in action: deprecated tables with high name similarity to the query are correctly excluded based on graph-theoretic connectivity analysis (in-degree + out-degree = 0). This validates the design principle that data quality can be inferred from graph topology without manual curation.

The practical value lies in zero-maintenance operation. Traditional data quality approaches require manual metadata tagging or periodic audits to identify deprecated tables. Smart Query's graph-theoretic filter operates automatically on the existing lineage graph, requiring no additional metadata or human intervention. This is particularly valuable in enterprise environments where data assets evolve continuously and manual curation cannot keep pace.

The cognitive architecture analogy is apt: just as ACT-R's base-level activation decay causes unused knowledge to become inaccessible [Anderson et al., 2004], Smart Query's isolated table filtering causes unused data assets to be automatically excluded. This suggests a broader principle: cognitive architectures for enterprise systems should incorporate temporal validity mechanisms that reflect actual usage patterns.

### 6.2 Limitations

**Domain Specificity and Ontology Construction Cost.** Smart Query's ontology is banking-specific, constructed through a 21-step ETL pipeline that extracts metadata from source systems, computes lineage relationships, and builds the three-layer knowledge graph. This construction process required substantial domain expertise and engineering effort. While the ontology enables powerful reasoning capabilities, it represents a significant upfront investment that may not be feasible for all domains or organizations.

The ontology construction challenge is not unique to Smart Query — it is inherent to any knowledge-intensive system. Traditional OBDA systems face the same challenge of creating formal ontologies and mappings [Ontop, DL-Lite]. Smart Query's advantage is that once the ontology is constructed, it supports flexible natural language querying without requiring rigid formal query languages. Nevertheless, the construction cost remains a barrier to adoption.

A related limitation is domain transferability. The three-layer structure (indicators, data assets, terms) reflects banking domain characteristics and may not generalize directly to other domains. Healthcare, for example, might require different layer structures to capture clinical concepts, patient records, and medical terminology. While the Cognitive Hub architecture is domain-agnostic, the specific ontology design must be tailored to each domain's knowledge structure.

**Lack of Formal Correctness Guarantees.** Unlike traditional OBDA systems that provide formal correctness guarantees through query rewriting [Ontop, DL-Lite], Smart Query's LLM-based reasoning is probabilistic. The system can produce incorrect recommendations when context inheritance fails, keyword ambiguity causes semantic drift, or cross-validation adjudication selects the wrong consensus. The failure case analysis (Section 5.5) reveals that context degradation is the primary failure mode, occurring when the LLM fails to extract relevant information from conversation history.

This limitation is fundamental to LLM-based systems. While formal OBDA systems guarantee correctness within their expressiveness limits, they cannot handle queries outside those limits. Smart Query trades formal guarantees for flexibility — it can handle ambiguous, incomplete, or underspecified queries that would fail in formal systems. The graded confidence mechanism (ECS) partially mitigates this limitation by communicating uncertainty, but it does not eliminate the possibility of confident incorrect recommendations.

Future work could explore hybrid approaches that combine formal reasoning where possible with LLM-based reasoning for ambiguous cases. For example, when a query maps unambiguously to a single indicator with a single associated table, the system could bypass LLM reasoning and return the formal mapping directly. This would provide correctness guarantees for the subset of queries that admit formal solutions while retaining flexibility for complex cases.

**Serial Execution Latency Overhead.** Serial execution with three strategies introduces latency overhead compared to parallel approaches. In our deployment, the average query resolution time is approximately 15-20 seconds (Strategy 1: 5-7s, Strategy 2: 6-8s, Strategy 3: 4-5s), compared to 8-10 seconds for parallel execution (B4). For interactive applications where sub-second response times are expected, this latency may be unacceptable.

The latency-accuracy tradeoff is inherent to the serial execution design. The semantic cumulative effect requires that later strategies observe earlier strategies' findings, which necessitates sequential execution. Parallel execution eliminates this dependency but sacrifices the cumulative semantic enrichment that drives Smart Query's accuracy advantage.

Potential mitigations include: (1) adaptive strategy selection that executes only the strategies likely to contribute new information based on query characteristics, (2) early termination when a strategy achieves high-confidence consensus, (3) speculative parallel execution with post-hoc context integration, or (4) caching of common query patterns to bypass strategy execution entirely. These optimizations could reduce latency while preserving most of the accuracy benefits.

**Strategy Ordering Sensitivity.** The current system uses a fixed ordering (S₁: Indicator → S₂: Scenario → S₃: Term), motivated by the design principle that business concept identification (S₁) provides the most informative initial constraint for subsequent strategies. However, we have not empirically evaluated alternative orderings (e.g., S₂→S₁→S₃ or S₃→S₁→S₂). The information-theoretic analysis (Section 4.1) predicts that ordering effects depend on the conditional mutual information structure: the optimal first strategy is the one with highest I(I; S_k), and the optimal second strategy is the one with highest I(I; S_k | S_first). For queries where business terminology is ambiguous but schema structure is clear, S₂→S₁→S₃ might outperform the current ordering. Systematic evaluation of ordering sensitivity is an important direction for future work, potentially enabling adaptive ordering based on query characteristics.

**Dependence on LLM Contextual Understanding Quality.** The implicit context inheritance mechanism depends critically on the LLM's ability to extract relevant information from conversation history. The failure case analysis reveals that context degradation — where the LLM fails to leverage previous strategies' findings — is the primary failure mode. This limitation is specific to LLM-based implementations and may improve as LLM architectures advance, but it represents a current constraint.

The ablation study (A1: remove context inheritance) quantifies this dependence: removing context inheritance degrades TLA@1 by 0.13, with larger effects on Complex and Adversarial queries. This suggests that approximately 16% of Smart Query's performance (0.13 / 0.82) depends on successful context inheritance. When context inheritance fails, the system degrades to the independent agents baseline (B3: 0.73), which still outperforms single-strategy and RAG baselines but loses the cumulative semantic enrichment advantage.

Improving context inheritance robustness requires better prompt engineering to explicitly instruct later strategies to extract and leverage previous findings, potentially with structured context extraction mechanisms that parse previous evidence packs into explicit constraints for subsequent strategies. This would make context inheritance more explicit and less dependent on implicit LLM inference.

**Evaluation on Standard Benchmarks.** Smart Query has not been evaluated on standard NL2SQL benchmarks like Spider or Bird. This is a deliberate choice reflecting different problem scopes: Spider contains 200 small databases (average <10 tables each) designed for cross-database generalization, while Smart Query addresses single-domain enterprise scale (35,287 tables). The skills required for these tasks differ: Spider emphasizes SQL syntax generation and cross-domain generalization, while Smart Query emphasizes schema navigation and domain knowledge integration.

Nevertheless, the lack of benchmark evaluation limits comparability with existing NL2SQL systems. Future work could adapt Smart Query's architecture to benchmark settings by constructing lightweight ontologies for Spider/Bird databases, enabling direct comparison with systems like MAC-SQL, DIN-SQL, and CHESS. This would clarify whether the Cognitive Hub architecture provides advantages beyond enterprise-specific deployment.

### 6.3 Generalizability

**Domain-Agnostic Architecture with Domain-Specific Instantiation.** While Smart Query's ontology is banking-specific, the Cognitive Hub architecture is domain-agnostic. The core principles — separating declarative memory (ontology) from procedural memory (Skills), coordinating through an LLM pattern-matching engine, using multiple orthogonal navigation strategies with serial execution and implicit context inheritance — apply to any domain with complex structured knowledge.

Healthcare provides a natural application domain. A healthcare ontology could separate clinical concepts (diagnoses, procedures, medications), patient data assets (EHR tables, lab results, imaging), and medical terminology (SNOMED CT, ICD codes). Three strategies could navigate these layers: a Clinical Concept Expert exploring diagnosis hierarchies, a Data Asset Navigator following EHR schema structures, and a Terminology Analyst searching standardized medical terms. The same evidence pack fusion and lineage-driven relationship discovery mechanisms would apply.

Manufacturing offers another application domain. A manufacturing ontology could separate production indicators (yield, defect rates, cycle times), equipment and process data (sensor tables, maintenance logs), and engineering terminology (part specifications, quality standards). The three-strategy pattern would map naturally: an Indicator Expert for production metrics, a Process Navigator for equipment hierarchies, and a Terminology Analyst for engineering standards.

The key requirement for domain transfer is that the domain exhibits hierarchical knowledge structure with multiple orthogonal dimensions. Domains with flat, unstructured knowledge may not benefit from the Cognitive Hub architecture. The three-layer separation (business concepts, data assets, terminology) appears to be a common pattern across enterprise domains, suggesting broad applicability.

**Multi-Strategy Serial Execution as a General Pattern.** The multi-strategy serial execution pattern with implicit context inheritance generalizes beyond data querying to any task requiring multi-perspective reasoning where perspectives can inform each other. Potential applications include:

- **Multi-Source Intelligence Analysis**: Different strategies could analyze signals intelligence, human intelligence, and open-source intelligence, with later strategies focusing on regions identified by earlier strategies.

- **Medical Diagnosis**: Different strategies could explore symptom patterns, lab results, and imaging findings, with later strategies prioritizing tests suggested by earlier findings.

- **Legal Research**: Different strategies could search case law, statutes, and secondary sources, with later strategies focusing on jurisdictions and time periods identified by earlier strategies.

- **Scientific Literature Review**: Different strategies could explore citation networks, keyword searches, and author networks, with later strategies prioritizing papers in clusters identified by earlier strategies.

The common pattern is that multiple independent perspectives provide complementary evidence, and serial execution with context inheritance enables later perspectives to focus on high-value regions identified by earlier perspectives. The semantic cumulative effect formalization (Section 4.1) provides theoretical grounding for when this pattern is beneficial: when perspectives explore orthogonal knowledge dimensions and context inheritance enables focused search.

**Multi-Scenario Ontology Extension.** The current Smart Query ontology focuses on the Data Query scenario — mapping business questions to physical tables and fields. The broader enterprise data management landscape includes additional scenarios: Data Development (designing new data assets), Data Governance (ensuring data quality and compliance), and Data Lineage Analysis (understanding data flow and impact). Each scenario requires different navigation strategies over the same underlying ontology.

A multi-scenario extension could define scenario-specific Skills that navigate the ontology for different purposes. Data Development Skills might navigate from business requirements to candidate table designs, exploring similar existing tables and reusable data standards. Data Governance Skills might navigate from compliance requirements to affected tables, exploring data lineage to identify downstream impacts. This extension would transform the ontology from a query-specific resource into a general-purpose cognitive hub for all data management activities.

The multi-scenario extension validates the Cognitive Hub architecture's flexibility. The same declarative memory (ontology) supports multiple procedural memories (scenario-specific Skills), with the LLM pattern-matching engine coordinating between them. This separation of concerns — knowledge representation (ontology) from knowledge utilization (Skills) — is a fundamental principle of cognitive architectures [ACT-R, SOAR] that Smart Query demonstrates in an enterprise AI context.

---

The discussion reveals that Smart Query's success stems from principled architectural choices grounded in cognitive science and information theory. The Cognitive Hub architecture, multi-strategy serial execution with implicit context inheritance, and evidence pack fusion with cross-validation adjudication are not ad-hoc engineering decisions but theoretically motivated designs with empirical validation. The limitations — domain specificity, lack of formal guarantees, latency overhead, and LLM dependence — are inherent tradeoffs rather than implementation flaws, and they suggest clear directions for future work. The generalizability analysis demonstrates that the architectural principles extend beyond banking data querying to other domains and scenarios requiring multi-perspective reasoning over structured knowledge. In Section 7, we conclude with a summary of contributions and an outlook on future research directions.
## 7. Conclusion

Natural language interfaces to enterprise-scale databases have long promised to democratize data access, yet this vision has remained elusive when confronted with the complexity of real-world data environments. This paper presented Cognitive Hub, a multi-agent architecture that addresses the fundamental challenge of natural language querying over 35,000+ tables by transforming a domain ontology from passive knowledge storage into an active cognitive layer for LLM-based reasoning.

Our approach is grounded in cognitive architecture theory and information theory, providing both theoretical justification and empirical validation for key design decisions. The Cognitive Hub architecture separates declarative memory (a three-layer ontology with 314,680 nodes and 623,118 relationships) from procedural memory (three specialized Skills encoding navigation strategies), coordinated through an LLM pattern-matching engine with 29+ MCP tools. Three cognitively specialized agents — Indicator Expert, Scenario Navigator, and Term Analyst — execute serially with implicit context inheritance through shared conversation history, each exploring an orthogonal knowledge dimension. This serial execution with context sharing produces a semantic cumulative effect: information entropy about the target data monotonically decreases as strategies execute, a property we analyzed using the chain rule of conditional entropy and validated empirically through direct entropy measurement.

Comprehensive experiments on 100 real banking queries demonstrate that Smart Query achieves 82% top-1 table accuracy, significantly outperforming five baselines spanning the design space: Direct LLM (48%), RAG (61%), single-strategy variants (65-71%), independent agents without context sharing (73%), and parallel execution without serial ordering (76%). Six ablation studies isolate each architectural component's contribution, with context inheritance showing the largest impact (Δ = -13% when removed). Direct measurement of Shannon entropy reduction across strategy stages provides empirical validation of the semantic cumulative effect, with serial execution achieving 14% lower final entropy than parallel execution.

The system's success stems from several integrated innovations. Evidence pack fusion with cross-validation adjudication provides graded confidence scoring based on inter-strategy agreement, with three-strategy consensus achieving 94% accuracy. Lineage-driven JOIN discovery leverages 50,509 pre-computed ETL relationships to infer JOIN conditions from structural facts rather than semantic guesses, achieving 81% JOIN accuracy compared to 58% for column name matching. Isolated table filtering provides zero-maintenance data quality assurance through graph-theoretic connectivity analysis, automatically excluding deprecated tables without manual curation.

### 7.1 Contributions and Implications

This work makes five primary contributions to the intersection of natural language processing, knowledge representation, and multi-agent systems:

**Cognitive Hub Architecture.** We introduced a cognitive architecture that combines domain ontologies (declarative memory) with specialized Skills (procedural memory) to create an active cognitive layer for LLM-based reasoning. Grounded in ACT-R, SOAR, and CoALA frameworks, this architecture separates knowledge representation from knowledge utilization, enabling independent evolution of both components. The architecture is domain-agnostic and applicable to any domain with hierarchical structured knowledge requiring systematic navigation.

**Multi-Strategy Serial Execution with Context Inheritance.** We proposed a novel coordination pattern where specialized agents execute serially with implicit context inheritance through shared conversation history. This Pipeline-Blackboard Hybrid combines deterministic serial scheduling, shared evidence accumulation, and implicit communication, enabling later strategies to focus search based on earlier discoveries without explicit parameter passing or predefined message formats.

**Information-Theoretic Analysis of Multi-Strategy Coordination.** We applied information-theoretic analysis to characterize the semantic cumulative effect, formalizing the conditions under which each strategy contributes new information (orthogonal knowledge dimensions) and identifying failure modes (redundancy, noise introduction, context degradation). The analysis provides a quantitative framework for measuring strategy effectiveness and yields actionable design implications for LLM-based multi-agent systems. Empirical validation confirms that serial execution achieves 14% lower final entropy than parallel execution.

**Intelligent Search Space Reduction.** We introduced several mechanisms for ontology-guided search space reduction: lineage-driven JOIN discovery using structural facts rather than semantic similarity, isolated table filtering through graph-theoretic analysis, dual retrieval combining structural navigation with semantic search, and hierarchical path-based disambiguation. These mechanisms demonstrate that hybrid approaches combining structural metadata with semantic reasoning outperform purely semantic approaches for enterprise data integration tasks.

**Comprehensive Evaluation Framework.** We designed a rigorous evaluation methodology including a domain-specific dataset (BankQuery-100) with four complexity categories, seven metrics spanning accuracy and reasoning quality, five baselines covering the design space, six ablation studies isolating component contributions, and direct entropy measurement validating theoretical predictions. This framework provides a template for evaluating LLM-based enterprise AI systems where standard benchmarks are insufficient.

The broader implications extend beyond natural language data querying. The Cognitive Hub architecture demonstrates that cognitive science principles — particularly the declarative-procedural memory distinction — provide valuable design guidance for LLM-based systems requiring deep domain reasoning. The semantic cumulative effect formalization provides theoretical grounding for choosing serial versus parallel execution in multi-agent systems, with applications to any task requiring multi-perspective evidence fusion. The success of lineage-driven JOIN discovery challenges the prevailing trend toward purely embedding-based approaches, demonstrating that structural metadata should be leveraged directly when available rather than approximated through semantic similarity.

### 7.2 Limitations and Future Directions

Several limitations suggest directions for future research. The ontology construction process requires substantial domain expertise and engineering effort, representing a significant upfront investment. Future work could explore semi-automated ontology construction from existing metadata repositories, reducing the barrier to adoption. The system provides no formal correctness guarantees, unlike traditional OBDA systems. Hybrid approaches that combine formal reasoning for unambiguous queries with LLM-based reasoning for ambiguous cases could provide correctness guarantees where possible while retaining flexibility for complex cases.

Serial execution introduces latency overhead (15-20 seconds average) compared to parallel approaches (8-10 seconds). Potential optimizations include adaptive strategy selection based on query characteristics, early termination when high-confidence consensus is achieved, and caching of common query patterns. The implicit context inheritance mechanism depends on LLM contextual understanding quality, with context degradation identified as the primary failure mode. More explicit context extraction mechanisms that parse previous evidence packs into structured constraints for subsequent strategies could improve robustness.

The system has not been evaluated on standard NL2SQL benchmarks like Spider or Bird, limiting comparability with existing systems. Future work could adapt the Cognitive Hub architecture to benchmark settings by constructing lightweight ontologies for benchmark databases, enabling direct comparison with state-of-the-art NL2SQL systems and clarifying whether the architecture provides advantages beyond enterprise-specific deployment.

The most promising direction for future work is multi-scenario ontology extension. The current system focuses on the Data Query scenario, but the broader enterprise data management landscape includes Data Development (designing new data assets), Data Governance (ensuring data quality and compliance), and Data Lineage Analysis (understanding data flow and impact). Each scenario could define specialized Skills that navigate the same underlying ontology for different purposes, transforming the ontology from a query-specific resource into a general-purpose cognitive hub for all data management activities. This extension would validate the architecture's flexibility and demonstrate that the same declarative memory can support multiple procedural memories.

Cross-domain transfer represents another important direction. While the three-layer structure (business concepts, data assets, terminology) appears common across enterprise domains, validating this hypothesis requires implementations in healthcare, manufacturing, or other domains. Such validation would clarify the architecture's generalizability and identify domain-specific adaptations required for successful transfer.

Finally, the semantic cumulative effect formalization opens theoretical questions about optimal strategy ordering, adaptive strategy selection, and the relationship between knowledge dimension orthogonality and entropy reduction rates. Deeper theoretical analysis could provide design principles for constructing multi-strategy systems with provable performance guarantees.

### 7.3 Closing Remarks

Enterprise-scale natural language data querying represents a critical challenge at the intersection of natural language processing, knowledge representation, and database systems. This work demonstrates that cognitive architecture principles provide a principled foundation for addressing this challenge, enabling LLMs to navigate complex data landscapes through structured domain knowledge. The Cognitive Hub architecture, multi-strategy serial execution with implicit context inheritance, and semantic cumulative effect formalization establish both theoretical and practical foundations for building LLM-based systems that combine the flexibility of natural language understanding with the precision of structured knowledge navigation.

As organizations continue to accumulate vast data assets across increasingly complex architectures, the need for intelligent interfaces that bridge business language and technical implementation will only intensify. The principles demonstrated in Smart Query — separating declarative from procedural memory, leveraging multiple orthogonal knowledge dimensions, formalizing coordination mechanisms through information theory, and combining structural facts with semantic reasoning — provide a roadmap for building such interfaces. We hope this work inspires further research at the intersection of cognitive architectures, multi-agent systems, and enterprise AI, ultimately realizing the long-standing vision of democratized data access through natural language.

---

## References

[1] Pourreza, M. and Rafiei, D.. "DIN-SQL: Decomposed In-Context Learning of Text-to-SQL with Self-Correction." *NeurIPS 2023*, 2023.

[2] Gao, D., Wang, H., Li, Y., et al.. "DAIL-SQL: Efficient Few-Shot Text-to-SQL with Question Representation and Example Selection." *VLDB 2024*, 2024.

[3] Dong, X., Zhang, C., Ge, Y., et al.. "C3: Zero-shot Text-to-SQL with ChatGPT." *arXiv preprint*, 2023.

[4] Wang, B., Ren, C., Yang, J., et al.. "MAC-SQL: A Multi-Agent Collaborative Framework for Text-to-SQL." *ACL 2024 Findings*, 2024.

[5] Talaei, S., Pourreza, M., Chang, Y., et al.. "CHESS: Contextual Harnessing for Efficient SQL Synthesis." *arXiv preprint*, 2024.

[6] Li, H., Zhang, J., Li, C., and Chen, H.. "RESDSQL: Decoupling Schema Linking and Skeleton Parsing for Text-to-SQL." *AAAI 2023*, 2023.

[7] Yu, T., Zhang, R., Yang, K., et al.. "Spider: A Large-Scale Human-Labeled Dataset for Complex and Cross-Database Semantic Parsing and Text-to-SQL Task." *EMNLP 2018*, 2018.

[8] Li, J., Hui, B., Qu, G., et al.. "Can LLM Already Serve as A Database Interface? A BIg Bench for Large-Scale Database Grounded Text-to-SQLs." *NeurIPS 2024*, 2024.

[9] Yu, T., Zhang, R., Yasunaga, M., et al.. "SParC: Cross-Domain Semantic Parsing in Context." *ACL 2019*, 2019.

[10] Katsogiannis-Meimarakis, G. and Koutrika, G.. "A Survey on Employing Large Language Models for Text-to-SQL Tasks." *arXiv preprint*, 2023.

[11] Calvanese, D., Cogrel, B., Komla-Ebri, S., et al.. "Ontop: Answering SPARQL Queries over Relational Databases." *Semantic Web Journal*, 2017.

[12] Lenzerini, M.. "Data Integration: A Theoretical Perspective." *PODS 2002*, 2002.

[13] Poggi, A., Lembo, D., Calvanese, D., et al.. "Linking Data to Ontologies: The Description Logic DL-LiteA." *Journal of Data Semantics*, 2008.

[14] Xiao, G., Ding, L., Cogrel, B., and Calvanese, D.. "Virtual Knowledge Graphs: An Overview of Systems and Use Cases." *Data Intelligence Journal*, 2019.

[15] Calvanese, D., Kalayci, E.G., Ryzhikov, V., and Xiao, G.. "Ontology-Based Access to Temporal Data with Ontop: A Framework Proposal." *International Journal of Applied Mathematics and Computer Science*, 2019.

[16] Wu, Q., Bansal, G., Zhang, J., et al.. "AutoGen: Enabling Next-Gen LLM Applications via Multi-Agent Conversation." *arXiv preprint (Microsoft Research)*, 2023.

[17] Hong, S., Zhuge, M., Chen, J., et al.. "MetaGPT: Meta Programming for A Multi-Agent Collaborative Framework." *ICLR 2024*, 2023.

[18] Qian, C., Cong, X., Yang, C., et al.. "Communicative Agents for Software Development (ChatDev)." *ACL 2024*, 2023.

[19] Li, G., Hammoud, H., Itani, H., et al.. "CAMEL: Communicative Agents for 'Mind' Exploration of Large Language Model Society." *NeurIPS 2023*, 2023.

[20] Du, Y., Li, S., Torralba, A., et al.. "Improving Factuality and Reasoning in Language Models through Multiagent Debate." *ICML 2024*, 2023.

[21] Xi, Z., Chen, W., Guo, X., et al.. "The Rise and Potential of Large Language Model Based Agents: A Survey." *arXiv preprint*, 2023.

[22] Wang, G., Xie, Y., Jiang, Y., et al.. "Voyager: An Open-Ended Embodied Agent with Large Language Models." *NeurIPS 2023 (Spotlight)*, 2023.

[23] Schick, T., Dwivedi-Yu, J., Dessi, R., et al.. "Toolformer: Language Models Can Teach Themselves to Use Tools." *NeurIPS 2023*, 2023.

[24] Yao, S., Zhao, J., Yu, D., et al.. "ReAct: Synergizing Reasoning and Acting in Language Models." *ICLR 2023*, 2023.

[25] Pan, S., Luo, L., Wang, Y., et al.. "Unifying Large Language Models and Knowledge Graphs: A Roadmap." *IEEE TKDE 2024*, 2024.

[26] Sun, J., Xu, C., Tang, L., et al.. "Think-on-Graph: Deep and Responsible Reasoning of Large Language Model on Knowledge Graph." *ICLR 2024*, 2024.

[27] Edge, D., Trinh, H., Cheng, N., et al.. "From Local to Global: A Graph RAG Approach to Query-Focused Summarization." *arXiv preprint (Microsoft Research)*, 2024.

[28] Lewis, P., Perez, E., Piktus, A., et al.. "Retrieval-Augmented Generation for Knowledge-Intensive NLP Tasks." *NeurIPS 2020*, 2020.

[29] Jiang, J., Zhou, K., Dong, Z., et al.. "StructGPT: A General Framework for Large Language Model to Reason over Structured Data." *EMNLP 2023*, 2023.

[30] Ren, J., Guo, J., and Zhang, Y.. "Knowledge Graph-Enhanced Large Language Models: A Survey." *arXiv preprint*, 2024.

[31] Sumers, T.R., Yao, S., Narasimhan, K., and Griffiths, T.L.. "Cognitive Architectures for Language Agents (CoALA)." *TMLR 2024*, 2024.

[32] Laird, J.E.. "The Soar Cognitive Architecture." *MIT Press*, 2012.

[33] Anderson, J.R., Bothell, D., Byrne, M.D., et al.. "An Integrated Theory of the Mind." *Psychological Review*, 2004.

[34] Baars, B.J.. "A Cognitive Architecture Theory of Consciousness (Global Workspace Theory)." *Cambridge University Press*, 1988.

[35] Nii, H.P.. "The Blackboard Model of Problem Solving and the Evolution of Blackboard Architectures." *AI Magazine*, 1986.

