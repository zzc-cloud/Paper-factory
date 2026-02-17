# B2: Experiment Design — Evaluation Framework for Smart Query

**Agent**: b2-experiment-designer | **Phase**: 2 | **Status**: Complete

---

## 1. Executive Summary

This document presents a comprehensive evaluation framework for Smart Query, a multi-agent, ontology-driven natural language data querying system deployed in a banking environment with 35,287 tables across 9 schemas. The framework comprises **7 precisely defined metrics** (TLA, FCR, ECS, QRR, SCS, ONE, JA), **5 baseline systems** (B0–B4) designed for controlled comparison, **6 ablation studies** (A1–A6) isolating each key architectural component, a **100-query evaluation dataset** spanning 4 complexity categories with dual-expert annotation, **5 experiment protocols** covering main comparison, ablation analysis, semantic cumulative effect measurement, efficiency analysis, and case studies, and a formal **semantic cumulative effect measurement methodology** grounded in Shannon entropy and the chain rule of conditional entropy. Every core innovation (Cognitive Hub Architecture, Implicit Context Inheritance, Semantic Cumulative Effect, Evidence Pack Fusion, Three-Layer Ontology) and supporting innovation (hybrid retrieval, dual retrieval, progressive degradation, isolated table filtering, lineage-driven JOIN, pre-computed mappings, cognitive modularity) is mapped to specific experimental validation. The framework prioritizes rigor, fairness, reproducibility, and statistical soundness.

---

## 2. Innovation-to-Experiment Mapping

Each of the 13 formalized innovations from Phase 1 is mapped to the specific baselines, ablations, protocols, and metrics that validate it:

| Innovation | Theme | Significance | Baselines | Ablations | Key Metrics |
|-----------|-------|-------------|-----------|-----------|-------------|
| 1. Cognitive Hub Architecture | A | Core | B0, B1 | A6 | TLA, FCR, ONE |
| 2. Serial Execution + Context Inheritance | B | Core | B3, B4 | A1 | TLA, SCS, ECS |
| 3. Semantic Cumulative Effect | B | Core | B4 | A1 | Entropy reduction |
| 4. Evidence Pack Fusion | B | Core | B2a-c | A2 | TLA, ECS, FCR |
| 5. Three-Layer Ontology | A | Core | B1 | A6 | TLA, ONE, FCR |
| 6. Hybrid Retrieval | C | Supporting | B1 | A5 | TLA, FCR |
| 7. Dual Retrieval | C | Supporting | B1 | A5 | TLA, FCR |
| 8. Progressive Degradation | C | Supporting | — | — | QRR, TLA (adversarial) |
| 9. Isolated Table Filtering | C | Supporting | — | A3 | Precision, FPR |
| 10. Lineage-Driven JOIN | C | Supporting | — | A4 | JA |
| 11. Pre-computed Mappings | C | Supporting | — | — | ONE, Latency |
| 12. Cognitive Modularity | A | Supporting | — | — | Compliance rate |
| 13. Multi-Scenario Ontology | D | Supporting | — | — | Future work |

---

## 3. Evaluation Metrics

### M1: Table Localization Accuracy (TLA)

**Definition**: The percentage of queries where the correct primary table is identified in the system's top-K table recommendations.

**Formula**:
$$TLA@K = \frac{|\{q \in Q : correct\_table(q) \in top\_K\_tables(q)\}|}{|Q|}$$

**Variants**:
- **TLA@1** (strict): Correct table must be the top recommendation. *Primary metric for system comparison.*
- **TLA@3** (relaxed): Correct table in top 3. *Measures whether correct table is in consideration set.*
- **TLA@5** (generous): Correct table in top 5. *Upper bound on system potential with re-ranking.*

**Measurement**: Compare system's `primary_table` output against ground truth annotation. **Significance**: Core metric — wrong table means wrong SQL. **Expected Range**: Smart Query 0.75–0.90 (TLA@1); Best baseline 0.55–0.70.

