# 会议/期刊配置文件

> 此文件是论文生成系统**唯一的会议/期刊配置源**。所有预定义和用户自定义的会议/期刊配置都在这里。
> 系统在启动论文生成时会读取此文件，根据用户指定的 `target_venue` 查找对应配置并应用格式化规则。
>
> **V2 新增**多交互式论文生成流程 — 预定义期刊现在包含写作风格配置，用于生成 `venue-style-guide.md`，指导后续 Phase 的写作风格适配。

---

## 预定义会议列表

以下系统预定义的会议/期刊配置，可以直接使用或作为参考模板多

### AAAI

```yaml
AAAI:
  full_name: "AAAI Conference on Artificial Intelligence"
  type: "conference"
  format: "double-column"
  page_limit: 8
  template: "aaai25"
  keywords: ["AAAI", "artificial intelligence", "AI conference"]
  deadline_note: "通常在 8-9 月截稿"

  # 写作风格配置（V2 新增）
  writing_style:
    abstract_length: {min: 200, max: 250, recommended: 225}
    abstract_structure: ["motivation", "approach", "results", "conclusion"]
    intro_depth: "medium"
    intro_length: {min: 800, max: 1200}
    related_work_depth: "comprehensive"
    related_work_organization: "thematic"
    method_detail: "high"
    algorithm_description: "pseudo_code_required"
    theory_proof: "optional"
    experiment_format: "standard"
    required_evaluations: ["accuracy", "efficiency", "scalability", "comparison_with_baselines"]
    statistical_tests: ["t-test", "anova", "significance"]
    discussion_focus: ["insights", "limitations", "future_work"]
    conclusion_length: {min: 300, max: 500}

  review_criteria:
    novelty_weight: 0.35
    technical_weight: 0.40
    presentation_weight: 0.25
    required_evaluations: ["originality", "significance", "technical_quality", "clarity"]
    special_attention: ["reproducibility", "ethical_considerations"]

  paper_types: ["full_paper"]
  theoretical_ratio: {min: 0.1, max: 0.6}

  historical_data:
    acceptance_rate: 0.23
    review_cycle: "3-4 months"
    trending_topics: ["LLM agents", "neuro-symbolic AI", "multi-agent coordination", "reasoning_under_uncertainty"]
```

### IJCAI

```yaml
IJCAI:
  full_name: "International Joint Conference on Artificial Intelligence"
  type: "conference"
  format: "single-column"
  page_limit: 8
  template: "ijcai25"
  keywords: ["IJCAI", "IJCAI", "artificial intelligence"]
  deadline_note: "通常在 1 月截稿"

  writing_style:
    abstract_length: {min: 200, max: 250, recommended: 225}
    abstract_structure: ["problem", "approach", "contribution", "results"]
    intro_depth: "deep"
    intro_length: {min: 1000, max: 1500}
    related_work_depth: "critical"
    related_work_organization: "comparative"
    method_detail: "very_high"
    algorithm_description: "detailed_pseudocode"
    theory_proof: "recommended"
    experiment_format: "extended"
    required_evaluations: ["correctness_proofs", "complexity_analysis", "empirical_validation"]
    statistical_tests: ["confidence_intervals", "significance_tests"]
    discussion_focus: ["theoretical_insights", "limitations", "future_directions"]
    conclusion_length: {min: 400, max: 600}

  review_criteria:
    novelty_weight: 0.40
    technical_weight: 0.40
    presentation_weight: 0.20
    required_evaluations: ["originality", "significance", "theoretical_soundness", "clarity"]
    special_attention: ["formal_correctness", "comparative_analysis"]

  paper_types: ["full_paper"]
  theoretical_ratio: {min: 0.3, max: 0.8}

  historical_data:
    acceptance_rate: 0.20
    review_cycle: "4-5 months"
    trending_topics: ["constraint_satisfication", "automated_planning", "knowledge_representation"]
```

