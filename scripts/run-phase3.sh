#!/usr/bin/env bash
# ============================================================
# run-phase3.sh — Phase 3: 论文撰写
# C1×8节 → C2 → C3
# ============================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../config.env"

echo "╔═══════════════════════════════════════════════════╗"
echo "║  Phase 3: Writing (论文撰写)                      ║"
echo "╚═══════════════════════════════════════════════════╝"
echo ""

# --- 论文章节定义 ---
SECTIONS=(
  "01-introduction:Introduction:a4-innovations.json,a1-literature-survey.json"
  "02-related-work:Related Work:a1-literature-survey.json,b1-related-work.json"
  "03-system-architecture:System Architecture:a2-engineering-analysis.json"
  "04-multi-agent-strategy:Multi-Agent Query Strategy:a2-engineering-analysis.json,a3-mas-theory.json"
  "05-implementation:Implementation Details:a2-engineering-analysis.json"
  "06-evaluation:Evaluation:b2-experiment-design.json,a2-engineering-analysis.json"
  "07-discussion:Discussion:a3-mas-theory.json,a4-innovations.json"
  "08-conclusion:Conclusion:a4-innovations.json"
)

# --- C1: Section Writer (逐章节) ---
for SECTION_DEF in "${SECTIONS[@]}"; do
  IFS=':' read -r SEC_FILE SEC_TITLE SEC_SOURCES <<< "$SECTION_DEF"

  echo "📝 Writing Section: ${SEC_TITLE}..."

  # 构建源文件提示
  SOURCE_HINT=""
  IFS=',' read -ra SRC_FILES <<< "$SEC_SOURCES"
  for SRC in "${SRC_FILES[@]}"; do
    if [[ "$SRC" == b* ]]; then
      SOURCE_HINT="${SOURCE_HINT} Read /Users/yyzz/Desktop/MyClaudeCode/research/workspace/phase2/${SRC} for context."
    else
      SOURCE_HINT="${SOURCE_HINT} Read /Users/yyzz/Desktop/MyClaudeCode/research/workspace/phase1/${SRC} for context."
    fi
  done

  "${SCRIPT_DIR}/run-agent.sh" \
    "${RESEARCH_DIR}/agents/phase3/c1-section-writer.md" \
    "${MODEL_WRITING}" \
    "${BUDGET_C1}" \
    "Read,Write" \
    "Write Section: ${SEC_TITLE}. Read /Users/yyzz/Desktop/MyClaudeCode/research/workspace/phase2/b3-paper-outline.json for the paper outline and structure.${SOURCE_HINT} Also read any previously written sections in /Users/yyzz/Desktop/MyClaudeCode/research/workspace/phase3/sections/ for continuity. Output to /Users/yyzz/Desktop/MyClaudeCode/research/workspace/phase3/sections/${SEC_FILE}.md"

  echo "  ✅ ${SEC_TITLE} complete"
  echo ""
done

# --- C2: Visualization Designer ---
echo "🎨 Launching C2: Visualization Designer..."
"${SCRIPT_DIR}/run-agent.sh" \
  "${RESEARCH_DIR}/agents/phase3/c2-visualization-designer.md" \
  "${MODEL_WRITING}" \
  "${BUDGET_C2}" \
  "Read,Write" \
  "Design all figures and tables for the paper. Read /Users/yyzz/Desktop/MyClaudeCode/research/workspace/phase2/b3-paper-outline.json for specifications, /Users/yyzz/Desktop/MyClaudeCode/research/workspace/phase1/a2-engineering-analysis.json for system data, and /Users/yyzz/Desktop/MyClaudeCode/research/workspace/phase2/b2-experiment-design.json for experiment structure. Output figures to /Users/yyzz/Desktop/MyClaudeCode/research/workspace/phase3/figures/all-figures.md and tables to /Users/yyzz/Desktop/MyClaudeCode/research/workspace/phase3/figures/all-tables.md"

echo ""

# --- C3: Academic Formatter ---
echo "📋 Launching C3: Academic Formatter..."
"${SCRIPT_DIR}/run-agent.sh" \
  "${RESEARCH_DIR}/agents/phase3/c3-academic-formatter.md" \
  "${MODEL_WRITING}" \
  "${BUDGET_C3}" \
  "Read,Write,Glob" \
  "Assemble the complete paper. Read all section drafts from /Users/yyzz/Desktop/MyClaudeCode/research/workspace/phase3/sections/, all figures and tables from /Users/yyzz/Desktop/MyClaudeCode/research/workspace/phase3/figures/, literature data from /Users/yyzz/Desktop/MyClaudeCode/research/workspace/phase1/a1-literature-survey.json, and the outline from /Users/yyzz/Desktop/MyClaudeCode/research/workspace/phase2/b3-paper-outline.json. Assemble into a single coherent paper with title, abstract, all sections, figures, tables, and references. Output to /Users/yyzz/Desktop/MyClaudeCode/research/output/paper.md"

echo ""
echo "╔═══════════════════════════════════════════════════╗"
echo "║  ✅ Phase 3 Complete                              ║"
echo "╚═══════════════════════════════════════════════════╝"
