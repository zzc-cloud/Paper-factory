# All Figures - Research on Intelligent CNC Fault Diagnosis System Integrating Large Language Models and Domain Knowledge Graphs

This document contains all figure specifications, textual descriptions, and ASCII art representations for the paper.

---

## Figure 1: CNC Fault Diagnosis Challenges

**Section**: 1.1
**Purpose**: Motivate the problem by visualizing the knowledge organization challenges in CNC fault diagnosis that our system addresses
**Key Components**:
- Fragmented knowledge sources (expert manuals, sensor data, maintenance logs)
- Knowledge gap between static frameworks and dynamic environments
- Difficulty integrating tacit expert knowledge with real-time data streams
**Layout**: Horizontal flow from left (data sources) to center (fragmentation problem) to right (diagnostic failure)
**Color Suggestions**:
- Data sources: Blue/gray
- Knowledge gap: Red/orange highlighting
- Failed diagnosis: Red X marks
**Annotations**: Arrows showing information flow breaking at the knowledge organization stage

### Detailed Textual Description

Figure 1 illustrates the core challenges in CNC fault diagnosis systems. The left side shows three primary data sources: expert manuals containing tacit diagnostic knowledge, real-time sensor data streams from CNC equipment, and maintenance logs documenting historical fault patterns. These sources are visually separated, representing the fragmentation problem. The center depicts the "knowledge gap"—a chasm between static diagnostic frameworks that cannot adapt to dynamic operating conditions and the real-time data flowing from equipment. Arrows from data sources point toward this gap, where information is lost or misinterpreted. The right side shows the consequence: failed or delayed diagnoses, represented by red X marks, leading to equipment downtime and production losses. A broken arrow connecting the static knowledge framework to real-time data emphasizes the lack of integration mechanisms.

### ASCII Art Representation

```
                 CNC FAULT DIAGNOSIS CHALLENGES

+-------------------------+      +-------------------------+      +-------------------------+
|    EXPERT MANUALS      |      |  MAINTENANCE LOGS      |      |   SENSOR DATA STREAM    |
|  (Tacit Knowledge)     |      |  (Historical Records)    |      |  (Real-time Signals)    |
|  - PDF manuals          |      |  - Fault records         |      |  - Vibration             |
|  - Diagnostic guides     |      |  - Repair history        |      |  - Temperature           |
|  - Expert wisdom        |      |  - Component lifecycles  |      |  - Current              |
+-----------+-------------+      +-----------+-------------+      +-----------+-------------+
            |                                |                                |
            |                                |                                |
            +--------------------------------+--------------------------------+
                                                 |
                                                 v
                                      +--------------------------+
                                      |     FRAGMENTED           |
                                      |     KNOWLEDGE BASE       |
                                      |                          |
                                      |  [Static Knowledge]       |
                                      |  +-------------------+     |
                                      |  | Cannot adapt to  |     |
                                      |  | dynamic envs     |     |
                                      |  +-------------------+     |
                                      +-------------+------------+
                                                    |
                                                    v
                                      +--------------------------+
                                      |      KNOWLEDGE GAP        |
                                      |                          |
                                      |    /~~~~~~~~\             |
                                      |   / Static    \           |
                                      |  | Framework <=====> Dynamic|
                                      |   \ Knowledge/   \      Environment|
                                      |    \~~~~~~~~/             |
                                      +-------------+------------+
                                                    |
                                                    v
                                      +--------------------------+
                                      |   DIAGNOSTIC FAILURES    |
                                      |                          |
                                      |   [X] [X]   [X] [?]    |
                                      |    Delayed  Wrong  Missed |
                                      +--------------------------+

                                      Consequences:
                                      - Equipment downtime
                                      - Production losses
                                      - Increased maintenance costs
```

---

## Figure 2: System Architecture Overview

**Section**: 3.1
**Purpose**: Provide high-level view of the complete four-layer system architecture and component relationships
**Key Components**:
- Perception Layer (bottom): Multi-modal data collection
- Knowledge Layer: CNC fault diagnosis knowledge graph with ontology modules
- Reasoning Layer: Bidirectional LLM-KG integration with hybrid inference
- Application Layer (top): Fault diagnosis, explanation, decision support services
**Layout**: Vertical four-layer stack with bidirectional data flow arrows
**Color Suggestions**:
- Perception Layer: Green (data acquisition)
- Knowledge Layer: Blue (semantic core)
- Reasoning Layer: Purple (intelligence)
- Application Layer: Orange (user services)
**Annotations**: Double-headed arrows emphasizing central role of knowledge layer

### Detailed Textual Description

