# Peer Review Report — Iteration 3 (FINAL)

## Paper: Cognitive Hub: A Multi-Agent Architecture for Ontology-Driven Natural Language Data Querying at Enterprise Scale

**Review Date:** 2026-02-11
**Iteration:** 3 (FINAL)
**Previous Scores:** 6.0/10 (Iter 1, Major Revision) → 6.7/10 (Iter 2, Minor Revision)
**Current Score:** 7.3/10 (Minor Revision, Accept-Leaning)

---

## Review History

| Iteration | Average Score | Recommendation | Key Changes |
|:----------|:-------------|:---------------|:------------|
| 1 | 6.0/10 | Major revision | Initial review |
| 2 | 6.7/10 | Minor revision | Addressed 1 critical, 5 important, 6 minor issues |
| **3 (FINAL)** | **7.3/10** | **Minor revision (accept-leaning)** | **All prior critical/important issues resolved** |

## Summary

This paper presents the Cognitive Hub architecture, implemented in a system called Smart Query, which transforms a domain ontology from passive knowledge storage into an active cognitive layer for LLM-based reasoning over enterprise-scale databases (35,000+ tables). Three specialized agents — Indicator Expert, Scenario Navigator, and Term Analyst — execute serially over a three-layer ontology (314K nodes, 623K relationships), with each agent exploring an orthogonal knowledge dimension and producing structured evidence packs. Cross-validation fusion with graded confidence scoring selects the primary table, while lineage-driven analysis discovers JOIN conditions from ETL data flow. The paper provides information-theoretic analysis of the "semantic cumulative effect" and validates the architecture on 100 real banking queries against five baselines, achieving 82% top-1 table accuracy. The paper has been revised twice based on prior review feedback, with all critical and most important issues addressed.

---

## Reviewer 1: Technical Expert

**Score**: 7.5/10
**Recommendation**: Minor revision
### Strengths
1. **Well-designed ablation study** (A1-A6) with clear hierarchy of component importance and appropriate statistical testing (paired bootstrap, Bonferroni correction, effect sizes)
2. **Information-theoretic analysis correctly scoped**: the entropy chain is presented as applying standard tools (chain rule, non-negativity of mutual information) to a new architectural context, not as novel theory
3. **Serial vs. parallel comparison honestly framed** as a hypothesis validated empirically rather than a proven theorem, with the intuitive argument clearly separated from the formal derivation
4. **Failure mode analysis** (redundancy, noise introduction, context degradation) is technically valuable and grounded in the information-theoretic framework
5. **Lineage-driven JOIN discovery** well-motivated with concrete comparison to column-name matching (JA-F1 = 0.81 vs 0.58, p < 0.01, d = 0.89)
6. **Entropy measurement methodology** includes an honest circularity caveat about LLM-generated confidence scores
7. **Formalization CH = (O, S, T, L)** now consistent with implicit context inheritance through the H_{k-1} notation clarification
8. **B3 vs B4 baseline distinction** now clear (sequential-without-context vs concurrent-without-context)

### Weaknesses
1. **Dataset size** (100 queries, 80 test) remains the primary limitation; while honestly acknowledged, the wide confidence intervals (±0.10 for Complex, ±0.30 for Adversarial) limit fine-grained conclusions
2. **Serial vs. parallel accuracy gap** (Δ = +0.06, d = 0.35) is small-to-medium effect size — the latency-accuracy tradeoff discussion is welcome but a formal Pareto analysis remains future work
3. **Strategy ordering sensitivity** discussed but not empirically evaluated — the claim that S₁ provides the most informative initial constraint is plausible but unvalidated
4. **Entropy measurement methodology**: the probability distribution construction (normalizing LLM confidence scores, ε = 0.001/N for unmentioned tables) involves choices that could influence results; no sensitivity analysis provided
5. **No cross-validation** beyond the 20/80 dev-test split — with only 80 test queries, overfitting to the test distribution is a concern despite the stated protocol

### Detailed Comments