### M2: Field Coverage Rate (FCR)

**Definition**: Percentage of ground-truth relevant fields in the system's recommendations.

$$FCR(q) = |recommended\_fields(q) \cap ground\_truth\_fields(q)| / |ground\_truth\_fields(q)|$$

**Variants**: FCR-required (essential fields), FCR-all (required + optional). **Significance**: Measures field discovery completeness.

### M3: Evidence Consensus Score (ECS)

**Definition**: Agreement across three strategies on the primary table.

$$ECS(q) = |\{s \in \{S_1, S_2, S_3\} : primary\_table(s,q) = final\_table(q)\}| / 3$$

**Values**: 0.33, 0.67, 1.0. **Significance**: Higher consensus → higher confidence; validates multi-strategy design.

### M4: Query Resolution Rate (QRR)

**Definition**: Percentage of queries resolved without human clarification. **Significance**: Measures system autonomy.

### M5: Semantic Consistency Score (SCS)

**Definition**: Average pairwise Jaccard similarity of field sets across strategies.

$$SCS(q) = \frac{1}{3}[J(F_{S1},F_{S2}) + J(F_{S1},F_{S3}) + J(F_{S2},F_{S3})]$$

### M6: Ontology Navigation Efficiency (ONE)

**Definition**: Ratio of useful MCP tool calls to total tool calls. **Significance**: Validates ontology hierarchy design.

### M7: JOIN Accuracy (JA)

**Definition**: Correctness of identified JOIN conditions (Complex queries only). **Variants**: JA-recall, JA-precision, JA-F1.

---

## 4. Baseline Systems

### B0: Direct LLM Prompting (No Ontology)
- Feed user query + top-100 table descriptions directly to LLM. Tests whether ontology provides value beyond raw LLM reasoning. Same LLM, same metadata — only difference is absence of ontology.

### B1: RAG-Based Approach (Vector Search Only)
- Embed all tables with same model (paraphrase-multilingual-MiniLM-L12-v2); retrieve top-30 by cosine similarity. Tests whether ontology structure adds value beyond vector similarity. Strong state-of-the-art baseline.

### B2: Single-Strategy Variants
- **B2a** (Indicator-only), **B2b** (Scenario-only), **B2c** (Term-only). Tests whether multi-strategy fusion outperforms any single strategy. Same ontology, tools, LLM.

### B3: Independent Agents (No Shared Context)
- Three strategies in isolated contexts (fresh conversation each). Tests implicit context inheritance value. Same strategies, same adjudication.

### B4: Parallel Execution (No Serial Ordering)
- Three strategies simultaneously, then merge. Tests whether serial ordering matters for semantic cumulative effect.

---

## 5. Ablation Studies

| ID | Component Removed | Hypothesis | Most Affected | Innovations |
|----|------------------|-----------|---------------|-------------|
| A1 | Implicit Context Inheritance | TLA@1 drops 10-20% | Complex, Adversarial | 2, 3 |
| A2 | Evidence Pack Fusion | TLA@1 drops 5-15% | Complex queries | 4 |
| A3 | Isolated Table Filtering | Precision drops 5-10% | Deprecated table schemas | 9 |
| A4 | Lineage-Driven JOIN | JA drops 15-25% | Multi-table queries | 10 |
| A5 | Dual Retrieval | FCR drops 10-15% | Non-standard terminology | 6, 7 |
| A6 | Ontology Hierarchy | ONE drops significantly | Ambiguous queries | 1, 5 |

### A1: Remove Implicit Context Inheritance
Each strategy receives only the original user query (no conversation history). Strategies still execute serially but without context sharing. **Hypothesis**: TLA@1 drops 10-20%; Strategy 3 suffers most. **Control**: Full Smart Query.

### A2: Remove Evidence Pack Fusion
Use only the highest-scoring single strategy's recommendation. **Hypothesis**: TLA@1 drops 5-15%; Complex queries suffer most. **Control**: Full Smart Query.