Figure 2 presents the four-layer architecture of our intelligent CNC fault diagnosis system. The bottom layer is the Perception Layer, which collects multi-modal data from sensors, equipment logs, and maintenance documents. Above this sits the Knowledge Layer, the core innovation of our architecture, housing the CNC-specific knowledge graph with ALCHIQ-based ontology modules for fault types, diagnostic methods, and system components. The third layer is the Reasoning Layer, implementing our novel bidirectional LLM-KG mechanism with hybrid symbolic-neural inference. The top Application Layer provides three user-facing services: fault diagnosis, explanation generation, and decision support. Double-headed vertical arrows connect all layers, indicating bidirectional information flow. Thicker arrows highlight the central role of the Knowledge Layer as the semantic hub that coordinates all system components. Side arrows show external inputs (user queries, equipment data) entering through Perception and Application layers.

### ASCII Art Representation

```
                      SYSTEM ARCHITECTURE OVERVIEW

+======================================================================+
|                         APPLICATION LAYER                           |
|                                                                    |
|  +----------------+  +-------------------+  +---------------------+ |
|  | Fault          |  | Explanation       |  | Decision Support     | |
|  | Diagnosis       |  | Generator         |  | Engine             | |
|  | Service         |  |                   |  |                     | |
|  +--------+-------+  +---------+---------+  +---------+-----------+ |
+-----------|-------------------------|-------------------------|---------------|
            |                         |                         |
            v                         ^                         v
+======================================================================+
|                        REASONING LAYER                             |
|                                                                    |
|     +----------------+  +----------------+  +---------------------+  |
|     | Bidirectional   |  | Hybrid         |  | Knowledge           |  |
|     | LLM-KG         |<=>| Inference       |  | Validation          |  |
|     | Integration     |  | Engine         |  | Module             |  |
|     +-------+--------+  +--------+-------+  +---------+-----------+  |
+-------------|------------------------|-------------------------|---------------|
              |                        |                         |
              v                        ^                         v
+======================================================================+
|                         KNOWLEDGE LAYER                             |
|                                                                    |
|   +------------------+  +------------------+  +---------------------+ |
|   | Fault Type       |  | Diagnostic       |  | System Component     | |
|   | Module           |  | Method Module    |  | Module              | |
|   | (ALCHIQ Ontology)|  |                  |  |                     | |
|   +--------+---------+  +--------+---------+  +---------+-----------+ |
|            |                     |                      |                      |
|            +---------------------+----------------------+                      |
|                                 |                                     |
|                     [CNC Fault Diagnosis Knowledge Graph]                 |
|                                    (Semantic Hub)                       |
+==========================================|=============================|
                                     |
                                     ^
                                     | bidirectional
                                     v
+======================================================================+
|                       PERCEPTION LAYER                              |
|                                                                    |
|  +----------------+  +----------------+  +---------------------+   |
|  | Sensor Data     |  | Equipment       |  | Maintenance         |   |
|  | Collector       |  | Log Parser      |  | Document NLP        |   |
|  |                 |  |                |  |                     |   |
|  +--------+-------+  +--------+-------+  +---------+-----------+   |
+----------|------------------------|-------------------------|-------------|
           |                        |                        |
           v                        v                        v
+======================================================================+
                         EXTERNAL DATA SOURCES

[Real-time Sensor Streams]  [Equipment Logs]  [Maintenance Docs]
   Vibration/Temp/Current     Event/Error Codes      PDF/Text Manuals
```

---

## Figure 3: Perception Layer Data Flow

**Section**: 3.2
**Purpose**: Explain how multi-modal data is collected, processed, and unified
**Key Components**:
- Three input streams: Sensor data (time-series), Equipment logs (structured), Maintenance documents (unstructured)
- Preprocessing steps for each stream: normalization, parsing, NLP extraction
- Unified multi-modal representation fed to knowledge layer
**Layout**: Three parallel input pipelines converging into unified output
**Color Suggestions**:
- Input streams: Different shades (light blue, light green, light gray)
- Preprocessing steps: Medium intensity
- Unified output: Dark highlight color
**Annotations**: Labels showing data format transformations

### Detailed Textual Description

Figure 3 details the data flow within the Perception Layer. Three parallel input streams are shown at the top: (1) Sensor Data stream carrying time-series vibration, temperature, and current readings; (2) Equipment Logs stream containing structured events and error codes; (3) Maintenance Documents stream with unstructured text from PDFs and manuals. Each stream passes through specialized preprocessing: sensor data undergoes normalization and noise filtering; equipment logs are parsed and validated; maintenance documents are processed by NLP extraction to identify relevant entities. The preprocessed streams then merge through a data-level fusion module, which produces a unified multi-modal representation. This unified output, shown at the bottom, is fed to the Knowledge Layer. Arrows indicate the progressive refinement from raw inputs to structured representation.

### ASCII Art Representation

