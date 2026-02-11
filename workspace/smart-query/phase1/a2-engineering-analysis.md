# A2 Engineering Analysis: Smart Query Codebase Deep Dive

## Executive Summary

This document presents a comprehensive engineering analysis of the Smart Query intelligent data querying system, conducted across 11 source files totaling 7,367 lines of code and documentation. The analysis extracts architecture patterns, quantitative metrics, design decisions, and maps all 13 proposed innovations to specific code locations with line ranges.

Smart Query is a production banking system that translates natural language data queries into precise database table/field mappings and executable SQL. Its core architectural innovation is the **Cognitive Hub Layer** -- the combination of a three-layer Neo4j ontology (314,680 nodes, 623,118 relationships) with instruction-following Skills (cognitive frameworks) that "activate" the static knowledge graph into a systematic domain cognition capability.

---

## 1. Architecture Overview

### 1.1 Four-Layer System Architecture

The system is organized into four distinct architectural layers:

**Layer 1: Cognitive Hub Layer (Conceptual)**
- Combines the Ontology Layer (static knowledge) with Skills (cognitive frameworks)
- Formula: `Ontology Layer + Skills = Cognitive Hub Layer`
- Source: `docs/knowledge/research-exploration.md`, lines 61-125

**Layer 2: Ontology Layer (Neo4j Knowledge Graph)**
- Three sub-layers with cross-layer associations
- 314,680 total nodes across 10 node types
- 623,118 total relationships across 7 relationship types
- Source: `docs/knowledge/ontology-graph-building.md`

**Layer 3: Skill Orchestration Layer**
- 5 SKILL.md files totaling 3,465 lines
- Main orchestrator dispatches to 3 independent strategy skills
- SQL Generation skill serves as the user-facing entry point
- Source: `.claude/skills/` directory

**Layer 4: MCP Tool Layer**
- 29 MCP tools across 2 servers
- ontology_server.py: 21 tools (Neo4j backend)
- simple_resources_server.py: 8 tools (MySQL backend)
- Source: `docs/knowledge/mcp-tools.md`

### 1.2 Information Flow

```
User NL Query
    |
    v
[Phase 0: Clarification] -- understand intent, extract keywords
    |
    v
[Strategy 1: Indicator-Driven] -- Magic Number indicator layer search
    |  (output to conversation history)
    v
[Strategy 2: Scenario-Driven] -- Schema->Topic->Table + hybrid search
    |  (reads Strategy 1 context implicitly)
    v
[Strategy 3: Term-Driven] -- business term search + data standards
    |  (reads Strategy 1+2 context implicitly)
    v
[Comprehensive Adjudication] -- cross-validation + lineage analysis
    |  (produces complete evidence pack)
    v
[SQL Generation] -- uses evidence pack to generate executable SQL
    |
    v
Executable SQL with business annotations
```

---

## 2. Quantitative Metrics

### 2.1 Ontology Scale

| Layer | Nodes | Key Node Types |
|-------|-------|----------------|
| Magic Number Indicator Layer | 163,284 | INDICATOR: 155,767; SUBPATH: 6,221; THEME: 961; CATEGORY: 301; SECTOR: 34 |
| Data Asset Layer | 35,379 | TABLE: 35,287; TABLE_TOPIC: 83; SCHEMA: 9 |
| Term Standard Layer | 40,319 | TERM: 39,558; DATA_STANDARD: 761 |
| **Total** | **314,680** | 10 distinct node types |

### 2.2 Relationship Scale

| Relationship Type | Count | Layer |
|-------------------|-------|-------|
| HAS_CHILD | 163,283 | Indicator (parent-child tree) |
| HAS_INDICATOR | 147,464 | Cross-layer (TABLE -> INDICATOR) |
| HAS_TERM | 251,227 | Term (TABLE -> TERM) |
| UPSTREAM | 50,509 | Data Asset (lineage) |
| BELONGS_TO_STANDARD | 7,167 | Term (TERM -> DATA_STANDARD) |
| HAS_TABLE | 3,385 | Data Asset (TOPIC -> TABLE) |
| HAS_TOPIC | 83 | Data Asset (SCHEMA -> TOPIC) |
| **Total** | **623,118** | 7 relationship types |

