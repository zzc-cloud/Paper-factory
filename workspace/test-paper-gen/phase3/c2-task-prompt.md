# C2 Visualization Designer Task Specification

## Agent Profile
You are C2 - Visualization Designer, an academic visualization designer specializing in computer science research papers.

## Project Context
- **Project Name**: test-paper-gen
- **Paper Title**: "Research on Intelligent CNC Fault Diagnosis System Integrating Large Language Models and Domain Knowledge Graphs"
- **Working Directory**: /Users/yyzz/Desktop/MyClaudeCode/paper-factory/workspace/test-paper-gen

## Your Task
Design all figures and tables for the paper based on the paper outline specifications.

### Figures to Design (9 total)

#### Figure 1: CNC Fault Diagnosis Challenges
- **Section**: 1.1
- **Type**: Problem illustration
- **Purpose**: Motivate problem by visualizing knowledge organization challenges
- **Content**: Show (a) fragmented knowledge sources (expert manuals, sensor data, maintenance logs), (b) knowledge gap between static frameworks and dynamic environments, (c) difficulty integrating tacit expert knowledge with real-time data

#### Figure 2: System Architecture Overview
- **Section**: 3.1
- **Type**: Architecture diagram
- **Purpose**: High-level view of complete system architecture
- **Content**: Four-layer architecture: (1) Perception Layer (bottom) - multi-modal data collection; (2) Knowledge Layer - CNC fault diagnosis KG with ontology; (3) Reasoning Layer - bidirectional LLM-KG integration; (4) Application Layer (top) - fault diagnosis, explanation, decision support services

#### Figure 3: Perception Layer Data Flow
- **Section**: 3.2
- **Type**: Flow diagram
- **Purpose**: Explain multi-modal data collection and processing
- **Content**: Three input streams: (1) Sensor data (time-series vibration, temperature, current); (2) Equipment logs (structured events, error codes); (3) Maintenance documents (unstructured text, PDFs). Each with preprocessing steps converging into unified representation.

#### Figure 4: CNC Fault Diagnosis Ontology
- **Section**: 3.3
- **Type**: Ontology diagram
- **Purpose**: Visualize structure of domain KG and key concept relationships
- **Content**: Three main modules: (1) Fault Type module - hierarchy of failure modes; (2) Diagnostic Method module - diagnostic procedures; (3) System Component module - CNC machine components. Key relationships: hasFault, diagnosedBy, affectsComponent, hasSymptom.

#### Figure 5: Bidirectional LLM-KG Reasoning Mechanism
- **Section**: 3.4
- **Type**: Architecture diagram
- **Purpose**: Explain core innovation of bidirectional reasoning
- **Content**: Left side: KG to LLM flow - subgraph retrieval, semantic matching, context construction, output validation. Right side: LLM to KG flow - knowledge extraction, entity/relation identification, ontology validation, KG updates. Center: feedback loop.

#### Figure 6: Application Layer Service Interfaces
- **Section**: 3.5
- **Type**: Component diagram
- **Purpose**: Show how end users interact with system
- **Content**: Three main services: (1) Fault Diagnosis Service - accepts NL/structured input, returns result with confidence; (2) Explanation Generator - traces reasoning path; (3) Decision Support - maintenance recommendations, part sourcing, scheduling.

#### Figure 7: Hybrid Reasoning Framework
- **Section**: 4.2
- **Type**: Architecture diagram
- **Purpose**: Illustrate symbolic and neural reasoning combination
- **Content**: Left side: Symbolic reasoning - OWL/DL classification, SWRL rules, SHACL validation. Right side: Neural reasoning - RotatE embeddings, R-GCN for fault propagation. Bottom: Task router directing queries. Center: Results aggregator.

#### Figure 8: Experimental Results Comparison
- **Section**: 5.2
- **Type**: Multi-panel bar chart
- **Purpose**: Present comprehensive comparison of system performance
- **Content**: Panel (a): Bar chart comparing accuracy, precision, recall, F1. Panel (b): Response time comparison. Panel (c): Hallucination rate (lower is better). Panel (d): Performance by fault category.

#### Figure 9: Ablation Study Results
- **Section**: 5.3
- **Type**: Heatmap
- **Purpose**: Visualize impact of each component on performance
- **Content**: Rows: A1-A4 ablations. Columns: affected metrics (Accuracy, Precision, Recall, Response Time, Hallucination Rate). Color gradient showing % change from full system. Highlight A2 (bidirectional reasoning) as causing largest drop.

### Tables to Design (6 total)

#### Table 1: Comparison of CNC Fault Diagnosis Approaches
- **Section**: 2.1
- **Columns**: Approach, Knowledge Representation, Explainability, Adaptability, Multi-Modal Support, LLM Integration
- **Rows**: Traditional rule-based, Deep learning, Knowledge-based, Our LLM-KG fusion