#### Section 1: Introduction
- [Minor] The cognitive architecture framing is well-scoped with appropriate citations (ACT-R, SOAR, CoALA). The entropy chain is correctly presented. The five contributions are now consistently enumerated. The terminology distinction (Cognitive Hub = architecture, Smart Query = system) resolves prior confusion. No changes needed.

#### Section 3: Architecture
- [Minor] The three-strategy design is well-motivated. The formalization using H_{k-1} notation correctly represents the implicit context mechanism. Instruction compliance claims are appropriately softened. *Suggestion*: Add a brief note on how the 50/50 keyword-vector ratio in hybrid retrieval was determined.

#### Section 4: Theory
- [Minor] Significantly improved across all three iterations. The CRR metric is well-defined. The parallel vs. serial comparison is appropriately framed as a hypothesis. *Suggestion*: Note how non-uniform priors (e.g., table popularity) would affect the CRR calculation.

#### Section 5: Experiments
- [Minor] Experimental design is sound with well-chosen baselines. Statistical reporting is rigorous. Dataset limitations thoroughly acknowledged. *Suggestion*: Report exact p-values for Smart Query vs. B4 comparison given the modest effect size.

#### Section 6: Discussion
- [Minor] The latency-accuracy tradeoff analysis is a valuable addition. Strategy ordering sensitivity discussion addresses a legitimate concern. No substantive changes needed.

### Questions for Authors
1. How does the system degrade when the ontology is partially incomplete (e.g., 50% of indicators missing)?
2. What is the variance in performance across different LLM backends (GPT-4, open-source models)?
3. For the 13% of queries where monotonic entropy decrease fails, is there a pattern in which strategy pair causes the violation?
4. How was ε = 0.001/N chosen for entropy measurement, and how sensitive are results to this choice?

---

## Reviewer 2: Novelty Expert

**Score**: 7.0/10
**Recommendation**: Minor revision

### Strengths
1. **Enterprise-scale NL2SQL** (35K+ tables) is genuinely underserved in the literature — this paper addresses a real gap
2. **Lineage-driven JOIN discovery** using pre-computed ETL relationships is genuinely novel and practically valuable
3. **Evidence pack fusion with graded confidence** is more sophisticated than existing voting/averaging; the ECS-accuracy correlation (ρ = 0.67) validates its utility
4. **Three-layer ontology design** enabling orthogonal navigation strategies is well-motivated — the separation reflects genuine knowledge dimensions
5. **Explicit technical comparisons** with GraphRAG and Think-on-Graph (Table 7, Section 2.4) clearly differentiate the approach
6. **Pipeline-Blackboard Hybrid with Context Inheritance** label (revised from "Stigmergic") is now more honest about the mechanism
7. **Cognitive architecture framing** (Table 8) is condensed and positioned as analogical rather than formal — more intellectually honest

### Weaknesses
1. **Core contribution is a novel configuration** of known components (ontology + multi-agent + LLM) rather than a fundamental conceptual advance — acknowledged implicitly but could be stated more directly
2. **Single-domain evaluation** (banking only) limits assessment of claimed domain-agnostic architecture — healthcare/manufacturing examples are speculative
3. **No comparison with existing enterprise-scale NL2SQL systems** (if any exist in industry) — baselines are all author-constructed
4. **Information-theoretic analysis provides limited actionable insight** beyond confirming that more evidence reduces uncertainty — CRR is descriptive rather than prescriptive
5. **Reproducibility is limited**: proprietary dataset, proprietary ontology, specific LLM — another team cannot replicate core results

### Detailed Comments

#### Section 1: Introduction
- [Minor] Problem motivation is compelling. Five contributions clearly enumerated and appropriately scoped. *Suggestion*: Consider softening "to our knowledge, this is the first system" to "among the first systems."

#### Section 2: Related Work
- [Minor] Comprehensive across four research areas. GraphRAG and Think-on-Graph comparisons are valuable. *Suggestion*: Brief mention of industry NL2SQL tools would acknowledge the commercial landscape.

#### Section 4: Theory
- [Minor] Information-theoretic analysis appropriately scoped. Table 8 is much improved. "Engineering Innovations Beyond Classical Architectures" correctly identifies what is genuinely new.