### A3: Remove Isolated Table Filtering
Include all tables regardless of lineage heat. **Hypothesis**: Precision drops 5-10% from deprecated tables. **Control**: Full Smart Query.

### A4: Remove Lineage-Driven JOIN
Replace with schema-based column name matching. **Hypothesis**: JA drops 15-25% due to ambiguous column names. **Control**: Full Smart Query.

### A5: Remove Dual Retrieval
Strategy 2 uses only convergent path (no hybrid search). **Hypothesis**: FCR drops 10-15%; synonym tables missed. **Control**: Full Smart Query.

### A6: Remove Ontology Hierarchy (Flat Search)
Search all indicators and tables in flat lists. **Hypothesis**: ONE drops significantly; ambiguous queries degrade. **Control**: Full Smart Query.

---

## 6. Dataset Specification: BankQuery-100

**Total**: 100 real banking queries (anonymized) across 4 complexity categories.

| Category | Count | Description | Example |
|----------|-------|-------------|---------|
| Simple | 30 | Single table, direct mapping | "查询客户贷款余额" |
| Medium | 40 | Multiple fields, disambiguation needed | "查询客户AUM和风险等级" |
| Complex | 20 | Multi-table JOIN, aggregation | "各分行中小企业贷款余额排名" |
| Adversarial | 10 | Ambiguous terms, deprecated tables | "查询ABC指标增长趋势" |

**Annotation Protocol**: Two independent domain experts (5+ years banking data experience). Cohen's kappa ≥ 0.80 required. Third expert adjudicates disagreements.

**Ground Truth Fields**: primary_table, required_fields[], optional_fields[], join_conditions[], complexity_category, ambiguity_notes.

**Dataset Splits**: 20 development (for tuning) + 80 test (for final evaluation, no tuning allowed).

**Quality Requirements**: Unique correct primary table per query; both required and optional fields annotated; exact JOIN conditions specified; coverage of all 9 schemas.

---

## 7. Experiment Protocols

### P1: Main Comparison (Smart Query vs. Baselines)
1. Configure all 8 systems with identical LLM (temperature=0)
2. Run each system on all 100 queries in randomized order
3. Record: primary_table, recommended_fields, evidence_packs, tool_call_logs, time, tokens
4. Compute TLA@1/3/5, FCR, QRR, ECS, SCS, JA for each system
5. Paired bootstrap test (10,000 resamples, p < 0.05) with Bonferroni correction
6. Report by: overall, complexity category, schema

### P2: Ablation Study
1. Run full Smart Query (control) and 6 ablation variants on all 100 queries
2. Compute Δ_metric = metric(full) − metric(ablated) for each ablation
3. Identify most affected query categories per ablation
4. Statistical significance via paired bootstrap; rank ablations by impact

### P3: Semantic Cumulative Effect Measurement
1. Instrument Smart Query to record state after each strategy
2. Extract candidate table probability distributions at each stage
3. Compute Shannon entropy: H_k = −Σ P_k(t) · log₂(P_k(t))
4. Verify monotonic decrease: H_0 > H_1 > H_2 > H_3
5. Compute cumulative reduction ratio: CRR = (H_0 − H_3) / H_0
6. Compare serial (Smart Query) vs. parallel (B4) vs. independent (B3)
7. Validate: correlation between CRR and TLA@1

### P4: Efficiency Analysis
1. Record wall-clock time, token usage, tool call counts per query
2. Compute ONE for Smart Query and applicable baselines
3. Analyze efficiency vs. accuracy tradeoff (Pareto frontier)

### P5: Case Study Analysis
1. Select 5 representative queries (1 per category + 1 failure case)
2. Trace complete execution paths through all strategies
3. Document context inheritance, evidence fusion, and entropy reduction in practice

---

## 8. Semantic Cumulative Effect Measurement

### Theoretical Foundation

**Theorem (SCE)**: For target information I and strategy evidence S₁, S₂, S₃:

