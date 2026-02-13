## 3. System Architecture

We now present the detailed architecture of Smart Query, grounding the Cognitive Hub concept introduced in Section 1 in concrete system design. The architecture consists of four integrated layers: a three-layer ontology serving as externalized declarative memory, specialized Skills encoding procedural knowledge, MCP tools providing structured access mechanisms, and an LLM-based orchestrator coordinating multi-strategy reasoning. We describe each component systematically, explaining design rationale and implementation details.

### 3.1 Overview: Cognitive Hub Architecture

The Cognitive Hub architecture formalizes the relationship between static knowledge structures and dynamic reasoning processes. We ground this formalization in cognitive architecture theory, drawing on three established frameworks: ACT-R (Adaptive Control of Thought-Rational) [Anderson2004], SOAR (State, Operator, And Result) [Laird2012], and CoALA (Cognitive Architecture for Language Agents) [Sumers2023].

**Declarative Memory: The Three-Layer Ontology.** The ontology layer serves as externalized long-term declarative memory, analogous to ACT-R's declarative module or SOAR's semantic memory. It contains 314,680 nodes and 623,118 relationships organized into three specialized layers: the Indicator Layer (163,284 nodes encoding business concepts), the Data Asset Layer (35,379 nodes representing physical database structures), and the Term/Standard Layer (40,319 nodes capturing business terminology). This separation is not arbitrary but reflects distinct knowledge dimensions that enable orthogonal navigation strategies. The ontology is stored in Neo4j, providing graph-native storage with O(1) relationship traversal and vector similarity search through native indexes.

**Procedural Memory: Specialized Skills.** Skills encode procedural knowledge — cognitive strategies for navigating the ontology and constructing evidence. Each of the three strategy Skills (Indicator Expert, Scenario Navigator, Term Analyst) is approximately 400-500 lines of structured instructions that guide the LLM through a specific reasoning process. These Skills correspond to production rules in ACT-R or operators in SOAR: they specify conditions for activation and sequences of actions to execute. The modular decomposition achieves near-perfect instruction-following compliance by limiting each Skill's scope to a single cognitive task, avoiding the attention degradation observed in monolithic 2000+ line instruction sets [SmartQueryDesign].

**Pattern Matching Engine: The LLM.** The LLM (Claude 3.5 Sonnet in our implementation) serves as the central pattern-matching and coordination engine, analogous to ACT-R's central production system or SOAR's decision procedure. It interprets natural language queries, selects appropriate Skills, invokes MCP tools based on Skill instructions, and performs final adjudication over structured evidence. Critically, the LLM does not store domain knowledge internally — it retrieves knowledge from the externalized ontology through tool calls, avoiding hallucination on enterprise-specific table and field names.

**Retrieval Mechanisms: MCP Tools.** The system exposes 29 MCP (Model Context Protocol) tools that bridge LLM working memory with the externalized ontology. These tools implement hybrid retrieval (keyword + vector), hierarchical path navigation, lineage traversal, and metadata enrichment. They correspond to retrieval operations in CoALA's external action space or ACT-R's buffer access operations. The tool layer abstracts Neo4j query complexity, providing the LLM with high-level semantic operations like `get_indicator_full_path()` or `get_table_dependencies()` rather than raw Cypher queries.

**Formalization.** We formalize the Cognitive Hub as a tuple CH = (O, S, T, L), where:
- O = {O_I, O_D, O_T} is the three-layer ontology (Indicator, Data Asset, Term)
- S = {S_1, S_2, S_3} is the set of strategy Skills
- T = {t_1, ..., t_29} is the set of MCP tools
- L is the LLM pattern-matching engine

The system processes a natural language query q through serial strategy execution: L invokes S_1(q, O, T) → E_1, then S_2(q, O, T, E_1) → E_2, then S_3(q, O, T, E_1, E_2) → E_3, where E_i denotes the evidence pack from strategy i. Context inheritance occurs implicitly through the conversation history H, which accumulates evidence across strategies. Final adjudication A(E_1, E_2, E_3, H) → R produces the recommendation R containing the primary table, related tables, and JOIN conditions.

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

(see Table 1)

**Digital Twin Concept.** We characterize the ontology as a "digital twin" of the enterprise data landscape — a structured representation that mirrors the organization, semantics, and relationships of the physical database environment. Unlike traditional database catalogs that capture only schema metadata, the digital twin integrates business logic (indicators), technical structure (schemas and lineage), and semantic mappings (terms and standards) into a unified knowledge graph. This integration enables the Cognitive Hub to reason about data at multiple levels of abstraction, from high-level business concepts to specific physical fields.

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

**Implicit Context Inheritance through Conversation History.** Although the `args` parameter passed to each Skill contains only the original `user_question`, each strategy has access to the full conversation history, including all prior strategies' tool calls, reasoning, and evidence packs. This enables implicit context inheritance: Strategy 2 can observe that Strategy 1 identified a particular schema or business domain and focus its convergent path navigation accordingly. Strategy 3 can observe that Strategies 1 and 2 converged on certain candidate tables and prioritize terms associated with those tables. This implicit communication through conversation history is a form of digital stigmergy [Grasse1959] — agents communicate by observing the traces left by their predecessors rather than through explicit parameter passing.

The implicit context inheritance design has several advantages over explicit parameter passing: (1) it maintains backward compatibility, as each Skill can be invoked independently with only the user question; (2) it reduces inter-Skill coupling, as strategies do not need to agree on a shared evidence format for parameter passing; (3) it leverages the LLM's natural ability to extract relevant information from conversation history, avoiding the need for explicit context extraction logic.

**Cognitive Modular Architecture.** Each strategy Skill is approximately 400-500 lines of structured instructions focused on a single cognitive task. This modular decomposition is motivated by empirical observations of instruction-following quality degradation in large monolithic Skills. We hypothesize that instruction-following quality is inversely proportional to instruction set size: a 2000-line monolithic Skill exhibits attention diffusion, where the LLM struggles to maintain focus on all instructions simultaneously. By decomposing into focused modules, each Skill achieves near-100% instruction compliance. We formalize this as: Intelligence = modularity × context_inheritance_efficiency × task_focus, where modularity enables specialization, context inheritance enables semantic accumulation, and task focus enables attention concentration.

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