### 2.3 Lineage Statistics

| Lineage Type | Count | Description |
|-------------|-------|-------------|
| TableDirectTable | 43,880 | Direct field references |
| TableIndirectTable | 6,629 | Indirect references (WHERE conditions) |
| **Total UPSTREAM** | **50,509** | All lineage relationships |

### 2.4 Term Coverage Statistics

| Metric | Value |
|--------|-------|
| Total terms in glossary | 63,338 |
| Terms matched to physical fields | 39,558 (62.5%) |
| Unmatched terms | 23,780 (37.5%) |
| Tables with term associations | 28,851 |
| Average terms per table | 8.7 |
| Median terms per table | 3 |
| 90th percentile | 22 terms/table |
| Maximum (single table) | 492 terms |

### 2.5 Codebase Metrics

| File | Lines | Role |
|------|-------|------|
| smart-query/SKILL.md | 790 | Main orchestrator |
| smart-query-indicator/SKILL.md | 455 | Strategy 1 |
| smart-query-scenario/SKILL.md | 454 | Strategy 2 |
| smart-query-term/SKILL.md | 508 | Strategy 3 |
| sql-generation/SKILL.md | 1,258 | SQL generation |
| **Total Skill Lines** | **3,465** | 5 skills |
| smart-query-design.md | 557 | Design documentation |
| research-exploration.md | 1,438 | Research documentation |
| sql-generation-design.md | 327 | SQL design documentation |
| ontology-graph-building.md | 419 | ETL documentation |
| mcp-tools.md | 915 | Tool documentation |
| CLAUDE.md | 246 | Project overview |
| **Total Knowledge Lines** | **3,902** | 6 documents |
| **Grand Total** | **7,367** | 11 files analyzed |

### 2.6 Tool Metrics

| Category | Count |
|----------|-------|
| Vector retrieval tools | 3 |
| Indicator strategy tools | 3 |
| Scenario strategy tools | 5 |
| Term strategy tools | 5 |
| **Smart Query core tools** | **16** |
| Data exploration tools | 5 |
| Dependency analysis tools | 3 |
| SQL execution tools | 2 |
| Other tools | 1 |
| **General purpose tools** | **11** |
| **Grand Total** | **29** |

### 2.7 Vector Infrastructure

| Parameter | Value |
|-----------|-------|
| Embedding model | paraphrase-multilingual-MiniLM-L12-v2 |
| Embedding dimensions | 384 |
| Language support | Chinese + English (bilingual) |
| Neo4j version | 5.25 Community Edition |
| Similarity function | COSINE |
| Vector indexes | indicator_vector_index, table_vector_index, term_vector_index |
| Default keyword_ratio | 0.5 (50% exact + 50% vector) |
| Default max_results | 30 |
| Table hybrid keyword_limit | 50 |
| Table hybrid vector_limit | 10 |

---

## 3. Innovation Mapping (All 13 Innovations)

### Innovation 1: Cognitive Hub Layer Architecture

- **Code Location**: `docs/knowledge/research-exploration.md`, lines 61-125
- **Supporting Files**: `CLAUDE.md` (lines 1-10 of core understanding section)
- **Description**: The ontology layer is the "digital twin" of business knowledge -- it stores knowledge structure but lacks cognitive ability. Skills are cognitive frameworks that "activate" the ontology into a Cognitive Hub. The key formula is: `Ontology Layer (static knowledge) + Skills (cognitive framework) = Cognitive Hub Layer (domain cognition capability)`.
- **Academic Significance**: Proposes a novel architecture paradigm distinct from RAG (which treats knowledge as flat documents) and fine-tuning (which embeds knowledge in model weights). The Cognitive Hub separates knowledge storage (ontology, updatable) from reasoning patterns (skills, composable), enabling independent evolution of both components.

### Innovation 2: Three-Strategy Serial Execution with Implicit Context Inheritance