### ISWC

```yaml
ISWC:
  full_name: "International Semantic Web Conference"
  type: "conference"
  format: "single-column"
  page_limit: 15
  template: "iswc2025"
  keywords: ["ISWC", "Semantic Web", "knowledge graph"]
  deadline_note: "通常在 10-11 月截稿"

  writing_style:
    abstract_length: {min: 250, max: 300, recommended: 275}
    abstract_structure: ["background", "challenge", "contribution", "evaluation"]
    intro_depth: "medium"
    intro_length: {min: 900, max: 1400}
    related_work_depth: "comprehensive"
    related_work_organization: "thematic"
    method_detail: "high"
    algorithm_description: "algorithm_plus_ontology"
    theory_proof: "optional"
    experiment_format: "standard"
    required_evaluations: ["ontology_quality", "reasoning_capability", "scalability"]
    statistical_tests: ["significance", "effect_size"]
    discussion_focus: ["semantic_insights", "limitaions", "future_research"]
    conclusion_length: {min: 350, max: 550}

  review_criteria:
    novelty_weight: 0.30
    technical_weight: 0.40
    presentation_weight: 0.30
    required_evaluations: ["originality", "technical_quality", "evaluation_clarity", "reproducibility"]
    special_attention: ["ontology_design", "linking_quality", "use_case_relevance"]

  paper_types: ["full_paper", "in_progress", "doctoral_symposium"]
  theoretical_ratio: {min: 0.2, max: 0.5}

  historical_data:
    acceptance_rate: 0.25
    review_cycle: "3-4 months"
    trending_topics: ["knowledge_graphs", "ontology_aligment", "RDF_STAR", "query_optimization"]
```

### WWW

```yaml
WWW:
  full_name: "The Web Conference"
  type: "conference"
  format: "double-column"
  page_limit: 8
  template: "www2025"
  keywords: ["WWW", "Web Conference", "web conference"]
  deadline_note: "通常在 10-11 月截稿"

  writing_style:
    abstract_length: {min: 200, max: 250, recommended: 225}
    abstract_structure: ["background", "problem", "solution", "evaluation"]
    intro_depth: "medium"
    intro_length: {min: 800, max: 1200}
    related_work_depth: "comprehensive"
    related_work_organization: "thematic"
    method_detail: "high"
    algorithm_description: "system_architecture"
    theory_proof: "optional"
    experiment_format: "standard"
    required_evaluations: ["user_study", "performance", "scalability", "real_world_applicability"]
    statistical_tests: ["t-test", "anova", "significance"]
    discussion_focus: ["practical_implications", "limitations", "future_work"]
    conclusion_length: {min: 300, max: 500}

  review_criteria:
    novelty_weight: 0.35
    technical_weight: 0.35
    presentation_weight: 0.30
    required_evaluations: ["originality", "significance", "technical_quality", "presentation_quality"]
    special_attention: ["real_world_impact", "user_evaluations", "ethical_considerations"]

  paper_types: ["full_paper", "poster", "demo"]
  theoretical_ratio: {min: 0.1, max: 0.4}

  historical_data:
    acceptance_rate: 0.22
    review_cycle: "3-4 months"
    trending_topics: ["web_privacy", "decentralized_systems", "AI_assisted_development", "accessibility"]
```

### ACL

