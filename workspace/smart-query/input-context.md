# 论文输入素材

## 论文主题

基于领域本体认知中枢层的智能问数系统：三策略串行推理与证据融合裁决机制

## 工作标题

OntoCognitive: A Domain Ontology-Driven Cognitive Hub Architecture for Intelligent Natural Language to SQL with Multi-Strategy Serial Reasoning and Evidence Fusion

## 目标系统

Smart Query — 一个面向银行业的智能问数系统，通过构建三层领域本体知识图谱（23.8 万+节点、19.7 万+关系），结合三策略串行推理与证据融合裁决机制，将用户自然语言需求精准映射到数据库 Schema、表和字段，最终生成可执行的复杂 SQL 查询。

## 创新点列表

### 创新点 1：领域本体作为认知中枢层（Ontology as Cognitive Hub）

**描述**：提出"本体层 + Skills = 认知中枢层"的架构范式。领域本体不仅是静态知识存储，而是通过与认知框架（Skills）结合，形成具备领域认知能力的"认知中枢层"，弥补通用 LLM 在专业领域的知识时效性、领域特异性和推理一致性等根本性局限。

**代码位置**：
- 本体层构建：`ontology-layer/src/load/main.py`（22 步 ETL 流水线）
- 认知框架定义：`.claude/skills/smart-query/SKILL.md`（主编排器）
- 理论阐述：`docs/knowledge/research-exploration.md`（探索一：1.2 节）

### 创新点 2：三层分层知识图谱设计（Three-Layer Hierarchical Knowledge Graph）

**描述**：设计了三层分层知识图谱架构——魔数师指标层（163,284 节点，5 级层次：SECTOR→CATEGORY→THEME→SUBPATH→INDICATOR）、数据资产层（35,379 节点，3 级层次：SCHEMA→TABLE_TOPIC→TABLE）、术语标准层（40,319 节点，TERM + DATA_STANDARD），通过 197,973 条跨层关联边实现跨层导航。

**代码位置**：
- 层次结构定义：`ontology-layer/config.py`（NODE_TYPE_MAPPING、PHYSICAL_SCHEMAS）
- 指标层构建：`ontology-layer/src/transform/build_hierarchy.py`
- 数据资产层构建：`ontology-layer/src/transform/build_physical_hierarchy.py`
- 术语标准层构建：`ontology-layer/src/transform/build_term_standard.py`
- 跨层关联加载：`ontology-layer/src/load/neo4j_loader.py`（create_cross_layer_relationships）

### 创新点 3：三策略串行推理与语义累积效应（Three-Strategy Serial Reasoning with Semantic Cumulative Effect）

**描述**：设计了三策略串行执行架构——指标驱动→场景驱动→术语驱动，利用对话历史实现隐式上下文继承，使后序策略能够利用前序策略的发现进行语义增强。从信息论角度，共享上下文模式下 H(I|S₁,S₂,S₃) < H(I|S₁,S₂) < H(I|S₁) < H(I)，实现语义的层层累积降熵。

**代码位置**：
- 串行编排：`.claude/skills/smart-query/SKILL.md`（三策略串行调度）
- 策略一（指标驱动）：`.claude/skills/smart-query-indicator/SKILL.md`
- 策略二（场景驱动）：`.claude/skills/smart-query-scenario/SKILL.md`
- 策略三（术语驱动）：`.claude/skills/smart-query-term/SKILL.md`
- 理论分析：`docs/knowledge/research-exploration.md`（探索二：2.2 节，语义累积效应）

### 创新点 4：证据包融合与 LLM 裁决机制（Evidence Pack Fusion with LLM Adjudication）

**描述**：每个策略独立收集结构化证据包（Evidence Pack），包含匹配指标、候选表、字段映射、置信度等信息。三个证据包在综合裁决阶段进行交叉验证、冲突解决和完整性检查，由 LLM 基于完整证据进行最终裁决，输出精炼的表-字段映射结果。

**代码位置**：
- 证据包结构定义：`.claude/skills/smart-query/SKILL.md`（evidence_pack 结构）
- 策略一证据包：`.claude/skills/smart-query-indicator/SKILL.md`（结构化输出）
- 策略二证据包：`.claude/skills/smart-query-scenario/SKILL.md`（结构化输出）
- 策略三证据包：`.claude/skills/smart-query-term/SKILL.md`（结构化输出）
- 裁决流程：`docs/knowledge/research-exploration.md`（1.3.3 节，证据包构建机制）

