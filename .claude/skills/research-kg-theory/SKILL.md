---
name: research-kg-theory
description: "Performs Knowledge Graph and Ontology Engineering theoretical analysis. Analyzes Description Logic foundations, ontology design patterns, KG reasoning approaches, neuro-symbolic integration, and KG-as-cognitive-hub architectures. Runs synchronously using LLM knowledge only (no WebSearch). Invoked as: Skill(skill='research-kg-theory', args='{project}')"
---

# Skill: Knowledge Graph & Ontology Engineering Theoretical Analysis

## Overview

This skill performs a deep theoretical analysis of Knowledge Graph (KG) and Ontology Engineering foundations as they relate to a target system described in the project's input context. It is extracted and expanded from A3's Area 5 (Ontology & KG Theoretical Foundations) into a standalone, self-contained analytical capability.

Unlike A3 which covers broad MAS theory, this skill focuses exclusively on the KG/Ontology dimension with significantly greater depth: formal Description Logic analysis, comprehensive ontology design pattern cataloging, KG reasoning taxonomy, and neuro-symbolic integration assessment.

**Invocation**: `Skill(skill="research-kg-theory", args="{project}")`
**Runtime**: Synchronous, LLM-knowledge only (NO WebSearch)
**Output**: `workspace/{project}/phase1/skill-kg-theory.json`

---

## Execution Steps

### Step 1: Read Input Context (MANDATORY FIRST STEP)

Read `workspace/{project}/phase1/input-context.md` to understand:

- What KG/ontology the target system uses (if any)
- The ontology's scope, domain, and purpose
- How the KG is constructed, populated, and maintained
- What reasoning is performed over the KG
- How the KG interacts with other system components (especially LLM agents)
- Any claimed theoretical properties related to KG usage
- Key terminology and domain concepts

If the input context does not mention KG or ontology usage, produce a minimal output noting that KG/ontology analysis is not applicable, with `status: "not_applicable"`.

### Step 2: Analyze Description Logic Foundations

Determine the DL expressiveness required by the target system's ontology. Work through the DL family hierarchy:

#### 2.1 DL Family Hierarchy

**ALC (Attributive Language with Complements)**
- The baseline expressive DL. Supports: concept conjunction (C ⊓ D), disjunction (C ⊔ D), negation (¬C), existential restriction (∃r.C), universal restriction (∀r.C).
- Reasoning complexity: EXPTIME-complete for concept satisfiability.
- Sufficient for simple taxonomies with disjointness and basic role constraints.

**ALCH (ALC + Role Hierarchies)**
- Adds role inclusion axioms: r ⊑ s (sub-property relationships).
- Enables modeling property hierarchies (e.g., `hasDirectSupervisor ⊑ hasSupervisor`).

**ALCN / ALCQ (ALC + Number/Qualified Number Restrictions)**
- ALCN adds unqualified number restrictions: (>= n r), (<= n r).
- ALCQ adds qualified number restrictions: (>= n r.C), (<= n r.C).
- Enables cardinality constraints (e.g., "a paper has at least 1 author").

**SHIQ (ALC + Role Hierarchies + Inverse Roles + Transitive Roles + Qualified Number Restrictions)**
- S = ALC + transitive roles (Trans(r)).
- H = role hierarchies (r ⊑ s).
- I = inverse roles (r⁻).
- Q = qualified number restrictions.
- Reasoning complexity: EXPTIME-complete.
- Underpins OWL DL (OWL 1).

**SROIQ (SHIQ + Complex Role Inclusions + Nominals + Self-Restriction)**
- R = complex role inclusion axioms (r ∘ s ⊑ t), role disjointness, reflexivity, irreflexivity, asymmetry.
- O = nominals (enumerated classes: {a1, a2, ...}).
- Adds Self concept (∃r.Self).
- Reasoning complexity: 2NEXPTIME-complete (decidable but expensive).
- Underpins OWL 2 DL.

**OWL 2 Profiles (Tractable Fragments)**

