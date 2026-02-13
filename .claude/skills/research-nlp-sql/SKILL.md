---
name: research-nlp-sql
description: "Performs NL2SQL / Text-to-SQL domain theoretical analysis and technical positioning. Analyzes the NL2SQL research landscape, schema linking theory, LLM-based approaches, enterprise challenges, and positions the target system within the field. Called by Team Lead during Phase 1 research."
---

# NL2SQL Domain Theoretical Analysis & Technical Positioning

## Overview

This skill performs a comprehensive theoretical analysis of the Natural Language to SQL (NL2SQL / Text-to-SQL) research domain. It reads the target project's input context, synthesizes the current state of NL2SQL research from LLM knowledge, and produces a structured analysis that positions the target system within the academic landscape.

This skill runs synchronously and relies entirely on LLM parametric knowledge — no web search is performed. The output serves as foundational material for Phase 1 research, feeding into the Innovation Formalizer (A4) and downstream paper design agents.

## Invocation

```
Skill(skill="research-nlp-sql", args="{project}")
```

Where `{project}` is the project directory name under `workspace/`.

## Execution Steps

### Step 1: Read and Parse Input Context

Read `workspace/{project}/phase1/input-context.md` (fall back to `workspace/{project}/input-context.md` if the phase1 copy does not exist).

Extract the following from the input context:
- **System name and description**: What the target NL2SQL system is called and what it does
- **Core technical approach**: How the system translates natural language to SQL
- **Schema handling strategy**: How the system deals with database schemas
- **Innovation claims**: What the authors claim as novel contributions
- **Architecture overview**: High-level system design
- **Target deployment context**: Enterprise, academic, or general-purpose

If the input context is missing or unreadable, write an error JSON to the output path and stop:

```json
{
  "skill_id": "research-nlp-sql",
  "domain": "nlp_to_sql",
  "status": "error",
  "error": "Input context file not found at workspace/{project}/phase1/input-context.md or workspace/{project}/input-context.md"
}
```

### Step 2: Analyze the NL2SQL Technical Landscape and Evolution

Produce a structured analysis of how NL2SQL has evolved across four generations:

#### Generation 1: Rule-Based and Template Systems (pre-2017)
- Keyword matching and pattern-based SQL generation
- Systems: NaLIR (2014), SQLizer (2017)
- Limitations: brittle to paraphrase, no generalization, hand-crafted grammars
- Contribution to the field: established the problem formulation and early benchmarks

#### Generation 2: Seq2Seq and Grammar-Based Neural Models (2017-2020)
- Encoder-decoder architectures treating SQL as a sequence or tree
- Key models: Seq2SQL (Zhong et al., 2017), SQLNet (Xu et al., 2017), SyntaxSQLNet (Yu et al., 2018), IRNet (Guo et al., 2019), RAT-SQL (Wang et al., 2020)
- Grammar-constrained decoding to ensure syntactic validity
- Schema encoding innovations: relation-aware transformers, graph neural networks
- Benchmarks that drove progress:
  - **WikiSQL** (Zhong et al., 2017): 80K single-table queries, simple SELECT-WHERE
  - **Spider** (Yu et al., 2018): 10K complex cross-database queries, multi-table joins, nested queries
  - **SParC** (Yu et al., 2019) and **CoSQL** (Yu et al., 2019): conversational / multi-turn extensions
- Limitations: poor cross-database generalization, struggled with complex queries

#### Generation 3: Pre-trained Language Model Era (2020-2023)
- BERT/RoBERTa-based schema-aware encoders
- Key models: BRIDGE (Lin et al., 2020), GRAPPA (Yu et al., 2021), UnifiedSKG (Xie et al., 2022), RESDSQL (Li et al., 2023)
- Schema linking as an explicit pre-processing or joint-training objective
- Intermediate representation approaches (SemQL, NatSQL)
- **BIRD benchmark** (Li et al., 2024): 12K queries with external knowledge, dirty data, large schemas
- Limitations: still required task-specific fine-tuning, limited to seen schema patterns

