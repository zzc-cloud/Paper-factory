# Literature Survey: Ontology-Driven Multi-Agent NL2SQL

## Executive Summary

This literature survey examines 35 academic papers across five research domains that intersect with the Smart Query system: (1) NL2SQL/Text-to-SQL, (2) Ontology-Based Data Access (OBDA), (3) LLM-Based Multi-Agent Systems, (4) Knowledge Graph + LLM integration, and (5) Cognitive Architecture. The survey was conducted to position Smart Query's novel contributions within the existing research landscape and identify gaps that the system uniquely addresses.

The survey reveals several key findings. First, the NL2SQL field has undergone a paradigm shift from fine-tuned neural models to LLM-based in-context learning approaches, with systems like DIN-SQL, DAIL-SQL, and MAC-SQL achieving 85%+ accuracy on the Spider benchmark. However, these systems operate on small, clean databases and lack mechanisms for navigating enterprise-scale schemas with 35,000+ tables. Second, traditional OBDA systems (Ontop, Mastro) provide principled ontology-mediated data access but rely on rigid formal mappings that cannot handle the ambiguity inherent in natural language queries. Third, multi-agent LLM frameworks (AutoGen, MetaGPT, ChatDev) demonstrate the power of role specialization but use explicit message passing rather than the implicit context inheritance that Smart Query employs. Fourth, KG-LLM integration is a rapidly growing field, but existing approaches focus on general knowledge graphs rather than enterprise-specific ontologies with pre-computed field mappings and lineage relationships.

Smart Query sits at a unique intersection of these five fields, combining: (a) a domain ontology as a cognitive hub for schema navigation, (b) multi-agent serial execution with cumulative semantic enrichment, (c) evidence pack fusion with cross-validation adjudication, and (d) cognitive architecture principles adapted for LLM-based enterprise data querying. No existing system combines all four of these elements.

---

## 1. NL2SQL / Text-to-SQL

### 1.1 Overview of the Field

Text-to-SQL research aims to automatically translate natural language questions into executable SQL queries. The field has evolved dramatically since the introduction of the Spider benchmark (Yu et al., 2018), progressing from rule-based systems through neural sequence-to-sequence models to modern LLM-based approaches. Recent work leverages large language models through in-context learning (DIN-SQL, DAIL-SQL, C3) and multi-agent collaboration (MAC-SQL), achieving 85%+ execution accuracy on Spider. However, the Bird benchmark (Li et al., 2024) revealed that real-world databases with dirty values and domain-specific knowledge requirements remain challenging, with best models achieving only ~73% accuracy.

### 1.2 Key Papers
**[P01] DIN-SQL: Decomposed In-Context Learning of Text-to-SQL with Self-Correction** (Pourreza & Rafiei, NeurIPS 2023). Decomposes text-to-SQL into schema linking, classification, generation, and self-correction subtasks using GPT-4. Achieved 85.3% on Spider. *Relevance*: Validates task decomposition principle; Smart Query uses ontology-driven rather than prompt-based decomposition.

**[P02] DAIL-SQL: Efficient Few-Shot Text-to-SQL** (Gao et al., VLDB 2024). Studies question representation and example selection for few-shot text-to-SQL. Achieved 86.6% on Spider dev. *Relevance*: Smart Query bypasses example selection by using ontology-guided context.

**[P03] C3: Zero-shot Text-to-SQL with ChatGPT** (Dong et al., 2023). Zero-shot approach using clear prompting, calibration hints, and consistency checking. 82.3% on Spider. *Relevance*: Smart Query's ontology provides richer calibration than C3's hints; consistency parallels multi-strategy cross-validation.

**[P04] MAC-SQL: Multi-Agent Collaborative Framework for Text-to-SQL** (Wang et al., ACL 2024 Findings). Three agents (Selector, Decomposer, Refiner) collaborate for text-to-SQL. 86.8% on Spider. *Relevance*: Most comparable to Smart Query's multi-agent approach, but lacks ontology guidance and evidence pack fusion.