### 创新点 5：收敛路径导航与双重检索机制（Convergent Path Navigation with Dual Retrieval）

**描述**：策略二采用 Schema→Topic→Table 的收敛路径导航，将 35,000+ 张表的搜索空间逐步缩小到目标 Topic 下的数十张表。同时强制执行双重检索——收敛路径导航（结构化精确匹配）+ 混合检索（关键词+向量语义扩展），两者互补确保无遗漏。

**代码位置**：
- 收敛路径实现：`.claude/skills/smart-query-scenario/SKILL.md`（Schema→Topic→Table 导航）
- 混合检索工具：`mcp-server/ontology_server.py`（hybrid_search_tables 函数）
- Schema 配置：`ontology-layer/config.py`（PHYSICAL_SCHEMAS，9 个 Schema，83 个 Topic）
- 设计文档：`docs/knowledge/smart-query-design.md`（6.2 节，双重检索机制）

### 创新点 6：字段级向量化与固定比例混合检索（Field-Level Vectorization with Fixed-Ratio Hybrid Retrieval）

**描述**：TABLE 节点的向量化不仅基于表描述，而是将表描述与所有关键字段的描述拼接后生成 embedding（embedding_text = description + key_columns），实现字段级语义检索能力。混合检索采用固定 50:50 比例（关键词精确匹配 + 向量语义扩展），两种方法召回不同维度的相关性。

**代码位置**：
- 字段级向量化：`ontology-layer/src/load/embedding_generator.py`（_generate_table_embeddings 方法，combined_text 构建逻辑）
- 混合检索实现：`mcp-server/ontology_server.py`（hybrid_search_tables，keyword_ratio=0.5）
- 向量索引创建：`ontology-layer/src/load/neo4j_loader.py`（create_vector_index）
- 设计文档：`docs/knowledge/smart-query-design.md`（4.1-4.3 节）

### 创新点 7：血缘关系驱动的关联表发现与 JOIN 推断（Lineage-Driven Related Table Discovery）

**描述**：在综合裁决阶段，对最终确定的主表执行血缘关系分析（上游/下游依赖），自动发现可关联的维度补充表，并基于血缘关系中的字段映射推断 JOIN 条件（包括 JOIN 类型、关联字段、SQL 条件），输出完整的关联表证据包。

**代码位置**：
- 血缘分析工具：`mcp-server/ontology_server.py`（get_table_dependencies、get_table_heat_info）
- 关联表发现流程：`.claude/skills/smart-query/SKILL.md`（综合裁决阶段）
- 上游关系构建：`ontology-layer/src/load/neo4j_loader.py`（UPSTREAM 关系）
- 设计文档：`docs/knowledge/smart-query-design.md`（5.1-5.4 节）

### 创新点 8：孤点表过滤机制（Isolated Table Filtering via Lineage Heat）

**描述**：利用血缘关系的"热度"信息（下游引用数 + 上游引用数），在证据包构建阶段过滤掉热度=0 且无上游的"孤点表"（已停止维护的历史固化表），避免向用户推荐无效数据资产，提高推荐质量。

**代码位置**：
- 热度查询工具：`mcp-server/ontology_server.py`（get_table_heat_info，is_isolated 判断）
- 过滤规则：`.claude/skills/smart-query/SKILL.md`（孤点表过滤规则）
- 上游深度配置：`ontology-layer/config.py`（max_upstream_depth=5）
- 设计文档：`docs/knowledge/smart-query-design.md`（5.2 节）

### 创新点 9：预计算指标-字段映射（Pre-computed Indicator-Field Mapping）

**描述**：在 ETL 流水线的第 22 步，从 MySQL 源表中提取指标的计算表达式（BizView），解析出引用的物理表和字段，将映射结果（mapped_schemas、mapped_tables、mapped_columns、mapped_full_paths）预存储到 INDICATOR 节点属性中，实现 O(1) 时间复杂度的指标到字段查询。

**代码位置**：
- ETL 第 22 步：`ontology-layer/src/load/main.py`（step_22_precompute_indicator_field_mappings）
- BizView 解析器：`ontology-layer/src/extract/bizview_parser.py`
- 表达式解析器：`ontology-layer/src/extract/expression_parser.py`
- 映射存储：`ontology-layer/src/load/neo4j_loader.py`（update_indicator_field_mappings）
- 映射查询：`mcp-server/ontology_server.py`（get_indicator_field_mapping）

