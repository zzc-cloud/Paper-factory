# All Figures for Smart Query Paper

This document contains detailed specifications, textual descriptions, and ASCII art representations for all 9 figures in the paper "Cognitive Hub: A Multi-Agent Architecture for Ontology-Driven Natural Language Data Querying at Enterprise Scale".

---

## Figure 1: Enterprise Data Querying Challenge

---
**Figure Number:** 1
**Section:** 1.1 (Introduction - Motivation and Problem Statement)
**Purpose:** Illustrate the needle-in-haystack problem of finding the correct table(s) among 35,287 tables in an enterprise data warehouse
**Key Components:** User query (Chinese NL), vast table landscape visualization, target tables highlighted, scale statistics
**Layout:** Left-right split: query on left, table landscape on right with magnified target area
**Color Suggestions:** Muted gray for table landscape, bright accent (orange/red) for target tables, blue for query
**Annotations:** Statistics overlay, scale comparison with Spider benchmark
---

### Detailed Description

Figure 1 presents the fundamental challenge that motivates Smart Query. On the left side, a user's natural language query in Chinese (e.g., "查询各分行中小企业贷款余额" - "Query each branch's SME loan balance") represents the input. On the right side, a hierarchical treemap or scatter field visualization depicts the vast landscape of 35,287 tables distributed across 9 schemas and 83 topics. The visualization uses muted colors to represent the overwhelming scale of the data environment. A magnifying glass or spotlight effect highlights 1-3 correct target tables among the thousands, visually emphasizing the needle-in-haystack problem. Key statistics are overlaid: 9 schemas, 83 topics, 35,287 tables, 163,284 indicators, 39,558 terms. A scale comparison inset contrasts Spider benchmark (200 databases, average <10 tables each) with Smart Query's enterprise environment (1 database, 35,287 tables), demonstrating that this problem is orders of magnitude beyond existing NL2SQL benchmarks.

### ASCII Art Representation

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

---

## Figure 2: Cognitive Hub Architecture Overview

---
**Figure Number:** 2
**Section:** 3.1 (System Architecture - Overview)
**Purpose:** Show the complete system architecture with ontology as cognitive hub, three strategy skills, MCP tools, and information flow
**Key Components:** Three-layer ontology (core), MCP Tool Layer (29 tools), Three Strategy Skills, Evidence Pack Fusion, Adjudication
**Layout:** Layered architecture diagram, center-outward or top-to-bottom
**Color Suggestions:** Three distinct colors for ontology layers (blue/green/purple), orange for skills, gray for tools
**Annotations:** Node/edge counts, formula "Ontology + Skills = Cognitive Hub", data flow arrows
---

### Detailed Description

Figure 2 presents the complete Cognitive Hub architecture. At the center is the three-layer ontology stored in Neo4j: (1) Indicator Layer with 163,284 nodes in a 5-level hierarchy (SECTOR→CATEGORY→THEME→SUBPATH→INDICATOR), (2) Data Asset Layer with 35,379 nodes in a 3-level hierarchy (SCHEMA→TABLE_TOPIC→TABLE) plus 50,509 UPSTREAM lineage edges, and (3) Term/Standard Layer with 40,319 nodes (39,558 terms + 761 data standards). Surrounding the ontology is the MCP Tool Layer with 29 tools across two servers providing navigation capabilities. The outer layer shows three strategy Skills executing serially: Strategy 1 (Indicator Expert), Strategy 2 (Scenario Navigator), Strategy 3 (Term Analyst). Arrows show serial execution flow (1→2→3) with implicit context inheritance (dashed arrows from conversation history). All three evidence packs converge into Comprehensive Adjudication, which performs cross-validation and produces the final evidence pack with primary table, related tables, and JOIN conditions. The formula "Ontology (declarative memory) + Skills (procedural memory) = Cognitive Hub" is prominently displayed.

### ASCII Art Representation

```