**[P05] CHESS: Contextual Harnessing for Efficient SQL Synthesis** (Talaei et al., 2024). Pipeline emphasizing contextual retrieval from database content. 72.7% on Bird (1st on leaderboard). *Relevance*: Parallels Smart Query's hybrid retrieval but lacks ontology-driven navigation.

**[P06] RESDSQL: Decoupling Schema Linking and Skeleton Parsing** (Li et al., AAAI 2023). Decouples schema linking from SQL generation using ranking-enhanced T5. 79.9% on Spider test. *Relevance*: Validates decoupling principle; Smart Query's ontology provides richer semantic schema linking.

**[P07] Spider: A Large-Scale Human-Labeled Dataset for Text-to-SQL** (Yu et al., EMNLP 2018). Foundational benchmark with 10,181 questions across 200 databases. *Relevance*: Smart Query operates in fundamentally different setting (single enterprise domain, 35K+ tables) vs. Spider's cross-database setting.

**[P08] Bird: A Big Bench for Large-Scale Database Grounded Text-to-SQL** (Li et al., NeurIPS 2024). Real-world benchmark with dirty values and external knowledge. Best models: ~73% accuracy. *Relevance*: Validates that enterprise databases require domain knowledge beyond schema-only approaches.

**[P09] SParC: Cross-Domain Semantic Parsing in Context** (Yu et al., ACL 2019). Multi-turn text-to-SQL benchmark with context-dependent questions. *Relevance*: Smart Query's serial agent execution addresses similar context-building challenges.

**[P10] A Survey on Employing LLMs for Text-to-SQL Tasks** (Katsogiannis-Meimarakis & Koutrika, 2023). Comprehensive survey of LLM-based text-to-SQL approaches. *Relevance*: Identifies domain adaptation as key open challenge that Smart Query addresses.

### 1.3 Gaps Relevant to Smart Query

- **Enterprise scale**: No existing NL2SQL system handles 35K+ tables with hierarchical business indicator taxonomies
- **Ontology integration**: All surveyed systems operate on raw schemas without semantic mediation layers
- **Multi-strategy evidence fusion**: No system uses independent evidence collection with cross-validation adjudication for table localization

---

## 2. Ontology-Based Data Access (OBDA)

### 2.1 Overview of the Field

OBDA provides principled approaches to accessing relational databases through ontology-mediated queries. Pioneered by systems like Ontop and Mastro, OBDA uses description logic ontologies (typically DL-Lite) with formal mappings (R2RML) to translate high-level semantic queries into SQL. While theoretically elegant, traditional OBDA suffers from rigidity: mappings must be complete and formally specified, and the systems cannot handle ambiguous or incomplete queries.

### 2.2 Key Papers

**[P11] Ontop: Answering SPARQL Queries over Relational Databases** (Calvanese et al., Semantic Web Journal 2017). Leading open-source OBDA system using R2RML mappings for SPARQL-to-SQL translation. *Relevance*: Smart Query extends the ontology-as-mediator principle but replaces rigid SPARQL-to-SQL rewriting with LLM-based flexible reasoning.

**[P12] Data Integration: A Theoretical Perspective** (Lenzerini, PODS 2002). Foundational theory for data integration defining GAV/LAV approaches. *Relevance*: Smart Query's three-layer ontology follows GAV paradigm enhanced with LLM reasoning.

**[P13] Linking Data to Ontologies: DL-LiteA** (Poggi et al., 2008). DL-Lite family enabling efficient OBDA with polynomial-time query answering. *Relevance*: Smart Query moves beyond DL-Lite's rigid formal mappings using LLM agents for flexible reasoning.

**[P14] Virtual Knowledge Graphs: An Overview** (Xiao et al., Data Intelligence 2019). Overview of VKG systems for unified data access through ontology mappings. *Relevance*: Smart Query implements VKG-like architecture with LLM-based reasoning replacing formal query rewriting.

**[P15] Ontology-Based Access to Temporal Data with Ontop** (Calvanese et al., 2019). Extends OBDA for temporal data querying. *Relevance*: Shows limitations of extending traditional OBDA; Smart Query's LLM approach is inherently more flexible.

### 2.3 Gaps Relevant to Smart Query

