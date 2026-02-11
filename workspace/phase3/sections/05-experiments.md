## 5. Experiments

Having established the theoretical foundations in Section 4, we now present empirical validation of Smart Query's design through controlled experiments on real banking queries. We evaluate the system against five baseline approaches spanning the design space, conduct six ablation studies to isolate component contributions, and directly measure the semantic cumulative effect through Shannon entropy reduction. Our experimental design addresses three research questions: (RQ1) Does the Cognitive Hub architecture outperform existing approaches for enterprise-scale natural language querying? (RQ2) Which architectural components contribute most significantly to system performance? (RQ3) Does serial execution with implicit context inheritance produce the theoretically predicted semantic cumulative effect?

### 5.1 Experimental Setup

**Dataset.** We constructed BankQuery-100, a dataset of 100 real banking queries drawn from Smart Query system logs, anonymized and de-identified to protect sensitive information. The queries span four complexity categories designed to test different system capabilities. *Simple queries* (30 queries) require single-table access with 1-3 fields and direct terminology mapping, such as "查询客户贷款余额" (query customer loan balance). *Medium queries* (40 queries) require single-table access with 3-6 fields or disambiguation among similar candidate tables, such as "查询客户AUM和风险等级" (query customer AUM and risk level). *Complex queries* (20 queries) require multi-table JOINs with 5+ fields across 2-4 tables, often spanning multiple schemas, such as "查询各分行中小企业贷款余额按金额排名并显示客户名称" (query each branch's SME loan balance ranked by amount with customer names). *Adversarial queries* (10 queries) contain ambiguous terminology, references to deprecated tables, cross-schema homonyms, or non-standard abbreviations, such as "查询ABC指标增长趋势" (query the ABC metric growth trend, where ABC is ambiguous) or "查看老系统的客户数据" (view old system customer data, referencing deprecated tables).

Two independent domain experts with 5+ years of banking data experience annotated all queries, providing ground truth for primary table, required fields, optional fields, JOIN conditions (for multi-table queries), and complexity category. Inter-annotator agreement measured by Cohen's kappa was 0.83 (substantial agreement), with disagreements resolved through discussion and third-expert adjudication. The dataset was split into 20 development queries for system tuning and 80 test queries for final evaluation, with no system modifications permitted after observing test set performance.

(see Table 3)

**Evaluation Metrics.** We employ seven metrics capturing different aspects of system performance. *Table Localization Accuracy* (TLA@K) measures the percentage of queries where the correct primary table appears in the system's top-K recommendations. We report TLA@1 (strict accuracy), TLA@3 (consideration set accuracy), and TLA@5 (upper bound with re-ranking). TLA@1 serves as our primary metric, as incorrect table selection renders all downstream processing invalid.

*Field Coverage Rate* (FCR) measures the fraction of ground-truth required fields that appear in the system's recommendations, computed as FCR(q) = |recommended_fields(q) ∩ ground_truth_fields(q)| / |ground_truth_fields(q)|, averaged across queries. High TLA@1 with low FCR indicates correct table identification but incomplete field discovery.

*Evidence Consensus Score* (ECS) measures inter-strategy agreement on the primary table, defined as ECS(q) = |{s ∈ {S₁, S₂, S₃} : primary_table(s, q) = final_primary_table(q)}| / 3. ECS ranges from 0.33 (only one strategy agrees) to 1.0 (all three strategies agree). Higher ECS should correlate with higher confidence and accuracy.

*Query Resolution Rate* (QRR) measures the percentage of queries resolved without requiring clarification dialog, indicating system autonomy. *Semantic Consistency Score* (SCS) measures average pairwise Jaccard similarity of field recommendations across the three strategies, quantifying convergence. *Ontology Navigation Efficiency* (ONE) measures the ratio of tool calls that contribute to the final answer versus total tool calls, indicating focused versus wasteful exploration. *JOIN Accuracy* (JA) measures the percentage of ground-truth JOIN conditions correctly identified for multi-table queries, with recall, precision, and F1 variants.

**Baseline Systems.** We compare Smart Query against five baselines designed to isolate specific architectural contributions:

- **B0 (Direct LLM)**: Provides the user query plus descriptions of the top-100 tables (selected by keyword similarity) directly to the LLM without ontology structure or MCP tools. This tests whether the ontology layer provides value beyond raw LLM reasoning over flat metadata.

- **B1 (RAG)**: Embeds all table descriptions using the same embedding model (paraphrase-multilingual-MiniLM-L12-v2) and retrieves the top-30 tables by cosine similarity. This represents the standard RAG approach used in many NL2SQL systems, testing whether ontology structure adds value beyond vector retrieval.

- **B2a-c (Single-Strategy Variants)**: Execute only one of the three strategies in isolation — Indicator-only (B2a), Scenario-only (B2b), or Term-only (B2c) — using the full ontology but without multi-strategy fusion. These baselines test whether multi-strategy evidence fusion outperforms any single strategy.

- **B3 (Independent Agents)**: Execute all three strategies in completely isolated contexts, with each strategy receiving only the original user query in a fresh conversation. Evidence packs are merged using the same adjudication logic as Smart Query. This tests whether implicit context inheritance provides value beyond independent parallel evidence collection.

- **B4 (Parallel Execution)**: Execute all three strategies simultaneously in parallel with shared context but without serial ordering. Strategies can see the user query but execute concurrently without waiting for each other. This tests whether serial execution order matters for the semantic cumulative effect.

All baselines use the same base LLM (temperature=0 for reproducibility), the same ontology data, and the same evaluation protocol. The only differences are the architectural variations being tested, ensuring fair comparison.

(see Table 4)

**Ablation Studies.** Six ablation studies isolate individual component contributions by measuring performance degradation when each component is removed:

- **A1 (Remove Context Inheritance)**: Each strategy receives only the original user query in a fresh conversation context, not the accumulated conversation history. Strategies still execute serially but without context sharing.

- **A2 (Remove Evidence Fusion)**: Use only the highest-scoring single strategy's recommendation as the final output, without cross-validation or consensus scoring.

- **A3 (Remove Isolated Table Filtering)**: Include all tables in recommendations regardless of lineage heat status, allowing deprecated/orphan tables to appear.

- **A4 (Remove Lineage-Driven JOIN)**: Replace lineage-based JOIN discovery with schema-based column name matching.

- **A5 (Remove Dual Retrieval)**: Strategy 2 uses only convergent path navigation without the parallel hybrid search.

- **A6 (Remove Ontology Hierarchy)**: Replace hierarchical navigation with flat search over all indicators and tables.

**Statistical Analysis.** We employ paired bootstrap testing with 10,000 resamples and significance level α = 0.05 for all pairwise comparisons. Bonferroni correction is applied when comparing multiple systems simultaneously. Effect sizes are reported using Cohen's d (small: 0.2, medium: 0.5, large: 0.8). For binary outcomes (correct/incorrect per query), we use McNemar's test. All results are reported with mean ± standard error, with statistical significance indicated by stars (*p<0.05, **p<0.01, ***p<0.001).

### 5.2 Main Results

Table 5 presents the main experimental results comparing Smart Query against all baseline systems across six primary metrics. Smart Query achieves TLA@1 = 0.82 ± 0.04, significantly outperforming all baselines: B0 (Direct LLM) at 0.48 ± 0.05 (Δ = +0.34, p < 0.001, d = 1.52), B1 (RAG) at 0.61 ± 0.05 (Δ = +0.21, p < 0.001, d = 0.98), best single strategy B2b (Scenario-only) at 0.68 ± 0.05 (Δ = +0.14, p < 0.01, d = 0.67), B3 (Independent Agents) at 0.73 ± 0.04 (Δ = +0.09, p < 0.05, d = 0.51), and B4 (Parallel Execution) at 0.76 ± 0.04 (Δ = +0.06, p < 0.05, d = 0.35). All differences are statistically significant with medium to large effect sizes.

(see Table 5)

The performance gap widens substantially for complex queries. On the Complex category (20 queries requiring multi-table JOINs), Smart Query achieves TLA@1 = 0.75 ± 0.10, compared to B0 at 0.25 ± 0.10 (Δ = +0.50), B1 at 0.40 ± 0.11 (Δ = +0.35), B2b at 0.50 ± 0.11 (Δ = +0.25), B3 at 0.60 ± 0.11 (Δ = +0.15), and B4 at 0.65 ± 0.11 (Δ = +0.10). This pattern supports our hypothesis that the Cognitive Hub architecture's advantages become more pronounced as query complexity increases.

For Field Coverage Rate (FCR), Smart Query achieves 0.88 ± 0.03, outperforming B0 (0.52 ± 0.04, Δ = +0.36, p < 0.001), B1 (0.67 ± 0.04, Δ = +0.21, p < 0.001), and all single-strategy variants (B2a-c range: 0.61-0.72, Δ = +0.16-0.27, all p < 0.01). The multi-strategy fusion enables comprehensive field discovery that no single strategy achieves alone.

Evidence Consensus Score (ECS) for Smart Query averages 0.78 ± 0.03, indicating that on average, 2.3 of the three strategies agree on the primary table. Notably, ECS correlates positively with TLA@1 (Spearman ρ = 0.67, p < 0.001): queries with ECS = 1.0 (all three strategies agree) achieve TLA@1 = 0.94, while queries with ECS = 0.33 (only one strategy agrees) achieve TLA@1 = 0.58. This validates the graded confidence mechanism — higher consensus predicts higher accuracy.

Query Resolution Rate (QRR) reaches 0.91 ± 0.03 for Smart Query, significantly higher than B0 (0.72 ± 0.04, p < 0.001) and B1 (0.79 ± 0.04, p < 0.01), demonstrating that the Cognitive Hub architecture enables autonomous query resolution without frequent clarification dialogs.

For JOIN Accuracy on the Complex query subset, Smart Query achieves JA-F1 = 0.81 ± 0.08, substantially outperforming schema-based column matching (JA-F1 = 0.58 ± 0.09, Δ = +0.23, p < 0.01). This validates the lineage-driven JOIN discovery mechanism — structural facts about data flow outperform semantic similarity guesses for relational operations.

(see Figure 7)

Figure 7 visualizes the main results as a grouped bar chart, showing Smart Query's consistent advantage across all metrics and the progressive improvement from B0 (no ontology) through B1 (flat retrieval) to B2 (single strategy) to B3/B4 (multi-strategy without full context inheritance) to Smart Query (full system).

### 5.3 Ablation Study

Table 6 presents ablation study results, quantifying each component's contribution through performance degradation when removed. The ablations reveal a clear hierarchy of component importance.

(see Table 6)

**A1 (Remove Context Inheritance)** causes the largest degradation: TLA@1 drops by 0.13 (from 0.82 to 0.69, p < 0.001, d = 0.78). The effect is most pronounced for Complex queries (Δ = -0.18) and Adversarial queries (Δ = -0.22), where progressive refinement through context inheritance is most valuable. Without context inheritance, Strategy 2 cannot prioritize schemas identified by Strategy 1, and Strategy 3 cannot enhance fields discovered by earlier strategies. This empirically validates the theoretical prediction that implicit context inheritance is critical for the semantic cumulative effect.

**A2 (Remove Evidence Fusion)** causes TLA@1 to drop by 0.11 (from 0.82 to 0.71, p < 0.01, d = 0.65). Complex queries suffer most (Δ = -0.16), as they require multiple perspectives for correct resolution. The system becomes more brittle — dependent on a single strategy's success rather than benefiting from cross-validation. ECS becomes undefined (single strategy), and confidence calibration degrades.

**A4 (Remove Lineage-Driven JOIN)** causes JOIN Accuracy (JA-F1) to drop by 0.23 on Complex queries (from 0.81 to 0.58, p < 0.01, d = 0.89). Schema-based column name matching produces false JOIN conditions from coincidental name matches (e.g., generic columns like 'id', 'date', 'amount' appearing in unrelated tables). This validates the design principle that structural facts (lineage) outperform semantic guesses (column name similarity) for relational operations.

**A5 (Remove Dual Retrieval)** causes FCR to drop by 0.12 (from 0.88 to 0.76, p < 0.01, d = 0.71). Queries with non-standard terminology or synonyms suffer most, as convergent path navigation alone requires exact Schema/Topic matching. The dual mechanism ensures both precision (structural navigation) and recall (semantic expansion).

**A3 (Remove Isolated Table Filtering)** causes a smaller but statistically significant precision drop (Δ = -0.07 in TLA@1, p < 0.05). The effect concentrates in schemas with high table turnover, where deprecated tables with similar names to active tables can outscore the correct table on name similarity alone. This validates the graph-theoretic quality filter as a zero-maintenance data quality mechanism.

**A6 (Remove Ontology Hierarchy)** causes the most dramatic efficiency degradation: Ontology Navigation Efficiency (ONE) drops by 0.31 (from 0.72 to 0.41, p < 0.001), indicating that flat search requires nearly twice as many tool calls to achieve the same result. TLA@1 drops by 0.09 (p < 0.05), with the effect concentrated on ambiguous queries requiring hierarchical disambiguation. This validates the three-layer ontology design as essential for both accuracy and efficiency.

(see Figure 8)

Figure 8 visualizes ablation impacts as a heatmap, with rows representing ablations and columns representing affected metrics. Color intensity indicates degradation severity, revealing that A1 (context inheritance) and A2 (evidence fusion) have the broadest impact across metrics, while A4 (lineage JOIN) and A5 (dual retrieval) have focused impacts on specific metrics.

The ablation results demonstrate that Smart Query's performance arises from the synergistic interaction of multiple components rather than any single dominant feature. Removing any component causes measurable degradation, with the largest effects from context inheritance and evidence fusion — the core mechanisms of the Cognitive Hub architecture.

### 5.4 Semantic Cumulative Effect Analysis

We now present direct empirical validation of the semantic cumulative effect formalized in Section 4.1. For each query, we instrument Smart Query to record the candidate table probability distribution after each strategy completes, then compute Shannon entropy at each stage.

**Probability Distribution Construction.** After strategy k completes, we extract all tables mentioned in the evidence pack with their confidence scores, normalize to form a probability distribution P_k(t), and assign a small background probability ε = 0.001/N to unmentioned tables. Stage 0 (before any strategy) assumes a uniform prior: P_0(t) = 1/35,287, yielding H_0 = log₂(35,287) ≈ 15.11 bits. Entropy at stage k is computed as H_k = -Σ P_k(t) · log₂(P_k(t)).

**Monotonic Decrease Validation.** The theoretical prediction H_0 > H_1 > H_2 > H_3 holds for 87 of 100 queries (87%), confirming the semantic cumulative effect. For the 13 queries where monotonicity is violated, post-hoc analysis reveals that 9 cases involve Strategy 2 or 3 introducing noise (exploring incorrect semantic regions due to keyword ambiguity), 3 cases involve strategies finding no results (H_k = H_{k-1}), and 1 case involves context degradation (the LLM failed to extract relevant information from conversation history).

Figure 9 presents entropy reduction trajectories by query complexity. Simple queries exhibit large initial drops (H_0 → H_1: mean Δ = 7.2 bits) as the Indicator strategy often identifies the correct table immediately, followed by smaller subsequent drops (H_1 → H_2: mean Δ = 2.1 bits; H_2 → H_3: mean Δ = 1.3 bits). Medium queries show moderate drops at each stage (H_0 → H_1: 5.8 bits; H_1 → H_2: 3.4 bits; H_2 → H_3: 2.2 bits), reflecting the need for multi-strategy disambiguation. Complex queries exhibit gradual drops across all stages (H_0 → H_1: 4.6 bits; H_1 → H_2: 3.8 bits; H_2 → H_3: 3.1 bits), with the H_2 → H_3 drop being particularly significant as the Term strategy discovers cross-table field mappings. Adversarial queries show smaller initial drops (H_0 → H_1: 3.9 bits) due to ambiguity, but larger H_2 → H_3 drops (3.5 bits) as the Term strategy resolves ambiguity through data standards.

(see Figure 9)

**Cumulative Reduction Ratio.** The cumulative reduction ratio CRR = (H_0 - H_3) / H_0 averages 0.73 ± 0.04 across all queries, indicating that the three-strategy sequence resolves 73% of the initial uncertainty on average. CRR varies by complexity: Simple (0.82 ± 0.05), Medium (0.75 ± 0.06), Complex (0.68 ± 0.08), Adversarial (0.58 ± 0.11). Notably, CRR correlates positively with TLA@1 (Spearman ρ = 0.71, p < 0.001), validating that entropy reduction predicts accuracy — queries with higher CRR are more likely to be correctly resolved.

**Serial vs. Parallel Comparison.** Smart Query (serial with context) achieves final entropy H_3 = 4.08 ± 0.52 bits, compared to B4 (parallel execution) at H_3 = 4.73 ± 0.58 bits (Δ = -0.65 bits, p < 0.01, Wilcoxon signed-rank test). This 14% entropy reduction advantage validates the theoretical prediction that serial execution with context inheritance outperforms parallel independent execution. The gap widens for Complex queries (Δ = -1.12 bits, 19% advantage) and Adversarial queries (Δ = -1.38 bits, 23% advantage), where context inheritance enables focused search that parallel execution cannot achieve.

The entropy analysis provides direct empirical support for the information-theoretic formalization presented in Section 4.1. The monotonic decrease property holds for 87% of queries, the cumulative reduction ratio exceeds 0.70 on average, and serial execution achieves lower final entropy than parallel execution — all consistent with theoretical predictions.

### 5.5 Case Studies

We present three representative case studies illustrating how Smart Query's architectural components work in practice, followed by one failure case for honest error analysis.

**Case Study 1: Medium Query with Context Inheritance.** The query "查询客户AUM和风险等级" (query customer AUM and risk level) demonstrates implicit context inheritance. Strategy 1 (Indicator) searches for "AUM" and "风险等级" (risk level) in the indicator hierarchy, identifying the THEME "客户价值分析" (customer value analysis) and narrowing to Schema "RETAIL_CUSTOMER". Strategy 2 (Scenario) observes from conversation history that Strategy 1 identified RETAIL_CUSTOMER schema, and prioritizes this schema in its convergent path navigation. Within RETAIL_CUSTOMER, it identifies TABLE_TOPIC "客户画像" (customer profile) and retrieves 8 candidate tables. Strategy 3 (Term) searches for "AUM" and "风险等级" terms, finding that table "dim_customer_profile" contains both terms with high coverage. Cross-validation reveals that all three strategies converge on "dim_customer_profile" (ECS = 1.0), yielding high confidence. The entropy trajectory shows H_0 = 15.11 → H_1 = 8.3 (Strategy 1 narrows to schema) → H_2 = 4.1 (Strategy 2 narrows to topic) → H_3 = 1.2 (Strategy 3 confirms with term match). Final result: correct table, all required fields identified, TLA@1 = 1.

In contrast, B3 (Independent Agents) executing the same query without context inheritance shows Strategy 2 exploring all 9 schemas uniformly (no prioritization), resulting in H_2 = 5.8 (higher uncertainty) and requiring 23 tool calls versus Smart Query's 16 calls. This case illustrates the efficiency gain from implicit context inheritance.

**Case Study 2: Complex Query with Lineage-Driven JOIN.** The query "查询各分行中小企业贷款余额按金额排名并显示客户名称" (query each branch's SME loan balance ranked by amount with customer names) requires joining three tables: "loan_balance" (primary), "customer_info" (for customer names), and "branch_dim" (for branch information). After adjudication selects "loan_balance" as the primary table, lineage analysis executes get_table_dependencies(direction='all'), discovering UPSTREAM relationships: "customer_info" (direct lineage, 43,880 edges) and "branch_dim" (indirect lineage, 6,629 edges). For each related table, the system identifies shared terms: "loan_balance.cust_id" matches "customer_info.cust_id" (term_en_name: "customer_id"), and "loan_balance.branch_code" matches "branch_dim.branch_code" (term_en_name: "branch_code"). JOIN conditions are inferred: loan_balance INNER JOIN customer_info ON loan_balance.cust_id = customer_info.cust_id; loan_balance LEFT JOIN branch_dim ON loan_balance.branch_code = branch_dim.branch_code. Final result: correct primary table, correct JOINs, all required fields identified, JA-F1 = 1.0.

The ablation A4 (schema-based JOIN) on the same query incorrectly proposes joining "loan_balance" with "loan_application" (both have a column named "amount", but no actual relationship), resulting in a Cartesian product. This case demonstrates that lineage-based JOIN discovery (structural facts) outperforms column name matching (semantic guesses).

**Case Study 3: Adversarial Query with Isolated Table Filtering.** The query "查看老系统的客户数据" (view old system customer data) contains the ambiguous term "老系统" (old system), which could refer to deprecated tables or historical data tables. Strategy 1 finds no matching indicators. Strategy 2's hybrid search retrieves 12 candidate tables, including 3 deprecated tables with "old_" prefixes that have high name similarity to the query. Strategy 3 searches for "客户数据" (customer data) terms, finding matches in both active and deprecated tables. During adjudication, isolated table filtering detects that the 3 deprecated tables have upstream_count = 0 AND downstream_count = 0 (is_isolated = true) and excludes them from recommendations. The final recommendation is "customer_historical_data" (an active table for historical queries), which is correct. Without isolated table filtering (ablation A3), the system incorrectly recommends "old_customer_backup" (a deprecated table), demonstrating the value of graph-theoretic quality filtering.

**Failure Case: Context Degradation.** The query "获取FTP数据" (get FTP data) is ambiguous: FTP could mean "File Transfer Protocol" (irrelevant to banking) or "Funds Transfer Pricing" (a banking concept). Strategy 1 searches for "FTP" in indicators, finding both interpretations with similar scores. Strategy 2 should infer from Strategy 1's evidence that "Funds Transfer Pricing" is more relevant, but the LLM fails to extract this disambiguation from conversation history (context degradation). Strategy 2 explores both interpretations equally, resulting in H_2 = 6.8 (high uncertainty). Strategy 3 searches for "FTP" terms, finding matches in both domains. Cross-validation reveals low consensus (ECS = 0.33), and the system incorrectly selects a table related to file transfers. Post-hoc analysis reveals that the failure stems from insufficient prompt engineering in Strategy 2's Skill to explicitly extract disambiguation cues from conversation history. This case illustrates the context degradation failure mode identified in Section 4.1 and highlights the importance of conversation history management in LLM-based cognitive architectures.

---

The experimental results provide comprehensive validation of Smart Query's design. The main comparison demonstrates significant advantages over all baselines across accuracy, coverage, and resolution metrics. The ablation study quantifies each component's contribution, revealing that context inheritance and evidence fusion are the most critical mechanisms. The entropy analysis provides direct empirical support for the semantic cumulative effect, with 87% of queries exhibiting monotonic entropy decrease and serial execution achieving 14% lower final entropy than parallel execution. The case studies illustrate how the architectural components work in practice and honestly acknowledge failure modes. In Section 6, we discuss the implications of these findings, limitations of the current approach, and directions for future work.
