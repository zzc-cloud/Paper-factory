# Venue Analyzer Skill

> **期刊配置解析器** — 解析 `venues.md` 中的期刊/会议配置，验证配置完整性，生成写作风格适配文件。
>
> **V2 新增**多交互式论文生成流程 — 读取扩展的期刊配置（包括写作风格、审稿标准、历史数据），生成 `venue-style-guide.md` 指导后续 Phase 的写作风格适配。

---

## Skill 概述

本 Skill 是论文生成流程中"期刊属性定位"的核心组件，负责多

1. **解析期刊配置**多从 `venues.md` 读取目标会议/期刊的完整配置
2. **验证配置完整性**多确保写作风格配置（writing_style）和审稿标准（review_criteria）存在
3. **生成风格指南**多创建 `workspace/{project}/venue-style-guide.md`
4. **检测期刊类型**多区分预定义期刊和自定义期刊（混合模式）

---

## 输入参数

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `project` | string | ✅ | 项目名称（对应 workspace/{project}/ 目录）|
| `target_venue` | string | ✅ | 目标会议/期刊 ID（如 AAAI, IJCAI）|

---

## 输出

### 1. 主输出多`workspace/{project}/venue-style-guide.md`

结构化的写作风格指南文件，包含多
- 基本信息（全称、类型、格式、页数限制）
- 摘要要求（字数范围、结构建议）
- Introduction 指导（深度、长度、结构建议）
- Related Work 指导（深度、组织方式、引用要求）
- Methodology 指导（详略程度、算法描述要求、理论证明要求）
- Experiments 指导（格式、必需评估、基线要求、统计检验）
- Discussion & Conclusion 指导（重点、长度建议）
- 审稿标准（权重分布、必需评估、特别注意）

### 2. 副助输出多`workspace/{project}/phase0/venue-analysis.json`

```json
{
  "venue_id": "AAAI",
  "full_name": "AAAI Conference on Artificial Intelligence",
  "type": "conference",
  "format": "double-column",
  "page_limit": 8,
  "is_predefined": true,
  "writing_style_configured": true,
  "review_criteria_configured": true,
  "historical_data_available": true,
  "trending_topics": ["LLM agents", "neuro-symbolic AI"],
  "acceptance_rate": 0.23,
  "review_cycle": "3-4 months"
}
```

### 3. 返回值（成功）

```json
{
  "success": true,
  "venue_id": "AAAI",
  "style_guide_path": "workspace/{project}/venue-style-guide.md",
  "analysis_path": "workspace/{project}/phase0/venue-analysis.json",
  "is_predefined": true,
  "warnings": []
}
```

### 4. 返回值（自定义期刊）

```json
{
  "success": true,
  "venue_id": "CUSTOM-VENUE",
  "style_guide_path": "workspace/{project}/venue-style-guide.md",
  "analysis_path": "workspace/{project}/phase0/venue-analysis.json",
  "is_predefined": false,
  "warnings": [
    "自定义期刊多请手动补充写作风格配置以获得最佳适配效果",
    "建议参考同类型会议/期刊的配置模板"
  ]
}
```

### 5. 返回值（失败）

```json
{
  "success": false,
  "error": "venue_not_found",
  "message": "在 venues.md 中未找到指定的期刊 ID: XXX",
  "suggestions": ["检查期刊 ID 是否正确", "考虑在 venues.md 中添加自定义配置"]
}
```

---

## 执行流程

### Step 1多初始化与验证

```bash
# 构建项目目录结构
project_dir="/Users/yyzz/Desktop/MyClaudeCode/paper-factory/workspace/${project}"
phase0_dir="${project_dir}/phase0"
mkdir -p "${phase0_dir}"

# 检查项目是否存在
if [ ! -d "${project_dir}" ]; then
  echo '{"success": false, "error": "project_not_found", "message": "项目目录不存在"}'
  exit 1
fi
```

### Step 2多读取 venues.md

使用 Read 工具读取 `/Users/yyzz/Desktop/MyClaudeCode/paper-factory/venues.md`，解析 YAML 配置块。

### Step 3多定位目标期刊配置

1. 在 venues.md 中搜索 `target_venue` 对应的 YAML 块
2. 如果找到，判断是否包含 `writing_style` 字段
3. 如果未找到，返回错误和建议

### Step 4多验证配置完整性

检查以下字段是否存在多
- 基本字段多`full_name`, `type`, `format`, `page_limit`, `template`
- 写作风格多`writing_style`（V2 新增）
  - 子字段多`abstract_length`, `abstract_structure`, `intro_depth`, ...
