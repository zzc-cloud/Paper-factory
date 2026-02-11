#!/usr/bin/env bash
# ============================================================
# run-phase2.sh — Phase 2: 论文设计
# B1 → B2 → B3 串行执行
# ============================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../config.env"

echo "╔═══════════════════════════════════════════════════╗"
echo "║  Phase 2: Design (论文设计)                       ║"
echo "╚═══════════════════════════════════════════════════╝"
echo ""

# --- B1: Related Work Analyst ---
echo "🚀 Launching B1: Related Work Analyst..."
"${SCRIPT_DIR}/run-agent.sh" \
  "${RESEARCH_DIR}/agents/phase2/b1-related-work-analyst.md" \
  "${MODEL_REASONING}" \
  "${BUDGET_B1}" \
  "Read,Write,WebSearch" \
  "Perform systematic comparison and positioning. Read /Users/yyzz/Desktop/MyClaudeCode/research/workspace/phase1/a1-literature-survey.json for the literature survey and /Users/yyzz/Desktop/MyClaudeCode/research/workspace/phase1/a4-innovations.json for formalized innovations. Create comparison matrix, gap analysis, and Related Work section outline. Output to /Users/yyzz/Desktop/MyClaudeCode/research/workspace/phase2/b1-related-work.json and .md"

echo ""

# --- B2: Experiment Designer ---
echo "🚀 Launching B2: Experiment Designer..."
"${SCRIPT_DIR}/run-agent.sh" \
  "${RESEARCH_DIR}/agents/phase2/b2-experiment-designer.md" \
  "${MODEL_REASONING}" \
  "${BUDGET_B2}" \
  "Read,Write" \
  "Design the evaluation methodology. Read /Users/yyzz/Desktop/MyClaudeCode/research/workspace/phase1/a2-engineering-analysis.json, /Users/yyzz/Desktop/MyClaudeCode/research/workspace/phase1/a4-innovations.json, and /Users/yyzz/Desktop/MyClaudeCode/research/workspace/phase1/a3-mas-theory.json. Design metrics, baselines (B0-B4), ablation studies, dataset specification, and semantic cumulative effect measurement. Output to /Users/yyzz/Desktop/MyClaudeCode/research/workspace/phase2/b2-experiment-design.json and .md"

echo ""

# --- B3: Paper Architect ---
echo "🚀 Launching B3: Paper Architect..."
"${SCRIPT_DIR}/run-agent.sh" \
  "${RESEARCH_DIR}/agents/phase2/b3-paper-architect.md" \
  "${MODEL_REASONING}" \
  "${BUDGET_B3}" \
  "Read,Write" \
  "Design the paper narrative and structure. Read ALL Phase 1 outputs (a1 through a4 JSON files) and Phase 2 outputs (b1, b2 JSON files) from /Users/yyzz/Desktop/MyClaudeCode/research/workspace/. Design narrative arc, detailed section outline with subsections, figure/table specifications, word count budget (target 8000-10000 words), and venue recommendation. Output to /Users/yyzz/Desktop/MyClaudeCode/research/workspace/phase2/b3-paper-outline.json and .md"

echo ""
echo "╔═══════════════════════════════════════════════════╗"
echo "║  ✅ Phase 2 Complete                              ║"
echo "╚═══════════════════════════════════════════════════╝"