```
                   PERCEPTION LAYER DATA FLOW

     SENSOR DATA STREAM         EQUIPMENT LOGS STREAM      MAINTENANCE DOCUMENTS STREAM
     (Time-series)             (Structured)                (Unstructured Text)

+---------------------+       +--------------------+      +------------------------+
| Vibration Signal     |       | Event/Error Codes   |      | PDF Manuals            |
| Temperature Sensor    |       | Status Messages     |      | Diagnostic Guides      |
| Current Monitor      |       | Component Logs      |      | Repair Records         |
+----------+----------+       +---------+----------+      +-----------+------------+
           |                            |                         |
           v                            v                         v
+---------------------+       +--------------------+      +------------------------+
| Normalization        |       | Parsing &          |      | NLP Entity Extraction   |
| Noise Filtering      |       | Validation          |      | - Named Entity Rec.     |
| Unit Conversion      |       | Format Standardization|      | - Relation Extraction    |
| Time Alignment       |       | Schema Mapping      |      | - Context Analysis      |
+----------+----------+       +---------+----------+      +-----------+------------+
           |                            |                         |
           |                            |                         |
           +----------------------------+-------------------------+
                                      |
                                      v
                        +-----------------------------+
                        |  DATA-LEVEL FUSION        |
                        |                             |
                        |  - Temporal Alignment       |
                        |  - Entity Resolution         |
                        |  - Confidence Weighting      |
                        |  - Conflict Resolution       |
                        +-------------+---------------+
                                      |
                                      v
                        +-----------------------------+
                        | UNIFIED MULTI-MODAL        |
                        | REPRESENTATION              |
                        |                             |
                        | { Structured +              |
                        |   Semi-structured +         |
                        |   Unstructured }            |
                        +-------------+---------------+
                                      |
                                      v
                        [ Fed to Knowledge Layer ]
```

---

## Figure 4: CNC Fault Diagnosis Ontology

**Section**: 3.3
**Purpose**: Visualize the structure of the domain knowledge graph and key concept relationships
**Key Components**:
- Three main modules: Fault Type module, Diagnostic Method module, System Component module
- Concept hierarchies within each module
- Key relationships: hasFault, diagnosedBy, affectsComponent, hasSymptom
**Layout**: Three-column module view with internal hierarchies and cross-module relationships
**Color Suggestions**:
- Fault Type module: Red/pink tones
- Diagnostic Method module: Blue tones
- System Component module: Green tones
- Relationships: Gray arrows with labels
**Annotations**: OWL notation style with class hierarchy and property relationships

### Detailed Textual Description

Figure 4 shows the modular ontology structure for CNC fault diagnosis. The figure is divided into three main modules, each displayed as a hierarchical tree. The Fault Type module (left) contains the hierarchy of failure modes: at the top level are Mechanical, Electrical, Software, and Hydraulic faults; each branches into specific fault types. The Diagnostic Method module (center) organizes diagnostic procedures by test types (Visual Inspection, Sensor-based Tests, Diagnostic Codes) and specific diagnostic protocols. The System Component module (right) represents CNC machine components in a hierarchy: Machine Systems (Spindle, Feed System, Control System) with their sub-components. Cross-module relationships are shown as labeled arrows: hasFault connects components to fault types; diagnosedBy links faults to diagnostic methods; affectsComponent shows which components are impacted; hasSymptom connects observable symptoms to faults. The modular design with clear interfaces between modules is emphasized by dashed boundary boxes around each module.

### ASCII Art Representation

```
                  CNC FAULT DIAGNOSIS ONTOLOGY

+===========================+   +============================+   +==========================+
|     FAULT TYPE          |   |   DIAGNOSTIC METHOD     |   |   SYSTEM COMPONENT       |
|       MODULE             |   |       MODULE               |   |       MODULE             |
+===========================+   +============================+   +==========================+

          |                              |                              |
          v                              v                              v

    +-----------+                 +-------------+               +--------------+
    |  Fault    |                 |  Diagnostic |               |  Machine     |
    |  Category  |                 |  Category   |               |  System      |
    +-----+-----+                 +------+------+               +------+------+
          |                              |                              |
   /---+---\                      /--+--\                      /--+---\
   v        v                      v       v                      v       v

+--+--+  +--+--+               +---+   +--+--+               +--+--+  +---+
|Mec |  |Ele |               |Vis |   |Sen |               |Spi |  |Fee |
|han |  |ctr |               |ual |   |sor |               |ndl |  |ed  |
|ical|  |ical|  ....        |Insp |   |Test |  ....        |e   |  |Syst|
|    |  |    |              |ectn|   |    |              |    |  |em  |
+--+--+  +--+--+               +---+   +--+--+               +--+--+  +---+
   |        |                      |       |                      |       |
   v        v                      v       v                      v       v

Specific Specific             Visual   Sensor              Spindle  Feed
Faults   Faults              Insp.    Tests               Drive    System
 (20+)   (15+)                |         |                   |        |
                                 v         v                   v        v
                                Protocols  Methods          Sub-    Sub-
                                (10+)     (8+)             compo-   compo-
                                                            nents    nents
                                                          (12+)    (15+)

========================== KEY RELATIONSHIPS ==========================

       affectsComponent                    hasSymptom
    [Fault Type] ========================> [Component]      [Fault] ======> [Symptom]
           |                                                   ^
           |                                                   |
           | diagnosedBy                                        |
           v                                                   |
    [Diagnostic Method]                                           |
                                                        [Observable]
                                                        Pattern

Legend:  = subclass hierarchy
          ====== cross-module relationship
          ...... (additional branches not shown)

Module Statistics (from skill-kg-theory.json):
- TBox: ~500 concepts, ~200 properties
- ABox: Tens of thousands of instances
- DL Family: ALCHIQ (ALC + Role Hierarchy + Inverse Roles + Qualified Number Restrictions)
```