### 创新点 10：认知模块化架构（Cognitive Modularization Architecture）

**描述**：将复杂的智能问数任务拆分为独立的认知模块（Skill），每个模块约 400 行，专注单一策略。独立 Skill 实现了三重优势：(1) 100% 注意力聚焦，(2) 可独立测试验证，(3) 隐式上下文继承。核心洞察：认知系统的智能度 ≈ 模块化程度 × 上下文继承效率 × 任务专注度。

**代码位置**：
- 主编排器：`.claude/skills/smart-query/SKILL.md`（~791 行）
- 策略一 Skill：`.claude/skills/smart-query-indicator/SKILL.md`（~456 行）
- 策略二 Skill：`.claude/skills/smart-query-scenario/SKILL.md`（~455 行）
- 策略三 Skill：`.claude/skills/smart-query-term/SKILL.md`（~509 行）
- 设计文档：`docs/knowledge/smart-query-design.md`（3.1-3.3 节）

### 创新点 11：22 步 ETL 流水线与断点续传（22-Step ETL Pipeline with Checkpoint/Resume）

**描述**：设计了 22 步全自动 ETL 流水线，从 10 个 MySQL 源表中提取数据，经过层次结构转换，加载到 Neo4j 知识图谱。支持断点续传（checkpoint/resume）和非交互模式（--non-interactive），包含数据清洗（删除"临时板块"和"系统维护"等无效数据）和空 Schema 清理。

**代码位置**：
- 流水线编排：`ontology-layer/src/load/main.py`（StepExecutor 类，22 个 step 方法）
- 数据提取：`ontology-layer/src/extract/`（extract_restree.py、extract_bigmeta.py、extract_bizattr.py、extract_glossary.py）
- 层次转换：`ontology-layer/src/transform/`（build_hierarchy.py、build_physical_hierarchy.py、build_term_standard.py）
- Neo4j 加载：`ontology-layer/src/load/neo4j_loader.py`

### 创新点 12：分层关键词检索与渐进降级（Layered Keyword Search with Progressive Degradation）

**描述**：策略一的指标搜索采用分层检索机制，按照 INDICATOR→THEME→SUBPATH→CATEGORY→SECTOR 的层级顺序逐层搜索，每层使用固定比例混合检索（关键词+向量），避免 TopK 截断导致的相关结果遗漏。

**代码位置**：
- 分层检索工具：`mcp-server/ontology_server.py`（layered_keyword_search 函数）
- 策略一调用：`.claude/skills/smart-query-indicator/SKILL.md`（阶段 1：分层检索）
- 向量索引：`ontology-layer/src/load/embedding_generator.py`（INDICATOR embedding 生成）

### 创新点 13：术语驱动的独立发现路径与语义增强层（Term-Driven Independent Discovery + Semantic Enhancement）

**描述**：策略三具有双重价值：(1) 作为语义增强层，为前两策略的发现提供数据标准语义确认；(2) 作为独立发现路径，通过术语→字段映射发现前两策略覆盖不到的数据资产（策略一覆盖~5,000 张表，策略二覆盖~30,000 张表，策略三覆盖所有有术语标注的字段）。

**代码位置**：
- 策略三完整实现：`.claude/skills/smart-query-term/SKILL.md`
- 术语搜索工具：`mcp-server/ontology_server.py`（search_terms_by_keyword、get_tables_by_term）
- 术语标准层数据：`ontology-layer/src/extract/extract_glossary.py`
- 标准信息查询：`mcp-server/ontology_server.py`（get_standard_info）

### 创新点 14：多层级跨域表评估（Cross-Layer Multi-Domain Table Evaluation）

**描述**：策略二在候选表评估时，考虑数据仓库的层级优先级（DM 集市层 > EDW_C 汇总层 > EDW_M 明细层 > EDW_T 临时层 > EDW_O 操作层），优先推荐高层级（已聚合、业务语义更明确）的表，同时支持跨 Schema 的综合评估。

**代码位置**：
- 层级优先级配置：`ontology-layer/config.py`（LAYER_PRIORITY：DM=1, EDW_C=2, EDW_M=3, EDW_T=4, EDW_O=5）
- 跨层评估：`.claude/skills/smart-query-scenario/SKILL.md`（M/C/Application 层综合评估）
- Schema 业务范围：`.claude/skills/smart-query/schema-reference.md`