- 审稿标准多`review_criteria`（V2 新增）
  - 子字段多`novelty_weight`, `technical_weight`, `presentation_weight`, ...
- 历史数据多`historical_data`（V2 新增，可选）
  - 子字段多`acceptance_rate`, `review_cycle`, `trending_topics`, ...

### Step 5多生成 venue-style-guide.md

根据期刊配置生成 Markdown 格式的写作风格指南。模板如下多

```markdown
# {full_name} 写作风格指南

> 本指南由 Venue Analyzer Skill 自动生成，基于 venues.md 中的期刊配置。
> 生成时间多{timestamp}

---

## 基本信息

| 属性 | 值 |
|------|------|
| **全称** | {full_name} |
| **类型** | {type} |
| **格式** | {format} |
| **页数限制** | {page_limit 或 "无限制"} |
| **模板** | {template} |

---

## 摘要要求

- **推荐字数**多{abstract_length.min} - {abstract_length.max} 字（推荐多{abstract_length.recommended} 字）
- **结构建议**多{abstract_structure 数组，用中文描述}
- **内容要点**多基于期刊特点的摘要写作建议

### 摘要结构模板

1. {abstract_structure[0]} — 背景/动机
2. {abstract_structure[1]} — 问题/挑战
3. {abstract_structure[2]} — 方法/方案
4. {abstract_structure[3]} — 结果/贡献
{# 如果有 4 个元素}
5. {abstract_structure[3]} — 结论/意义

---

## Introduction

- **深度要求**多{intro_depth 中文描述}
- **推荐长度**多{intro_length.min} - {intro_length.max} 字
- **结构建议**多基于期刊特点的 Introduction 写作建议

### Introduction 结构建议

1. 研究背景与动机（{intro_length.min} 字起）
2. 问题陈述与挑战
3. 本文贡献
{# 如果 intro_depth 是 deep}
4. 本文结构与预览

---

## Related Work

- **深度要求**多{related_work_depth 中文描述}
- **组织方式**多{related_work_organization 中文描述}
- **引用要求**多基于期刊特点的相关工作写作建议

### Related Work 结构建议

{# 根据 related_work_organization 提供不同模板}
{# thematic: 主题组织式}
{# historical: 历史演进式}
{# comparative: 对比分析式}

---

## Methodology

- **详略程度**多{method_detail 中文描述}
- **算法描述**多{algorithm_description 中文描述}
- **理论证明**多{theory_proof 中文描述}

### Methodology 写作建议

{# 根据期刊特点提供具体建议}

---

## Experiments

- **格式**多{experiment_format 中文描述}
- **必需评估**多{required_evaluations 数组，用中文描述}
- **基线对比**多{# 如果有 baselines_required，添加相关要求}
- **统计检验**多{statistical_tests 数组，用中文描述}

### Experiments 结构建议

1. 实验设置与数据集
2. 评估指标
3. 基线方法
{# 如果 extended}
4. 实验结果与分析
5. 消融实验

---

## Discussion & Conclusion

- **重点关注**多{discussion_focus 数组，用中文描述}
- **Conclusion 长度**多{conclusion_length.min} - {conclusion_length.max} 字

### Discussion 结构建议

1. 结果解读与洞察
2. 局限性讨论
3. 未来工作方向
{# 如果是期刊}
4. 更广泛的影响与启示

---

## 审稿标准

### 权重分布

| 维度 | 权重 | 说明 |
|------|------|------|
| **创新性** | {novelty_weight} | {# 根据权重提供解释} |
| **技术质量** | {technical_weight} | {# 根据权重提供解释} |
| **表述质量** | {presentation_weight} | {# 根据权重提供解释} |

### 必需评估维度

{required_evaluations 数组，用中文描述}

### 审稿特别注意

{special_attention 数组，用中文描述}

---

## 接受论文类型

{# paper_types 数组，用中文描述}

---

## 历史数据（参考）

| 指标 | 值 |
|------|------|
| **接受率** | {acceptance_rate}（近三年平均）|
| **审稿周期** | {review_cycle} |
| **当前热点** | {trending_topics 数组，用中文列出} |

---

## 写作建议总结

基于以上分析，本期刊/会议的写作应重点多

1. **核心优势**多{# 根据期刊特点总结}
2. **避免雷区**多{# 根据审稿标准总结}
3. **成功策略**多{# 根据历史数据总结}
```

### Step 6多生成 venue-analysis.json

保存期刊分析结果到 `workspace/{project}/phase0/venue-analysis.json`。

### Step 7多返回结果

根据配置完整性返回相应的 JSON 结果。

---

## 期刊类型判断逻辑

