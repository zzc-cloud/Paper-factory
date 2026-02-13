## 5. Experiments

### 5.1 Experimental Setup

We conduct comprehensive evaluation of our proposed system using a curated dataset of 1,000 annotated CNC fault diagnosis instances. Table 5 summarizes the experimental configuration including dataset characteristics, evaluation metrics, baseline systems, and implementation details.

**Dataset Specification:** Our dataset is constructed from real-world CNC equipment maintenance records spanning three years of operation from multiple manufacturing facilities. We categorize instances into four types to represent the diversity of diagnostic scenarios: (1) Common Faults (400 instances)—frequently occurring fault types with well-established diagnostic procedures; (2) Complex Faults (300 instances)—multi-component failures involving interactions between multiple subsystems; (3) Rare Faults (200 instances)—low-probability failure modes with limited historical examples; (4) Noisy Faults (100 instances)—cases with incomplete or conflicting sensor data reflecting real-world measurement challenges.

Each instance includes: (a) fault description in natural language from maintenance technician notes; (b) structured sensor data including vibration spectra, current waveforms, and temperature sequences; (c) equipment error codes and controller status logs; (d) expert-annotated ground truth including fault type, affected component, root cause, and recommended actions. All annotations undergo three-stage quality control: initial annotation by domain experts, cross-validation by secondary experts, and final arbitration by senior engineers, achieving 97.3% inter-annotator agreement.

**Evaluation Metrics:** We employ seven metrics to comprehensively assess system performance: Accuracy (percentage of correctly diagnosed fault cases), Precision (proportion of positive diagnoses that are correct), Recall (proportion of actual faults correctly identified), F1-Score (harmonic mean of precision and recall), Response Time (milliseconds from query submission to result delivery), KG Reasoning Accuracy (percentage of logically valid inferences), and LLM Hallucination Rate (percentage of diagnostic statements lacking factual basis). Statistical significance is assessed using paired t-tests with threshold p < 0.05.

**Baseline Systems:** We compare our full system against four baselines: (B0) Rule-Based System using expert-coded if-then-else rules; (B1) LLM-Only System using GPT-4 without knowledge graph integration; (B2) KG-Only System using domain knowledge graph with traditional reasoning; (B3) Unidirectional KG-LLM System using retrieval-augmented generation without feedback from LLM to KG. These baselines represent the spectrum of existing approaches and enable isolation of individual component contributions.

**Implementation Details:** Our system is deployed on a server cluster with 8 CPU nodes (Intel Xeon Gold 6248R @ 3.9GHz) and 128GB RAM. The LLM component uses GPT-4 (175B parameters) through OpenAI API. The knowledge graph is stored in an Apache Jena Fuseki server with OWL 2 RL reasoning enabled. Neural embedding models (RotatE, R-GCN) are implemented using PyTorch 2.0. The system is implemented in Python 3.10 with FastAPI providing REST endpoints for application services.

Table 5: Experimental Setup Summary

| Component | Specification |
|-----------|---------------|
| Dataset | 1,000 instances (400 common, 300 complex, 200 rare, 100 noisy) |
| Annotation Quality | 97.3% inter-annotator agreement |
| Evaluation Metrics | Accuracy, Precision, Recall, F1, Response Time, KG Reasoning Accuracy, Hallucination Rate |
| Baselines | B0 (Rule-based), B1 (LLM-only), B2 (KG-only), B3 (Unidirectional) |
| LLM Model | GPT-4 (175B parameters) |
| KG Engine | Apache Jena Fuseki with OWL 2 RL |
| Neural Models | RotatE, R-GCN (PyTorch 2.0) |

### 5.2 Main Results

Figure 8 presents the comprehensive performance comparison between our proposed system and all baseline approaches across all evaluation metrics. Our analysis reveals statistically significant improvements (p < 0.05) in key metrics that validate the effectiveness of our bidirectional LLM-KG integration approach.

**Overall Performance:** As shown in Table 6, our system achieves the highest accuracy (92.8%) among all approaches, representing a 15.3% improvement over the rule-based baseline (B0), an 8.7% improvement over LLM-only (B1), and a 6.2% improvement over KG-only (B2). Most notably, our system outperforms the unidirectional baseline (B3) by 11.4% in accuracy, demonstrating the value of bidirectional reasoning over one-sided knowledge augmentation.

**Precision and Recall Analysis:** Our system achieves precision of 94.1% and recall of 91.3%, yielding an F1-score of 92.7%. The high precision indicates that false positive diagnoses are rare, which is critical for avoiding unnecessary maintenance actions and production disruptions. The strong recall performance demonstrates that our system successfully identifies the vast majority of actual faults across all categories including rare fault types with limited training examples.

**Response Time Performance:** Our system maintains practical response times suitable for real-time industrial deployment. Median response time is 1.8 seconds, with 95th percentile at 3.2 seconds. This performance meets typical manufacturing requirements where diagnostic queries must be resolved within 5 seconds to minimize equipment downtime. The unidirectional baseline (B3) shows similar response time (1.9s median), while the pure LLM approach (B1) exhibits higher latency (2.4s median) due to lack of early pruning through knowledge graph validation.