## 系统架构概述

Smart Query 系统采用"领域本体 + 认知中枢层"的架构范式，核心由三大子系统构成：

**第一层：领域本体知识图谱（Neo4j）**。系统构建了一个包含 238,982 个节点和 197,973 条关系的三层分层知识图谱。魔数师指标层（163,284 节点）以 5 级层次结构（SECTOR→CATEGORY→THEME→SUBPATH→INDICATOR）组织银行业务指标体系；数据资产层（35,379 节点）以 3 级层次（SCHEMA→TABLE_TOPIC→TABLE）组织物理数据库结构；术语标准层（40,319 节点）管理业务术语与数据标准的映射关系。三层之间通过 HAS_INDICATOR（147,464 条）和 UPSTREAM（50,509 条）等跨层关联边实现知识互通。知识图谱的构建由一个 22 步全自动 ETL 流水线完成，从 10 个 MySQL 源表中提取、转换并加载数据到 Neo4j，支持断点续传和增量更新。

**第二层：MCP 工具服务层**。系统通过 Model Context Protocol 暴露约 28 个工具函数，分布在两个 MCP 服务器中：ontology_server（基于 Neo4j，提供知识图谱导航、混合检索、血缘分析等约 20 个工具）和 simple_resources_server（基于 MySQL，提供表结构查询、SQL 执行等约 8 个工具）。关键工具包括分层关键词检索（layered_keyword_search）、混合检索（hybrid_search_tables，50% 关键词 + 50% 向量）、血缘依赖分析（get_table_dependencies）等。向量检索基于 sentence-transformers 的 paraphrase-multilingual-MiniLM-L12-v2 模型（384 维），支持中英文多语言语义匹配。

**第三层：认知推理层（Skills）**。系统的核心推理逻辑封装在 5 个独立的 Skill 模块中，采用三策略串行执行架构：策略一（指标驱动）通过魔数师指标层搜索定位业务概念和候选字段；策略二（场景驱动）通过 Schema→Topic→Table 收敛路径导航 + 混合检索定位候选表；策略三（术语驱动）通过业务术语搜索提供语义增强和独立发现路径。三个策略的证据包在综合裁决阶段进行交叉验证和融合，由 LLM 基于完整证据进行最终裁决。裁决后对主表执行血缘关系分析，发现关联表并推断 JOIN 条件。最终由 SQL Generation Skill 基于完整证据包生成可执行的复杂 SQL 查询。整个推理过程利用对话历史实现隐式上下文继承，后序策略能够利用前序策略的发现进行语义增强，形成"语义累积效应"。

## 关键术语定义

- **认知中枢层（Cognitive Hub Layer）**：本体层（静态知识结构）+ Skills（认知框架）= 认知中枢层（领域认知能力），是弥补通用 LLM 领域局限的核心架构
- **证据包（Evidence Pack）**：每个策略执行后输出的结构化数据，包含匹配指标、候选表、字段映射、置信度等信息，供综合裁决使用
- **收敛路径（Convergent Path）**：Schema→Topic→Table 的渐进式导航路径，每步缩小搜索空间
- **孤点表（Isolated Table）**：热度=0 且上游=0 的表，通常已废弃，应从推荐结果中排除
- **血缘关系（Lineage）**：表之间的数据流动关系（UPSTREAM），用于发现关联表和推断 JOIN 条件
- **语义累积效应（Semantic Cumulative Effect）**：三策略串行执行中，后序策略利用前序策略的发现进行语义增强，信息熵逐层降低的效应
- **分层检索（Layered Keyword Search）**：按知识图谱层级逐层搜索，避免 TopK 截断遗漏
- **混合检索（Hybrid Search）**：关键词精确匹配 + 向量语义检索的组合，固定 50:50 比例
- **字段级向量化（Field-Level Vectorization）**：TABLE 节点 embedding = 表描述 + 关键字段描述，实现字段级语义检索
- **预计算映射（Pre-computed Mapping）**：ETL 第 22 步将指标→物理字段的映射预存储到 INDICATOR 节点属性，实现 O(1) 查询
- **魔数师（Magic Number）**：某银行自研的数据分析平台，其指标体系构成知识图谱的指标层
- **本体层（Ontology Layer）**：基于 Neo4j 的三层知识图谱，包含指标层、数据资产层、术语标准层