```python
# 伪代码多判断期刊类型
PREDEFINED_VENUES = [
    "AAAI", "IJCAI", "ISWC", "WWW", "ACL", "EMNLP",
    "KR", "AAMAS", "TOIS", "TKDE"
]

def detect_venue_type(venue_id, venues_config):
  if venue_id in PREDEFINED_VENUES:
    return {
      "is_predefined": true,
      "config_source": "venues.md_predefined",
      "writing_style_available": True,
      "review_criteria_available": True
    }
  else:
    # 自定义期刊
    venue_config = venues_config.get(venue_id, {})
    has_writing_style = "writing_style" in venue_config
    has_review_criteria = "review_criteria" in venue_config

    return {
      "is_predefined": False,
      "config_source": "user_customized",
      "writing_style_available": has_writing_style,
      "review_criteria_available": has_review_criteria,
      "warnings": generate_warnings(has_writing_style, has_review_criteria)
    }

def generate_warnings(has_writing_style, has_review_criteria):
  warnings = []
  if not has_writing_style:
    warnings.append("自定义期刊缺少写作风格配置（writing_style），建议参考同类型会议/期刊模板进行补充")
  if not has_review_criteria:
    warnings.append("自定义期刊缺少审稿标准配置（review_criteria），建议补充以获得更准确的评审模拟")
  return warnings
```

---

## 混合模式处理

根据用户选择，采用混合模式多

### 预定义期刊（AAAI, IJCAI 等）

- 直接从 venues.md 读取完整配置
- 自动生成完整的风格指南
- 无警告

### 自定义期刊

- 从 venues.md 读取用户配置
- 如果缺少 `writing_style` 或 `review_criteria`多
  - 生成基础风格指南（使用通用默认值）
  - 在返回值中添加 warnings
  - 在风格指南中标注"配置不完整，建议补充"

---

## 配置值到中文描述的映射

```yaml
# intro_depth 映射
brief: "简洁版 — 快速引入主题，600-1000 字"
medium: "中等版 — 充分阐述背景和动机，800-1200 字"
deep: "深度版 — 详细研究背景和问题定位，1000-1500 字"

# related_work_depth 映射
selective: "选择性 — 重点引用最相关的 5-8 篆工作"
comprehensive: "全面性 — 广泛引用相关领域 10-15 篔工作"
critical: "批判性 — 分析现有工作的优缺点，提供对比评价"

# related_work_organization 映射
thematic: "主题组织式 — 按研究主题/问题分类组织相关工作"
historical: "历史演进式 — 按时间线/技术演进顺序组织"
comparative: "对比分析式 — 按方法/视角进行对比分析"

# method_detail 映射
brief: "简要版 — 窺述核心思想，略过实现细节"
medium: "中等版 — 核心算法描述 + 关键伪代码"
high: "详细版 — 完整算法描述 + 完整伪代码 + 复杂度分析"
very_high: "极详版 — 理论证明 + 完整伪代码 + 复杂度/正确性证明

# theory_proof 映射
optional: "可选 — 如果有理论贡献，建议提供证明"
recommended: "推荐 — 理论工作较重要时，建议提供形式化证明"
required: "必需 — 必须包含理论正确性证明"
not_required: "不需要 — 实验工作为主，理论证明非必需"

# experiment_format 映射
standard: "标准版 — 核准的实验设置 + 结果 + 分析"
compact: "紧凑版 — 精化实验描述，侧重结果"
extended: "扩展版 — 详尽的实验 + 消融实验 + 限制性分析"
```

---

## 错误处理

| 错误类型 | 处理方式 |
|---------|---------|
| `project_not_found` | 返回错，提示检查项目名称 |
| `venue_not_found` | 返回错，提供建议的期刊 ID 列表 |
| `invalid_venues_md` | 返回错，提示检查 venues.md 格式 |
| `config_incomplete` | 返回成功 + warnings，使用默认值填充 |

---

## 使用示例

```bash
# 预定义期刊
Skill(skill="venue-analyzer", args="my-project,AAAI")

# 自定义期刊
Skill(skill="venue-analyzer", args="my-project,CUSTOM-CONF-2025")
```

---

## 与其他 Skill 的集成

1. **paper-generation**多在 Phase 0 之前调用本 Skill
2. **interaction-manager**多根据 `is_predefined` 和 warnings 决定如何处理自定义期刊
3. **paper-phase2-design**多B3-paper-architect 读取 `venue-style-guide.md` 来设计论文章节结构
4. **paper-phase3-writing**多C1-section-writer 和 C3-academic-formatter 参考 `venue-style-guide.md` 进行写作和格式化