- **LLM integration**: No OBDA system integrates LLMs for flexible query interpretation
- **Ambiguity handling**: Traditional OBDA requires unambiguous formal queries; cannot handle natural language ambiguity
- **Scale**: OBDA systems tested on small ontologies; Smart Query operates on 238K+ node ontology

---
## 3. LLM-based Multi-Agent Systems

### 3.1 Overview of the Field

The emergence of capable LLMs has sparked rapid development of multi-agent systems where specialized LLM-powered agents collaborate on complex tasks. Frameworks like AutoGen (Microsoft), MetaGPT, ChatDev, and CAMEL demonstrate diverse collaboration patterns including sequential workflows, parallel debate, and hierarchical orchestration. Key design dimensions include agent communication (explicit message passing vs. shared memory), role specialization, and orchestration strategy.

### 3.2 Key Papers

**[P16] AutoGen: Enabling Next-Gen LLM Applications via Multi-Agent Conversation** (Wu et al., Microsoft Research 2023). Framework for multi-agent conversation with customizable agents supporting LLM, tool use, and human input. *Relevance*: Contrasts with Smart Query's implicit context inheritance; AutoGen uses explicit message passing.

**[P17] MetaGPT: Meta Programming for Multi-Agent Collaboration** (Hong et al., ICLR 2024). Encodes SOPs into agent workflows with role-specialized agents for software development. *Relevance*: SOP-based workflow parallels Smart Query's serial execution; both enforce structured collaboration.

**[P18] ChatDev: Communicative Agents for Software Development** (Qian et al., ACL 2024). Virtual software company with role-playing LLM agents collaborating through chat chains. *Relevance*: Sequential phase execution mirrors Smart Query's serial strategy execution.

**[P19] CAMEL: Communicative Agents for Mind Exploration** (Li et al., NeurIPS 2023). Role-playing framework for studying cooperative LLM agent behaviors using inception prompting. *Relevance*: Smart Query's Skill instructions serve similar function to inception prompts.

**[P20] Improving Factuality through Multiagent Debate** (Du et al., ICML 2024). Multiple LLM instances debate to improve factual accuracy. *Relevance*: Evidence pack fusion parallels debate consensus, but Smart Query uses serial execution rather than parallel debate.

**[P21] The Rise and Potential of LLM-Based Agents: A Survey** (Xi et al., 2023). Comprehensive survey of LLM agents covering construction, society, and applications. *Relevance*: Provides taxonomic context; Smart Query introduces novel ontology-as-cognitive-hub element.

**[P22] Voyager: An Open-Ended Embodied Agent with LLMs** (Wang et al., NeurIPS 2023). LLM agent with skill library for lifelong learning in Minecraft. *Relevance*: Skill library parallels Smart Query's MCP tool library.

**[P23] Toolformer: Language Models Can Teach Themselves to Use Tools** (Schick et al., NeurIPS 2023). LLMs learn to use external tools through self-supervised training. *Relevance*: Smart Query extends tool-use paradigm with 29+ domain-specific MCP tools.

**[P24] ReAct: Synergizing Reasoning and Acting in Language Models** (Yao et al., ICLR 2023). Interleaves reasoning traces and actions for grounded decision-making. *Relevance*: Smart Query's agents follow ReAct-like patterns with ontology tool calls; serial execution adds cumulative context.

### 3.3 Gaps Relevant to Smart Query

- **Implicit context inheritance**: No MAS framework models cumulative context enrichment through serial execution without explicit parameter passing
- **Evidence fusion**: No framework provides structured evidence pack fusion with confidence-weighted cross-validation
- **Domain ontology integration**: MAS frameworks are domain-agnostic; none integrate enterprise ontologies as shared cognitive resources

---

## 4. Knowledge Graph + LLM

### 4.1 Overview of the Field

The integration of knowledge graphs with LLMs is a rapidly growing research area. KGs provide structured, factual knowledge that can ground LLM reasoning, reduce hallucination, and enable domain-specific applications. Approaches range from KG-enhanced pre-training to inference-time retrieval and reasoning over graph structures. Graph RAG extends traditional RAG by leveraging graph structure for richer context retrieval.