```yaml
ACL:
  full_name: "Association for Computationa Linguistics"
  type: "conference"
  format: "double-column"
  page_limit: 8
  template: "acl2025"
  keywords: ["ACL", "computationa linguistics", "NLP"]
  deadline_note: "通常在 2 月截稿"

  writing_style:
    abstract_length: {min: 200, max: 250, recommended: 225}
    abstract_structure: ["background", "method", "results", "conclusions"]
    intro_depth: "medium"
    intro_length: {min: 800, max: 1200}
    related_work_depth: "comprehensive"
    related_work_organization: "thematic"
    method_detail: "high"
    algorithm_description: "model_architecture"
    theory_proof: "optional"
    experiment_format: "standard"
    required_evaluations: ["benchmark_performance", "ablation_study", "error_analysis"]
    statistical_tests: ["significance", "confidence_intervals", "bootstrap"]
    discussion_focus: ["linguistic_insights", "error_analysis", "future_work"]
    conclusion_length: {min: 300, max: 500}

  review_criteria:
    novelty_weight: 0.35
    technical_weight: 0.40
    presentation_weight: 0.25
    required_evaluations: ["originality", "technical_soundness", "evaliation_rigor", "clarity"]
    special_attention: ["baseline_comparisons", "statistical_significance", "reproducibility"]

  paper_types: ["full_paper", "short_paper", "findings"]
  theoretical_ratio: {min: 0.1, max: 0.3}

  historical_data:
    acceptance_rate: 0.25
    review_cycle: "3-4 months"
    trending_topics: ["arge_language_models", "efficiency", "multilinguality", "low_resource_NLP"]
```

### EMNLP

```yaml
EMNLP:
  full_name: "Conference on Empirical Methods in Natural Language Processing"
  type: "conference"
  format: "double-column"
  page_limit: 8
  template: "emnlp2025"
  keywords: ["EMNLP", "EMNLP", "NLP", "natural language processing"]
  deadline_note: "通常在 5-6 月截稿"

  writing_style:
    abstract_length: {min: 200, max: 250, recommended: 225}
    abstract_structure: ["introduction", "method", "experiments", "conclusions"]
    intro_depth: "brief"
    intro_length: {min: 600, max: 1000}
    related_work_depth: "focused"
    related_work_organization: "method_oriented"
    method_detail: "very_high"
    algorithm_description: "detailed_model_description"
    theory_proof: "not_required"
    experiment_format: "extended"
    required_evaluations: ["benchmark_results", "ablation", "statistical_significance", "error_analysis"]
    statistical_tests: ["significance", "bootstrap", "confidence_intervals"]
    discussion_focus: ["empirical_insights", "limitations", "future_research"]
    conclusion_length: {min: 300, max: 500}

  review_criteria:
    novelty_weight: 0.30
    technical_weight: 0.45
    presentation_weight: 0.25
    required_evaluations: ["technical_novelty", "experimental_rigor", "reproducibility", "clarity"]
    special_attention: ["statistical_validity", "baselines", "data_availability"]

  paper_types: ["full_paper", "short_paper"]
  theoretical_ratio: {min: 0.05, max: 0.2}

  historical_data:
    acceptance_rate: 0.22
    review_cycle: "3-4 months"
    trending_topics: ["instruction_tuning", "efficiency", "parameter_efficient_methods", "multilingual_benchmarks"]
```

### KR

```yaml
KR:
  full_name: "IEEE International Conference on Knowledge Representation"
  type: "conference"
  format: "single-column"
  page_limit: 10
  template: "kr2025"
  keywords: ["KR", "knowledge representation", "reasoning"]
  deadline_note: "通常在 11 月截稿"

  writing_style:
    abstract_length: {min: 200, max: 250, recommended: 225}
    abstract_structure: ["motivation", "contribution", "technical_details", "evaluation"]
    intro_depth: "deep"
    intro_length: {min: 1000, max: 1500}
    related_work_depth: "comprehensive"
    related_work_organization: "thematic"
    method_detail: "very_high"
    algorithm_description: "formal_description"
    theory_proof: "recommended"
    experiment_format: "standard"
    required_evaluations: ["correctness", "complexity", "scalability"]
    statistical_tests: ["significance"]
    discussion_focus: ["theoretical_insights", "limitations", "future_work"]
    conclusion_length: {min: 400, max: 600}

  review_criteria:
    novelty_weight: 0.35
    technical_weight: 0.45
    presentation_weight: 0.20
    required_evaluations: ["originality", "technical_soundness", "clarity", "significance"]
    special_attention: ["formal_correctness", "comparative_analysis", "theoretical_contributions"]

  paper_types: ["full_paper", "short_paper"]
  theoretical_ratio: {min: 0.4, max: 0.9}

  historical_data:
    acceptance_rate: 0.28
    review_cycle: "4-5 months"
    trending_topics: ["neurosymbolic_AI", "description_logic", "ontological_aligment", "explainable_AI"]
```