#### Generation 4: LLM-Based Approaches (2023-present)
- In-context learning with GPT-4, Claude, and open-source LLMs
- Key systems: DIN-SQL, DAIL-SQL, MAC-SQL, CHESS, SuperSQL
- Agent-based and multi-step reasoning pipelines
- Minimal or zero fine-tuning paradigms
- Current frontier: combining LLM reasoning with structured schema understanding

### Step 3: Analyze Schema Linking Theory and Approaches

Schema linking — the process of mapping natural language mentions to database schema elements (tables, columns, values) — is the critical bottleneck in NL2SQL. Analyze the following taxonomy:

#### 3.1 String-Based Matching
- Exact and fuzzy string matching between question tokens and schema elements
- N-gram overlap, edit distance, phonetic matching
- Fast but brittle: fails on synonyms, abbreviations, domain jargon
- Used as baseline in most systems

#### 3.2 Embedding-Based Matching
- Dense vector similarity between question spans and schema elements
- Pre-trained embeddings (GloVe, BERT) or task-specific learned embeddings
- Better semantic coverage but computationally expensive for large schemas
- Examples: SchemaLinker in BRIDGE, column attention in RAT-SQL

#### 3.3 Graph-Based Schema Linking
- Model schema as a graph (tables as nodes, foreign keys as edges)
- GNN-based propagation to capture relational structure
- Question-schema interaction through cross-attention over graph
- Examples: SADGA (Cai et al., 2022), S2SQL (Hui et al., 2022)

#### 3.4 LLM-Based Schema Linking
- Prompt-based: provide schema in context, let LLM identify relevant elements
- Chain-of-thought schema decomposition
- Schema filtering/pruning as a pre-processing step for LLM-based NL2SQL
- Examples: DIN-SQL schema linking module, CHESS schema pruning
- Challenge: context window limits with large schemas (hundreds of tables)

#### 3.5 Ontology-Enhanced Schema Linking (Emerging)
- Use domain ontologies to bridge semantic gap between NL and schema
- Ontology provides: synonyms, hierarchical relationships, domain constraints
- Map NL concepts to ontology concepts to schema elements (two-hop linking)
- Advantages: handles domain jargon, supports schema evolution, explainable
- Current state: under-explored in literature, high potential for enterprise NL2SQL

### Step 4: Evaluate LLM-Based NL2SQL Methods in Depth

#### 4.1 In-Context Learning (ICL) Approaches
- **Zero-shot**: Schema + question to SQL (no examples)
  - Relies entirely on LLM's pre-trained SQL knowledge
  - Performance: ~70% on Spider (GPT-4), drops significantly on complex queries
- **Few-shot**: Schema + examples + question to SQL
  - Example selection strategies: random, similarity-based, diversity-based
  - **DAIL-SQL** (Gao et al., 2024): masked question similarity for example selection, achieved SOTA on Spider with GPT-4
  - Critical factor: example quality and relevance matter more than quantity

#### 4.2 Decomposition and Chain-of-Thought Approaches
- **DIN-SQL** (Pourreza & Rafiei, 2024): decomposes NL2SQL into sub-problems
  - Schema linking, query classification, SQL generation, self-correction
  - Each sub-problem solved by a separate LLM call
  - Achieved strong results on Spider and BIRD
- **Chain-of-Thought SQL**: step-by-step reasoning before SQL generation
  - Intermediate steps: identify tables, identify columns, determine joins, write clauses
  - Improves interpretability and debuggability
- **Self-consistency**: generate multiple SQL candidates, select by execution agreement

#### 4.3 Agent-Based and Multi-Step Approaches
- **MAC-SQL** (Wang et al., 2024): multi-agent collaborative framework
  - Decomposer agent, selector agent, refiner agent
  - Agents communicate through structured intermediate representations
  - Handles complex queries through divide-and-conquer