- **Code Location**: `.claude/skills/smart-query/SKILL.md`, lines 98-147 (architecture diagram), lines 360-410 (skill dispatch)
- **Supporting Files**: `docs/knowledge/research-exploration.md` (lines 791-815), `docs/knowledge/smart-query-design.md` (lines 104-113)
- **Description**: Three independent strategy Skills execute serially via synchronous `Skill()` calls. Although `args` only passes `user_question`, each sub-Skill accesses the full conversation history. Strategy 2 can implicitly infer Strategy 1's Schema/Topic discoveries; Strategy 3 can infer all prior discoveries. This exploits the LLM's natural ability to extract information from conversation history as an implicit communication channel.
- **Academic Significance**: Combines the benefits of independent execution (testability, state isolation, modular development) with shared context (semantic accumulation, progressive refinement). This is a novel coordination pattern for LLM-based multi-agent systems.

### Innovation 3: Semantic Cumulative Effect

- **Code Location**: `docs/knowledge/research-exploration.md`, lines 654-783
- **Description**: Formalized using information entropy: `H(I|S1) < H(I)`, `H(I|S1,S2) < H(I|S1)`, `H(I|S1,S2,S3) < H(I|S1,S2)`. Each strategy progressively reduces uncertainty about the user's intent. In shared context mode, the cumulative effect exceeds the sum of independent effects. Concrete example: Strategy 1 identifies "retail credit" domain -> Strategy 2 narrows to `dmrbm_data` Schema and `E_LN_` Topic -> Strategy 3 achieves precise `loan_balance` field matching.
- **Academic Significance**: Provides a formal information-theoretic framework for understanding why serial shared-context execution outperforms parallel independent execution. The entropy reduction model is quantifiable and experimentally testable. Predicted metrics: Topic search accuracy improves from 75% (no context) to ~85% (implicit inheritance).

### Innovation 4: Evidence Pack Fusion with Cross-Validation Adjudication

- **Code Location**: `.claude/skills/smart-query/SKILL.md`, lines 453-605
- **Supporting Files**: `docs/knowledge/research-exploration.md` (lines 188-529), `docs/knowledge/smart-query-design.md` (lines 404-452)
- **Description**: Three strategies independently collect structured JSON evidence packs. Evidence strength is graded: 3 strategies agree = high confidence, 2 = medium-high, 1 = cautious. Cross-validation checks table consistency, field coverage, and conflict resolution. The LLM performs final adjudication based on complete evidence from all three perspectives. Evidence packs include: matched indicators, field mappings, candidate tables with heat scores, term definitions, and data standards.
- **Academic Significance**: More rigorous than simple voting or ranking. Preserves the complete reasoning chain from each perspective, enabling transparent conflict resolution and confidence scoring.

### Innovation 5: Three-Layer Ontology with Cross-Layer Associations

- **Code Location**: `docs/knowledge/ontology-graph-building.md`, lines 1-16 (overview), lines 337-366 (final statistics)
- **Supporting Files**: `CLAUDE.md` (ontology structure section)
- **Description**: Three specialized layers connected by cross-layer associations. Magic Number Indicator Layer (163,284 nodes, 5-level hierarchy SECTOR->INDICATOR), Data Asset Layer (35,379 nodes, 3-level hierarchy SCHEMA->TABLE), Term Standard Layer (40,319 nodes, TERM->DATA_STANDARD). Cross-layer: HAS_INDICATOR (147,464 edges connecting TABLE->INDICATOR), HAS_TERM (251,227 edges connecting TABLE->TERM), UPSTREAM (50,509 lineage edges).
- **Academic Significance**: Demonstrates a scalable multi-layer ontology design for banking domain with 300K+ nodes that supports three independent navigation paths while maintaining cross-layer semantic coherence through 600K+ relationships.

### Innovation 6: Fixed-Ratio Hybrid Retrieval with Field-Level Vectorization

