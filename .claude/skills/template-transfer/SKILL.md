---
name: template-transfer
description: "模板转换专家 — 将论文从一个会议/期刊格式转换为另一个格式，支持 LaTeX→LaTeX 迁移。"
---

# Template Transfer: 模板转换专家

## 调用方式

`Skill(skill="template-transfer", args="{project}:{target_venue}")`

## 参数解析

从 `args` 解析（以 `:` 分隔）：
- `project` — 项目目录名称（必需）
- `target_venue` — 目标会议/期刊 ID（必需，如 `CVPR`、`NeurIPS`）

验证：
1. `workspace/{project}/output/paper.tex` 存在（C4 输出的 LaTeX 源码）
2. `templates/manifest.json` 中存在目标模板
3. 目标 venue 与当前 venue 不同

如果验证失败，返回 `"status": "blocked"` 并描述缺失内容。

---

## 角色定义

您是一名 **LaTeX 模板转换专家**。您将已有的 LaTeX 论文从一个会议/期刊模板迁移到另一个模板，保持学术内容不变，仅调整格式、样式和结构以符合目标模板要求。

此功能借鉴了 OpenPrism 的 Template Transfer 设计（LangGraph 工作流），适配为 Paper Factory 的 Skill 架构。

---

## 执行步骤

### 步骤 1：分析源项目

读取 `workspace/{project}/output/paper.tex`，提取：
- **preamble**：`\documentclass` 到 `\begin{document}` 之间的所有内容
- **metadata**：`\title{}`、`\author{}`、`\date{}`
- **body**：`\begin{document}` 到 `\end{document}` 之间的内容
- **bibliography**：`\bibliography{}` 或 `\begin{thebibliography}` 的内容
- **assets**：引用的 `.bib`、`.sty`、图片文件列表

记录源模板类型（从 `\documentclass` 和 `\usepackage` 推断）。

### 步骤 2：分析目标模板

读取 `templates/{target_template}/` 目录：
- 主文件结构（preamble、document body 骨架）
- 必需的样式文件（`.sty`、`.bst`）
- 模板特定的命令和环境
- 章节组织方式（单文件 vs 多文件 `\input{}`）

### 步骤 3：生成迁移计划

基于源和目标的差异，生成迁移计划：

```json
{
  "source_template": "acl",
  "target_template": "cvpr",
  "changes": [
    {"type": "preamble", "action": "replace_documentclass", "from": "article", "to": "cvpr"},
    {"type": "preamble", "action": "replace_style", "from": "acl.sty", "to": "cvpr.sty"},
    {"type": "preamble", "action": "add_package", "package": "cvpr_specific_pkg"},
    {"type": "bibliography", "action": "change_style", "from": "acl_natbib", "to": "ieeenat_fullname"},
    {"type": "author", "action": "reformat", "note": "ACL 格式→CVPR 格式"},
    {"type": "structure", "action": "merge_sections", "note": "如果目标模板要求单文件"}
  ]
}
```

### 步骤 4：执行迁移

1. 创建新项目目录：`workspace/{project}/output/transfer-{target_venue}/`
2. 复制目标模板的样式文件到新目录
3. 生成新的 `paper.tex`：
   - 使用目标模板的 preamble
   - 迁移 metadata（适配目标模板的作者格式）
   - 迁移 body 内容（保持学术内容不变）
   - 适配 bibliography 格式
4. 复制 `references.bib` 和其他资源文件

### 步骤 5：编译验证

调用编译流程验证转换后的论文：

```bash
cd workspace/{project}/output/transfer-{target_venue}/
pdflatex -interaction=nonstopmode paper.tex
bibtex paper
pdflatex -interaction=nonstopmode paper.tex
pdflatex -interaction=nonstopmode paper.tex
```

如果编译失败，进入自动修复循环（最多 3 轮），与 C4 的诊断修复逻辑一致。

### 步骤 6：输出结果

**成功时**：
```json
{
  "status": "success",
  "source_venue": "ACL",
  "target_venue": "CVPR",
  "output_dir": "workspace/{project}/output/transfer-cvpr/",
  "files": ["paper.tex", "references.bib", "cvpr.sty", "paper.pdf"],
  "compile_status": "success",
  "warnings": []
}
```

**编译失败但 tex 可用时**：
```json
{
  "status": "tex_ready",
  "message": "LaTeX 源码已生成，但编译失败。请手动修复或使用 Overleaf 编译。",
  "unresolved_errors": ["..."]
}
```

---

## 模板差异映射

| 维度 | ACL | CVPR | NeurIPS | ICML |
|------|-----|------|---------|------|
| documentclass | article | cvpr | article | article |
| 格式 | 双栏 | 双栏 | 单栏 | 双栏 |
| 作者格式 | `\author{A \And B}` | `\author{A\\inst \And B\\inst}` | `\author{A \And B}` | `\author{A \And B}` |
| bib style | acl_natbib | ieeenat_fullname | plainnat | icml |
| 页数限制 | 8+unlimited appendix | 8+unlimited suppl | 9+unlimited appendix | 8+unlimited appendix |

---

## 约束

- 不修改论文的学术内容——仅做格式迁移
- 保持所有引用、交叉引用、公式编号不变
- 如果目标模板不支持源模板的某些特性（如特殊环境），用最接近的等效替换
- 转换后的文件放在独立目录，不覆盖原始输出
