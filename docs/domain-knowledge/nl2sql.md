# Domain Knowledge: NL2SQL / Text-to-SQL

## 概述

本文档提供 NL2SQL (Natural Language to SQL) 领域的完整知识支持，包含：
1. **理论分析**：Schema Linking、语义解析、LLM-based 方法
2. **评审认知框架**：核心概念、评估维度和评审方法论

**调用方式：** `Skill(skill="domain-knowledge-nl2sql", args="{project}")`

**输出：** `workspace/{project}/phase1/skill-nl2sql.json`

---

## Part 1: 理论分析

### 核心研究范式

1. **语义解析范式**：将自然语言映射到形式化查询语言
2. **Schema Linking 范式**：识别自然语言中的数据库元素引用
3. **端到端学习范式**：使用神经网络直接生成 SQL
4. **LLM 增强范式**：利用大语言模型的上下文学习能力

### 关键技术组件

#### 1. Schema Linking
- **定义**：将自然语言中的词汇映射到数据库 schema 元素（表名、列名、值）
- **方法**：字符串匹配、语义相似度、图神经网络
- **挑战**：同义词、缩写、隐式引用

#### 2. SQL 生成策略
- **Sketch-based**：先生成 SQL 骨架，再填充细节
- **Seq2Seq**：序列到序列模型直接生成
- **Grammar-based**：基于 SQL 语法的约束生成
- **LLM Prompting**：通过提示词引导 LLM 生成

#### 3. 执行引导优化
- **Execution Feedback**：利用查询执行结果优化生成
- **Self-Correction**：检测并修正语法错误
- **Result Verification**：验证查询结果的合理性

### 评估维度

1. **精确匹配（Exact Match）**：生成的 SQL 与标准答案完全一致
2. **执行准确率（Execution Accuracy）**：查询结果与标准答案一致
3. **组件准确率**：SELECT、WHERE、JOIN 等子句的正确性
4. **跨数据库泛化**：在未见过的数据库上的性能

---

## Part 2: 评审认知框架

### 核心概念与评估维度

#### Schema Linking
- **期望用法**：明确说明 Schema Linking 方法，评估链接准确率
- **常见问题**：忽视同义词和缩写，未处理隐式引用
- **评审要点**：检查 Schema Linking 的完整性和准确性

#### SQL 复杂度处理
- **期望用法**：讨论对嵌套查询、：表 JOIN、聚合函数的支持
- **常见问题**：只在简单查询上测试，忽视复杂查询
- **评审要点**：验证是否在不同复杂度级别上评估

#### 错误处理
- **期望用法**：说明如何处理语法错误、语义错误、执行错误
- **常见问题**：假设生成的 SQL 总是有效的
- **评审要点**：检查是否有错误检测和修正机制

### 经典文献对标

| 论文 | 为什么重要 | 应在何处引用 |
|------|-----------|-------------|
| Seq2SQL (Zhong et al., 2017) | 首个大规模 NL2SQL 数据集 | 相关工作-数据集 |
| Spider (Yu et al., 2018) | 跨数据库泛化基准 | 实验-基准测试 |
| RAT-SQL (Wang et al., 2020) | 关系感知的 Schema Linking | 方法-Schema Linking |
| RESDSQL (Li et al., 2023) | LLM-based NL2SQL | 相关工作-LLM 方法 |

### SOTA 对比清单

- **传统方法**：Seq2SQL, SQLNet, TypeSQL
- **图神经网络方法**：RAT-SQL, LGESQL, S²SQL
- **LLM-based 方法**：RESDSQL, DIN-SQL, DAIL-SQL, C3
- **基准数据集**：Spider, WikiSQL, CoSQL, SParC

### 领域特定评审问题

1. Schema Linking 方法是什么？准确率如何？
2. 如何处理复杂 SQL（嵌套、：表 JOIN）？
3. 是否在 Spider 等标准基准上评估？
4. 跨数据库泛化能力如何？
5. 如何处理 SQL 语法错误？
6. 是否使用执行反馈优化？
7. 对未见过的表和列的泛化能力？
8. 如何处理自然语言的歧义？
9. 是否支持多轮对话式查询？
10. 与最新 LLM-based 方法的对比？