- **Code Location**: `docs/knowledge/smart-query-design.md`, lines 204-297
- **Supporting Files**: `docs/knowledge/mcp-tools.md` (lines 52-133)
- **Description**: TABLE embeddings are generated by concatenating table description + all column name:description pairs (field-level vectorization). Fixed 50/50 ratio hybrid retrieval: 15 keyword results + 15 vector results. Design philosophy: "not pursuing complete elimination of TopK truncation, but providing complementary semantic retrieval paths." Both-recalled nodes get `fusion_score=1.0`, single-source nodes get `0.5`.
- **Academic Significance**: Proposes field-level vectorization for table retrieval and a principled fixed-ratio hybrid strategy. The embedding formula `embedding_text = table_description + " ".join([f"{col_name}:{col_desc}" for col in columns])` enables field-level semantic matching.

### Innovation 7: Dual Retrieval Mechanism

- **Code Location**: `docs/knowledge/smart-query-design.md`, lines 454-489
- **Supporting Files**: `.claude/skills/smart-query-scenario/SKILL.md` (lines 80-100), `docs/knowledge/mcp-tools.md` (lines 396-478)
- **Description**: Strategy 2 MUST simultaneously execute: (1) Convergent path navigation (`list_schemas -> get_schema_topics -> get_topic_tables`) for structured coverage, and (2) `hybrid_search_tables(keyword_limit=50, vector_limit=10)` for semantic expansion. Results are fused with deduplication. Tables recalled by both methods get highest confidence. Neither method alone is sufficient: convergent path misses synonym expressions; hybrid search may miss tables in the correct business domain.
- **Academic Significance**: Demonstrates that structured ontology navigation and semantic vector search are complementary. The dual mechanism ensures both precision (convergent path covers the target domain) and recall (semantic expansion discovers alternative expressions).

### Innovation 8: Progressive Degradation Search

- **Code Location**: `.claude/skills/smart-query-indicator/SKILL.md`, lines 84-100
- **Supporting Files**: `.claude/skills/smart-query/SKILL.md` (lines 360-410)
- **Description**: Strategy 1 uses `layered_keyword_search` with fixed-ratio hybrid. If indicator search yields no results, falls back to `find_indicators_by_name` for fuzzy matching. If still no results, the strategy gracefully degrades and reports findings to the orchestrator. The orchestrator continues with remaining strategies rather than failing. Each strategy can partially fail without blocking the overall system.
- **Academic Significance**: Critical robustness property for production NL-to-SQL systems. The three-strategy architecture provides natural redundancy -- if one strategy fails, the other two can still produce useful evidence.

### Innovation 9: Isolated Table Filtering via Lineage Heat Analysis

- **Code Location**: `.claude/skills/smart-query/SKILL.md`, lines 486-519
- **Supporting Files**: `docs/knowledge/smart-query-design.md` (lines 319-343)
- **Description**: Isolated tables defined as: `total_downstream_count=0 AND upstream_count=0` (`is_isolated=true`). These represent deprecated tables with no data flow. Filtering applied during comprehensive adjudication on candidate related tables. Preservation rules: source tables (downstream=0, upstream>0) are kept; normal downstream tables (downstream>0, upstream=0) are kept. Only true orphans (both=0) are excluded.
- **Academic Significance**: Graph-theoretic approach to data quality. By analyzing lineage graph topology (in-degree and out-degree), the system automatically identifies deprecated tables without manual curation. This is a zero-maintenance quality filter.

### Innovation 10: Lineage-Driven Related Table Discovery with Automatic JOIN

- **Code Location**: `.claude/skills/smart-query/SKILL.md`, lines 473-555
- **Supporting Files**: `docs/knowledge/sql-generation-design.md` (lines 99-198)
- **Description**: After primary table determination, `get_table_dependencies(direction='all')` discovers upstream/downstream tables via pre-computed lineage. For each candidate: (1) check isolation, (2) get terms/columns, (3) identify matching fields via shared `term_en_name`, (4) determine JOIN type. Key insight: "lineage relationships reflect actual ETL data flow, making JOIN conditions more reliable than vector-search-based table discovery." Lineage = structural facts; vector search = semantic guesses.
- **Academic Significance**: Fundamental insight that pre-computed data lineage provides more reliable JOIN discovery than semantic similarity. This challenges the common assumption that vector search is the universal solution for table relationship discovery.