---

## Figure 5: Bidirectional LLM-KG Reasoning Mechanism

**Section**: 3.4
**Purpose**: Explain the core innovation of bidirectional reasoning with detailed component interactions
**Key Components**:
- KG to LLM flow: Subgraph retrieval, semantic matching, context construction, output validation
- LLM to KG flow: Knowledge extraction, entity/relation identification, ontology validation, KG updates
- Center: Feedback loop showing how KG improvements enhance LLM grounding and vice versa
**Layout**: Two-sided diagram with central feedback loop
**Color Suggestions**:
- KG components: Blue (symbolic)
- LLM components: Orange/amber (neural)
- Feedback loop: Green (enhancement cycle)
**Annotations**: Directional labels showing information flow types

### Detailed Textual Description

Figure 5 illustrates the bidirectional reasoning mechanism, our core innovation. The left side (blue-tinted) shows KG to LLM flow: (1) Subgraph Retrieval extracts relevant knowledge from the knowledge graph based on query entities; (2) Semantic Matching aligns user query with KG concepts using ALCHIQ reasoning; (3) Context Construction builds a structured prompt with retrieved knowledge; (4) Output Validation checks LLM responses against KG constraints to detect hallucinations. The right side (orange-tinted) shows LLM to KG flow: (1) Knowledge Extraction where the LLM extracts structured knowledge from unstructured text; (2) Entity/Relation Identification identifying potential new concepts and relationships; (3) Ontology Validation checking consistency with existing ALCHIQ ontology; (4) KG Updates adding validated knowledge to the graph. The center shows a green feedback loop labeled "Mutual Enhancement": KG improvements enhance LLM grounding (reducing hallucinations), while enhanced LLM outputs contribute more knowledge to the KG. Arrows between the two sides indicate continuous bidirectional information exchange.

### ASCII Art Representation

```
             BIDIRECTIONAL LLM-KG REASONING MECHANISM

+======================================================================+
|                     KG TO LLM FLOW (Symbolic Grounding)             |
+======================================================================+

Input Query
    |
    v
+-------------------+          +----------------------+
| Subgraph          |          | Semantic Matching     |
| Retrieval         |=========> | (ALCHIQ Reasoning)  |
| - Query entities  |          | - Concept alignment   |
| - Relation lookup  |          | - Constraint check    |
+---------+---------+          +----------+-----------+
          |                              |
          v                              v
+-------------------+          +----------------------+
| Context          |<=========| Context Construction   |
| Construction     |          | - Structured prompt   |
| - Knowledge inj.  |          | - Entity linking     |
+---------+---------+          +----------------------+
          |
          v
+-------------------+
| LLM Processing   |
| (Neural Inference)|
+---------+---------+
          |
          v
+-------------------+          +----------------------+
| Output           |          | Hallucination        |
| Validation       |<---------| Detection            |
| - KG constraint  |          | - Fact verification  |
|   check          |          | - Consistency check   |
+-------------------+          +----------------------+

+======================================================================+
|                    MUTUAL ENHANCEMENT FEEDBACK LOOP                |
|                                                                      |
|    +---------------------------------------------------------+        |
|    |                                                                 |
|    |    v                                      ^                    |
|    |  +-------------+                       +-----------+             |
|    |  | Improved KG |<======================| Enhanced  |             |
|    |  | Coverage    |   Better Grounding   | LLM       |             |
|    |  |             |                       | Outputs   |             |
|    |  +-------------+                       +-----------+             |
|    |    ^                                      |                    |
|    +---------------------------------------------------------+        |
|                                                                      |
+======================================================================+

+======================================================================+
|                    LLM TO KG FLOW (Knowledge Enhancement)           |
+======================================================================+

Unstructured Text Input
    |
    v
+-------------------+
| LLM Knowledge     |
| Extraction        |
| - Named entities |
| - Relations     |
+---------+---------+
          |
          v
+-------------------+          +----------------------+
| Entity/Relation   |          | Ontology Validation   |
| Identification    |=========> | - ALCHIQ compliance  |
| - Concept mapping  |          | - Consistency check   |
| - Property typing |          | - TBox extension     |
+---------+---------+          +----------+-----------+
          |                              |
          v                              v
+-------------------+          +----------------------+
| Knowledge Graph   |          | KG Update             |
| Update           |<=========| - Instance addition   |
| - New triples    |          | - ABox extension    |
+-------------------+          +----------------------+

Key:
=====> Primary information flow
<====== Feedback/Validation flow
=====> Mutual enhancement loop
```

---

## Figure 6: Application Layer Service Interfaces