### 4.2 Key Papers

**[P25] Unifying LLMs and Knowledge Graphs: A Roadmap** (Pan et al., IEEE TKDE 2024). Comprehensive roadmap for LLM-KG integration covering three paradigms. *Relevance*: Smart Query exemplifies KG-enhanced LLM inference paradigm.

**[P26] Think-on-Graph: Deep Reasoning on Knowledge Graph** (Sun et al., ICLR 2024). LLMs perform beam search on KGs for grounded reasoning. *Relevance*: Smart Query's ontology navigation strategies perform similar graph traversal reasoning.

**[P27] Graph RAG: From Local to Global** (Edge et al., Microsoft Research 2024). Builds KG from documents with hierarchical community summaries. *Relevance*: Hierarchical structure parallels Smart Query's three-layer ontology; Smart Query's is pre-built via ETL.

**[P28] Retrieval-Augmented Generation for Knowledge-Intensive NLP** (Lewis et al., NeurIPS 2020). Foundational RAG combining parametric and non-parametric memory. *Relevance*: Smart Query extends RAG with structured ontology retrieval rather than unstructured document retrieval.

**[P29] StructGPT: LLM Reasoning over Structured Data** (Jiang et al., EMNLP 2023). Framework for LLM reasoning over tables, KGs, and databases through specialized interfaces. *Relevance*: Smart Query's MCP tools serve similar function but are domain-specific and ontology-aware.

**[P30] Knowledge Graph-Enhanced LLMs: A Survey** (Ren et al., 2024). Surveys KG-LLM integration methods for hallucination reduction. *Relevance*: Positions Smart Query within the inference-time KG augmentation category.

### 4.3 Gaps Relevant to Smart Query

- **Enterprise ontologies**: Existing work focuses on general KGs (Wikidata, Freebase); no enterprise-specific ontology integration with pre-computed mappings
- **Multi-strategy graph navigation**: No system combines multiple graph traversal strategies with evidence fusion
- **Lineage-driven discovery**: No KG-LLM system uses data lineage relationships for related table discovery and automatic JOIN generation

---
## 5. Cognitive Architecture

### 5.1 Overview of the Field

Cognitive architectures provide computational frameworks for modeling intelligent behavior, drawing from cognitive science theories about human cognition. Classical architectures (ACT-R, Soar) model cognition through modular memory systems, production rules, and goal-directed reasoning. Recent work (CoALA) maps these concepts to LLM-based agents, while foundational theories (Global Workspace Theory, Blackboard Architecture) provide design principles for integrating diverse knowledge sources.

### 5.2 Key Papers

**[P31] Cognitive Architectures for Language Agents (CoALA)** (Sumers et al., TMLR 2024). Maps cognitive architecture concepts to LLM agent components (memory types, action spaces, decision cycles). *Relevance*: Directly applicable framework; Smart Query's ontology = semantic memory, MCP tools = procedural memory, conversation history = working memory.

**[P32] The Soar Cognitive Architecture** (Laird, MIT Press 2012). Unified framework with problem spaces, operators, and chunking-based learning. *Relevance*: Soar's impasse-driven subgoaling parallels Smart Query's progressive degradation search.

**[P33] ACT-R: An Integrated Theory of the Mind** (Anderson et al., Psychological Review 2004). Modular buffer architecture with activation-based memory retrieval. *Relevance*: ACT-R's modular buffers inspire Smart Query's cognitive hub concept; ontology as declarative memory, tools as procedural memory.

**[P34] Global Workspace Theory** (Baars, Cambridge University Press 1988). Shared workspace broadcasting information to specialized processors. *Relevance*: Smart Query's shared conversation history functions as a global workspace enabling cumulative semantic integration.

**[P35] The Blackboard Model of Problem Solving** (Nii, AI Magazine 1986). Multiple knowledge sources contribute to shared blackboard with control scheduling. *Relevance*: Smart Query closely resembles a blackboard system: conversation context = blackboard, strategies = knowledge sources, serial execution = control strategy.

### 5.3 Gaps Relevant to Smart Query