### Innovation 11: Pre-computed Indicator Field Mappings

- **Code Location**: `docs/knowledge/ontology-graph-building.md`, lines 199-312
- **Description**: The `c_expression` field contains complex expressions in 8 format types (standard `^C_FIELD.schema.table.column^`, missing caret, function-wrapped, arithmetic, CASE WHEN, REF, C_BIZATTR, BizView). An expression parser with 7-step priority chain extracts physical references. Mappings are pre-computed during ETL and stored as HAS_INDICATOR relationships (147,464 edges). At query time, `get_indicator_field_mapping()` reads directly from Neo4j in O(1).
- **Academic Significance**: Converts runtime O(n) expression parsing into O(1) graph lookup. The 8-format expression parser handles real-world complexity of banking indicator definitions, including mixed Chinese/English formats and nested expressions.

### Innovation 12: Cognitive Modular Architecture with Instruction-Following Optimization

- **Code Location**: `docs/knowledge/smart-query-design.md`, lines 131-187
- **Description**: Each strategy is an independent Skill (~400 lines) focused on a single cognitive task. Key formulas: `Intelligence = modularity x context_inheritance_efficiency x task_focus` and `Instruction-following quality = context_focus x instruction_clarity x task_complexity`. By splitting a monolithic skill into focused modules, each achieves near-perfect instruction compliance with 100% attention on current instructions.
- **Academic Significance**: Provides a theoretical framework for optimizing LLM instruction-following in complex multi-step tasks. The principle that smaller, focused instruction sets yield better compliance has broad implications for LLM-based system design beyond NL-to-SQL.

### Innovation 13: Multi-Scenario Unified Ontology

- **Code Location**: `docs/knowledge/research-exploration.md`, lines 979-1411
- **Description**: Proposes extending the Smart Query ontology into a unified ontology supporting three scenarios: Smart Query (user perspective), Data Development (implementation perspective), and Data Governance (management perspective). Architecture: shared foundation layer (TABLE, FIELD, TERM, STANDARD, SCHEMA) + three scenario-specific layers. Cross-scenario associations create a flywheel effect: Smart Query identifies hot data -> Data Governance prioritizes quality -> Data Development optimizes -> standards improve.
- **Academic Significance**: Novel multi-scenario ontology fusion architecture. The flywheel effect between querying, development, and governance represents a contribution to enterprise data management theory. Currently Smart Query is implemented; the other two scenarios are proposed extensions.

---

## 4. Architecture Patterns

### 4.1 Main Orchestrator Pattern

**Location**: `.claude/skills/smart-query/SKILL.md`, lines 98-147

The main Smart Query skill acts as an orchestrator that dispatches to three independent sub-skills via synchronous `Skill()` calls. Each sub-skill returns a structured evidence pack. The orchestrator then performs comprehensive adjudication including cross-validation, lineage analysis, and final recommendation.

```
Orchestrator (smart-query/SKILL.md, 790 lines)
    |-- Skill("smart-query-indicator", args=user_question)  -> Evidence Pack 1
    |-- Skill("smart-query-scenario", args=user_question)   -> Evidence Pack 2
    |-- Skill("smart-query-term", args=user_question)       -> Evidence Pack 3
    |-- Comprehensive Adjudication (cross-validation + lineage)
    |-- Output: Complete Evidence Pack (primary + related tables + JOIN conditions)
```

### 4.2 Two-Phase SQL Generation Pattern

**Location**: `.claude/skills/sql-generation/SKILL.md`, lines 26-50

SQL Generation uses a two-phase architecture:
- Phase 1: Internally calls Smart Query to build complete evidence pack (user is unaware)
- Phase 2: Uses evidence pack to design SQL structure and generate code

This separation ensures that business understanding (Phase 1) and SQL engineering (Phase 2) are cleanly decoupled.

### 4.3 Convergent Path Navigation Pattern

**Location**: `.claude/skills/smart-query-scenario/SKILL.md`, lines 80-100