| Profile | DL Fragment | Complexity | Use Case |
|---------|-------------|------------|----------|
| OWL 2 EL | EL++ | PTIME | Large biomedical ontologies (SNOMED CT), classification-heavy |
| OWL 2 QL | DL-Lite_R | AC0 data / NLogSpace combined | OBDA, query rewriting to SQL, large ABoxes |
| OWL 2 RL | pD* subset | PTIME data | Rule-based reasoning, RDF integration, RDFS++ |

**Analysis Questions for the Target System:**
- Which DL constructs does the ontology actually use?
- Is the ontology within a tractable OWL 2 profile, or does it require full OWL 2 DL?
- Are there reasoning tasks (classification, consistency checking, query answering) that impose complexity constraints?
- Does the system trade expressiveness for tractability, and is this trade-off justified?

#### 2.2 Open-World vs Closed-World Semantics

Assess the target system's assumption model:
- **Open-World Assumption (OWA)**: Absence of information does not imply falsity. Standard in OWL/DL reasoning. Appropriate when the KG is incomplete.
- **Closed-World Assumption (CWA)**: What is not known to be true is false. Standard in databases and SPARQL queries. Appropriate for integrity constraints.
- **Local Closed-World Assumption**: Hybrid approach where certain predicates are closed while others remain open. Increasingly common in practical KG systems.
- Does the target system need to reason under uncertainty about missing edges? If so, OWA is essential but may require probabilistic extensions.

#### 2.3 TBox vs ABox Analysis

- **TBox (Terminological Box)**: Schema-level axioms defining classes, properties, and their relationships. Assess complexity and size.
- **ABox (Assertional Box)**: Instance-level assertions. Assess volume and update frequency.
- What is the TBox-to-ABox ratio? A large TBox with small ABox suggests a schema-heavy design; a small TBox with massive ABox suggests a data-heavy design.
- Does the system perform TBox reasoning (classification, subsumption) or primarily ABox reasoning (instance checking, query answering)?

### Step 3: Identify Ontology Design Patterns

Catalog which ontology design patterns (ODPs) are present or should be present in the target system's ontology.

#### 3.1 Content Ontology Design Patterns

These encode domain-independent recurring modeling solutions:

**Participation Pattern**
- Models entities participating in events/processes.
- Structure: Entity --participatesIn--> Event; Event --hasParticipant--> Entity.
- Relevant when the target system models agent participation in tasks or workflows.

**Part-Whole (Componency) Pattern**
- Models mereological relationships: hasPart / isPartOf.
- Variants: mandatory part, optional part, shared part.
- Relevant for system architectures with component hierarchies.

**Classification Pattern**
- Models type hierarchies with explicit classification criteria.
- Uses punning (OWL 2) or reification to represent classification schemes.
- Relevant when the KG organizes entities into taxonomies.

**Situation Pattern**
- Models n-ary relationships as first-class entities (situations/contexts).
- Reifies complex relationships that cannot be captured by binary properties alone.
- Relevant when the target system needs to represent contextual information.

**Information Realization Pattern**
- Distinguishes information objects from their physical realizations.
- Structure: InformationObject --isRealizedBy--> PhysicalEntity.
- Relevant for systems that distinguish between abstract knowledge and concrete artifacts.

**Sequence Pattern**
- Models ordered sequences of entities.
- Structure: Element --precedes/follows--> Element.
- Relevant for pipeline architectures, workflow ordering, temporal sequences.

**Collection Pattern**
- Models bags, sets, and collections as first-class entities.
- Relevant when the KG groups entities into meaningful collections.

#### 3.2 Structural Ontology Design Patterns

These address ontology architecture rather than domain content:

**Modular Ontology Pattern**
- Decompose a large ontology into self-contained modules with well-defined import relationships.
- Benefits: independent development, selective loading, reduced reasoning scope.
- Assess whether the target system's ontology is monolithic or modular.

**Normalization Pattern**
- Ensure each class has a single axis of classification (no multiple inheritance from unrelated hierarchies).
- Reduces maintenance burden and reasoning ambiguity.

**Closure Axiom Pattern**
- Add closure axioms (∀r.C) to restrict the range of a property for a specific class.
- Converts OWA to local CWA for specific properties.

