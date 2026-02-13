---
name: research-bridge-eng
description: >
  Bridge Engineering domain theoretical analysis skill. Performs deep analysis of how
  knowledge graphs, ontologies, and AI intersect with bridge inspection, condition
  assessment, and structural health monitoring. Produces structured findings for
  academic paper generation in the paper-factory pipeline.
---

# Skill: Bridge Engineering Domain Theoretical Analysis

## Purpose

This skill provides expert-level theoretical analysis of bridge engineering as it intersects with knowledge graph technology, ontology engineering, and artificial intelligence. It is designed to supply Phase 1 research material for academic papers that sit at the crossroads of civil/structural engineering and knowledge engineering.

The skill operates synchronously using LLM domain knowledge only — no web search is performed. It reads the project's `input-context.md` to understand the specific bridge engineering application under study, then produces a comprehensive structured analysis covering inspection methodology, structural health monitoring, BIM-KG fusion, domain ontology modeling, AI/ML applications, and regulatory frameworks.

## Invocation

```
Skill(skill="research-bridge-eng", args="{project}")
```

Where `{project}` is the project directory name under `workspace/`.

## Inputs

| Input | Path | Required |
|-------|------|----------|
| Project context | `workspace/{project}/input-context.md` | Yes |
| Engineering analysis (if available) | `workspace/{project}/phase1/a2-engineering-analysis.json` | No |

## Output

| Output | Path |
|--------|------|
| Structured findings | `workspace/{project}/phase1/skill-bridge-eng.json` |

---

## Execution Steps

### Step 1: Read Project Context

Read `workspace/{project}/input-context.md` to extract:
- The specific bridge engineering system or application being studied
- Innovation claims related to bridge inspection, SHM, or infrastructure management
- Target ontology scope (bridge components, defects, materials, load models)
- Any existing system architecture involving KG, BIM, or sensor integration

If `workspace/{project}/phase1/a2-engineering-analysis.json` exists, also read it to ground the analysis in concrete engineering artifacts from the target codebase.

### Step 2: Analyze Bridge Inspection and Condition Assessment Methodologies

Produce findings covering the full spectrum of bridge inspection practice:

**Visual Inspection Regimes:**
- Routine inspection (RI): frequency, scope, inspector qualifications
- In-depth inspection (IDI): element-level assessment, access requirements
- Special inspection: triggered by events (earthquakes, overloads, flooding)
- Damage inspection: post-incident rapid assessment protocols
- Underwater inspection: diving-based and ROV-assisted methods

**Non-Destructive Evaluation (NDE) Techniques:**
- Ground Penetrating Radar (GPR): deck delamination detection, rebar mapping
- Infrared Thermography (IRT): subsurface defect identification via thermal contrast
- Ultrasonic Testing (UT): thickness measurement, crack depth estimation
- Impact Echo (IE): void and delamination detection in concrete elements
- Acoustic Emission (AE): real-time crack propagation monitoring
- Half-cell potential and corrosion rate measurement for reinforcement assessment
- Magnetic Flux Leakage (MFL) for steel cable and tendon inspection

**Condition Rating Systems:**
- FHWA/NBI condition ratings (0-9 scale for deck, superstructure, substructure)
- Element-level condition state assessment (CoRe elements, AASHTO elements)
- Bridge Health Index (BHI) computation from element condition states
- Sufficiency Rating formula and its components
- Chinese bridge technical condition assessment (BCI, Dr index per JTG/T H21)

**Knowledge Representation Opportunities:**
- Mapping inspection findings to ontology instances (defect type, severity, location)
- Temporal modeling of condition state transitions
- Spatial referencing of defects within bridge component hierarchies
- Inspector uncertainty and confidence modeling in KG assertions

### Step 3: Evaluate Structural Health Monitoring (SHM) Theory and Practice

Analyze SHM as a data-intensive domain ripe for knowledge graph integration:

**Sensor Technologies and Deployment:**
- Strain gauges (foil, vibrating wire, fiber optic): placement strategies, drift concerns
- Accelerometers: ambient vibration monitoring, modal parameter extraction
- Displacement sensors (LVDT, GPS, vision-based): static and dynamic measurement
- Temperature sensors: thermal gradient effects on structural response
- Fiber Optic Sensing (FOS): distributed strain/temperature via Brillouin or Rayleigh
- Weigh-in-Motion (WIM) systems: traffic load characterization
- Corrosion sensors: embedded probes, linear polarization resistance
- Environmental sensors: wind speed, humidity, precipitation