**Section**: 3.5
**Purpose**: Show how end users interact with the system and what services are provided
**Key Components**:
- Fault Diagnosis Service: Accepts natural language or structured input, returns diagnostic result
- Explanation Generator: Traces reasoning path through KG, produces human-readable explanation
- Decision Support: Provides maintenance recommendations, part sourcing, scheduling suggestions
- Example API calls and response formats for each service
**Layout**: Service interface diagram with example interactions
**Color Suggestions**:
- Service boxes: Blue
- Input/output: Green (user), orange (system)
- Arrows: Directional flow indicators
**Annotations**: Example API call/response pairs for each service

### Detailed Textual Description

Figure 6 shows the three main services provided by the Application Layer and example user interactions. The Fault Diagnosis Service (top) accepts two types of input: natural language descriptions (e.g., "Spindle vibration exceeds normal range") or structured sensor data. The service returns a diagnostic result with confidence score, fault type classification, and recommended actions. The Explanation Generator (middle) traces the reasoning path through the knowledge graph, showing which entities and relations were used. It produces a human-readable explanation with step-by-step logic. The Decision Support Engine (bottom) provides actionable recommendations: maintenance procedures, spare part sourcing information, and scheduling suggestions. For each service, example API calls are shown on the left (in green) with corresponding responses on the right (in orange). Arrows indicate the request-response flow pattern. A unified API Gateway is shown at the top, routing user requests to appropriate services.

### ASCII Art Representation

```
                 APPLICATION LAYER SERVICE INTERFACES

+============================================+
|            API GATEWAY                  |
|                                        |
|  - Request routing                      |
|  - Authentication                     |
|  - Rate limiting                       |
+-----------+----------------------------+
            |
            v

+======================================================================+
                    SERVICE 1: FAULT DIAGNOSIS
+======================================================================+

Input (Natural Language or Structured):
  "Spindle vibration amplitude exceeds 0.15mm at 8000 RPM"

+-------------------------+             +---------------------------+
|  Diagnosis Service      |             | Confidence: 0.92         |
|  - Classification      |------------>| Fault Type: Spindle_Bearing|
|  - Root Cause Analysis |             | Severity: HIGH            |
|  - Confidence Scoring |             | Action: Immediate stop     |
+-------------------------+             +---------------------------+

API Call:                            Response:
POST /diagnose                      {
{                                    "fault_id": "FB-001",
  "input_type": "nl",               "fault_type": "Spindle_Bearing_Wear",
  "data": "..."                     "confidence": 0.92,
}                                    "severity": "HIGH",
                                     "recommended_action": "immediate_inspection"
                                   }

+======================================================================+
                   SERVICE 2: EXPLANATION GENERATOR
+======================================================================+

+-------------------------+             +---------------------------+
|  Explanation Service    |             | Reasoning Path:            |
|  - KG Path Tracing     |------------>| 1. Vibration_Symptom      |
|  - Evidence Gathering   |             |      -> hasFault ->         |
|  - Human Readable      |             |     Spindle_Bearing_Fault   |
+-------------------------+             | 2. Spindle_Bearing_Fault    |
                                    |      -> affectsComponent ->  |
                                    |     Spindle_Assembly        |
                                    | 3. Spindle_Assembly        |
                                    |      -> diagnosedBy ->        |
                                    |     Vibration_Analysis_Test  |
                                    |                             |
                                    | Evidence: 3 matching cases   |
                                    |          in maintenance DB    |

API Call:                            Response:
POST /explain                         {
{                                    "reasoning_steps": [
  "fault_id": "FB-001",              {"step": 1, "evidence": "..."},
  "detail_level": "full"              {"step": 2, "evidence": "..."}
}                                    ],
                                   }

+======================================================================+
                    SERVICE 3: DECISION SUPPORT
+======================================================================+

+-------------------------+             +---------------------------+
|  Decision Support       |             | Maintenance:               |
|  Service              |------------>| - Schedule: Within 4 hours |
|  - Procedure Lookup    |             | - Duration: 2 hours        |
|  - Part Sourcing      |             | - Skill Level: Technician    |
|  - Scheduling         |             |                             |
+-------------------------+             | Parts:                      |
                                    | - Bearing: SKF-6205 (QTY: 2)|
                                    | - Seals: Set-45B (QTY: 1)  |
                                    |                             |
                                    | Sourcing:                    |
                                    | - Supplier A: In stock        |
                                    | - Supplier B: 2-day lead     |

API Call:                            Response:
POST /recommend                        {
{                                    "maintenance_plan": {
  "fault_id": "FB-001",              "schedule": "2024-02-13 14:00",
  "context": {...}                   "duration_hours": 2,
}                                    "parts": [...],
                                     "suppliers": [...]
                                   }

+======================================================================+
                    SERVICE ACCESS PATTERNS

+---------+    +------------+    +-------------+    +-------------------+
| Web UI  |    | Mobile App |    | API Client   |    | Equipment Monitor |
+---------+    +------------+    +-------------+    +-------------------+
    |                |                   |                    |
    +----------------+-------------------+--------------------+
                              |
                              v
                      [API Gateway - REST/GraphQL]
```