- **LLM integration**: Classical architectures predate LLMs; modern adaptations (CoALA) are descriptive rather than prescriptive
- **Domain ontology as cognitive hub**: No framework models how structured domain knowledge serves as an integrating cognitive hub
- **Cumulative entropy reduction**: No cognitive architecture formalizes how serial strategy execution reduces information entropy about target data

---

## 6. Research Gap Analysis

Seven major research gaps were identified across the five categories:

| Gap | Description | Smart Query's Response |
|-----|-------------|----------------------|
| G1 | No NL2SQL system integrates domain ontology at enterprise scale (35K+ tables) | Three-layer ontology with 238K+ nodes as semantic mediator |
| G2 | No MAS framework models implicit context inheritance with cumulative semantic enrichment | Serial execution with shared conversation history; formalized as entropy reduction |
| G3 | Traditional OBDA relies on rigid formal mappings, cannot handle NL ambiguity | LLM-based flexible reasoning over ontology structure |
| G4 | No evidence pack fusion with cross-validation adjudication for table localization | Three independent strategies with confidence-weighted consensus |
| G5 | KG-LLM approaches lack enterprise ontology integration with pre-computed mappings | Purpose-built ontology with 22-step ETL pipeline and pre-computed field mappings |
| G6 | Cognitive architecture frameworks don't model ontology as cognitive hub | Cognitive Hub = Ontology Layer + Skills (cognitive frameworks) |
| G7 | Benchmarks don't capture hierarchical business indicator navigation across schemas | 5-level indicator hierarchy across 9 schemas with 83 table topics |

---

## 7. Research Trends

1. **From fine-tuning to in-context learning** (T1): NL2SQL has shifted from fine-tuned models to LLM prompting, enabling rapid adaptation. Smart Query leverages this with ontology-provided context.

2. **Multi-agent architectures for complex tasks** (T2): Role-specialized LLM agents are replacing monolithic approaches. Smart Query introduces novel serial execution with implicit context inheritance.

3. **KG-LLM convergence** (T3): Knowledge graphs increasingly ground LLM reasoning. Smart Query uses enterprise-scale ontology (238K+ nodes) for domain-specific grounding.

4. **Benchmark-to-reality gap** (T4): Spider (85%+) vs. Bird (~73%) reveals real-world challenges. Smart Query targets enterprise deployment where benchmarks are insufficient.

5. **Cognitive architecture revival** (T5): Classical cognitive concepts are being mapped to LLM agents. Smart Query extends this with the Cognitive Hub concept.

6. **Tool-augmented LLM agents** (T6): External tool use is becoming standard. Smart Query's 29+ MCP tools represent mature domain-specific tool integration.

7. **OBDA evolution toward AI** (T7): Traditional OBDA is evolving from rigid formal mappings toward flexible AI-enhanced approaches. Smart Query represents the next generation.

---

## 8. Positioning Smart Query

Smart Query occupies a unique position at the intersection of five research fields. It is:

- **More than NL2SQL**: It doesn't just translate questions to SQL — it navigates a complex enterprise ontology to discover relevant tables and fields before generating SQL.
- **More than OBDA**: It replaces rigid formal mappings with flexible LLM-based reasoning while retaining the ontology-as-mediator principle.
- **More than a multi-agent system**: Its serial execution with implicit context inheritance and evidence pack fusion introduces novel collaboration patterns not found in AutoGen, MetaGPT, or ChatDev.
- **More than KG-enhanced LLM**: Its enterprise-scale ontology with pre-computed mappings and lineage relationships goes beyond general KG-LLM integration.
- **A modern cognitive architecture**: Its Cognitive Hub concept (Ontology + Skills = Domain Reasoning) bridges classical cognitive architecture theory with practical LLM-based enterprise systems.

The key innovation is the **integration** of these five elements into a coherent system where the ontology serves as the cognitive hub that enables multi-agent serial reasoning with cumulative semantic enrichment — a combination that no existing system achieves.

---

*Survey conducted by A1-Literature-Surveyor | 35 papers across 5 categories | 7 research gaps identified | 7 research trends identified*