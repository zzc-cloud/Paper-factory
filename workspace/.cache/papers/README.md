# 论文缓存目录使用指南

本目录用于存储论文工厂项目检索到的论文缓存，避免重复检索并支持用户手动添加论文。

## 目录结构

```
papers/
├── {domain}/                 # 领域子目录（如 multi_agent_systems）
│   ├── README.md            # 本说明文件
│   ├── {paper-id}.md       # 论文条目（Markdown + Frontmatter）
│   ├── .index.json          # 索引（自动生成）
│   └── .last-update.json    # 最后更新时间戳
└── search-history/           # 检索历史记录
    └── {domain}/
        ├── queries.log           # 检索查询历史
        └── processed-ids.txt      # 已处理的论文ID列表
```

## 论文条目格式

每个论文条目都是一个 `.md` 文件

### Frontmatter (元数据）

```markdown
---
id: "arxiv-2402-xxxxx"
title: "Paper Title"
authors: ["Author A", "Author B"]
year": 2024
venue: "arXiv preprint arXiv:2402.xxxxx"
source: "websearch"  # 或 "manual"
added_date": "2024-02-14T10:30:00Z"
tags": ["multi-agent", "cognitive architecture"]
status": "read"  # read | skim | todo
---
```

### 正文内容

```markdown
## Summary

论文的核心内容摘要...

## Key Contributions

1. 贡献点一
2. 贡献点二

## Relevance to Current Project

本论文与当前项目的关联点...
```

## 手动添加论文

### 1. 创建论文文件

在对应的 `{domain}/` 目录下创建新的 `.md` 文件：

```markdown
---
id: "manual-bdi-1989"
title: "Multiagent Systems: A Modern Distributed AI Approach"
authors: ["Bond, A.H.", "Gasser, L."]
year": 1989
venue: "Readings in Distributed Artificial Intelligence"
source: "manual"
added_date": "2024-02-14"
tags": ["foundational", "BDI", "multi-agent"]
status": "read"
---

## Summary

这是多智能体系统的奠基性论文，首次提出了BDI参考架构...

## Key Contributions

1. 定义了多智能体系统的核心概念和协作模式
2. 提出了BDI (Blackboard Data) 参考架构
3. 讨论了智能体间的通信和协调机制

## Relevance to Current Project

本论文提供了我们系统的理论基础...
```

### 2. 系统自动处理

下次论文生成流程运行时，系统会：
1. 自动解析新添加的论文文件
2. 将 `id` 添加到 `search-history/{domain}/processed-ids.txt`
3. 在文献综述中包含该论文
4. 更新缓存索引

## 支持的领域

| 领域标识 | 全名 | 目录名 |
|----------|------|--------|
| `multi_agent_systems` | Multi-Agent Systems | `multi_agent_systems/` |
| `knowledge_graph` | Knowledge Graphs | `knowledge_graph/` |
| `nlp_to_sql` | NL2SQL/Text2SQL | `nlp_to_sql/` |
| `bridge_engineering` | Bridge Engineering | `bridge_engineering/` |

## 缓存效果

### 首次执行
- 系统建立初始缓存
- 速度：无变化（仍需检索）
- 效果：为后续执行建立基础

### 第二次执行（同领域）
- 系统从缓存读取已处理论文
- 只检索新增论文
- 速度提升：**60-80%**
- WebSearch 调用减少：**70-90%**

### 手动添加论文后
- 立即反映到文献综述
- 无需等待检索
- 保持人类可读的文档格式

## 注意事项

1. **ID 唯一性**：每篇论文的 `id` 必须唯一，推荐使用 `{source}-{year}-{标识}` 格式
2. **source 字段**：使用 `websearch` 或 `manual`，系统据此区分来源
3. **status 更新**：可以随时更新论文的阅读状态（todo → skim → read）
4. **目录组织**：不要在不同领域间移动论文文件，系统通过目录结构识别领域

## 技术支持

如有问题，请参考：
- [论文工厂文档](../../../docs/)
- [cache-utils Skill](../../../.claude/skills/cache-utils/SKILL.md)