$$H(I|S_1,S_2,S_3) \leq H(I|S_1,S_2) \leq H(I|S_1) \leq H(I)$$

**Proof**: By the chain rule: H(I|S₁,...,Sₖ) = H(I|S₁,...,Sₖ₋₁) − I(I; Sₖ|S₁,...,Sₖ₋₁). Since conditional mutual information I(I; Sₖ|S₁,...,Sₖ₋₁) ≥ 0, the inequality follows. Strict inequality holds when strategies explore orthogonal knowledge dimensions.

### Measurement Stages

| Stage | Distribution | Expected Entropy |
|-------|-------------|-----------------|
| H₀ (before any strategy) | Uniform over 35,287 tables | ~15.11 bits |
| H₁ (after Indicator) | Weighted by indicator match scores | 8-12 bits (clear matches) |
| H₂ (after Scenario) | Combined indicator + scenario evidence | 4-8 bits |
| H₃ (after Term) | Full evidence pack | 1-4 bits |

### Probability Distribution Construction

After strategy k, extract tables from evidence pack with confidence scores. Normalize: P_k(t) = (1−ε_total) · score_k(t) / Σ scores + ε/N for unmentioned tables. Background ε = 0.001 ensures non-zero probability.

### Expected Patterns
- **Monotonic decrease** for >80% of queries
- **CRR > 0.70** on average; >0.85 for Simple; >0.50 for Adversarial
- **Serial vs. parallel gap**: 5-15% lower final entropy for serial execution

### Visualizations
1. **Line chart**: Entropy vs. stage by complexity category (with 95% CI)
2. **Box plot**: ΔH distribution at each stage transition
3. **Heatmap**: Per-query entropy trajectories (100 queries × 4 stages)
4. **Scatter plot**: CRR vs. TLA@1 (validation that reduction predicts accuracy)

---

## 9. Expected Results Summary

### Main Comparison Hypotheses

| Comparison | Metric | Expected Gap | Rationale |
|-----------|--------|-------------|-----------|
| SQ vs. B0 (Direct LLM) | TLA@1 | +25-35% | Ontology enables systematic navigation |
| SQ vs. B1 (RAG) | TLA@1 | +15-25% | Hierarchy + cross-layer > flat vectors |
| SQ vs. Best B2 (Single) | TLA@1 | +10-20% | Multi-strategy covers blind spots |
| SQ vs. B3 (Independent) | TLA@1 | +10-15% | Context inheritance enables refinement |
| SQ vs. B4 (Parallel) | TLA@1 | +5-10% | Serial ordering enables cumulative effect |

### Ablation Impact Hypotheses

| Ablation | Primary Metric | Expected Drop | Most Affected |
|---------|---------------|--------------|---------------|
| A1 (no context) | TLA@1 | −10-20% | Complex, Adversarial |
| A2 (no fusion) | TLA@1 | −5-15% | Complex |
| A3 (no filtering) | Precision | −5-10% | Deprecated table schemas |
| A4 (no lineage JOIN) | JA-F1 | −15-25% | Multi-table queries |
| A5 (no dual retrieval) | FCR | −10-15% | Non-standard terminology |
| A6 (no hierarchy) | ONE | Significant | Ambiguous queries |

---

## 10. Statistical Analysis Plan

- **Primary test**: Paired bootstrap (10,000 resamples, α = 0.05)
- **Multiple comparisons**: Bonferroni correction
- **Effect size**: Cohen's d (small=0.2, medium=0.5, large=0.8)
- **Non-parametric**: Wilcoxon signed-rank when normality violated
- **Confidence intervals**: 95% bootstrap CIs for all estimates
- **Binary outcomes**: McNemar's test for correct/incorrect per query
- **Correlations**: Spearman rank for ordinal relationships
- **Reporting**: Mean ± SE; significance stars (*p<0.05, **p<0.01, ***p<0.001); effect sizes alongside p-values; complete results including negative findings