### AAMAS

```yaml
AAMAS:
  full_name: "International Conference on Autonomous Agents and Multiagent Systems"
  type: "conference"
  format: "double-column"
  page_limit: 8
  template: "aamas2025"
  keywords: ["AAMAS", "autonomous agents", "multiagent systems"]
  deadline_note: "通常在 5-6 月截稿"

  writing_style:
    abstract_length: {min: 200, max: 250, recommended: 225}
    abstract_structure: ["background", "problem", "approach", "contribution", "evaluation"]
    intro_depth: "medium"
    intro_length: {min: 800, max: 1200}
    related_work_depth: "comprehensive"
    related_work_organization: "thematic"
    method_detail: "high"
    algorithm_description: "agent_protocol_plus_pseudocode"
    theory_proof: "optional"
    experiment_format: "standard"
    required_evaluations: ["coordination_efficiency", "scalability", "robustness", "simulation_validity"]
    statistical_tests: ["significance", "confidence_intervals"]
    discussion_focus: ["agent_insights", "limitations", "future_directions"]
    conclusion_length: {min: 300, max: 500}

  review_criteria:
    novelty_weight: 0.35
    technical_weight: 0.40
    presentation_weight: 0.25
    required_evaluations: ["originality", "technical_quality", "evaliation_rigor", "clarity"]
    special_attention: ["agent_coordination", "scalability", "real_world_applicability"]

  paper_types: ["full_paper", "short_paper", "demo"]
  theoretical_ratio: {min: 0.2, max: 0.5}

  historical_data:
    acceptance_rate: 0.24
    review_cycle: "3-4 months"
    trending_topics: ["LLM_agents", "multi_agent_coordination", "decentralized_decision_making", "human_agent_teams"]
```

### TOIS (期刊)

```yaml
TOIS:
  full_name: "ACM Transactions on Information Systems"
  type: "journal"
  format: "single-column"
  page_limit: null
  template: "acm-transactions"
  keywords: ["TOIS", "ACM TOIS", "information systems", "journal"]
  deadline_note: "期刊，全年可投稿"

  writing_style:
    abstract_length: {min: 250, max: 300, recommended: 275}
    abstract_structure: ["background", "problem", "contribution", "results", "implications"]
    intro_depth: "deep"
    intro_length: {min: 1200, max: 2000}
    related_work_depth: "comprehensive"
    related_work_organization: "thematic"
    method_detail: "very_high"
    algorithm_description: "detailed_system_description"
    theory_proof: "optional"
    experiment_format: "extended"
    required_evaluations: ["performance", "usability", "scalability", "user_satisfaction"]
    statistical_tests: ["significance", "effect_size", "confidence_intervals"]
    discussion_focus: ["practical_implications", "limitations", "future_research", "broader_impact"]
    conclusion_length: {min: 500, max: 800}

  review_criteria:
    novelty_weight: 0.35
    technical_weight: 0.35
    presentation_weight: 0.30
    required_evaluations: ["originality", "significance", "technical_quality", "presentation", "practical_impact"]
    special_attention: ["real_world_relevance", "user_evaluations", "ethical_considerations"]

  paper_types: ["full_paper", "survey", "reproducibility_summary"]
  theoretical_ratio: {min: 0.1, max: 0.4}

  historical_data:
    acceptance_rate: 0.20
    review_cycle: "6-12 months"
    trending_topics: ["information_retrieval", "user_behavior", "data_management", "system_security"]
```