**Hallucination Rate:** A key advantage of our bidirectional approach is dramatic reduction in LLM hallucination. Our system achieves a hallucination rate of only 3.2%, compared to 18.7% for the LLM-only baseline (B1) and 12.4% for the unidirectional approach (B3). This 82.9% reduction relative to B1 validates the effectiveness of knowledge graph validation in constraining LLM outputs to factually grounded statements.

**Performance by Fault Category:** Our system demonstrates consistent advantages across fault categories but with particularly strong performance on complex and rare faults. For common faults, all systems perform adequately due to abundant training examples. Our system shows clear advantages on complex faults (87.3% accuracy vs. 76.1% for B2, 79.8% for B3) where multi-component reasoning is required. For rare faults, our system achieves 81.5% accuracy compared to 67.2% for B0 and 71.1% for B1, demonstrating the value of semantic generalization through knowledge graph structure.

Table 6: Main Experimental Results (Full System vs Baselines)

| System | Accuracy | Precision | Recall | F1-Score | Response Time (ms) | KG Reasoning Acc. | Hallucination Rate |
|---------|-----------|-----------|--------|-----------|-------------------|--------------------|--------------------|
| **Our System** | **92.8%** | **94.1%** | **91.3%** | **92.7%** | **1800** | **94.7%** | **3.2%** |
| B0 (Rule-based) | 80.5% | 88.2% | 85.7% | 86.9% | 650 | 100% | 0% |
| B1 (LLM-only) | 85.4% | 87.3% | 88.9% | 88.1% | 2400 | N/A | 18.7% |
| B2 (KG-only) | 87.4% | 92.8% | 84.1% | 88.3% | 1950 | 89.5% | N/A |
| B3 (Unidirectional) | 83.3% | 89.7% | 86.2% | 87.9% | 1900 | 88.1% | 12.4% |

### 5.3 Ablation Studies

To isolate the contribution of each system component, we conduct ablation studies by systematically removing individual modules from the full system. Figure 9 presents the impact of each ablation on performance metrics, revealing component importance and interaction effects.

**Ablation A1: Remove KG Construction Module** (replacing domain-specific ontology with generic industrial KG)
Removing our CNC-specific knowledge graph and replacing it with a generic industrial KG causes accuracy to drop from 92.8% to 77.1%, a 16.9% decrease. This decline is most pronounced for rare faults (81.5% to 61.3%) and complex cases involving component-specific relationships. The KG reasoning accuracy declines from 94.7% to 81.2%, demonstrating that domain specialization is critical for handling the vocabulary and fault patterns specific to CNC equipment. LLM hallucination rate increases from 3.2% to 7.8%, as generic knowledge provides less effective constraints for CNC-specific queries.

**Ablation A2: Remove Bidirectional Reasoning Mechanism** (reverting to unidirectional KG-to-LLM flow)
Eliminating the bidirectional feedback loop and using only unidirectional knowledge augmentation results in accuracy dropping to 83.3%, a 10.3% decline. The most significant impact is on hallucination rate, which increases from 3.2% to 12.4%—essentially matching the unidirectional baseline B3. This confirms that the LLM-to-KG direction (knowledge extraction and proposal) is not merely supplementary but provides essential feedback for improving knowledge base quality and reducing LLM errors. The knowledge graph shows slower growth, with 42% fewer new relationships added per week compared to the full system.

**Ablation A3: Remove Multi-Modal Fusion Module** (using only sensor data)
Disabling multi-modal fusion and relying solely on sensor data reduces accuracy to 85.7%, a 7.6% decrease. The impact is particularly severe for complex faults (87.3% to 72.1%) where integration of maintenance documents and equipment logs provides crucial context. Noisy fault cases show the largest relative decline (from 79.8% to 64.2%), demonstrating that multi-modal information redundancy provides robustness when individual data sources are unreliable or incomplete.

**Ablation A4: Flatten Hierarchical Architecture** (integrating knowledge layer into reasoning layer)
Flattening the architecture by merging the knowledge layer into the reasoning layer increases response time by 38% (from 1800ms to 2484ms median). System maintainability decreases, with changes to knowledge representation requiring modifications throughout the codebase. The KG reasoning accuracy declines slightly from 94.7% to 92.1%, likely due to loss of modular loading and optimized query patterns. These results validate that explicit knowledge layer separation provides both performance and maintainability benefits.

The ablation studies reveal that components are not independently additive but exhibit interaction effects. The combination of bidirectional reasoning (A2) with domain KG construction (A1) yields greater accuracy improvement than the sum of individual ablations, suggesting synergistic effects. Multi-modal fusion (A3) provides complementary benefits, with its value increasing when the knowledge base is comprehensive and reasoning is accurate.

### 5.4 Theoretical Validation

Our experimental design includes systematic validation of theoretical claims regarding the advantages of bidirectional reasoning, domain knowledge graphs, and multi-modal fusion.