- **CHESS** (Talaei et al., 2024): contextual heuristic ensemble for schema and SQL
  - Schema pruning, candidate generation, candidate selection pipeline
  - Entity retrieval and column filtering as explicit pre-processing
- **SuperSQL** (Li et al., 2024): schema-aware prompting with NL reasoning
- **Agent-based paradigm advantages**:
  - Modularity: each agent specializes in one sub-task
  - Error isolation: failures in one step don't cascade unpredictably
  - Iterative refinement: agents can self-correct through execution feedback

#### 4.4 Fine-Tuning Approaches
- **CodeS** (Li et al., 2024): fine-tuned StarCoder for NL2SQL
- **SENSE** (synthetic data generation for NL2SQL fine-tuning)
- **SQLCoder** (Defog): fine-tuned Code Llama specifically for SQL generation
- Trade-offs: better domain adaptation vs. loss of generality, training cost

### Step 5: Analyze Cross-Database Generalization Challenges

Cross-database generalization — the ability to handle unseen database schemas at inference time — remains a fundamental challenge:

#### 5.1 Schema Representation
- How to encode an unseen schema so the model understands its structure
- Column type information, primary/foreign key relationships, value distributions
- Challenge: same column name can mean different things in different databases

#### 5.2 Domain Transfer
- Models trained on one domain (e.g., academic databases) struggle with others (e.g., healthcare)
- Domain-specific terminology, naming conventions, implicit knowledge
- Few-shot adaptation vs. zero-shot generalization trade-offs

#### 5.3 Compositional Generalization
- Handling novel combinations of SQL operations not seen during training
- Nested subqueries, complex aggregations, HAVING clauses, CTEs
- Benchmark analysis: Spider's "extra hard" category still below 50% for most systems

#### 5.4 Evaluation Methodology
- Execution accuracy vs. exact match vs. test-suite accuracy
- Limitations of current metrics: multiple valid SQL for same question
- **Test-suite accuracy** (Zhong et al., 2020): evaluates against multiple test databases
- Need for more realistic evaluation: noisy questions, ambiguous intent, partial schemas

### Step 6: Assess Enterprise NL2SQL Challenges

Enterprise deployment introduces challenges rarely addressed in academic benchmarks:

#### 6.1 Schema Scale
- Enterprise databases: hundreds to thousands of tables, tens of thousands of columns
- Context window limitations: cannot fit entire schema in LLM prompt
- Schema pruning/filtering becomes mandatory, not optional
- Hierarchical schema organization: catalogs, schemas, tables, columns

#### 6.2 Domain Terminology and Jargon
- Business terms that don't match column names (e.g., "revenue" vs `amt_net_sales`)
- Abbreviations, acronyms, legacy naming conventions
- Need for business glossary / semantic layer mapping
- Ontology as a bridge between business language and technical schema

#### 6.3 Multi-Table Join Complexity
- Enterprise queries routinely involve 5-10+ table joins
- Join path discovery: multiple valid paths between tables
- Performance implications of join order
- Implicit joins through business rules not captured in foreign keys

#### 6.4 Data Governance and Access Control
- Column-level and row-level security policies
- Users should only see SQL touching data they're authorized to access
- Generated SQL must respect data governance rules
- Audit trail requirements for generated queries

#### 6.5 Query Complexity Distribution
- Academic benchmarks skew toward SELECT-WHERE-JOIN patterns
- Enterprise needs: window functions, CTEs, recursive queries, pivots
- Analytical queries: aggregations across time dimensions, YoY comparisons
- Reporting patterns: parameterized templates, drill-down hierarchies

#### 6.6 Ambiguity and Underspecification
- Enterprise users often ask vague questions ("show me sales data")
- Clarification dialogue: when to ask vs. when to assume
- Default filters, time ranges, aggregation levels
- Multi-intent queries: "show sales by region and compare to last year"