### TKDE (期刊)

```yaml
TKDE:
  full_name: "ACM Transactions on Knowledge Discovery from Data"
  type: "journal"
  format: "single-column"
  page_limit: null
  template: "acm-transactions"
  keywords: ["TKDE", "ACM TKDE", "knowledge discovery", "data mining", "journal"]
  deadline_note: "期刊，全年可投稿"

  writing_style:
    abstract_length: {min: 250, max: 300, recommended: 275}
    abstract_structure: ["background", "problem", "method", "experiments", "conclusions"]
    intro_depth: "deep"
    intro_length: {min: 1200, max: 2000}
    related_work_depth: "comprehensive"
    related_work_organization: "thematic"
    method_detail: "very_high"
    algorithm_description: "detailed_algorithm"
    theory_proof: "optional"
    experiment_format: "extended"
    required_evaluations: ["predictive_accuracy", "efficiency", "scalability", "statistical_significance"]
    statistical_tests: ["significance", "confidence_intervals", "effect_size", "multiple_comparison_correction"]
    discussion_focus: ["data_insights", "limitations", "future_research", "domain_impact"]
    conclusion_length: {min: 500, max: 800}

  review_criteria:
    novelty_weight: 0.35
    technical_weight: 0.40
    presentation_weight: 0.25
    required_evaluations: ["originality", "technical_quality", "evaliation_rigor", "clarity"]
    special_attention: ["statistical_validity", "baselines", "data_availability", "reproducibility"]

  paper_types: ["full_paper", "survey", "alorithm"]
  theoretical_ratio: {min: 0.1, max: 0.4}

  historical_data:
    acceptance_rate: 0.18
    review_cycle: "6-12 months"
    trending_topics: ["fairness", "interpretability", "autoML", "graph_neural_networks", "time_series_mining"]
```

---

## 添加自定义会议/期刊

如果你的目标会议/期刊不在上方预定义列表中，可以在此处添加自定义配置。

### 配置模板（V2 更新）

```yaml
[VENUE_ID]:
  full_name: "[会议/期刊全称]"
  type: "[conference | journal]"
  format: "[single-column | double-column]"
  page_limit: [数字 | null]
  template: "[模板标识符]"
  keywords: ["关键词1", "关键词2", "..."]
  deadline_note: "[截稿提示]"

  # 写作风格配置（V2 新增）
  writing_style:
    abstract_length: {min: 数字, max: 数字, recommended: 数字}
    abstract_structure: ["元素1", "元素2", "..."]
    intro_depth: "[brief | medium | deep]"
    intro_length: {min: 数字, max: 数字}
    related_work_depth: "[selective | comprehensive | critical]"
    related_work_organization: "[thematic | historical | comparative]"
    method_detail: "[brief | medium | high | very_high]"
    algorithm_description: "[描述要求]"
    theory_proof: "[optional | recommended | required]"
    experiment_format: "[standard | compact | extended]"
    required_evaluations: ["评估指标1", "评估指标2", "..."]
    statistical_tests: ["统计检验1", "统计检验2", "..."]
    discussion_focus: ["讨论点1", "讨论点2", "..."]
    conclusion_length: {min: 数字, max: 数字}

  review_criteria:
    novelty_weight: 0.X
    technical_weight: 0.X
    presentation_weight: 0.X
    required_evaluations: ["评估标准1", "评估标准2", "..."]
    special_attention: ["特别注意点1", "特别注意点2", "..."]

  paper_types: ["论文类型1", "论文类型2", "..."]
  theoretical_ratio: {min: 0.X, max: 0.X}

  historical_data:
    acceptance_rate: 0.XX
    review_cycle: "[审稿周期]"
    trending_topics: ["热点1", "热点2", "..."]
```

### 字段说明

