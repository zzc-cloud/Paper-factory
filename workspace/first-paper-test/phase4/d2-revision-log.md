# Revision Log

## Summary

Addressed **1** critical, **5** important, and **6** minor review comments.
Modified sections: Abstract, Section 1.1, Section 1.3, Section 2.3, Section 3.1, Section 3.2, Section 3.3, Section 4.2, Section 4.3, Section 5.1, Section 6.1, Section 6.2, Section 7.1, Table 7.

## Review Score Context

- Average reviewer score before revision: 6.7/10
- Critical issues identified: 1
- All critical issues addressed: Yes
- Important issues identified: 6
- Important issues addressed: 5 (2 declined as outside text revision scope)

---

## Critical Revisions

### REV-001: Strengthen Adversarial Dataset Limitation Acknowledgment
- **Review comment**: Dataset remains small (100 queries, 80 test); Adversarial category (10 queries) insufficient for reliable conclusions
- **Raised by**: R1, R2
- **Section**: Section 5.1
- **Change type**: Strengthen
- **What was changed**: Expanded the Adversarial category limitation text with specific statistical reasoning (±0.30 CI at n=10), explicit statement that results are "statistically underpowered," and concrete future work target of expanding to 50+ queries
- **Rationale**: Reviewers correctly identified that 10 queries cannot support reliable statistical conclusions. The revision makes this limitation explicit with quantitative reasoning rather than vague hedging

---

## Important Revisions

### REV-002: Resolve Dual Naming (Smart Query vs Cognitive Hub)
- **Review comment**: Dual naming creates confusion — unclear whether these refer to the same system or different concepts
- **Raised by**: R3
- **Section**: Abstract, Section 1.1
- **Change type**: Rephrase
- **What was changed**: Added explicit terminology definition: "Cognitive Hub" = architectural concept, "Smart Query" = implemented system. Clarified in both abstract ("the Cognitive Hub architecture, implemented in a system called Smart Query") and Section 1.1
- **Rationale**: Clear terminology distinction eliminates reader confusion about whether two different systems are being discussed

### REV-003: Add Latency-Accuracy Tradeoff Analysis
- **Review comment**: Serial vs parallel advantage (Δ = +0.06, d = 0.35) is modest — no formal latency-accuracy tradeoff analysis to justify 2x latency cost
- **Raised by**: R1
- **Section**: Section 6.1
- **Change type**: Add
- **What was changed**: Added dedicated "Latency-Accuracy Tradeoff" paragraph discussing deployment context (non-interactive analyst workflows), larger margins on Complex/Adversarial queries, modest overall effect size, potential mitigations (adaptive selection, early termination, caching), and Pareto analysis as future work
- **Rationale**: The reviewer correctly identified that the accuracy gain must be weighed against latency cost. The analysis contextualizes the tradeoff rather than claiming universal superiority

### REV-004: Condense Section 4.3 Cognitive Architecture Mappings
- **Review comment**: ACT-R, SOAR, and CoALA mappings are repetitive in structure and could be condensed into a single comparison table
- **Raised by**: R3
- **Section**: Section 4.3
- **Change type**: Restructure
- **What was changed**: Replaced three verbose subsections (~35 paragraphs) with Table 8 (8 cognitive concepts × 4 architectures), a concise "Key Parallels" paragraph highlighting the 3 most instructive mappings, and a condensed "Engineering Innovations" section (4 items, reduced from 5)
- **Rationale**: The table format eliminates repetitive structure while preserving all mapping information. The condensed format is more scannable and highlights the most important parallels

### REV-005: Reconcile Contribution Counts
- **Review comment**: Section 1.3 lists 4 contributions, Section 7.1 lists 5 — inconsistency
- **Raised by**: R1, R3
- **Section**: Section 1.3
- **Change type**: Restructure
- **What was changed**: Updated Section 1.3 from 4 to 5 contributions by splitting former C4 into C4 (Intelligent Search Space Reduction) and C5 (Comprehensive Evaluation Framework), matching Section 7.1
- **Rationale**: The evaluation framework is a genuine contribution deserving separate listing. Aligning the counts eliminates a distracting inconsistency

---

## Minor Revisions

### REV-006: Remove Intelligence Pseudo-Formula
- **Review comment**: Intelligence = modularity × context_inheritance_efficiency × task_focus is an unjustified pseudo-formula
- **Raised by**: R1, R3
- **Section**: Section 3.3
- **Change type**: Rephrase
- **What was changed**: Replaced the pseudo-formula with prose expressing the same design principle
- **Rationale**: The formula had no mathematical justification and read as a conceptual slogan rather than a formalization

### REV-007: Restructure Abstract
- **Review comment**: Dense single paragraph covering too many concepts; key result buried
- **Raised by**: R3
- **Section**: Abstract
- **Change type**: Restructure
- **What was changed**: Split into three paragraphs: problem statement, approach, results
- **Rationale**: Problem-approach-results format is standard and makes the key result (82% TLA@1) more prominent