### Step 7: Position the Target System

Based on the input context analysis (Step 1) and the landscape analysis (Steps 2-6), position the target system along these dimensions:

#### 7.1 Technical Positioning Matrix
Map the target system on these axes:
- **NL2SQL generation approach**: rule-based / neural / LLM-ICL / LLM-agent / hybrid
- **Schema linking method**: string / embedding / graph / LLM / ontology-enhanced
- **Generalization strategy**: fine-tuned / few-shot / zero-shot / retrieval-augmented
- **Target scale**: single-database / cross-database / enterprise-scale
- **Query complexity**: simple / moderate / complex / analytical

#### 7.2 Innovation Mapping
For each claimed innovation in the input context:
- Identify which research gap it addresses
- Map to the NL2SQL evolution timeline (which generation does it advance?)
- Identify closest related work and differentiation
- Assess novelty: incremental improvement vs. paradigm shift vs. new problem formulation
- Determine academic significance: what would reviewers find compelling?

#### 7.3 Contribution Framing Recommendations
Suggest how to frame contributions for maximum academic impact:
- Which aspects are most novel relative to current SOTA?
- What theoretical foundations support the approach?
- Which benchmarks and baselines are most appropriate for evaluation?
- What ablation studies would strengthen the claims?

### Step 8: Synthesize and Write Output

Compile all analyses into the unified output JSON format and write to `workspace/{project}/phase1/skill-nlp-sql.json`.

## Output Format Specification

The output MUST conform to this JSON structure. The top-level fields are fixed; the `findings` array and `domain_specific_data` object are populated dynamically based on the analysis.

```json
{
  "skill_id": "research-nlp-sql",
  "domain": "nlp_to_sql",
  "status": "complete",
  "timestamp": "<ISO-8601>",
  "input_context_path": "workspace/{project}/phase1/input-context.md",
  "summary": "...",
  "findings": [
    {
      "finding_id": "F1",
      "type": "theory|method|comparison|architecture",
      "title": "...",
      "description": "...",
      "evidence": "...",
      "related_innovations": [],
      "academic_significance": "..."
    }
  ],
  "domain_specific_data": {
    "landscape_analysis": {
      "generations": [
        {"id": "gen1|gen2|gen3|gen4", "name": "...", "period": "...", "representative_systems": ["..."], "key_benchmarks": ["..."], "key_limitation": "..."}
      ],
      "benchmark_timeline": [
        {"name": "WikiSQL", "year": 2017, "size": "80K", "complexity": "single-table, simple SELECT-WHERE"},
        {"name": "Spider", "year": 2018, "size": "10K", "complexity": "cross-database, multi-table, nested"},
        {"name": "SParC", "year": 2019, "size": "4.3K", "complexity": "multi-turn conversational"},
        {"name": "CoSQL", "year": 2019, "size": "3K", "complexity": "conversational with clarification"},
        {"name": "Spider-DK", "year": 2021, "size": "535", "complexity": "domain knowledge required"},
        {"name": "Spider-Realistic", "year": 2021, "size": "508", "complexity": "realistic NL variations"},
        {"name": "BIRD", "year": 2024, "size": "12K", "complexity": "external knowledge, dirty data, large schemas"},
        {"name": "Spider 2.0", "year": 2024, "size": "632", "complexity": "enterprise-scale, multi-dialect"}
      ]
    },
    "schema_linking": {
      "approaches": [
        {"type": "string_matching|embedding_based|graph_based|llm_based|ontology_enhanced", "description": "...", "strengths": ["..."], "weaknesses": ["..."], "representative_work": ["..."], "research_gap": false}
      ],
      "key_insight": "..."
    },
    "llm_approaches": {
      "paradigms": [
        {"name": "...", "description": "...", "key_systems": [{"name": "...", "contribution": "...", "performance": "..."}], "strengths": ["..."], "limitations": ["..."], "research_frontier": false}
      ]
    },
    "enterprise_challenges": {
      "dimensions": [
        {"challenge": "...", "description": "...", "impact": "...", "current_solutions": ["..."], "open_problems": ["..."]}
      ],
      "key_insight": "..."
    },
    "positioning": {
      "technical_axes": ["nl2sql_approach", "schema_linking", "generalization", "query_complexity", "deployment"],
      "system_position": {"nl2sql_approach": "...", "schema_linking": "...", "generalization": "...", "query_complexity": "...", "deployment": "..."},
      "innovation_assessments": [
        {"innovation_id": 1, "gap_addressed": "...", "generation_advanced": "gen4", "closest_related_work": "...", "novelty_level": "incremental|paradigm_shift|new_problem", "academic_significance": "..."}
      ],
      "target_venues": [
        {"venue": "ACL/EMNLP/NAACL", "focus": "NLP methodology", "fit_score": "high|medium|low"},
        {"venue": "VLDB/SIGMOD", "focus": "Database systems", "fit_score": "high|medium|low"},
        {"venue": "AAAI/IJCAI", "focus": "AI methodology", "fit_score": "high|medium|low"},
        {"venue": "WWW/CIKM", "focus": "Web and information systems", "fit_score": "high|medium|low"},
        {"venue": "ISWC/ESWC", "focus": "Semantic web, ontology, KG", "fit_score": "high|medium|low"}
      ]
    }
  }
}
```