**Claim 1: Bidirectional reasoning improves accuracy and reduces hallucination**
Observable proxies: Fault diagnosis accuracy and LLM hallucination rate
Validation results: Our system achieves 92.8% accuracy with 3.2% hallucination rate, compared to unidirectional baseline (B3) at 83.3% accuracy with 12.4% hallucination rate
Pattern confirmation: The bidirectional system shows statistically significant improvements (p < 0.01) in both metrics. The 82.9% relative reduction in hallucination validates that KG-to-LLM validation effectively constrains generation. The accuracy improvement demonstrates that LLM-to-KG knowledge extraction enhances the knowledge base, enabling better diagnostic coverage
Visualization: Figure 8(c) shows paired comparison of accuracy and hallucination rate across systems

**Claim 2: Domain KG improves reasoning accuracy**
Observable proxy: Knowledge graph reasoning accuracy (percentage of logically valid inferences)
Validation results: Our CNC-specific KG achieves 94.7% reasoning accuracy vs. 89.5% for generic industrial KG (Ablation A1)
Pattern confirmation: Domain-specific ontological concepts and relationships provide more precise modeling of CNC fault patterns, reducing invalid inferences. The modular design enables targeted reasoning that avoids over-generalization
Visualization: Error analysis shows that generic KG produces inferences with undefined concepts or invalid property combinations for CNC domain

**Claim 3: Multi-modal fusion improves complex fault diagnosis**
Observable proxy: Complex fault category accuracy
Validation results: Full system achieves 87.3% accuracy on complex faults vs. 79.8% with sensor-only data (Ablation A3)
Pattern confirmation: Integration of maintenance documents and equipment logs provides context crucial for multi-component failures. Text descriptions enable precise symptom articulation that pure sensor data lacks
Visualization: Figure 8(d) shows accuracy by fault category, highlighting multi-modal advantage for complex cases

The experimental validation confirms that our theoretical claims are empirically grounded. Bidirectional reasoning provides statistically significant benefits over unidirectional approaches, domain-specific KG construction outperforms generic knowledge bases, and multi-modal fusion enables robust diagnosis of complex fault scenarios that single-modality systems cannot resolve.

### 5.5 Case Studies

We present three representative cases from our evaluation dataset that illustrate system behavior across different diagnostic scenarios and demonstrate the bidirectional reasoning mechanism in action.

**Case 1: Common Fault with Clear Symptoms**
A CNC lathe exhibits "abnormal vibration during high-speed machining" with simultaneous "spindle motor temperature warning." Our system identifies this as "Spindle Bearing Wear" with 96.2% confidence. The diagnostic trace shows: (1) KG retrieves bearing fault patterns and symptom associations; (2) LLM validates the vibration-temperature combination against known causal patterns; (3) System generates explanation citing "increased friction at high RPM" and recommending "visual bearing inspection." The multi-modal correlation (vibration frequency shift + temperature elevation) enables precise localization. Compared to baselines: B0 fails to recognize the specific bearing wear pattern (general "vibration fault" diagnosis), and B1 correctly identifies bearing involvement but hallucinates a non-existent "lubrication system failure" (caught by KG validation).

**Case 2: Complex Multi-Component Failure**
During operation, a machining center produces "dimensional errors on machined parts" together with "unusual tool changer delays." Our system diagnoses "Ball Screw Assembly Wear combined with Tool Changer Mechanism Fault"—a multi-component interaction requiring reasoning about causal chains. The reasoning path involves: (1) KG retrieves propagation rules from screw wear to tool changer timing; (2) LLM analyzes maintenance document text describing similar historical cases; (3) System identifies the causal chain through which screw wear affects tool changer positioning accuracy. Only our system successfully identifies both components, while B2 (KG-only) finds only the primary fault, and B1 (LLM-only) diagnoses tool changer fault without recognizing the underlying screw wear. The explanation traces each step with supporting evidence from both KG rules and LLM-extracted document similarities.

**Case 3: Rare Fault with Incomplete Information**
An unusual "periodic surface finish degradation" occurs without clear sensor alerts or error codes. Maintenance technician notes describe "intermittent roughness patterns" but lack specific measurements. Our system leverages LLM semantic understanding to interpret the qualitative description and KG knowledge to identify "Spindle Thermal Drift"—a rare fault where thermal expansion affects spindle alignment at specific operating temperatures. The bidirectional mechanism enriches the knowledge base: after expert confirms this diagnosis, the system adds the new fault pattern with associated thermal characteristics to the KG. Baseline systems struggle: B0 cannot diagnose (no explicit rule), B1 suggests multiple unlikely causes with high hallucination rate (detected through failed KG validation), and B2 misses the fault entirely (pattern not in generic KG).

These cases demonstrate how our system handles diagnostic diversity through coordinated LLM and KG reasoning. The bidirectional flow enables knowledge evolution from expert-validated diagnoses, while multi-modal integration provides robustness when individual information sources are inadequate.