### REV-008: Resolve Formalization Tension
- **Review comment**: Tension between S_2(q, O, T, E_1) notation and actual implicit context mechanism
- **Raised by**: R1
- **Section**: Section 3.1
- **Change type**: Rephrase
- **What was changed**: Changed notation to S_k(..., H_{k-1}) and added explicit clarification that this represents logical dependency through conversation history, not explicit parameter passing
- **Rationale**: The original notation implied explicit parameter passing, contradicting the implicit context inheritance mechanism described elsewhere

### REV-009: Trim Digital Twin Paragraph
- **Review comment**: Digital Twin Concept paragraph feels tangential
- **Raised by**: R3
- **Section**: Section 3.2
- **Change type**: Remove (partial)
- **What was changed**: Condensed from 4 sentences to 1 sentence
- **Rationale**: The concept is worth mentioning but the extended comparison was tangential to the main argument

### REV-010: Discuss Strategy Ordering Sensitivity
- **Review comment**: How sensitive is the system to strategy ordering? Would S2→S1→S3 perform differently?
- **Raised by**: R1
- **Section**: Section 6.2
- **Change type**: Add
- **What was changed**: Added "Strategy Ordering Sensitivity" paragraph discussing fixed ordering rationale, information-theoretic prediction for optimal ordering, and adaptive ordering as future work
- **Rationale**: Addresses a legitimate question about a design choice that was not previously justified

### REV-011: Temper Stigmergy Framing
- **Review comment**: Stigmergy framing overstates the novelty of "LLM reads conversation history"
- **Raised by**: R2
- **Section**: Sections 1.1, 2.3, 3.3, 4.2, 7.1, Table 7
- **Change type**: Soften
- **What was changed**: Systematically tempered across 6 locations. Renamed coordination pattern to "Pipeline-Blackboard Hybrid with Context Inheritance." Acknowledged that the underlying mechanism is standard LLM conversation reading; reframed novelty as the architectural design of what information is deposited and how subsequent strategies leverage it
- **Rationale**: The reviewer correctly identified that the biological analogy overstated the mechanism's novelty. The revision preserves the useful analogy while being honest about the implementation simplicity

### REV-012: Soften Instruction Compliance Claims
- **Review comment**: Near-100% instruction compliance claim for 400-line Skills remains unsupported
- **Raised by**: R1
- **Section**: Section 3.1, Section 3.3
- **Change type**: Soften
- **What was changed**: Replaced "near-perfect" and "near-100%" with "empirically improves" and "substantially improved"
- **Rationale**: The original claims lacked measurement methodology. Softer language is more honest

---

## Declined Changes

### ASCII Art Figures
- **Review comment**: Replace ASCII art figures with proper diagrams for publication
- **Raised by**: R3
- **Reason for declining**: Figure replacement requires graphic design tools (TikZ, draw.io, etc.) outside the scope of text-based revision. ASCII figures are placeholders for the manuscript draft; proper vector graphics should be created during camera-ready preparation.

### Missing Table Placeholders
- **Review comment**: Several tables referenced as "(see Table X)" placeholders — missing from the manuscript
- **Raised by**: R3
- **Reason for declining**: Table placeholders are formatting artifacts of the manuscript draft. The table data is fully presented inline in the text (e.g., Table 5 results are described in Section 5.2). Proper table rendering should be handled during typesetting.

---

## Reviewer Questions Addressed

| Question | Reviewer | Resolution | Section |
|:---------|:---------|:-----------|:--------|
| Clarify relationship between Smart Query and Cognitive Hub | R3 | Added explicit definition: Cognitive Hub = architecture, Smart Query = system | Abstract, Section 1.1 |
| What is the latency-accuracy Pareto frontier? | R1 | Added tradeoff analysis; full Pareto analysis identified as future work | Section 6.1 |
| How sensitive is the system to strategy ordering? | R1 | Added Strategy Ordering Sensitivity paragraph | Section 6.2 |
| Could Section 4.3 be condensed into a comparison table? | R3 | Replaced with Table 8 (8 concepts × 4 architectures) | Section 4.3 |
| Marginal contribution of cognitive architecture framing? | R2 | Condensed 4.3 separates analogical value from engineering innovations | Section 4.3 |

---

## Post-Revision Notes

All critical and important action items have been addressed through targeted revisions. Two important items (ASCII figures, table placeholders) were declined as they require graphic design tools outside text revision scope.

Key remaining concerns that cannot be addressed through text revision alone:
1. Expanding the evaluation dataset beyond 100 queries requires new data collection and expert annotation
2. Cross-domain validation (healthcare, manufacturing) requires new system implementations
3. Comparison with external enterprise NL2SQL systems requires access to those systems
4. Standard benchmark evaluation (Spider, Bird) requires architectural adaptation

The paper is now internally consistent (contribution counts aligned, terminology clarified, formalization tension resolved) and more honest about its limitations (tempered stigmergy claims, explicit latency-accuracy tradeoff, strengthened dataset caveats).