#### Table 2: System Comparison with Related Work
- **Section**: 2.4
- **Columns**: System, Uses LLM, Uses Domain KG, Bidirectional Reasoning, Natural Language Interface, Target Domain
- **Rows**: Our system, KG-based fault diagnosis, Deep learning diagnosis, LLM+KG QA

#### Table 3: Multi-Modal Data Sources and Preprocessing
- **Section**: 3.2
- **Columns**: Data Source, Format, Volume, Preprocessing Steps, Integration Method
- **Rows**: Sensor data, Equipment logs, Maintenance documents

#### Table 4: CNC Fault Diagnosis Ontology Statistics
- **Section**: 3.3
- **Columns**: Module, Concepts, Properties, Instances, Description
- **Rows**: Fault Type module, Diagnostic Method module, System Component module

#### Table 5: Experimental Setup
- **Section**: 5.1
- **Columns**: Component, Specification
- **Rows**: Dataset, Evaluation metrics, Baseline systems, Implementation environment

#### Table 6: Main Experimental Results
- **Section**: 5.2
- **Columns**: System, Accuracy, Precision, Recall, F1-Score, Response Time (ms), KG Reasoning Acc., Hallucination Rate
- **Rows**: Target system (full), B0 (rule-based), B1 (LLM-only), B2 (KG-only), B3 (unidirectional)

## Input Files
Read these files to gather design data:

1. **b3-paper-outline.json**: /Users/yyzz/Desktop/MyClaudeCode/paper-factory/workspace/test-paper-gen/phase2/b3-paper-outline.json
   - Contains detailed figure/table specifications

2. **b2-experiment-design.json**: /Users/yyzz/Desktop/MyClaudeCode/paper-factory/workspace/test-paper-gen/phase2/b2-experiment-design.json
   - Contains dataset spec (1000 instances), metrics (7 metrics), baselines (B0-B3), ablation studies (A1-A4)

3. **a4-innovations.json**: /Users/yyzz/Desktop/MyClaudeCode/paper-factory/workspace/test-paper-gen/phase1/a4-innovations.json
   - Contains 4 contribution themes, formal contributions

4. **skill-kg-theory.json**: /Users/yyzz/Desktop/MyClaudeCode/paper-factory/workspace/test-paper-gen/phase1/skill-kg-theory.json
   - Contains ontology details (ALCHIQ DL, 3 modules, TBox ~500 concepts), reasoning analysis

5. **b1-related-work.json**: /Users/yyzz/Desktop/MyClaudeCode/paper-factory/workspace/test-paper-gen/phase2/b1-related-work.json
   - Contains comparison data, strongest competitors

## Output Files

### File 1: All Figures
**Path**: /Users/yyzz/Desktop/MyClaudeCode/paper-factory/workspace/test-paper-gen/phase3/figures/all-figures.md

### File 2: All Tables
**Path**: /Users/yyzz/Desktop/MyClaudeCode/paper-factory/workspace/test-paper-gen/phase3/figures/all-tables.md

## Design Format Requirements

### For Each Figure:
```
---
Figure N: [Title]
Section: [section number]
Purpose: [what it communicates]
Key Components: [list of elements]
Layout: [horizontal/vertical/grid/flow]
Color Suggestions: [if applicable]
Annotations: [callouts, labels, arrows]
---

#### Detailed Description
[3-8 sentences prose description]

#### ASCII Art Representation
[Box-drawing characters diagram]
```

### For Each Table:
```
---
Table N: [Title]
Section: [section number]
Purpose: [what it communicates]
Data Source: [which input file]
---

#### Table Content
| Column 1 | Column 2 | ... |
|-----------|-----------|-----|
| Data      | Data      | ... |

#### Caption
[1-3 sentences explaining what the table shows]

#### Footnotes
[Any necessary notes]
```

## Important Constraints
- Do NOT invent experimental data - use data from b2-experiment-design.json
- If data is unavailable, use "[TBD]" with explanatory note
- Use consistent terminology across all figures/tables (e.g., "Knowledge Layer" not "Knowledge Graph" in Fig2, then "Ontology Layer" in Fig3)
- Design for black-and-white printing - use patterns and labels, not just colors
- Make figures progressive: high-level (Fig1) -> detailed (Figs 2-6) -> analytical (Figs 7-9)

## Execution Steps
1. Read all input files
2. Create inventory checklist of all 9 figures and 6 tables
3. Design each figure with specification, description, and ASCII art
4. Design each table with specification, complete data, caption, footnotes
5. Verify cross-reference consistency
6. Write both output files

## Begin Execution
Start by reading all input files, then proceed with the design.