Strategy 2 navigates the data asset layer via a convergent path: `Schema -> Topic -> Table`. This progressive narrowing avoids searching all 35,287 tables globally. At each step, the search space is constrained by business domain semantics.

### 4.4 Evidence Pack Communication Protocol

**Location**: `.claude/skills/smart-query/SKILL.md`, lines 608-667

Structured JSON evidence packs serve as the inter-component communication protocol. Each evidence pack contains: matched indicators, field mappings, candidate tables, primary table selection, related tables with JOIN conditions, and filtered (excluded) tables with reasons.

---

## 5. Design Decisions

### 5.1 Serial over Parallel Execution

**Decision**: Execute three strategies serially rather than in parallel.

**Rationale**: Enables semantic cumulative effect where each strategy benefits from prior discoveries via conversation history. Information entropy decreases monotonically: `H(I|S1,S2,S3) < H(I|S1,S2) < H(I|S1) < H(I)`.

**Location**: `docs/knowledge/research-exploration.md`, lines 654-783

### 5.2 Independent Skills over Monolithic Skill

**Decision**: Split a single large skill into 4-5 focused skills (~400 lines each).

**Rationale**: Each focused skill achieves 100% instruction-following attention. A monolithic 2000+ line skill suffers from attention dilution and instruction compliance degradation.

**Location**: `docs/knowledge/smart-query-design.md`, lines 131-187

### 5.3 Implicit over Explicit Context Passing

**Decision**: Use conversation history as implicit context channel rather than explicit parameter passing.

**Rationale**: Leverages LLM's natural conversation understanding; maintains backward compatibility (skills can be called independently); reduces inter-skill coupling. Explicit passing is documented as a future enhancement option.

**Location**: `docs/knowledge/research-exploration.md`, lines 791-968

### 5.4 Lineage-Driven over Vector-Search-Based JOIN

**Decision**: Use pre-computed data lineage for related table discovery and JOIN condition identification.

**Rationale**: Lineage reflects actual ETL data flow (structural facts) while vector search provides semantic guesses. For relational operations like JOIN, structural facts are more reliable. One lineage query retrieves the complete dependency chain.

**Location**: `docs/knowledge/sql-generation-design.md`, lines 99-198

### 5.5 Pre-computed Mappings over Runtime Parsing

**Decision**: Pre-compute indicator-to-field mappings during ETL rather than parsing expressions at query time.

**Rationale**: Converts O(n) runtime parsing of 8 expression format types into O(1) Neo4j graph lookup. The 147,464 pre-computed HAS_INDICATOR relationships enable real-time indicator resolution.

**Location**: `docs/knowledge/ontology-graph-building.md`, lines 199-312

### 5.6 Fixed-Ratio over Adaptive Hybrid Retrieval

**Decision**: Use a fixed 50/50 keyword-to-vector ratio rather than adaptive weighting.

**Rationale**: Provides consistent complementary coverage. Keyword and vector retrieval recall different dimensions of relevance. The fixed ratio is simple, predictable, and empirically effective. Configurable per-scenario (0.3-0.7 range documented).

**Location**: `docs/knowledge/smart-query-design.md`, lines 228-268

### 5.7 Lineage Analysis in Adjudication Phase

**Decision**: Perform blood lineage analysis during comprehensive adjudication (Step 4), not during individual strategy execution.

**Rationale**: Lineage analysis must be based on the final primary table (determined after cross-validation of all three strategies). Premature lineage exploration on candidate tables wastes resources and may explore irrelevant paths.

**Location**: `.claude/skills/smart-query/SKILL.md`, lines 288-356

### 5.8 SQL Generation Calls Smart Query Internally

**Decision**: SQL Generation internally calls Smart Query rather than directly operating MCP tools.

**Rationale**: Avoids duplication of business understanding logic. Single source of truth for table/field location. Ensures consistent results across different callers.

**Location**: `docs/knowledge/sql-generation-design.md`, lines 90-98

---

## 6. Ontology ETL Pipeline

### 6.1 Overview

