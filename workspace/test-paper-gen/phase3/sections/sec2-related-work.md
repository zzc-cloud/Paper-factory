## 2. Related Work

### 2.1 CNC Fault Diagnosis Methods

Intelligent fault diagnosis for CNC systems has evolved through several technological paradigms. Traditional rule-based approaches encode expert diagnostic knowledge as if-then-else rules, providing transparent reasoning paths that maintenance personnel can verify. However, these systems exhibit limited flexibility when encountering novel fault patterns not represented in the rule base, requiring manual rule updates that create maintenance bottlenecks [Zhang2023]. Knowledge-based expert systems address this limitation through more sophisticated reasoning mechanisms, yet they still rely on manually curated knowledge and struggle with the semantic complexity of natural language fault descriptions.

Deep learning methods have emerged as powerful alternatives for fault diagnosis, leveraging neural networks to automatically learn diagnostic patterns from historical sensor data. Convolutional Neural Networks (CNNs) and Long Short-Term Memory (LSTM) networks have demonstrated strong performance in detecting and classifying fault types from time-series vibration and current signals [Zhang2023]. However, these approaches operate as black boxes—while they achieve high classification accuracy, they cannot provide the explanations required for maintenance decision-making in industrial settings. The lack of interpretability remains a significant barrier to adoption in safety-critical manufacturing environments.

Knowledge-based fault diagnosis systems have addressed the explainability limitation through structured knowledge representations. These systems construct domain ontologies that formally represent fault types, system components, and causal relationships. Reasoning engines then apply logical inference to derive diagnostic conclusions from observed symptoms [Li2022]. While effective for well-defined fault scenarios, these systems face challenges in handling the ambiguity and semantic complexity of natural language fault reports, which remain the primary interface for maintenance technicians.

Despite these advances, a significant gap remains: existing approaches do not effectively integrate the semantic understanding capabilities of language models with the structured reasoning of knowledge graphs specifically for CNC fault diagnosis. Table 1 summarizes the comparative strengths and limitations of major CNC fault diagnosis approaches.

### 2.2 Large Language Models in Fault Diagnosis

The application of Large Language Models (LLMs) to industrial fault diagnosis represents a rapidly developing research direction. LLMs such as GPT-4 have demonstrated remarkable capabilities in understanding natural language fault descriptions and generating diagnostic hypotheses [Zhao2024]. These models can process unstructured maintenance documents, technical manuals, and technician notes to extract diagnostic knowledge that would be difficult to formalize explicitly. Several studies have reported success in fine-tuning pre-trained LLMs on domain-specific fault diagnosis datasets, achieving text classification accuracy exceeding 90% [Zhao2024].

However, LLM-based approaches face significant limitations when applied to specialized domains. A well-documented challenge is the hallucination problem, where models generate plausible-sounding but factually incorrect diagnostic suggestions [Sun2023]. In safety-critical applications like CNC fault diagnosis, such errors can have serious consequences, including misdiagnosis, inappropriate maintenance actions, and equipment damage. Additionally, LLMs lack explicit representation of the complex interdependencies between system components and fault modes that domain experts have formalized through decades of experience.

Knowledge augmentation techniques have been proposed to address these limitations, typically through retrieval-augmented generation that injects relevant domain facts into the LLM context window [Zhou2023]. While effective at reducing certain types of errors, these approaches treat knowledge sources as static retrieval targets rather than active reasoning components. The integration remains fundamentally unidirectional, with knowledge flowing from databases to the language model but no mechanism for the model to enhance or correct the knowledge base.

### 2.3 Knowledge Graphs in Industrial Applications

Knowledge Graphs have gained prominence as a robust framework for organizing and reasoning over domain knowledge in industrial applications. Industrial knowledge graph construction methodologies typically involve ontology engineering processes that define formal schemas for representing entities, relationships, and constraints specific to a domain [Wu2023]. For fault diagnosis, ontologies must capture the hierarchical structure of fault types, the causal relationships between symptoms and failures, and the procedural knowledge of diagnostic methods.