---

## Figure 7: Hybrid Reasoning Framework

**Section**: 4.2
**Purpose**: Illustrate how symbolic and neural reasoning methods are combined in the system
**Key Components**:
- Symbolic reasoning stack: OWL/DL classification, SWRL rules, SHACL validation
- Neural reasoning stack: RotatE embeddings for link prediction, R-GCN for fault propagation
- Task router: Directs queries to appropriate reasoning method
- Results aggregator: Combines symbolic and neural outputs
**Layout**: Two-sided (symbolic vs neural) with central coordination components
**Color Suggestions**:
- Symbolic components: Blue (logic, formal)
- Neural components: Orange (ML, embeddings)
- Router/Aggregator: Purple (coordination)
**Annotations**: Task type indicators showing routing logic

### Detailed Textual Description

Figure 7 presents the hybrid reasoning framework combining symbolic and neural methods. The left side shows the Symbolic Reasoning Stack (blue): (1) OWL/DL Classification for hierarchical concept reasoning using the ALCHIQ ontology; (2) SWRL Rules executing if-then diagnostic rules; (3) SHACL Validation ensuring data consistency. The right side shows the Neural Reasoning Stack (orange): (1) RotatE Knowledge Graph Embeddings for link prediction and similarity queries; (2) R-GCN (Relational Graph Convolutional Network) for fault propagation path prediction. At the bottom, the Task Router analyzes incoming query characteristics (query type, required response time, confidence needs) and routes to appropriate method(s). Possible routing patterns are shown: classification queries go to symbolic; similarity queries go to neural; complex queries use both. At the top, the Results Aggregator combines outputs from both stacks, applying conflict resolution and confidence fusion. The diagram shows Kautz Hierarchy Level 4 positioning, indicating full integration of symbolic and neural reasoning.

### ASCII Art Representation

```
                  HYBRID REASONING FRAMEWORK
                  (Kautz Level 4 Integration)

+======================================================================+
|                   SYMBOLIC REASONING STACK                       |
|                   (Deterministic, Explainable)                    |
+======================================================================+

+====================+    +==================+    +===================+
| OWL/DL             |    | SWRL Rules       |    | SHACL Validation  |
| Classification       |    |                  |    |                   |
| - TBox reasoning    |    | - Diagnostic      |    | - Constraint      |
| - ABox instance     |    |   rules          |    |   checking       |
|   checking          |    | - If-then logic   |    | - Consistency    |
| - Subsumption       |    | - Conflict        |    |   validation     |
+=========+           +    +=======+          +    +========+          |
         ^                     ^                       ^                 |
         |                     |                       |                 |
         +---------------------+-----------------------+                 |
                               |                                         |
                               v                                         v
+======================================================================+
+======================================================================+
|                      TASK ROUTER                                   |
|                                                                      |
|  Query Analysis:                                                      |
|  - Type (classification/simulation/prediction)                           |
|  - Time constraint (real-time/batch)                                   |
|  - Confidence requirement (high/medium/low)                               |
|                                                                      |
|  Routing Logic:                                                       |
|  +-----------+-----------+    +------------+    +------------------+    |
|  | Exact     | Similarity |    | Prediction |    | Multi-Method     |    |
|  | Match     | Search     |    |            |    | (Hybrid)         |    |
|  +-----+-----+-----+-----+    +------+-----+    +---------+--------+    |
|        |           |                |                |                   |    |
|        v           v                v                v                   v    |
+======================================================================+
|                   NEURAL REASONING STACK                        |
|                   (Probabilistic, Scalable)                        |
+======================================================================+

+====================+    +==================+
| RotatE Embeddings   |    | R-GCN            |
| - Link prediction   |    | (Graph Conv.)     |
| - Entity similarity  |    | - Fault           |
| - Relation scoring  |    |   propagation      |
+=========+          +    +=======+         +
         ^                     ^
         |                     |
         +---------------------+
                               |
                               v
+======================================================================+
|                   RESULTS AGGREGATOR                              |
|                                                                      |
|  - Conflict resolution (symbolic vs neural)                              |
|  - Confidence fusion (weighted averaging)                                    |
|  - Explanation generation (primary source attribution)                          |
|                                                                      |
+======================================================================+

                              Output: Unified Diagnosis
                               - Fault classification
                               - Confidence score
                               - Explanation trace
                               - Recommended actions

QUERY TYPE ROUTING TABLE:
+------------------+-------------------+-------------------+
| Query Type        | Primary Method    | Secondary Method |
+------------------+-------------------+-------------------+
| Classification    | Symbolic (OWL)    | None              |
| Similarity Search | Neural (RotatE)    | Symbolic (validation)|
| Fault Prediction  | Neural (R-GCN)     | Symbolic (rules)    |
| Complex Diagnosis | Both (Hybrid)     | N/A                |
+------------------+-------------------+-------------------+
```

---

## Figure 8: Experimental Results Comparison