The ontology is built through a 21-step ETL pipeline defined in `ontology-layer/src/load/main.py`. The pipeline extracts data from 6 MySQL source tables, transforms it into graph structures, and loads it into Neo4j.

### 6.2 Step Breakdown

| Steps | Layer | Description |
|-------|-------|-------------|
| 1-9 | Magic Number Indicator | Extract tree structure from `t_restree`, transform node types (SECTOR/CATEGORY/THEME/SUBPATH/INDICATOR), load with HAS_CHILD relationships |
| 10 | Cleaning | Remove temporary sectors and invalid nodes |
| 11-16 | Data Asset | Extract tables from `bigmeta_entity_table`, parse `c_expression` from `t_bizattr` for indicator-field mappings, build SCHEMA/TABLE_TOPIC/TABLE nodes with HAS_TOPIC/HAS_TABLE/UPSTREAM/HAS_INDICATOR relationships |
| 17 | Cleaning | Remove empty SCHEMAs with no tables |
| 18-21 | Term Standard | Extract matched terms from `data_business_glossary` (INNER JOIN with `bigmeta_entity_column`), load TERM/DATA_STANDARD nodes with HAS_TERM/BELONGS_TO_STANDARD relationships |

### 6.3 Expression Parser

The expression parser (`expression_parser.py`) handles 8 format types with a 7-step priority chain:

1. `_parse_cbizattr()` -- Statistics only (Chinese business attribute names)
2. `_parse_standard_format()` -- Standard `^C_FIELD.schema.table.column^`
3. `_parse_missing_caret()` -- Missing closing `^`
4. `_parse_function_wrapped()` -- `cast()`, `to_date()`, `substr()` wrappers
5. `_parse_arithmetic()` -- Arithmetic operations (`+ - * /`)
6. `_parse_case_when()` -- CASE WHEN expressions
7. `_extract_all_c_fields()` -- Final fallback: extract all `^C_FIELD...^` references

Key design: C_BIZATTR uses Chinese names (collected for statistics only); C_FIELD uses standard `schema.table.column` format (primary mapping source).

### 6.4 Data Sources

| Source Table | Purpose | Key Fields |
|-------------|---------|------------|
| `t_restree` | Indicator tree structure | c_resid, c_resalias, c_restype, c_pid |
| `t_bizattr` | Indicator-field mapping expressions | c_attrid, c_expression, c_themeid |
| `bigmeta_entity_table` | Table metadata and lineage | guid, name, Input, Output |
| `t_schema_topic_config` | Schema-Topic configuration | schema_name, topic_prefix |
| `data_business_glossary` | Business terms | term_code, term_name, field_name |
| `data_standard` | Data standards | std_code, std_name |

---

## 7. Cross-Reference: Innovation to File Mapping

| Innovation | Primary File | Line Range | Supporting Files |
|-----------|-------------|------------|-----------------|
| 1. Cognitive Hub | research-exploration.md | 61-125 | CLAUDE.md |
| 2. Serial Execution + Implicit Context | smart-query/SKILL.md | 98-147, 360-410 | research-exploration.md, smart-query-design.md |
| 3. Semantic Cumulative Effect | research-exploration.md | 654-783 | -- |
| 4. Evidence Pack Fusion | smart-query/SKILL.md | 453-605 | research-exploration.md, smart-query-design.md |
| 5. Three-Layer Ontology | ontology-graph-building.md | 1-16, 337-366 | CLAUDE.md |
| 6. Hybrid Retrieval + Field Vectorization | smart-query-design.md | 204-297 | mcp-tools.md |
| 7. Dual Retrieval Mechanism | smart-query-design.md | 454-489 | smart-query-scenario/SKILL.md, mcp-tools.md |
| 8. Progressive Degradation | smart-query-indicator/SKILL.md | 84-100 | smart-query/SKILL.md |
| 9. Isolated Table Filtering | smart-query/SKILL.md | 486-519 | smart-query-design.md |
| 10. Lineage-Driven JOIN | smart-query/SKILL.md | 473-555 | sql-generation-design.md |
| 11. Pre-computed Mappings | ontology-graph-building.md | 199-312 | -- |
| 12. Cognitive Modular Architecture | smart-query-design.md | 131-187 | smart-query/SKILL.md |
| 13. Multi-Scenario Ontology | research-exploration.md | 979-1411 | -- |