#### Section 5: Experiments
- [Minor] Evaluation is thorough within its constraints. Honest acknowledgment of dataset limitations is commendable. *Suggestion*: Brief discussion of what a synthetic enterprise-scale NL2SQL benchmark might look like.

#### Section 6: Discussion
- [Minor] Generalizability discussion appropriately speculative. Multi-scenario extension idea is interesting. Limitations section is thorough and honest.

### Questions for Authors
1. Could the architecture be validated on a publicly available large-schema dataset to improve reproducibility?
2. How does the system handle queries spanning knowledge dimensions not captured by the three-layer ontology?
3. What is the marginal contribution of the cognitive architecture framing beyond providing useful vocabulary?
4. Is there evidence that the three-layer structure generalizes beyond banking?

---

## Reviewer 3: Clarity Expert

**Score**: 7.5/10
**Recommendation**: Minor revision
### Strengths
1. **Well-organized** with logical flow: Introduction → Related Work → Architecture → Theory → Experiments → Discussion → Conclusion
2. **Terminology distinction** (Cognitive Hub = architecture, Smart Query = system) resolves dual-naming confusion from earlier iterations
3. **Abstract well-structured** in three paragraphs (problem, approach, results) with key result prominently placed
4. **Table 8** (cognitive architecture mapping) is a significant improvement over verbose subsections — scannable and informative
5. **Case studies** effectively illustrate architectural components in practice; failure case adds credibility
6. **Formalization** now consistent with implicit context mechanism, resolving notation tension
7. **Section 2.4 comparisons** use clear three-point structure that is easy to follow
8. **Statistical reporting** consistent throughout (mean ± SE, p-values, effect sizes)

### Weaknesses
1. **Missing inline tables**: Tables 2-6 referenced as "(see Table X)" placeholders — results described only in prose, hindering readability
2. **ASCII art figures**: Figures 2, 5, 6, 7, 8, 9 are placeholders that significantly reduce visual communication
3. **Paper length** (~8,800 words excluding references) — Discussion (Section 6) repeats findings from Section 5
4. **Section 3.3 repetitive**: each strategy description follows the same template (phases, evidence pack, effectiveness) that could be streamlined
5. **Chinese query examples**: authentic but may be inaccessible to non-Chinese readers; translations provided but Chinese text takes visual space

### Detailed Comments

#### Abstract
- [Minor] Well-structured. Key result prominent. *Suggestion*: Remove one instance of "to our knowledge" (appears in both abstract and introduction).

#### Section 1: Introduction
- [Minor] Clear problem motivation. Five contributions well-enumerated. *Suggestion*: Shorten Section 1.4 (Paper Organization) to 2-3 sentences.

#### Section 2: Related Work
- [Minor] Well-structured. GraphRAG/Think-on-Graph comparisons effective. *Suggestion*: Smoother transition between Sections 2.3 and 2.4.

#### Section 3: Architecture
- [Minor] Architecture clearly described. Formalization consistent. *Suggestion*: Render Table 2 inline rather than as placeholder to reduce repetitive prose.

#### Section 5: Experiments
- [Important] **Missing inline tables (Tables 3-6) force readers to reconstruct results from prose.** This is the single most impactful presentation improvement remaining. Render these tables inline.

#### Section 6: Discussion
- [Minor] Thorough but repetitive of Section 5. *Suggestion*: Tighten Section 6.1 by focusing on interpretation rather than restating numbers.

### Questions for Authors
1. Will the final submission include proper vector graphics for all figures?
2. Can Tables 2-6 be rendered inline in the manuscript?
3. Would a notation table or glossary help readers track the various symbols?
4. Is the paper length appropriate for the target venue?

---

## Consolidated Review

**Average Score**: 7.3/10
**Overall Recommendation**: Minor revision (accept-leaning)

### Score Progression Across Iterations