**Value Partition Pattern**
- Model exhaustive and mutually exclusive value sets (e.g., severity levels: Low ⊔ Medium ⊔ High, all pairwise disjoint).
- Relevant for categorical attributes in the KG.

#### 3.3 Correspondence Patterns

- **Alignment Pattern**: Map concepts between two ontologies using equivalence or subsumption.
- **Bridge Pattern**: Create a bridging ontology that imports and relates concepts from multiple source ontologies.
- Relevant when the target system integrates knowledge from heterogeneous sources.

#### 3.4 Methodology Assessment

Evaluate which ontology engineering methodology the target system follows (explicitly or implicitly):

| Methodology | Key Characteristics | When Appropriate |
|-------------|-------------------|------------------|
| METHONTOLOGY | Waterfall-like: specification, conceptualization, formalization, implementation | Well-defined, stable domains |
| NeOn Methodology | Scenario-based, supports reuse of ontological resources, networked ontologies | Complex domains requiring ontology reuse and integration |
| DILIGENT | Distributed, loosely-controlled, evolving ontologies with argumentation | Collaborative ontology development |
| Agile Ontology Dev | Iterative, test-driven, continuous integration of ontology changes | Rapidly evolving domains, software-engineering-aligned teams |

### Step 4: Analyze KG Reasoning Approaches

Build a comprehensive taxonomy of reasoning approaches and determine where the target system falls.

#### 4.1 Symbolic / Rule-Based Reasoning

**Deductive Reasoning (Entailment)**
- OWL/DL reasoners: HermiT, Pellet, FaCT++, ELK, Konclude.
- Standard reasoning services: consistency checking, classification, realization, conjunctive query answering.
- SWRL (Semantic Web Rule Language): extends OWL with Horn-like rules. Adds expressiveness but may break decidability.
- Datalog-based reasoning: bottom-up evaluation, guaranteed termination, polynomial data complexity for common fragments.
- SHACL (Shapes Constraint Language): validation rather than inference. Checks whether data conforms to declared shapes.

**Forward Chaining vs Backward Chaining**
- Forward chaining (materialization): pre-compute all inferences, store as explicit triples. Fast query time, expensive update.
- Backward chaining (query rewriting): compute inferences at query time. No materialization cost, slower queries.
- Hybrid: materialize frequently-used inferences, rewrite for the rest.

#### 4.2 Embedding-Based / Neural Reasoning

**Translational Models**
- TransE: models relations as translations in embedding space (h + r ≈ t). Simple, effective for 1-to-1 relations. Struggles with 1-to-N, N-to-N.
- TransR: projects entities into relation-specific spaces before translation. Handles complex relation types better.
- RotatE: models relations as rotations in complex space. Can model symmetry, antisymmetry, inversion, composition.

**Semantic Matching Models**
- RESCAL / DistMult / ComplEx: bilinear models capturing pairwise interactions.
- DistMult: diagonal relation matrices, efficient but limited to symmetric relations.
- ComplEx: complex-valued embeddings, handles antisymmetric relations.

**Graph Neural Network Approaches**
- R-GCN (Relational Graph Convolutional Networks): message passing with relation-specific weight matrices.
- CompGCN: composition-based, jointly embeds nodes and relations.
- These capture multi-hop neighborhood structure, enabling inductive reasoning on unseen entities.

**Analysis Questions:**
- Does the target system use KG embeddings? If so, which family and why?
- Is the embedding used for link prediction, entity classification, or relation extraction?
- How are embedding quality and coverage evaluated?

#### 4.3 Hybrid Reasoning (Symbolic + Neural)