## 定量指标

### 知识图谱规模
- **总节点数**：238,982 个
  - 魔数师指标层：163,284 节点（SECTOR→CATEGORY→THEME→SUBPATH→INDICATOR，5 级层次）
  - 数据资产层：35,379 节点（SCHEMA: 9 → TABLE_TOPIC: 83 → TABLE: 35,287）
  - 术语标准层：40,319 节点（TERM: 39,558 + DATA_STANDARD: 761）
- **总关系数**：197,973 条跨层关联
  - HAS_INDICATOR：147,464 条（TABLE→INDICATOR）
  - UPSTREAM：50,509 条（TABLE→TABLE 血缘关系）
- **关系类型**：7 种（HAS_CHILD、HAS_TOPIC、HAS_TABLE、UPSTREAM、HAS_INDICATOR、HAS_TERM、BELONGS_TO_STANDARD）
- **向量索引**：3 个（INDICATOR、TABLE、TERM），384 维，余弦相似度

### 系统组件
- **MCP 工具**：~28 个（ontology_server: ~20 个 + simple_resources_server: ~8 个）
- **核心 Skill**：5 个（smart-query 主编排器 + 3 个策略 Skill + sql-generation）
- **ETL 步骤**：22 步（指标层 9 步 + 数据资产层 7 步 + 术语标准层 4 步 + 预计算映射 2 步）
- **MySQL 源表**：10 个
- **物理 Schema**：9 个（dmrbm_data、dmcbm_data、dmhrm_data 等）
- **表主题（Topic）**：83 个
- **层级优先级**：5 级（DM > EDW_C > EDW_M > EDW_T > EDW_O）

### 代码规模
- **Python 源文件**：60 个（ontology-layer: 46 个 + MCP server: 2 个 + 其他: 12 个）
- **Python 代码行数**：~17,607 行（不含 venv）
- **Skill 文件**：23 个 SKILL.md，共 6,554 行
- **知识文档**：73 个 Markdown 文件，共 21,283 行
- **Embedding 模型**：paraphrase-multilingual-MiniLM-L12-v2（384 维，多语言支持）
- **批处理配置**：BATCH_SIZE=1000, CHUNK_SIZE=500

## 代码库信息

**路径**：`/Users/yyzz/Desktop/MyClaudeCode/smart-query`

**关键文件**：
| 文件 | 说明 | 行数 |
|------|------|------|
| `ontology-layer/src/load/main.py` | 22 步 ETL 流水线编排器 | 1,442 |
| `ontology-layer/src/load/neo4j_loader.py` | Neo4j 数据加载器 | 1,095 |
| `ontology-layer/src/load/embedding_generator.py` | 向量 embedding 生成器 | 729 |
| `ontology-layer/config.py` | 全局配置（Schema、Topic、层级优先级） | 398 |
| `mcp-server/ontology_server.py` | Neo4j MCP 服务器（~20 个工具） | ~1,250 |
| `mcp-server/simple_resources_server.py` | MySQL MCP 服务器（~8 个工具） | ~900 |
| `.claude/skills/smart-query/SKILL.md` | 主编排器 Skill | ~791 |
| `.claude/skills/smart-query-indicator/SKILL.md` | 策略一：指标驱动 | ~456 |
| `.claude/skills/smart-query-scenario/SKILL.md` | 策略二：场景驱动 | ~455 |
| `.claude/skills/smart-query-term/SKILL.md` | 策略三：术语驱动 | ~509 |
| `.claude/skills/sql-generation/SKILL.md` | SQL 生成 Skill | ~1,259 |
| `docs/knowledge/research-exploration.md` | 科研探索文档（理论基础） | ~1,439 |
| `docs/knowledge/smart-query-design.md` | 系统设计文档 | ~558 |

**技术栈**：
- **知识图谱**：Neo4j（图数据库）+ Cypher 查询语言
- **向量检索**：sentence-transformers（paraphrase-multilingual-MiniLM-L12-v2，384 维）
- **数据源**：MySQL（10 个源表）
- **MCP 协议**：Model Context Protocol（2 个 MCP 服务器）
- **AI 框架**：Claude Code + Skill 架构（认知模块化）
- **编程语言**：Python 3.14（ETL + MCP 服务器）
- **ETL 工具**：自研 22 步流水线（StepExecutor 类）