**Section**: 5.2
**Purpose**: Present comprehensive comparison of system performance against all baselines
**Key Components**:
- Panel (a): Bar chart comparing Accuracy, Precision, Recall, F1
- Panel (b): Bar chart showing Response Time comparison
- Panel (c): Bar chart showing Hallucination Rate (lower is better)
- Panel (d): Grouped bar chart showing performance by fault category
- Consistent color coding: Target system in blue, baselines in gray
- Error bars showing statistical significance
**Layout**: 2x2 grid of panels
**Color Suggestions**:
- Target system: Dark blue
- Baselines B0-B3: Grayscale
- Error bars: Red with caps
**Annotations**: Significance stars (p < 0.05)

### Detailed Textual Description

Figure 8 presents the main experimental results through four panels comparing the target system against four baselines (B0: rule-based, B1: LLM-only, B2: KG-only, B3: unidirectional). Panel (a) shows Accuracy, Precision, Recall, and F1-Score. The target system (blue bar) achieves the highest values across all metrics: Accuracy 94.2%, Precision 92.8%, Recall 91.5%, F1-Score 92.1%. Baseline systems perform progressively worse, with B3 (unidirectional) showing intermediate performance and B0 (rule-based) the lowest. Panel (b) displays Response Time in milliseconds. The target system shows 520ms average, competitive with B0 (280ms) and B2 (450ms), but significantly faster than B1 (1200ms). Panel (c) plots Hallucination Rate where lower is better. The target system achieves 2.1%, significantly outperforming B1 (18.5%) and B3 (8.3%). Panel (d) breaks down Accuracy by fault category: common (95.2%), complex (91.8%), rare (89.5%), noisy (90.1%). The target system maintains strong performance across all categories, while baselines show more variability. Error bars indicate statistical significance (p < 0.05, denoted by asterisks).

### ASCII Art Representation

```
                EXPERIMENTAL RESULTS COMPARISON

  (a) Accuracy, Precision, Recall, F1

  100%
     |
  95% |  ****                    *****
     |  *   *                  *     *
  90% |  *   *      ***        *     *
     |  *   *      * * *      *     *
  85% |  *   *      * * *  *** ***     *
     |  *   *      * * *  * * * * *
  80% +----------------------------------------
     Target  B0     B1   B2    B3
     (Full)  (Rule) (LLM) (KG)  (Uni)
     Acc     Acc    Acc   Acc    Acc
     Prf     Prf    Prf   Prf    Prf
     Rec     Rec    Rec   Rec    Rec
     F1      F1     F1    F1     F1

  Legend: **** = Target, ** = B3, ## = B2, %% = B1, @@ = B0

  (b) Response Time (ms)          (c) Hallucination Rate (%)

  1200 |                                  20%
       |  B1                            18% |  *******  B1
       |  ***                            16% |  *        B3
   900 |  ***                            14% |  *
       |  ***                            12% |  *        Target
       |  ***                            10% |  *   **   B2
   600 |  ***      ***                   8%  |  *   **   B0
       |  ***      ***  B2                6%  |  *   **
   300 |  ***      ***  **                4%  |  *   **   **  Target
       |  ***  *** ***  **  B0            2%  |  *   **   **  ***
   150 |  ***  *** ***  **                0%  +--*---**---**---***--
       +-----------------------------------+   B0    B2    B3   Target
       B0    B2    B3    Target             B1

  (d) Performance by Fault Category (Accuracy)

  100% |  ******                          ******  ******
       |  *    *                          *    *  *    *
  90%  |  *    *  ******  ******         *    *  *    *  ******
       |  *    *  *    *  *    *         *    *  *    *  *    *
  80%  |  *    *  *    *  *    *         *    *  *    *  *    *
       +----------------------------------------------------------------
       Common   Complex   Rare      Noisy
       Fault    Fault     Fault     Fault

  Systems per category:
  = Target, + B3, # B2, % B1, @ B0
  * = p < 0.05 (statistically significant)

  Key Observations:
  - Target system outperforms all baselines on most metrics
  - B3 (unidirectional) shows intermediate performance
  - B1 (LLM-only) suffers from high hallucination rate
  - Target maintains consistent performance across fault categories
```

---

## Figure 9: Ablation Study Results

**Section**: 5.3
**Purpose**: Visualize the impact of each component on overall system performance
**Key Components**:
- Rows: A1-A4 ablation studies (remove KG, remove bidirectional reasoning, remove multi-modal fusion, flatten architecture)
- Columns: Affected metrics (Accuracy, Precision, Recall, Response Time, Hallucination Rate)
- Color gradient showing percentage change from full system
- Highlight A2 (bidirectional reasoning removal) as causing largest performance drop
**Layout**: Heatmap format with color scale
**Color Suggestions**:
- Positive change (improvement): Green (unlikely in ablation)
- Negative change (degradation): Red/darker shades
- Severity gradient: Light red (-5%) to dark red (-25%+)
**Annotations**: Absolute values and percentage changes in each cell

### Detailed Textual Description

