# 已生成论文索引

> 所有生成的论文存储在各项目的 `workspace/{project}/output/paper.md`，历史记录通过 Git 管理。

## 快速查看

```bash
# 列出所有工作空间
ls -d workspace/*/

# 查看某项目的最终论文
cat workspace/{project}/output/paper.md

# 查看某项目的评审分数
cat workspace/{project}/phase4/d1-review-report.json | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('average_score','N/A'))"
```

## 论文历史记录

论文历史通过 Git 进行版本管理。查看历史论文：

```bash
# 查看当前项目的论文历史提交
git log --oneline -- workspace/{project}/output/paper.md

# 查看特定历史版本的论文内容
git show <commit-hash>:workspace/{project}/output/paper.md
```

## 首篇论文：Cognitive Hub

虽然 `papers/` 目录已移除，但首篇论文仍值得记录：

- **完整标题**: Cognitive Hub: A Multi-Agent Architecture for Ontology-Driven Natural Language Data Querying at Enterprise Scale
- **项目名**: smart-query
- **最终评分**: 7.3/10 (Minor Revision, Accept-Leaning)
- **目标会议**: AAAI (primary) | CIKM (secondary)
- **生成日期**: 2026-02-11
- **总执行时间**: ~3 小时 40 分钟

### 研究问题

如何在包含 35,000+ 表格的企业级数据库环境中，实现自然语言到数据库映射的精准查询？

### 核心贡献

- **认知中枢架构**：本体层（陈述性记忆）+ 技能层（程序性记忆）
- **三策略串行执行**：Indicator Expert → Scenario Navigator → Term Analyst
- **隐式上下文继承**：通过对话历史实现数字间接通信（Stigmergy）
- **证据包融合**：三策略交叉验证，分级置信度评分

### 系统规模

| 指标 | 数值 |
|------|------|
| 本体节点 | 314,680 个 |
| 关系数量 | 623,118 条 |
| 物理表数 | 35,287 个 |

### 原始文件位置

- 工作空间: `workspace/smart-query/`（已重命名为 `smart-query-OLD/`）
- 输入素材: `workspace/smart-query/phase1/input-context.md`
- 评审报告: `workspace/smart-query/phase4/d1-review-report.md`

---

**最后更新**: 2026-02-13