**Data Processing and Analysis Pipelines:**
- Signal conditioning: filtering, resampling, outlier removal
- Modal analysis: Operational Modal Analysis (OMA), Stochastic Subspace Identification
- Damage detection paradigms (Rytter's hierarchy): Level 1 Detection, Level 2 Localization, Level 3 Quantification, Level 4 Prognosis
- Statistical pattern recognition for anomaly detection
- Physics-informed approaches: FEM model updating, digital twins

**SHM-KG Integration Patterns:**
- Sensor metadata ontology: sensor type, location, calibration, data channel
- Time-series data referencing within graph structures (RDF-star, named graphs)
- Alert and threshold modeling as ontology-driven rules (SHACL, SWRL)
- Provenance tracking for SHM data processing chains
- Cross-referencing SHM readings with inspection findings in unified KG

### Step 4: Analyze BIM-KG Fusion for Infrastructure Management

Examine the convergence of Building Information Modeling and Knowledge Graphs for bridge lifecycle management:

**BIM for Bridges — Current State:**
- IFC-Bridge extension (buildingSMART): geometry, materials, structural properties
- IFC 4.3 infrastructure additions: alignment, linear placement, earthworks
- OpenBrIM: open parametric bridge information model
- Limitations of current BIM: weak semantic querying, poor cross-domain linking

**BIM-to-KG Transformation Approaches:**
- IFC-to-RDF/OWL conversion: ifcOWL ontology, geometric simplification strategies
- Selective extraction: converting only semantically relevant BIM entities
- Linked Data approaches: BIM elements as URI-addressable resources
- Maintaining geometric context while enabling graph-based reasoning

**Fusion Architecture Patterns:**
- BIM as geometric backbone + KG as semantic layer
- Federated querying across BIM database and SPARQL endpoint
- Digital Twin architecture: BIM geometry + KG semantics + real-time SHM data
- GIS-BIM-KG integration for network-level bridge management

**Infrastructure Lifecycle Use Cases:**
- Design-phase: code compliance checking via SHACL constraints on BIM-KG
- Construction-phase: progress tracking, material traceability in KG
- Operation-phase: maintenance scheduling driven by KG reasoning over condition data
- Deterioration modeling: linking material properties, environmental exposure, and observed degradation patterns through ontology relationships

### Step 5: Assess Bridge Domain Ontology Modeling

Analyze ontology engineering specifically for the bridge infrastructure domain:

**Existing Bridge Ontologies and Standards:**
- IFC-Bridge / ifcOWL: buildingSMART's semantic web representation of IFC schema
- COBie (Construction Operations Building Information Exchange): facility handover data
- Uniclass / OmniClass: classification systems for construction information
- QUDT (Quantities, Units, Dimensions, Types): measurement ontology for engineering data
- SSN/SOSA (Semantic Sensor Network / Sensor, Observation, Sample, Actuator): W3C standard for sensor and observation modeling, directly applicable to SHM

**Bridge Component Taxonomy:**

A well-formed bridge ontology must capture the hierarchical decomposition of bridge structures. The core modeling challenge includes:

```
Bridge
 +-- Superstructure
 |    +-- Deck (concrete slab, steel orthotropic, composite)
 |    +-- Girder/Beam (I-beam, box girder, T-beam)
 |    +-- Truss (Warren, Pratt, Howe configurations)
 |    +-- Arch (deck arch, through arch, tied arch)
 |    +-- Cable System (stay cables, main cables, hangers)
 |    +-- Diaphragm/Cross-frame
 |    +-- Wearing Surface/Overlay
 +-- Substructure
 |    +-- Abutment (gravity, cantilever, integral)
 |    +-- Pier/Column (single column, multi-column bent, wall pier)
 |    +-- Pier Cap/Bent Cap
 |    +-- Foundation (spread footing, pile, drilled shaft, caisson)
 |    +-- Wing Wall/Retaining Wall
 +-- Bearing System
 |    +-- Elastomeric Bearing (plain, laminated, lead-rubber)
 |    +-- Pot Bearing, Spherical Bearing, Rocker/Roller Bearing
 +-- Joint System
 |    +-- Expansion Joint (strip seal, modular, finger)
 |    +-- Construction Joint, Integral/Jointless Connection
 +-- Drainage System
 |    +-- Deck Drain/Scupper, Downspout/Collection Pipe
 +-- Appurtenances
      +-- Railing/Barrier, Approach Slab, Lighting, Signage
```

**Defect Ontology Modeling:**
- Concrete defects: cracking (flexural, shear, map, longitudinal), spalling, delamination, efflorescence, scaling, honeycombing, ASR (alkali-silica reaction)
- Steel defects: corrosion (uniform, pitting, crevice), fatigue cracking, buckling, connection failure (bolt loosening, weld cracking), paint system deterioration
- Timber defects: decay (brown rot, white rot), insect damage, split, check, crush
- Defect attributes: severity (minor/moderate/severe), extent (localized/widespread), urgency (routine/priority/critical), progression rate

**Material Property Modeling:**
- Concrete: compressive strength, chloride content, carbonation depth, cover depth
- Steel: yield strength, tensile strength, fatigue category, corrosion allowance
- Prestressing: tendon type, jacking force, losses, grouting condition
- FRP (Fiber Reinforced Polymer): tensile modulus, environmental degradation factors

**Load Type Ontology:**
- Dead load: self-weight, superimposed dead load (wearing surface, utilities)
- Live load: vehicular (design truck, design lane, permit), pedestrian
- Environmental: wind, thermal, seismic, ice, water pressure, earth pressure
- Extreme events: vessel collision, vehicle collision, blast
- Construction loads: temporary supports, equipment, staged construction

### Step 6: Evaluate AI/ML Applications in Bridge Engineering

Analyze the state of artificial intelligence and machine learning as applied to bridge engineering problems, with emphasis on KG-enhanced approaches:

**Computer Vision for Defect Detection:**
- CNN-based crack detection: image classification and semantic segmentation approaches
- Object detection models (YOLO, Faster R-CNN) for multi-defect identification
- UAV-based inspection: autonomous flight path planning, image stitching, 3D reconstruction
- Challenges: class imbalance (rare defect types), environmental variation (lighting, weather), scale variation, distinguishing structural cracks from surface blemishes
- KG enhancement: linking detected defects to ontology instances, enriching visual detections with structural context (load path, stress concentration zones)

**Deterioration Prediction and Remaining Life Estimation:**
- Markov chain models for condition state transition prediction
- Mechanistic models: chloride diffusion (Fick's law), carbonation, fatigue accumulation
- Machine learning regression: predicting condition ratings from feature vectors (age, traffic, climate, material, design type)
- Deep learning time-series: LSTM/Transformer models for SHM data trend prediction
- Physics-Informed Neural Networks (PINNs): embedding structural mechanics constraints
- KG-enhanced prediction: using graph structure to propagate deterioration effects across connected components, reasoning about failure cascades

**FEM-Based Structural Assessment:**
- Finite Element Model updating from SHM data: calibrating stiffness, boundary conditions
- Load rating analysis: RF (Rating Factor) computation per AASHTO MBE
- Reliability analysis: Monte Carlo simulation, FORM/SORM for probability of failure
- KG role: storing FEM model parameters, linking analysis results to bridge components, tracking model versions and calibration history

**Natural Language Processing for Bridge Engineering:**
- Extracting structured data from inspection reports (named entity recognition)
- Classifying maintenance recommendations from free-text inspector notes
- Automated generation of condition summaries from sensor data and inspection records
- KG population from unstructured engineering documents

**Multi-Agent Systems in Bridge Management:**
- Agent-based simulation of bridge network deterioration
- Distributed decision-making for maintenance prioritization across bridge portfolios
- Negotiation protocols for resource allocation among competing maintenance needs
- KG as shared knowledge base for multi-agent coordination

### Step 7: Analyze Regulatory and Standards Frameworks

Assess the standards landscape that governs bridge engineering practice and how ontology/KG systems can encode and operationalize these standards:

**AASHTO Standards (United States):**
- AASHTO LRFD Bridge Design Specifications (9th Edition): load combinations, resistance factors, limit states (Strength, Service, Extreme Event, Fatigue)
- AASHTO Manual for Bridge Evaluation (MBE): load rating procedures (ASR, LFR, LRFR), load posting, permit analysis
- AASHTO Guide Manual for Bridge Element Inspection: element-level condition state definitions, feasible actions, quantity calculations
- AASHTO Bridge Management (AASHTOWare BrM): deterioration modeling, lifecycle cost analysis, project-level and network-level optimization

**Eurocode Standards (Europe):**
- EN 1990 (Eurocode 0): Basis of structural design, reliability framework
- EN 1991 (Eurocode 1): Actions on structures (traffic loads, wind, thermal, accidental)
- EN 1992 (Eurocode 2): Concrete structures — design and detailing
- EN 1993 (Eurocode 3): Steel structures — design, fatigue, connections
- EN 1998 (Eurocode 8): Seismic design — bridge-specific provisions in Part 2
- CEN/TC 250 evolution: Eurocodes second generation development

**Chinese Standards (JTG Series):**
- JTG D60: General Specifications for Design of Highway Bridges and Culverts
- JTG D62: Code for Design of Highway Reinforced Concrete and Prestressed Concrete Bridges and Culverts
- JTG D64: Specifications for Design of Highway Steel Bridges
- JTG/T H21: Standards for Technical Condition Evaluation of Highway Bridges
- JTG 5120: Highway Bridge Maintenance Specifications
- JTG/T J21: Specifications for Inspection and Evaluation of Load-bearing Capacity of Highway Bridges

**Standards-KG Integration Opportunities:**
- Encoding design rules as SHACL shapes or SPARQL-based constraints
- Automated compliance checking: validating bridge designs against code provisions
- Cross-standard comparison: mapping equivalent provisions across AASHTO/Eurocode/JTG
- Version management: tracking standard revisions and their impact on existing assessments
- Traceability: linking every design decision and assessment result to its governing standard clause

### Step 8: Synthesize Findings and Generate Output

Compile all analysis into the structured output format. For each major analysis area, generate one or more findings with:
- A unique finding ID (F1, F2, ...)
- A type classification (theory, method, comparison, architecture)
- A clear title and description
- Supporting evidence drawn from domain knowledge
- Links to innovation claims from the input context (`related_innovations` array)
- An assessment of academic significance

Populate the `domain_specific_data` object with detailed sub-structures for each analysis area (inspection, SHM, BIM-KG, ontology, AI, standards).

### Step 9: Write Output File

Write the complete JSON output to `workspace/{project}/phase1/skill-bridge-eng.json`. Ensure the JSON is valid and well-formatted.

---

## Output Format Specification

The output file must conform to the following schema:

```json
{
  "skill_id": "research-bridge-eng",
  "domain": "bridge_engineering",
  "status": "complete",
  "timestamp": "<ISO-8601 timestamp>",
  "project": "<project name>",
  "summary": "<2-3 sentence summary of key findings>",
  "findings": [
    {
      "finding_id": "F1",
      "type": "theory|method|comparison|architecture",
      "title": "<concise finding title>",
      "description": "<detailed description, 100-300 words>",
      "evidence": "<supporting evidence from domain knowledge>",
      "related_innovations": [1, 3],
      "academic_significance": "<why this matters for the paper>"
    }
  ],
  "domain_specific_data": {
    "inspection_methodology": {
      "visual_inspection_types": ["routine", "in-depth", "special", "damage", "underwater"],
      "nde_techniques": [
        {
          "name": "Ground Penetrating Radar",
          "abbreviation": "GPR",
          "target_defects": ["delamination", "rebar_corrosion", "void"],
          "applicable_materials": ["concrete"],
          "kg_modeling_notes": "<how to represent in KG>"
        }
      ],
      "condition_rating_systems": [
        {
          "name": "NBI Condition Rating",
          "origin": "FHWA/US",
          "scale": "0-9",
          "granularity": "component-level",
          "kg_modeling_notes": "<ontology representation approach>"
        }
      ]
    },
    "shm_analysis": {
      "sensor_types": [
        {
          "type": "accelerometer",
          "measured_quantity": "acceleration",
          "typical_applications": ["modal_analysis", "seismic_monitoring"],
          "data_characteristics": "high_frequency_time_series",
          "kg_integration_pattern": "<how sensor data links to KG>"
        }
      ],
      "damage_detection_levels": [
        {
          "level": 1,
          "name": "Detection",
          "description": "Determine if damage is present",
          "typical_methods": ["statistical_control_charts", "novelty_detection"],
          "kg_role": "<how KG supports this level>"
        }
      ],
      "data_pipeline_stages": ["acquisition", "preprocessing", "feature_extraction",
                                "statistical_modeling", "decision_making"]
    },
    "bim_kg_fusion": {
      "bim_standards": ["IFC-Bridge", "IFC_4.3", "OpenBrIM", "COBie"],
      "transformation_approaches": [
        {
          "name": "ifcOWL direct conversion",
          "description": "<approach details>",
          "advantages": ["<list>"],
          "limitations": ["<list>"]
        }
      ],
      "fusion_architectures": [
        {
          "name": "Digital Twin Architecture",
          "layers": ["BIM_geometry", "KG_semantics", "SHM_realtime", "analytics"],
          "description": "<architecture description>"
        }
      ]
    },
    "domain_ontology": {
      "existing_ontologies": [
        {
          "name": "ifcOWL",
          "scope": "building_and_infrastructure",
          "relevance": "high",
          "limitations_for_bridges": "<specific gaps>"
        }
      ],
      "component_taxonomy_depth": 4,
      "defect_categories": ["concrete", "steel", "timber", "composite"],
      "material_properties_modeled": ["strength", "durability", "degradation"],
      "load_type_categories": ["dead", "live", "environmental", "extreme", "construction"]
    },
    "ai_applications": {
      "computer_vision": {
        "tasks": ["crack_detection", "multi_defect_classification", "corrosion_assessment"],
        "model_families": ["CNN", "YOLO", "Faster_RCNN", "semantic_segmentation"],
        "kg_enhancement": "<how KG improves CV results>"
      },
      "deterioration_prediction": {
        "approaches": ["markov_chain", "mechanistic", "ml_regression", "deep_learning", "PINN"],
        "kg_role": "<how KG supports prediction>"
      },
      "nlp_applications": {
        "tasks": ["report_extraction", "recommendation_classification", "summary_generation"],
        "kg_role": "<how KG supports NLP tasks>"
      }
    },
    "standards_framework": {
      "standard_families": [
        {
          "region": "US",
          "body": "AASHTO",
          "key_standards": ["LRFD_BDS", "MBE", "Element_Inspection_Guide"],
          "kg_encoding_approach": "<how to represent in KG>"
        },
        {
          "region": "EU",
          "body": "CEN",
          "key_standards": ["EN_1990", "EN_1991", "EN_1992", "EN_1993", "EN_1998"],
          "kg_encoding_approach": "<how to represent in KG>"
        },
        {
          "region": "China",
          "body": "MOT",
          "key_standards": ["JTG_D60", "JTG_D62", "JTG_D64", "JTG_T_H21", "JTG_5120"],
          "kg_encoding_approach": "<how to represent in KG>"
        }
      ],
      "cross_standard_mapping_feasibility": "<assessment>",
      "compliance_checking_via_shacl": "<approach description>"
    }
  }
}
```

### Finding Type Definitions

| Type | Description | Example |
|------|-------------|---------|
| `theory` | Established theoretical framework or principle | Rytter's damage detection hierarchy |
| `method` | Specific technique, algorithm, or methodology | Markov chain deterioration modeling |
| `comparison` | Comparative analysis of approaches or standards | AASHTO vs Eurocode load models |
| `architecture` | System design pattern or integration architecture | Digital Twin BIM-KG-SHM fusion |

### Expected Finding Count

The skill should produce 15-25 findings distributed across all analysis areas:
- Inspection methodology: 2-4 findings
- SHM theory and practice: 3-5 findings
- BIM-KG fusion: 2-4 findings
- Domain ontology: 3-5 findings
- AI/ML applications: 3-5 findings
- Standards framework: 2-3 findings

---

## Constraints

1. **No Web Search**: This skill relies entirely on LLM domain knowledge. Do not invoke WebSearch or WebFetch tools. All analysis must be generated from training knowledge about bridge engineering, structural engineering, and knowledge graph technology.

2. **Synchronous Execution**: The skill runs as a single synchronous task. It does not spawn sub-agents or parallel processes.

3. **Output Validity**: The output JSON must be parseable. Validate structure before writing. All string values must be properly escaped. No trailing commas.

4. **Domain Accuracy**: Bridge engineering terminology must be used precisely. Do not conflate structural engineering concepts (e.g., do not confuse shear cracking with flexural cracking, or mix up LRFD limit states). Use correct standard designations (e.g., "AASHTO LRFD BDS 9th Edition" not "AASHTO bridge code").

5. **Innovation Alignment**: Every finding should be assessed for relevance to the innovations listed in `input-context.md`. The `related_innovations` array must reference valid innovation IDs from the input context.

6. **Academic Tone**: All descriptions and summaries must be written in formal academic English suitable for direct incorporation into a research paper.

7. **Balanced Coverage**: Ensure roughly equal analytical depth across all six analysis areas. Do not over-index on any single topic at the expense of others.

8. **File Path Convention**: Always use the project-relative path pattern `workspace/{project}/phase1/skill-bridge-eng.json` for output. The `{project}` variable is provided as the skill argument.

9. **Idempotency**: If the output file already exists, overwrite it completely. Do not attempt to merge with previous output.

10. **Size Budget**: The output JSON should be between 15KB and 50KB. This ensures sufficient analytical depth without exceeding downstream processing limits.
