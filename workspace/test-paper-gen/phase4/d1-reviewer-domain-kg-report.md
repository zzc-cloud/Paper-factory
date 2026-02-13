# D1 Knowledge Graph Domain Expert Review Report

**Paper**: Research on Intelligent CNC Fault Diagnosis System Integrating Large Language Models and Domain Knowledge Graphs

**Reviewer**: D1-Domain-Expert-KG (Knowledge Graphs & Ontology Engineering Focus)

**Date**: 2025-02-13

---

## Summary

This paper presents a domain-specific knowledge graph construction methodology for CNC fault diagnosis using ALCHIQ description logic. The modular ontology design separates fault types, diagnostic methods, and system components into independent modules. The KG is integrated with an LLM through a bidirectional reasoning mechanism. The approach is technically sound and addresses a clear gap in applying KG techniques to industrial fault diagnosis.

---

## Overall Assessment

**Score**: 8.0/10
**Recommendation**: Minor Revision

The knowledge graph and ontology engineering aspects of this paper are solid. The choice of ALCHIQ description logic is appropriate, and the modular design follows ontology engineering best practices. The domain-specific focus provides genuine value over generic industrial KGs. Minor revisions are recommended to strengthen ontology engineering contributions through concrete examples, formalization of assumptions, and completeness evaluation.

---

## Strengths

### 1. Appropriate DL Framework Selection
The choice of ALCHIQ (Attributive Language with Complement, Role restriction, Hierarchies, Inverse roles, and Qualified number restrictions) is well-justified for the CNC fault diagnosis domain:
- **Complement (C)**: Enables negation and class complements for fault classification
- **Role restrictions (R)**: Enables cardinality constraints on properties
- **Hierarchies (H)**: Supports fault type and component inheritance
- **Inverse roles (I)**: Enables bidirectional navigation between components and faults
- **Qualified number restrictions (Q)**: Enables precise modeling (e.g., "exactly 4 components in assembly")

These constructors provide the right expressiveness for modeling complex fault hierarchies and diagnostic procedures while maintaining reasoning tractability.

### 2. Sound Modular Ontology Design
The separation into three modules is well-designed:
- **Fault Type Module**: Classifies faults by component, failure mode, and severity
- **Diagnostic Method Module**: Encodes procedural knowledge for diagnosis and repair
- **System Component Module**: Represents structural/functional decomposition of CNC equipment

This modular design follows established ontology engineering patterns and enables independent maintenance and extension of each module.

### 3. Correct OWL 2 DL Profile Alignment
The paper correctly notes that ALCHIQ maps to OWL 2 DL profile, a W3C standard. This alignment enables:
- Use of standard reasoners (Protégé, HermiT, Pellet)
- Interoperability with Semantic Web technologies
- Access to existing ontology development tools

### 4. Substantial Domain Coverage
The ontology statistics indicate substantial work:
- ~460 concepts across three modules
- ~147 properties
- ~23,700 instances

This represents significant domain coverage for CNC fault diagnosis.

### 5. Sound Hybrid Reasoning Approach
The integration of symbolic reasoning (OWL/DL classification, SWRL rules) with neural methods (RotatE embeddings, R-GCN) is well-designed for KG completion and link prediction. This hybrid approach leverages strengths of both paradigms.

### 6. Appropriate Use of Domain Terminology
The paper uses correct KG/ontology terminology throughout:
- Description Logic constructors are properly named
- OWL/RDF concepts are used correctly
- Reasoning types (symbolic vs. neural) are appropriately distinguished

---

## Weaknesses

### 1. Missing Concrete Ontology Code Examples
The ALCHIQ framework and modular design are described in text, but actual ontology axioms in OWL or Manchester syntax are not shown. This prevents:
- Verification of formal correctness by reviewers
- Understanding of concrete implementation details
- Reproducibility for researchers wanting to build on this work

### 2. Incomplete LCWA/OWA Formalization
The Local Closed World Assumption (LCWA) hybrid approach is mentioned but not formally specified:
- Which specific classes/properties use LCWA?
- Which use OWA?
- What are the precise boundary criteria?
- How do queries handle mixed assumptions?

### 3. SHACL Validation Not Demonstrated
SHACL validation is mentioned in Section 4.2 but:
- No example SHACL shapes are provided
- No validation results are shown
- No discussion of how many constraints are defined
- No explanation of what violations are detected

### 4. Ontology Completeness Not Evaluated
The paper reports ontology size (460 concepts, etc.) but does not evaluate:
- What percentage of possible CNC fault types are covered?
- How completeness compares to reference taxonomies?
- Whether expert validation of coverage was performed

### 5. KG Reasoning Evaluation Methodology Unclear
Section 5 reports "KG reasoning accuracy: 94.7%" but does not specify:
- What is the test set composition?
- What constitutes a "correct" vs. "incorrect" inference?
- How does this compare to baseline reasoning accuracy?
- What types of reasoning tasks were evaluated?