---

## 8. Key Formulas and Theoretical Contributions

### 8.1 Cognitive Hub Formula
```
Ontology Layer (static knowledge) + Skills (cognitive framework) = Cognitive Hub Layer (domain cognition)
```
Source: `docs/knowledge/research-exploration.md`, line 121

### 8.2 Semantic Cumulative Effect (Information Entropy)
```
H(I|S1) < H(I)                    -- Strategy 1 reduces uncertainty
H(I|S1,S2) < H(I|S1)              -- Strategy 2 further reduces uncertainty
H(I|S1,S2,S3) < H(I|S1,S2)       -- Strategy 3 completes precise location
```
Source: `docs/knowledge/research-exploration.md`, lines 663-674

### 8.3 Intelligence Formula
```
Cognitive system intelligence = modularity x context_inheritance_efficiency x task_focus
```
Source: `docs/knowledge/smart-query-design.md`, line 155

### 8.4 Instruction-Following Quality Formula
```
Instruction-following quality = context_focus x instruction_clarity x task_complexity
```
Source: `docs/knowledge/smart-query-design.md`, line 186

### 8.5 Table Recommendation Quality Formula
```
Table recommendation quality = field_coverage x business_semantic_match x table_validity (non-isolated)
```
Source: `docs/knowledge/smart-query-design.md`, line 342

### 8.6 SQL Generation Quality Formula
```
SQL generation quality = primary_table_accuracy x lineage_application_capability x JOIN_condition_precision
```
Source: `docs/knowledge/sql-generation-design.md`, line 192

### 8.7 Retrieval System Effectiveness Formula
```
Retrieval system effectiveness = vectorization_quality x complementary_retrieval_design x fusion_strategy
```
Source: `docs/knowledge/smart-query-design.md`, line 301

---

## 9. Comparison with Existing Approaches

The research-exploration.md document (lines 567-626) provides a systematic comparison:

| Dimension | Direct Prompting | RAG | Fine-tuned LLM | Ontology + Cognitive Hub (This Work) |
|-----------|-----------------|-----|-----------------|--------------------------------------|
| Knowledge Representation | Text fragments | Unstructured documents | Model weights | Structured knowledge graph |
| Reasoning Capability | LLM built-in | LLM + retrieval | LLM enhanced | LLM + domain cognitive framework |
| Accuracy | Low (hallucinations) | Medium | Medium-high | High (cross-validation) |
| Explainability | Weak | Weak | Weak | Strong (complete reasoning chain) |
| Domain Adaptation | Depends on prompt | Depends on retrieval quality | Requires retraining | Depends on ontology quality |
| Update Cost | Retrain/fine-tune | Update document store | Retrain | Update knowledge graph |

---

## 10. Conclusion

The Smart Query system represents a comprehensive engineering effort that combines a large-scale domain ontology (314,680 nodes, 623,118 relationships) with a modular cognitive architecture (5 skills, 29 MCP tools) to solve the NL-to-SQL problem in the banking domain. The 13 innovations span from theoretical contributions (Cognitive Hub Layer, Semantic Cumulative Effect) to practical engineering patterns (Isolated Table Filtering, Pre-computed Mappings, Dual Retrieval Mechanism).

The system's key architectural insight is that domain-specific NL-to-SQL requires not just knowledge retrieval (as in RAG) but systematic domain cognition -- the ability to navigate structured knowledge from multiple perspectives, accumulate semantic understanding progressively, and adjudicate across independent evidence sources. This is achieved through the Cognitive Hub Layer architecture where the ontology provides the knowledge structure and Skills provide the cognitive activation.

---

*Analysis completed by A2 Engineering Analyst agent. All file paths are absolute references within the `/Users/yyzz/Desktop/MyClaudeCode/smart-query/` project directory.*