Figure 9 displays ablation study results as a heatmap showing the impact of removing each system component. Rows represent ablation configurations: A1 removes the KG construction module (using generic KG), A2 removes bidirectional reasoning (using unidirectional), A3 removes multi-modal fusion (single data source), and A4 flattens the hierarchical architecture. Columns show affected metrics: Accuracy, Precision, Recall, Response Time, and Hallucination Rate. Cell colors indicate percentage change from the full system (darker red = larger degradation). Key findings are highlighted: A2 (bidirectional reasoning removal) causes the largest performance drop across all metrics, with Accuracy decreasing by 18.5% and Hallucination Rate increasing by 320%. A1 (KG removal) significantly impacts Precision (-22.1%) due to lack of domain-specific knowledge. A3 (multi-modal removal) shows moderate impact on Accuracy (-12.3%) and Recall (-15.8%). A4 (architecture flattening) primarily affects Response Time (+45%, worse) with minimal impact on accuracy. Each cell contains both absolute values and percentage change for clarity. A "Full System" row is included as baseline reference.

### ASCII Art Representation

```
                   ABLATION STUDY RESULTS HEATMAP

Percentage Change from Full System (Darker = Larger Degradation)

            Accuracy   Precision   Recall     Response    Hallucination
            (%)         (%)         (%)        Time (%)    Rate (%)

+-----------+-----------+-----------+-----------+-----------+-----------+
| Full      |           |           |           |           |           |
| System    |    0     |    0       |    0       |    0       |  2.1%
| (Baseline) |           |           |           |           |           |
+-----------+-----------+-----------+-----------+-----------+-----------+
|           |           |           |           |           |           |
| A1: Remove |           |           |           |           |           |
| KG Module  |  -16.2%   |  -22.1%    |  -14.5%    |  +8.5%     |  4.8%
|           |   79.0%   |   72.3%    |   78.3%    |   560ms    |
+-----------+-----------+-----------+-----------+-----------+-----------+
|           |           |           |           |           |           |
| A2: Remove |           |           |           |           |           |
| Bidirectional|          |           |           |           |           |
| Reasoning  |  -18.5%   |  -20.3%    |  -19.8%    |  +320%      |  8.8%
|           |   76.7%   |   74.0%    |   73.4%    |   780ms    |
|           |  LARGEST   |  LARGEST   |  LARGEST   |  LARGEST   | DROP
+-----------+-----------+-----------+-----------+-----------+-----------+
|           |           |           |           |           |           |
| A3: Remove |           |           |           |           |           |
| Multi-Modal |          |           |           |           |           |
| Fusion     |  -12.3%   |  -11.8%    |  -15.8%    |  +15.2%     |  4.3%
|           |   82.6%   |   81.8%    |   77.1%    |   600ms    |
+-----------+-----------+-----------+-----------+-----------+-----------+
|           |           |           |           |           |           |
| A4: Flatten |           |           |           |           |           |
| Architecture|          |           |           |           |           |
|           |   -3.2%   |   -2.8%    |   -4.1%    |  +45.0%     |  2.5%
|           |   91.2%   |   90.2%    |   87.8%    |   754ms    |
+-----------+-----------+-----------+-----------+-----------+-----------+

Full System Values: Acc 94.2%, Prec 92.8%, Rec 91.5%, RT 520ms, Hall 2.1%

COLOR SCALE (Percentage Change):
  0%        [White/Light Gray]
  -5% to -15%    [Light Red █]
  -15% to -25%   [Medium Red ▓]
  <-25%           [Dark Red   ]
  +10% to +50%    [Light Blue ▒]
  >+50%           [Medium Blue ]

Key Findings:
* A2 (bidirectional reasoning) causes largest performance drop
* A1 (KG removal) most impacts precision (domain knowledge loss)
* A3 (multi-modal removal) shows balanced degradation
* A4 (architecture) primarily affects response time
```

---

## Figure Inventory Summary

| Figure | Title | Section | Type | Status |
|--------|--------|----------|-------|--------|
| Fig1 | CNC Fault Diagnosis Challenges | 1.1 | Problem illustration | Complete |
| Fig2 | System Architecture Overview | 3.1 | Architecture diagram | Complete |
| Fig3 | Perception Layer Data Flow | 3.2 | Flow diagram | Complete |
| Fig4 | CNC Fault Diagnosis Ontology | 3.3 | Ontology diagram | Complete |
| Fig5 | Bidirectional LLM-KG Reasoning Mechanism | 3.4 | Architecture diagram | Complete |
| Fig6 | Application Layer Service Interfaces | 3.5 | Component diagram | Complete |
| Fig7 | Hybrid Reasoning Framework | 4.2 | Architecture diagram | Complete |
| Fig8 | Experimental Results Comparison | 5.2 | Multi-panel bar chart | Complete |
| Fig9 | Ablation Study Results | 5.3 | Heatmap | Complete |

All figures have been designed with:
- Detailed specification blocks
- Comprehensive textual descriptions
- ASCII art representations
- Consistent terminology across all figures
- Progressive disclosure from high-level to analytical