Reasoning over industrial knowledge graphs employs multiple strategies. Symbolic reasoning engines use description logics and rule-based inference to derive conclusions from observed facts [Zheng2022]. Machine learning approaches enhance knowledge graphs through embeddings that enable link prediction and similarity-based retrieval. However, knowledge graphs for fault diagnosis face limitations in coverage (manual construction cannot keep pace with new equipment models) and expressiveness (capturing the temporal evolution of faults and complex multi-component interactions). Table 2 compares the characteristics of major industrial KG approaches for fault diagnosis.

### 2.4 LLM-Knowledge Graph Fusion

The integration of Large Language Models with Knowledge Graphs has emerged as a promising research direction combining the semantic understanding of neural models with the structured reasoning of symbolic systems. Current approaches primarily implement unidirectional knowledge augmentation, where knowledge graphs serve as retrieval sources that provide context for LLM generation [Chen2023]. These systems typically retrieve relevant subgraphs or entity descriptions based on semantic similarity to user queries, then inject this structured knowledge into the LLM prompt to constrain generation.

While effective at reducing certain error types, unidirectional approaches leave significant opportunities untapped. The knowledge graph remains a passive resource that cannot benefit from the language model's ability to extract knowledge from unstructured text or identify patterns that suggest new relationships [Wei2024]. Additionally, the reasoning capabilities of LLMs are not fully leveraged, as these systems treat language models solely as text generators rather than as reasoning components that can participate in knowledge graph completion and validation.

Recent research has begun to explore more sophisticated integration patterns. Neuro-symbolic approaches combine neural embeddings with symbolic reasoning, enabling systems that learn from data while maintaining logical consistency [Feng2024]. Graph neural networks applied to knowledge graphs can capture complex relational patterns that traditional reasoning misses. However, these approaches have not been extensively evaluated in the CNC fault diagnosis domain, where the specific requirements of explainability, real-time performance, and multi-source data integration create unique challenges.

Our approach differentiates from prior work in three key aspects. First, we focus specifically on CNC fault diagnosis, enabling ontology design optimized for this domain rather than adapting generic industrial knowledge schemas. Second, we implement true bidirectional reasoning where the LLM and knowledge graph mutually enhance each other's capabilities through a feedback loop. Third, we design our system for real-time deployment in manufacturing environments, where rapid diagnostic response is critical for minimizing equipment downtime.

### 2.5 Positioning and Differentiation

Table 1: Comparison of CNC Fault Diagnosis Approaches

| Approach | Knowledge Representation | Explainability | Adaptability | Multi-Modal Support | LLM Integration |
|------------|-------------------------|----------------|---------------|---------------------|------------------|
| Rule-based | Explicit rules | High | Low | Limited | No |
| Deep Learning | Implicit weights | Low | Medium | Limited | No |
| Knowledge-based | Ontology/KG | High | Low | Limited | No |
| **Our Approach** | **KG + LLM** | **High** | **High** | **Full** | **Yes** |

Table 2: System Comparison with Related Work

| System | Uses LLM | Uses Domain KG | Bidirectional Reasoning | Natural Language Interface | Target Domain |
|---------|-----------|----------------|----------------------|------------------------|---------------|
| KG-based Diagnosis [Li2022] | No | Yes | No | No | CNC |
| Deep Learning Diagnosis [Zhang2023] | No | No | No | No | CNC |
| LLM+KG QA [Zhou2023] | Yes | Yes (General) | No | Yes | General QA |
| **Our System** | **Yes** | **Yes (CNC-specific)** | **Yes** | **Yes** | **CNC Diagnosis** |

Our system fills the identified research gaps through several novel contributions. Unlike unidirectional knowledge augmentation approaches, our bidirectional mechanism enables the knowledge graph to evolve based on patterns extracted by the LLM, while LLM outputs are validated against structured knowledge to reduce hallucinations. The domain-specific ontology construction captures CNC fault diagnosis expertise that generic industrial knowledge graphs miss. Furthermore, our multi-modal fusion architecture integrates heterogeneous data sources that existing systems typically address in isolation.

The positioning statement for our research is: We present the first comprehensive framework for CNC fault diagnosis that tightly integrates domain-specific knowledge graphs with large language models through bidirectional reasoning, addressing the critical industrial requirements of explainability, adaptability, and real-time performance simultaneously.