### 6. DL Complexity Claim Not Fully Justified
The claim of "EXPTIME-complete" reasoning for ALCHIQ is stated but:
- No citation to standard DL complexity results is provided
- No proof sketch is given
- No reference to established complexity results for ALCHIQ specifically

### 7. Symbolic-Neural Combination Not Explicit
The hybrid reasoning framework combines symbolic and neural approaches, but:
- How are results combined? (voting? weighted aggregation? confidence-based selection?)
- How are conflicts between symbolic and neural results resolved?

---

## Detailed Comments by Section

### Section 3.3: Knowledge Layer - Important
**Issue**: The ontology module descriptions are clear but lack concrete examples. The relationship structures between modules are described textually but not shown in formal notation.

**Suggestion**: Add a concrete example showing ontology structure for a specific fault type.

**Example to Add**:
```owl
# Example: Spindle Bearing Fault Ontology

Class: SpindleBearingWear
    SubClassOf: MechanicalFault
    SubClassOf: ∃hasSymptom.AbnormalVibration
    SubClassOf: ∃hasSymptom.ElevatedTemperature
    SubClassOf: ∃affectsComponent.SpindleBearing
    SubClassOf: hasSeverity.Major

ObjectProperty: hasSymptom
    Domain: Fault
    Range: Symptom
    InverseOf: isSymptomOf

ObjectProperty: affectsComponent
    Domain: Fault
    Range: Component
    Characteristics: Asymmetric, Irreflexive
```

### Section 4.1: Expressiveness and Tractability - Minor
**Issue**: The computational complexity claim is stated but not justified.

**Suggestion**: Add citation to standard DL complexity results:
> "ALCHIQ reasoning is EXPTIME-complete for subsumption and instance retrieval [Horrocks et al., 2003], which is acceptable for real-time diagnostic applications given our knowledge base size of ~23,700 instances."

Or provide a brief justification:
> "The EXPTIME complexity is acceptable for our scale because worst-case reasoning completes in seconds for knowledge bases of this size, enabling real-time response requirements."

### Section 4.2: Hybrid Reasoning Framework - Minor
**Issue**: The description of RotatE and R-GCN is technically sound, but the combination mechanism is not explicit.

**Suggestion**: Add details on result combination:
> "The symbolic and neural reasoning results are combined through a confidence-weighted aggregation scheme. When symbolic reasoning produces a conclusion with confidence ≥0.8, it is prioritized. Neural predictions supplement symbolic results when symbolic reasoning is inconclusive or has low confidence (<0.5)."

### Section 4.3: Neuro-Symbolic Integration Properties - Important
**Issue**: The LCWA/OWA hybrid approach is abstract and not formally specified.

**Suggestion**: Formalize the hybrid assumption:
> "Our system applies Local Closed World Assumption (LCWA) to core domain knowledge authored by experts—specifically, fault type taxonomies, diagnostic procedures, and component relationships authored in the initial ontology. For knowledge extracted from maintenance documents and proposed by the LLM, we maintain Open World Assumption (OWA), enabling graceful assimilation of new knowledge. Formally, for any class C or property P in the core ontology:
> - LCWA: ¬C(x) ⊑ C(x) (if not stated as false, assume true)
> - OWA for extensions: ¬C(x) ⊑ ¬C(x) (if not stated, unknown)"

### Section 5.2: Main Results - Important
**Issue**: KG reasoning accuracy (94.7%) is reported but methodology is unclear.

**Suggestion**: Add description of evaluation methodology:
> "KG reasoning accuracy was evaluated on a test set of 200 fault cases. A reasoning inference was deemed correct if: (1) all logically derived conclusions followed from ontology axioms, and (2) recommended diagnostic actions matched expert-provided ground truth. The baseline system (generic industrial KG) achieved 89.5% accuracy on the same test set."

### Section 5.3: Ablation Studies - Important
**Issue**: Ablation A1 (replacing domain KG with generic industrial KG) shows accuracy drop (77.1% vs. 92.8%) but doesn't explain the generic KG being used.

**Suggestion**: Clarify the baseline:
> "Removing our CNC-specific ontology and replacing it with a generic industrial KG [cite relevant KG] caused accuracy to drop from 92.8% to 77.1%. The generic KG lacked: (1) CNC-specific fault taxonomies, (2) equipment model-specific component relationships, and (3) domain-specific diagnostic procedures."

### SHACL Validation - Important
**Issue**: SHACL is mentioned but not demonstrated.

**Suggestion**: Add SHACL examples and validation results:

```shacl
# Example SHACL: Fault Must Have Symptom

ex:FaultShape a sh:NodeShape ;
    sh:property [
        ex:hasSymptom ex:SymptomShape ;
        ex:affectsComponent ex:ComponentShape
    ] ;
    sh:closed true .

ex:SymptomShape a sh:NodeShape ;
    sh:property ex:symptomType ;
    sh:minCount 1 ;
    sh:severity sh:Violation .

# Validation Results
# - Total SHACL shapes defined: 47
# - Faults validated: 23,700 instances
# - Violations detected: 312 (1.3%)
# - Common violations: Missing symptom (78%), Invalid component type (22%)
```