## Findings Generation Guidelines

Generate a minimum of 5 findings, typically 8-12 for a thorough analysis. Each finding should:

1. **Have a unique `finding_id`**: Sequential from F1 to FN
2. **Be typed correctly**:
   - `theory`: Foundational concepts, frameworks, taxonomies
   - `method`: Specific techniques, algorithms, approaches
   - `comparison`: Comparative analysis between approaches
   - `architecture`: System design patterns and structural insights
3. **Include concrete evidence**: Reference specific papers, benchmarks, metrics where possible
4. **Map to innovations**: The `related_innovations` array should reference innovation IDs from the input context (1-indexed)
5. **Assess academic significance**: What would a reviewer at a top venue think about this?

### Typical Findings for an NL2SQL System

Depending on the target system, findings should cover:

- **F1-F2**: Landscape positioning (which generation, what gap)
- **F3-F4**: Schema linking analysis (how the system's approach compares)
- **F5-F6**: LLM integration analysis (if applicable: ICL vs. agent vs. fine-tuning)
- **F7-F8**: Enterprise challenge analysis (which challenges the system addresses)
- **F9-F10**: Ontology/KG integration analysis (if the system uses semantic knowledge)
- **F11-F12**: Novelty assessment and contribution framing recommendations

## Key Academic References (from LLM Knowledge)

The following references should be cited or discussed where relevant. These are drawn from parametric knowledge and should be verified by downstream agents if used in the final paper.

### Foundational Benchmarks
- Zhong et al. (2017). "Seq2SQL: Generating Structured Queries from Natural Language using Reinforcement Learning." -- WikiSQL
- Yu et al. (2018). "Spider: A Large-Scale Human-Labeled Dataset for Complex and Cross-Domain Semantic Parsing and Text-to-SQL Task." -- Spider
- Yu et al. (2019). "SParC: Cross-Domain Semantic Parsing in Context." -- Multi-turn
- Yu et al. (2019). "CoSQL: A Conversational Text-to-SQL Challenge Towards Cross-Domain Natural Language Interfaces to Databases." -- Conversational
- Li et al. (2024). "Can LLM Already Serve as A Database Interface? A BIg Bench for Large-Scale Database Grounded Text-to-SQL." -- BIRD

### Neural NL2SQL Models
- Wang et al. (2020). "RAT-SQL: Relation-Aware Schema Encoding and Linking for Text-to-SQL Parsers." -- Schema encoding
- Lin et al. (2020). "Bridging Textual and Tabular Data for Cross-Domain Text-to-SQL Semantic Parsing." -- BRIDGE
- Li et al. (2023). "RESDSQL: Decoupling Schema Linking and Skeleton Parsing for Text-to-SQL." -- Decoupled approach
- Scholak et al. (2021). "PICARD: Parsing Incrementally for Constrained Auto-Regressive Decoding from Language Models." -- Constrained decoding

### LLM-Based NL2SQL
- Pourreza & Rafiei (2024). "DIN-SQL: Decomposed In-Context Learning of Text-to-SQL with Self-Correction." -- Decomposition
- Gao et al. (2024). "Text-to-SQL Empowered by Large Language Models: A Benchmark Evaluation." -- DAIL-SQL
- Wang et al. (2024). "MAC-SQL: A Multi-Agent Collaborative Framework for Text-to-SQL." -- Multi-agent
- Talaei et al. (2024). "CHESS: Contextual Heuristic for Efficient SQL Synthesis." -- Enterprise-oriented
- Li et al. (2024). "Codes: Towards Building Open-source Language Models for Text-to-SQL." -- Fine-tuning

### Schema Linking
- Cai et al. (2022). "SADGA: Structure-Aware Dual Graph Aggregation Network for Text-to-SQL." -- Graph-based
- Hui et al. (2022). "S2SQL: Injecting Syntax to Question-Schema Interaction Graph Encoder for Text-to-SQL Parsers." -- Syntax-enhanced
- Lei et al. (2020). "Re-examining the Role of Schema Linking in Text-to-SQL." -- Schema linking analysis

### Ontology and Knowledge-Enhanced NL2SQL
- Baik et al. (2020). "Bridging the Semantic Gap with SQL Query Logs in Natural Language Interfaces to Databases." -- Query log augmentation
- Katsogiannis-Meimarakis & Koutrika (2023). "A survey on deep learning approaches for text-to-SQL." -- Comprehensive survey
- Deng et al. (2022). "Recent Advances in Text-to-SQL: A Survey of What We Have and What We Expect." -- Survey with future directions

## Constraints

1. **No WebSearch**: This skill relies entirely on LLM parametric knowledge. Do not invoke WebSearch, WebFetch, or any external data retrieval tools. All analysis is synthesized from training data.

2. **No code execution**: Do not run any code, SQL queries, or scripts. This is a purely analytical skill.

3. **Output path is fixed**: Always write to `workspace/{project}/phase1/skill-nlp-sql.json`. Do not write to any other location.

4. **JSON validity**: The output MUST be valid JSON. Use `Write` tool to produce the file. Double-check that all strings are properly escaped, arrays are properly closed, and no trailing commas exist.

5. **Finding quality**: Each finding must have all 7 required fields populated with substantive content. Empty or placeholder values are not acceptable.

6. **Innovation mapping**: The `related_innovations` field must reference actual innovation IDs from the input context. If the input context lists 5 innovations, valid values are [1], [2], [1, 3], etc. Use an empty array [] only for findings that are purely background/landscape analysis.

7. **Academic rigor**: All claims about system performance, benchmark results, and method comparisons should be stated with appropriate hedging (e.g., "approximately", "reported as", "on the order of") since they are drawn from parametric knowledge and may not reflect the most recent results.

8. **Positioning objectivity**: The positioning analysis should be balanced and honest. If the target system's approach has known limitations relative to SOTA, acknowledge them. Reviewers value honest assessment over advocacy.

9. **Scope boundary**: Focus on NL2SQL / Text-to-SQL. Adjacent topics (general semantic parsing, KBQA, table QA) should only be mentioned when directly relevant to positioning the target system.

10. **Synchronous execution**: This skill must complete in a single invocation. Do not spawn sub-agents, create follow-up tasks, or defer any analysis to later steps.