**Neural-Symbolic Integration Spectrum** (Henry Kautz's taxonomy):

| Level | Name | Description | Example |
|-------|------|-------------|---------|
| 1 | Symbolic Neuro Symbolic | Neural nets inside a symbolic framework | Neural theorem provers |
| 2 | Symbolic[Neuro] | Neural pattern recognition feeding symbolic reasoning | NER + rule-based KG population |
| 3 | Neuro pipe Symbolic | Separate neural and symbolic modules with interface | LLM + SPARQL query generation |
| 4 | Neuro:Symbolic -> Neuro | Symbolic knowledge compiled into neural architecture | Knowledge graph embeddings |
| 5 | Neuro_{Symbolic} | Symbolic reasoning emerging from neural architecture | GNNs with logical message passing |
| 6 | Neuro[Symbolic] | Symbolic representations inside neural computation | Differentiable logic programming |

Determine where the target system falls on this spectrum. Most modern KG systems operate at levels 2-4.

### Step 5: Evaluate Ontology Alignment and Integration (if applicable)

If the target system integrates multiple knowledge sources or ontologies:

#### 5.1 Schema-Level Alignment

- **Lexical matching**: string similarity between class/property names.
- **Structural matching**: graph-structure similarity (shared neighborhoods, paths).
- **Semantic matching**: logical entailment between axioms.
- **Instance-based matching**: overlap in instance populations.
- Tools and frameworks: LogMap, AML (AgreementMakerLight), PARIS.

#### 5.2 Instance-Level Integration

- **Entity resolution / record linkage**: identifying when two nodes in different KGs refer to the same real-world entity.
- **Conflict resolution**: handling contradictory assertions from different sources (trust scores, provenance tracking, voting).
- **Provenance and trust**: tracking the origin of each triple to enable source-aware reasoning.

#### 5.3 Federated KG Architecture

- Does the target system maintain a single unified KG or a federation of linked KGs?
- If federated: how are cross-KG queries resolved? SPARQL federation (SERVICE keyword)? Materialized integration?
- Trade-offs: autonomy vs consistency, query performance vs freshness.

### Step 6: Analyze KG as Cognitive Hub for Multi-Agent Coordination (if applicable)

This is a novel intersection of KG theory and MAS theory. If the target system uses its KG/ontology as a coordination mechanism between agents:

#### 6.1 KG as Shared Conceptual Model

- The ontology provides a common vocabulary and shared understanding across agents.
- Analogous to the "blackboard" in classical MAS, but with formal semantics.
- Agents can reason about each other's knowledge contributions through the shared ontology.
- The ontology constrains what agents can assert (schema validation) and what they can query (query interface).

#### 6.2 KG-Augmented Retrieval vs Pure Vector Retrieval

- **Pure vector retrieval (RAG)**: embed documents, retrieve by cosine similarity. No structural reasoning.
- **KG-augmented retrieval (GraphRAG)**: traverse KG structure to retrieve contextually relevant subgraphs. Preserves relational structure.
- **Hybrid**: use vector similarity for initial retrieval, then KG traversal for structural enrichment.
- Theoretical advantages of KG-augmented: explainability (provenance paths), compositionality (multi-hop reasoning), consistency (ontological constraints).

#### 6.3 Ontology-Driven Agent Coordination

- The ontology can define agent capabilities, task types, and workflow constraints.
- Agents can use ontological reasoning to determine task eligibility, dependency resolution, and conflict detection.
- This represents a form of "semantic coordination" distinct from both direct message passing and stigmergic coordination.

### Step 7: Assess Neuro-Symbolic Integration (LLM + KG Grounding)

Analyze how the target system combines LLM capabilities with KG-based knowledge:

#### 7.1 LLM Grounding via KG

- **Problem**: LLMs hallucinate, lack domain-specific knowledge, and cannot guarantee factual accuracy.
- **Solution**: Ground LLM outputs in KG facts. The KG serves as a "factual anchor."
- **Mechanisms**: retrieval-augmented generation with KG subgraphs, post-generation fact-checking against KG, constrained decoding guided by ontological constraints.

#### 7.2 LLM-Assisted KG Construction and Maintenance

- **KG population**: LLMs extract entities and relations from unstructured text, guided by the ontology schema.
- **KG completion**: LLMs predict missing links using both textual context and graph structure.
- **Ontology learning**: LLMs suggest new classes, properties, or axioms based on corpus analysis.
- **Quality assurance**: LLMs detect inconsistencies, redundancies, or gaps in the KG.

#### 7.3 Bidirectional Synergy Assessment

Evaluate the degree of bidirectional integration:
- Does the KG improve LLM outputs? (grounding, factuality, consistency)
- Does the LLM improve the KG? (population, completion, maintenance)
- Is there a feedback loop? (LLM populates KG -> KG grounds LLM -> improved LLM populates better KG)
- What is the "trust boundary"? When does the system trust the LLM vs the KG?

#### 7.4 Theoretical Framework for LLM-KG Integration

Position the target system within the emerging theoretical landscape:
- **Knowledge-Augmented Language Models**: KG triples injected into LLM context (ERNIE, K-BERT, KEPLER).
- **LLM-Enhanced Knowledge Graphs**: LLMs as flexible reasoners over structured knowledge (KG-BERT, StAR).
- **Unified Neuro-Symbolic Architectures**: tight integration where symbolic and neural components share representations.

### Step 8: Synthesize Findings and Write Output

Compile all analyses into the output JSON. For each finding, assess:
- Its relevance to the target system's specific KG/ontology usage
- Its academic significance (is this a known result, an open problem, or a novel contribution?)
- Which innovations from input-context.md it supports or challenges
- Concrete evidence from the input context that supports the finding

---

## Output Format

Write a single JSON file to `workspace/{project}/phase1/skill-kg-theory.json`:

```json
{
  "skill_id": "research-kg-theory",
  "domain": "knowledge_graph",
  "status": "complete",
  "summary": "One-paragraph summary of the KG/ontology theoretical analysis, highlighting the most significant findings and their implications for the target system.",
  "findings": [
    {
      "finding_id": "F1",
      "type": "theory|method|comparison|architecture",
      "title": "Concise title of the finding",
      "description": "Detailed description of the finding, including theoretical background and how it relates to the target system.",
      "evidence": "Specific evidence from input-context.md that supports or motivates this finding.",
      "related_innovations": [1, 3],
      "academic_significance": "Why this finding matters for the paper. What gap does it address? What contribution does it support?"
    }
  ],
  "domain_specific_data": {
    "dl_analysis": {
      "identified_dl_family": "e.g., ALCHIQ or OWL 2 RL",
      "expressiveness_requirements": [
        "List of DL constructs the ontology requires and why"
      ],
      "tractability_assessment": "Whether reasoning is tractable at the system's scale",
      "owl_profile_fit": "Which OWL 2 profile (if any) the ontology fits within",
      "semantic_assumption": "OWA|CWA|Local CWA with justification",
      "tbox_abox_characterization": "Description of TBox complexity and ABox scale"
    },
    "design_patterns": {
      "content_patterns_identified": [
        {
          "pattern_name": "e.g., Participation Pattern",
          "usage_in_system": "How the target system uses this pattern",
          "conformance": "full|partial|implicit"
        }
      ],
      "structural_patterns_identified": [
        {
          "pattern_name": "e.g., Modular Ontology Pattern",
          "usage_in_system": "How the target system uses this pattern",
          "conformance": "full|partial|implicit"
        }
      ],
      "methodology_assessment": "Which methodology the ontology development follows",
      "pattern_gaps": "Design patterns that should be present but are missing"
    },
    "reasoning_analysis": {
      "primary_reasoning_approach": "symbolic|neural|hybrid",
      "symbolic_methods": ["List of symbolic reasoning methods used"],
      "neural_methods": ["List of neural reasoning methods used, if any"],
      "kautz_level": "1-6, position on the neuro-symbolic spectrum",
      "reasoning_tasks": ["classification", "query_answering", "link_prediction", "etc."],
      "scalability_assessment": "How reasoning scales with KG size"
    },
    "neurosymbolic_assessment": {
      "integration_type": "grounding|population|bidirectional|unified",
      "llm_to_kg_flow": "How LLM outputs feed into the KG",
      "kg_to_llm_flow": "How KG knowledge grounds LLM reasoning",
      "feedback_loop": "Whether a virtuous cycle exists between LLM and KG",
      "trust_boundary": "How the system arbitrates between LLM and KG when they conflict",
      "theoretical_position": "Where the system sits in the LLM-KG integration landscape"
    },
    "cognitive_hub_analysis": {
      "is_cognitive_hub": true,
      "coordination_role": "How the KG coordinates multi-agent activity",
      "vs_blackboard": "Comparison with classical blackboard architecture",
      "vs_vector_retrieval": "Advantages over pure vector-based approaches",
      "semantic_coordination_mechanisms": "Specific ontology-driven coordination patterns"
    }
  }
}
```

**Field-level guidance:**

- `findings`: Aim for 6-12 findings. Each should be substantive and non-overlapping.
- `type` values: Use "theory" for foundational DL/logic results, "method" for reasoning approaches and design patterns, "comparison" for positioning against alternatives, "architecture" for system-level KG design analysis.
- `related_innovations`: Reference innovation numbers from input-context.md (1-indexed). Use an empty array if the finding is background theory not tied to a specific innovation.
- `academic_significance`: Be specific. "This is important" is not sufficient. State what gap it fills, what claim it supports, or what novelty it highlights.

---

## Constraints

1. **NO WebSearch**: This skill runs entirely on LLM knowledge. Do not attempt to use WebSearch or WebFetch tools. All theoretical content must come from the model's training knowledge of KG/ontology literature.

2. **Single output file**: Write only `workspace/{project}/phase1/skill-kg-theory.json`. Do not create markdown companion files (the JSON is self-contained).

3. **Input-context driven**: Every finding must be grounded in something observed or described in `input-context.md`. Do not produce generic KG theory surveys disconnected from the target system.

4. **Not-applicable handling**: If the target system does not use KG/ontology, write a minimal JSON with `"status": "not_applicable"` and a brief explanation in `summary`. Do not fabricate KG analysis for a system that does not use one.

5. **No paper writing**: This skill produces analytical findings, not paper prose. Findings should be factual, precise, and structured. The paper writing is handled by downstream agents (C1, C3).

6. **Scope boundary**: Do not analyze MAS theory (that is A3's job), engineering implementation details (that is A2's job), or literature survey (that is A1's job). Stay within KG/ontology theoretical foundations.

7. **Depth over breadth**: It is better to deeply analyze 3 relevant DL constructs than to superficially list 20. Focus analysis on what the target system actually uses.

8. **Honest assessment**: If the target system's ontology is simple (e.g., RDFS-level), say so. Do not inflate the theoretical complexity to make the paper seem more impressive. Reviewers will see through this.

9. **Valid JSON**: The output must be valid, parseable JSON. Use proper escaping for special characters in string values. Do not include comments in the JSON output.

---

## Reference Knowledge Base

The following canonical references underpin this skill's analytical framework. Use them to contextualize findings (cite by author-year in finding descriptions):

**Description Logic and OWL:**
- Baader et al. (2003) -- "The Description Logic Handbook" -- foundational DL theory
- Horrocks et al. (2003) -- OWL formal semantics and design rationale
- Motik et al. (2009) -- OWL 2 profiles: rationale and design
- Grau et al. (2008) -- OWL 2: next step for OWL

**Ontology Design Patterns:**
- Gangemi & Presutti (2009) -- Ontology Design Patterns (ODPs) catalog and methodology
- Blomqvist et al. (2016) -- Ontology design patterns in practice
- Hammar (2017) -- Template-based ontology design patterns

**KG Reasoning:**
- Bordes et al. (2013) -- TransE: translating embeddings for modeling multi-relational data
- Sun et al. (2019) -- RotatE: knowledge graph embedding by relational rotation
- Schlichtkrull et al. (2018) -- R-GCN: modeling relational data with graph convolutional networks

**Neuro-Symbolic Integration:**
- Kautz (2022) -- "The Third AI Summer" -- neuro-symbolic taxonomy
- Pan et al. (2024) -- "Unifying Large Language Models and Knowledge Graphs: A Roadmap"
- Zhang et al. (2022) -- ERNIE: enhanced language representation with informative entities

**KG + LLM:**
- Ji et al. (2022) -- Survey on knowledge graphs: representation, acquisition, and applications
- Hogan et al. (2021) -- "Knowledge Graphs" -- comprehensive survey covering construction, hosting, querying
