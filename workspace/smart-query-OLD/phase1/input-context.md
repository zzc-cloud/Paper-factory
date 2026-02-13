# Research Context: Multi-Agent Architecture for Ontology-Driven Data Querying

## Research Topic

This research investigates a novel multi-agent architecture for natural language data querying in enterprise banking environments. The system, called **Smart Query**, uses a layered ontology (knowledge graph) combined with specialized cognitive agents to map business questions to physical database tables and fields.

## Paper Direction

The paper targets the intersection of:
- **NL2SQL / Text-to-SQL**: Natural language interfaces to databases
- **Ontology-Based Data Access (OBDA)**: Using knowledge graphs for data navigation
- **LLM-Based Multi-Agent Systems**: Specialized agents collaborating on complex tasks
- **Cognitive Architecture**: How structured knowledge + reasoning strategies = domain intelligence

## Proposed Title

**"Cognitive Hub: A Multi-Agent Architecture for Ontology-Driven Natural Language Data Querying"**

---

## Smart Query System Overview

Smart Query is a production system deployed in a banking environment with:
- **238,982 nodes** and **770,582 relationships** in a Neo4j knowledge graph
- **3 ontology layers**: Business Indicator (163,284 nodes), Data Asset (35,379 nodes), Term/Standard (40,319 nodes)
- **29+ MCP tools** for ontology navigation and data querying
- **3 specialized cognitive agents** executing serially with implicit context inheritance
- **Evidence pack fusion** with cross-validation adjudication

---

## 13 Technical Innovations

### Innovation 1: Cognitive Hub Layer Architecture
The system proposes that Ontology Layer (static knowledge) + Skills (cognitive frameworks) = Cognitive Hub (domain reasoning capability). This differs from RAG (text chunks), fine-tuning (baked-in knowledge), and direct prompting (no structure).

### Innovation 2: Three-Strategy Serial Execution with Implicit Context Inheritance
Three specialized agents execute serially (not parallel), where later agents implicitly inherit earlier agents' discoveries through shared conversation history — without explicit parameter passing.

### Innovation 3: Semantic Cumulative Effect
Formalized as: H(I|S₁,S₂,S₃) < H(I|S₁,S₂) < H(I|S₁) < H(I), where each successive strategy reduces information entropy about the target data.

### Innovation 4: Evidence Pack Fusion with Cross-Validation Adjudication
Three independent evidence packs are merged through cross-validation: 3-strategy consensus = ⭐⭐⭐ High, 2-strategy = ⭐⭐ Medium-High, 1-strategy = ⭐ Medium.

### Innovation 5: Three-Layer Ontology with Cross-Layer Associations
Business Indicator Layer (5-level hierarchy) + Data Asset Layer (Schema→Topic→Table) + Term/Standard Layer, connected by 197,973 cross-layer relationships.

### Innovation 6: Fixed-Ratio Hybrid Retrieval with Field-Level Vectorization
Tables are vectorized by concatenating table description + all column names and descriptions. 50/50 split between keyword exact matching and vector semantic search.

### Innovation 7: Dual Retrieval Mechanism (Strategy 2)
Mandatory parallel execution of convergent path navigation (structural) AND hybrid search (semantic), with result fusion.

### Innovation 8: Progressive Degradation Search
When searching the 5-level indicator hierarchy, the system trades precision for recall at each level: INDICATOR (⭐⭐⭐⭐⭐) → THEME (⭐⭐⭐⭐) → SUBPATH (⭐⭐⭐) → CATEGORY (⭐⭐) → SECTOR (⭐).

### Innovation 9: Isolated Table Filtering via Lineage Heat Analysis
Tables with heat=0 AND upstream=0 are classified as "isolated" (deprecated). Filtering is deferred to adjudication phase for maximum evidence collection.

### Innovation 10: Lineage-Driven Related Table Discovery with Automatic JOIN
Uses pre-computed blood lineage relationships (UPSTREAM edges) to discover related tables and automatically identify JOIN conditions.

### Innovation 11: Pre-computed Indicator Field Mappings
The ETL pipeline pre-computes field mappings for INDICATOR nodes and stores them as node properties, eliminating runtime cross-system queries.

### Innovation 12: Cognitive Modular Architecture with Instruction-Following Optimization
Each strategy Skill is ~400 lines focused on a single cognitive task, achieving near-100% instruction compliance. Formalized as: Intelligence ≈ Modularity × Context Inheritance Efficiency × Task Focus.

### Innovation 13: Multi-Scenario Unified Ontology (Proposed Extension)
The same ontology serves Smart Query, Data Development, and Data Governance with flywheel effects between scenarios.

---

## Key Metrics

| Metric | Value |
|--------|-------|
| Total ontology nodes | 238,982 |
| Total relationships | 770,582 |
| Business Indicator nodes | 163,284 |
| Data Asset nodes | 35,379 |
| Term/Standard nodes | 40,319 |
| Cross-layer associations | 197,973 |
| Physical schemas | 9 |
| Table topics | 83 |
| Physical tables | 35,287 |
| MCP tools | 29+ |
| Cognitive strategies | 3 |
| ETL pipeline steps | 22 |