```
Iteration 1:  R1=6.5  R2=5.5  R3=6.0  → Avg=6.0  (Major revision)
Iteration 2:  R1=7.0  R2=6.0  R3=7.0  → Avg=6.7  (Minor revision)
Iteration 3:  R1=7.5  R2=7.0  R3=7.5  → Avg=7.3  (Minor revision, accept-leaning)
```

### Priority Action Items

#### Important
1. **Render Tables 2-6 as formatted inline tables** instead of "(see Table X)" placeholders (Sections 3.3, 5.1, 5.2, 5.3) — Raised by: R3. *This is the single most impactful remaining improvement. Results tables are essential for reader comprehension.*
2. **Replace ASCII art figures with proper vector graphics** for camera-ready submission (Figures 2, 5, 6, 7, 8, 9) — Raised by: R3. *ASCII art is acceptable for draft review but inadequate for publication.*

#### Minor
3. **Report exact p-values** for Smart Query vs. B4 comparison rather than p < 0.05, given the modest effect size d = 0.35 (Section 5.2) — Raised by: R1
4. **Add note on hybrid retrieval ratio**: explain how the 50/50 keyword-vector ratio was determined (Section 3.3) — Raised by: R1
5. **Add note on non-uniform priors**: briefly discuss how table popularity priors would affect CRR calculation (Section 4.1) — Raised by: R1
6. **Soften first-system claim**: consider "among the first systems" to hedge against unpublished industry systems (Abstract, Section 1.3) — Raised by: R2
7. **Tighten Section 6.1**: reduce repetition of numerical results already in Sections 5.2-5.4; focus on interpretation (Section 6.1) — Raised by: R3
8. **Shorten Section 1.4**: Paper Organization paragraph is standard boilerplate; 2-3 sentences suffice (Section 1.4) — Raised by: R3
9. **Mention industry NL2SQL tools**: brief acknowledgment of commercial landscape in Related Work (Section 2.1) — Raised by: R2
10. **Remove duplicate phrase**: "to our knowledge" appears in both abstract and introduction; remove one instance — Raised by: R3

### Overall Assessment

This paper has improved substantially across three review iterations (6.0 → 6.7 → 7.3), demonstrating responsive and thoughtful revision. The core contribution — transforming a domain ontology into an active cognitive layer for LLM-based enterprise-scale data querying — addresses a genuine and underserved gap in the NL2SQL literature. No existing system tackles the scale of 35,000+ tables with structured domain knowledge navigation.

**What works well.** The paper's strengths are considerable: a well-designed evaluation with five baselines and six ablation studies, rigorous statistical reporting, honest acknowledgment of limitations (dataset size, reproducibility, latency tradeoffs), correctly scoped theoretical analysis that applies standard information-theoretic tools to a new architectural context, and clear differentiation from prior work through explicit technical comparisons. The revisions have successfully addressed all critical issues from prior rounds — the information-theoretic claims are appropriately positioned, the stigmergy framing has been tempered, the formalization is internally consistent, and the contribution counts are aligned. The lineage-driven JOIN discovery and evidence pack fusion with graded confidence are genuinely novel contributions with practical value.

**What needs improvement.** The remaining weaknesses fall into two categories. First, inherent scope limitations that the authors acknowledge transparently: single-domain evaluation, small dataset (100 queries), proprietary data limiting reproducibility, and the modest serial-vs-parallel effect size (d = 0.35). These are honest tradeoffs of a real-world systems paper and do not warrant rejection. Second, presentation polish items needed for camera-ready preparation: inline tables, proper figures, and minor tightening of repetitive sections. These are straightforward to address.

**Recommendation.** The panel recommends **minor revision with an accept-leaning disposition**. No critical issues remain. The two important items (inline tables, proper figures) are formatting tasks rather than intellectual concerns. The minor items are polish suggestions that would improve the paper but are not essential for acceptance. The paper makes a solid contribution to the intersection of NL2SQL, knowledge representation, and multi-agent systems, with practical relevance for enterprise AI deployment. The primary value lies in the architectural design and empirical validation rather than theoretical novelty, which is appropriate for a systems-oriented contribution at venues like VLDB, SIGMOD, or AAAI.