### Table 4: Ontology Statistics - Important
**Issue**: Statistics are given but completeness is not evaluated.

**Suggestion**: Add completeness assessment:
> "To evaluate ontology completeness, we compared our fault type coverage against: (1) the ISO 13347 machinery fault taxonomy [cite], and (2) a fault catalog from 5 CNC manufacturers covering 87 equipment models. Our ontology covers 94.3% of fault types in the reference taxonomy, with missing types primarily related to optional accessories and non-standard configurations."

---

## Questions for Authors

### Ontology Formalization
1. Can you provide 1-2 example ontology axioms in OWL Manchester syntax for the Fault Type Module?
2. Are there example instances showing how faults are represented in the ontology?
3. Can you show an example SWRL rule for a diagnostic heuristic?

### LCWA/OWA Specification
4. What is the precise formal definition of which parts of the ontology use LCWA vs. OWA?
5. Which specific classes and properties fall under each assumption?
6. How does the query engine handle queries that involve both LCWA and OWA concepts?

### SHACL Validation
7. How many SHACL shapes are defined in the ontology?
8. Can you provide 1-2 example SHACL shapes showing constraint definitions?
9. What validation results were obtained? How many violations detected in test data?
10. What types of violations are most common?

### Completeness Evaluation
11. What is the coverage of the ontology against the full space of CNC fault types?
12. Has completeness been evaluated against a reference taxonomy (e.g., ISO 13347)?
13. What percentage of possible fault types from equipment manuals are covered?

### Reasoning Evaluation
14. What is the test set composition for KG reasoning accuracy evaluation?
15. What constitutes a "correct" vs. "incorrect" inference in the evaluation?
16. How does the 94.7% accuracy compare to baseline systems (generic industrial KG)?
17. What types of reasoning tasks were evaluated (classification, property assertion, query answering)?

### Hybrid Reasoning
18. How are symbolic and neural reasoning results combined? Is there a voting mechanism?
19. How are conflicts between symbolic and neural results resolved?
20. What are the confidence thresholds for preferring symbolic vs. neural results?

### Ablation Clarification
21. What is the specific generic industrial KG used in Ablation A1 for comparison?
22. What were the specific deficiencies of the generic KG compared to the domain-specific ontology?

---

## Priority Action Items

### Important

1. **[Section 3.3] Add concrete ontology axioms in OWL/Manchester syntax**
   - Rationale: Actual ontology code would enable verification of formal correctness, provide implementation guidance, and allow readers to understand the concrete structure beyond textual descriptions.

2. **[Section 4.3] Formalize LCWA/OWA hybrid boundary conditions**
   - Rationale: The hybrid assumption approach is theoretically interesting but currently abstract. Precise formalization with boundary criteria is needed for theoretical rigor and implementation clarity.

3. **[Section 4.2] Provide SHACL constraint examples and validation results**
   - Rationale: SHACL validation is mentioned but not demonstrated. Examples showing constraint definitions and validation metrics would substantiate this aspect of the ontology engineering work.

4. **[Table 4 / Section 5] Add ontology completeness evaluation**
   - Rationale: Ontology size statistics are given but completeness is not evaluated. Coverage metrics against reference taxonomies or expert-defined fault catalogs are needed to assess ontology quality.

5. **[Section 5.2] Describe KG reasoning evaluation methodology**
   - Rationale: KG reasoning accuracy is reported but evaluation methodology is unclear. Test set composition, correctness criteria, and baseline comparisons must be specified.

### Minor

6. **[Section 4.1] Add DL complexity citation or justification**
   - Rationale: The EXPTIME-complete claim needs citation to standard DL complexity results or a brief justification sketch.

7. **[Section 4.2] Clarify symbolic-neural result combination mechanism**
   - Rationale: The hybrid framework combines reasoning types but the combination mechanism is not explicit. Details on voting, aggregation, or conflict resolution are needed.

8. **[Section 5.3] Specify generic industrial KG in ablation**
   - Rationale: The baseline generic KG should be identified so readers can understand the comparison and contribution of domain-specific modeling.

---

## Conclusion

This paper presents a solid knowledge graph contribution for the CNC fault diagnosis domain. The choice of ALCHIQ description logic is well-motivated, and the modular ontology design follows established best practices. The domain-specific focus provides genuine value over generic industrial knowledge graphs.

The main areas for improvement relate to ontology engineering rigor:
1. **Concrete formalization**: Adding actual OWL/Manchester syntax examples would significantly strengthen the ontology contribution
2. **Assumption specification**: Formalizing the LCWA/OWA hybrid with precise boundary conditions
3. **Validation demonstration**: Showing SHACL constraints and validation results
4. **Completeness assessment**: Evaluating ontology coverage against reference taxonomies

With these additions, the knowledge graph and ontology aspects of the paper would be substantially stronger. The current work represents a solid contribution that advances the application of KG techniques to industrial fault diagnosis.

**Recommendation**: Minor Revision
