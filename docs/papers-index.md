# 已生成论文索引

## 论文列表

| # | 标题 | 项目 | 评分 | 日期 |
|---|------|------|------|------|
| 001 | Cognitive Hub: A Multi-Agent Architecture for Ontology-Driven Natural Language Data Querying at Enterprise Scale | smart-query | 7.3/10 | 2026-02-11 |

---

## 论文详情

### #001 — Cognitive Hub

**完整标题**: Cognitive Hub: A Multi-Agent Architecture for Ontology-Driven Natural Language Data Querying at Enterprise Scale

**项目名**: smart-query
**最终评分**: 7.3/10 (Minor Revision, Accept-Leaning)
**目标会议**: AAAI (primary) | CIKM (secondary)
**生成日期**: 2026-02-11
**总执行时间**: ~3 小时 40 分钟

**研究问题**: 如何在包含 35,000+ 表格的企业级数据库环境中，实现自然语言到数据库映射的精准查询？

**核心贡献**:
- 认知中枢架构：本体层（陈述性记忆）+ 技能层（程序性记忆）
- 三策略串行执行：Indicator Expert → Scenario Navigator → Term Analyst
- 隐式上下文继承：通过对话历史实现数字间接通信（Stigmergy）
- 证据包融合：三策略交叉验证，分级置信度评分

**系统规模**:
| 指标 | 数值 |
|------|------|
| 本体节点 | 314,680 个 |
| 关系数量 | 623,118 条 |
| 物理表数 | 35,287 个 |

**文件路径**:
- 论文全文: `papers/001-smart-query-cognitive-hub.md`
- 工作空间: `workspace/smart-query/`
- 输入素材: `workspace/smart-query/phase1/input-context.md`
- 评审报告: `workspace/smart-query/phase4/d1-review-report.md`

---

## 添加新论文

当生成新论文后，请按以下模板添加条目：

```markdown
### #{编号} — {简称}

**完整标题**: {论文标题}

**项目名**: {project-name}
**最终评分**: {score}/10
**目标会议**: {venue}
**生成日期**: YYYY-MM-DD

**研究问题**: {一句话描述}

**核心贡献**:
- {贡献 1}
- {贡献 2}

**文件路径**:
- 论文全文: `papers/{编号}-{project-name}-{short-title}.md`
- 工作空间: `workspace/{project-name}/`
```

---

## 快速发现

```bash
# 列出所有已归档论文
ls papers/*.md

# 列出所有工作空间
ls -d workspace/*/

# 查看最新论文的评审分数
cat workspace/*/phase4/d1-review-report.json | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('average_score','N/A'))"
```