| 字段 | 说明 | 示例 |
|------|------|------|
| `[VENUE_ID]` | 会议/期刊唯一标识符（使用简短英文字母） | `ICSE-2025`、`CHI-2025` |
| `full_name` | 会议/期刊完整名称 | International Conference on Software Engineering |
| `type` | 类型（conference 或 journal） | conference |
| `format` | 格式（single-column 或 double-column） | double-column |
| `page_limit` | 页数限制（数字或 null） | 12 或 null |
| `template` | 模板标识符（用于内部识别） | icse2025 |
| `keywords` | 关键词列表（用于文献搜索） | ["software engineering", "ICSE"] |
| `deadline_note` | 截稿时间提示 | 通常在 8-9 月截稿 |

### 写作风格配置说明

| 子字段 | 说明 | 可选值 |
|--------|------|--------|
| `abstract_length` | 摘要字数范围 | {min: 最小值, max: 最大值, recommended: 推荐值} |
| `abstract_structure` | 摘要结构组成 | ["background", "problem", "approach", "results", "conclusions"] |
| `intro_depth` | Introduction 深度 | brief, medium, deep |
| `intro_length` | Introduction 字数范围 | {min: 最小值, max: 最大值} |
| `related_work_depth` | Related Work 深度 | selective, comprehensive, critical |
| `related_work_organization` | Related Work 组织方式 | thematic, historical, comparative |
| `method_detail` | Methodology 详略程度 | brief, medium, high, very_high |
| `algorithm_description` | 算法描述要求 | pseudo_code_required, detailed_model_description 等 |
| `theory_proof` | 理论证明要求 | optional, recommended, required, not_required |
| `experiment_format` | 实验格式 | standard, compact, extended |
| `required_evaluations` | 必需评估指标列表 | ["accuracy", "efficiency", "scalability"] |
| `statistical_tests` | 统计检验方法列表 | ["t-test", "anova", "significance"] |
| `discussion_focus` | Discussion 重点关注 | ["insights", "limitations", "future_work"] |
| `conclusion_length` | Conclusion 字数范围 | {min: 最小值, max: 最大值} |

### 审稿标准说明

| 子字段 | 说明 |
|--------|------|
| `novelty_weight` | 创新性权重（0-1） |
| `technical_weight` | 技术质量权重（0-1） |
| `presentation_weight` | 表述质量权重（0-1） |
| `required_evaluations` | 必需评估标准列表 |
| `special_attention` | 评审特别注意点列表 |

### 示例

#### 示例 1多ICSE 2025（会议）

```yaml
ICSE-2025:
  full_name: "International Conference on Software Engineering"
  type: "conference"
  format: "double-column"
  page_limit: 12
  template: "icse2025"
  keywords: ["software engineering", "ICSE", "software development", "testing"]
  deadline_note: "通常在 8-9 月截稿"

  writing_style:
    abstract_length: {min: 250, max: 300, recommended: 275}
    abstract_structure: ["background", "problem", "approach", "evaluation", "implications"]
    intro_depth: "medium"
    intro_length: {min: 900, max: 1500}
    related_work_depth: "comprehensive"
    related_work_organization: "thematic"
    method_detail: "high"
    algorithm_description: "system_design"
    theory_proof: "optional"
    experiment_format: "extended"
    required_evaluations: ["performance", "scalability", "usability", "industrial_relevance"]
    statistical_tests: ["significance", "effect_size"]
    discussion_focus: ["practical_implications", "limitations", "future_work"]
    conclusion_length: {min: 400, max: 700}

  review_criteria:
    novelty_weight: 0.30
    technical_weight: 0.35
    presentation_weight: 0.35
    required_evaluations: ["originality", "significance", "technical_quality", "practical_impact"]
    special_attention: ["industrial_relevance", "empirical_validation", "reproducibility"]

  paper_types: ["full_paper", "tool_demo", "early_results"]
  theoretical_ratio: {min: 0.1, max: 0.4}

  historical_data:
    acceptance_rate: 0.25
    review_cycle: "3-4 months"
    trending_topics: ["AI_assisted_SE", "DevOps", "microservices", "green_computing"]
```

#### 示例 2多CHI 2025（会议）

```yaml
CHI-2025:
  full_name: "ACM CHI Conference on Human Factors in Computing Systems"
  type: "conference"
  format: "single-column"
  page_limit: 10
  template: "chi2025"
  keywords: ["CHI", "human-computer interaction", "UX", "user experience"]
  deadline_note: "通常在 9-10 月截稿"

  writing_style:
    abstract_length: {min: 200, max: 250, recommended: 225}
    abstract_structure: ["background", "problem", "approach", "study", "insights"]
    intro_depth: "medium"
    intro_length: {min: 800, max: 1200}
    related_work_depth: "comprehensive"
    related_work_organization: "thematic"
    method_detail: "high"
    algorithm_description: "study_protocol"
    theory_proof: "optional"
    experiment_format: "standard"
    required_evaluations: ["usability", "user_satisfaction", "task_performance", "engagement"]
    statistical_tests: ["significance", "effect_size"]
    discussion_focus: ["design_insights", "limitations", "future_work", "practical_implications"]
    conclusion_length: {min: 350, max: 600}

  review_criteria:
    novelty_weight: 0.35
    technical_weight: 0.30
    presentation_weight: 0.35
    required_evaluations: ["originality", "significance", "methodology_rigor", "contribution", "presentation"]
    special_attention: ["user_centeredness", "ethical_considerations", "inclusivity", "accessibility"]

  paper_types: ["full_paper", "poster", "wiip", "interactivity_demo"]
  theoretical_ratio: {min: 0.05, max: 0.3}

  historical_data:
    acceptance_rate: 0.28
    review_cycle: "3-4 months"
    trending_topics: ["accessibility", "AI_in_HCI", "XR_VR_interfaces", "sustainable_HCI"]
```

#### 示例 3多VLDB Journal（期刊）

```yaml
VLDB-Journal:
  full_name: "Proceedings of the VLDB Endowment"
  type: "journal"
  format: "single-column"
  page_limit: null
  template: "vldb"
  keywords: ["VLDB", "database", "data management", "large-scale data"]
  deadline_note: "期刊，全年可投稿"

  writing_style:
    abstract_length: {min: 250, max: 300, recommended: 275}
    abstract_structure: ["background", "problem", "approach", "contribution", "evaluation"]
    intro_depth: "deep"
    intro_length: {min: 1200, max: 2000}
    related_work_depth: "comprehensive"
    related_work_organization: "thematic"
    method_detail: "very_high"
    algorithm_description: "detailed_algorithm_plus_complexity"
    theory_proof: "recommended"
    experiment_format: "extended"
    required_evaluations: ["throughput", "latency", "scalability", "storage_efficiency"]
    statistical_tests: ["confidence_intervals", "significance"]
    discussion_focus: ["system_insights", "limitations", "future_research"]
    conclusion_length: {min: 500, max: 800}

  review_criteria:
    novelty_weight: 0.35
    technical_weight: 0.45
    presentation_weight: 0.20
    required_evaluations: ["originality", "significance", "technical_soundness", "evaliation_rigor"]
    special_attention: ["complexity_analysis", "scalability", "comparative_analysis", "reproducibility"]

  paper_types: ["full_paper", "survey", "demo", "reproducibility_summary"]
  theoretical_ratio: {min: 0.2, max: 0.6}

  historical_data:
    acceptance_rate: 0.22
    review_cycle: "6-12 months"
    trending_topics: ["learned_indexes", "vector_databases", "serverless_databases", "data_lakes"]
```

---

## 用户自定义配置区

<!-- 在此处分隔线下方添加你的自定义会议/期刊配置 -->
<!-- 使用上方的模板格式，系统会自动解析 -->
