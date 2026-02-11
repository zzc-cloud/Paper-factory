#!/usr/bin/env bash
# ============================================================
# run-phase1.sh — Phase 1: 素材收集
# A1/A2/A3 并行执行 → 等待完成 → A4 串行执行
# ============================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../config.env"

echo "╔═══════════════════════════════════════════════════╗"
echo "║  Phase 1: Research (素材收集)                     ║"
echo "╚═══════════════════════════════════════════════════╝"
echo ""

# --- A1: Literature Surveyor (并行) ---
echo "🚀 Launching A1: Literature Surveyor (background)..."
"${SCRIPT_DIR}/run-agent.sh" \
  "${RESEARCH_DIR}/agents/phase1/a1-literature-surveyor.md" \
  "${MODEL_WRITING}" \
  "${BUDGET_A1}" \
  "WebSearch,WebFetch,Read,Write" \
  "Execute the literature survey. Read /Users/yyzz/Desktop/MyClaudeCode/research/workspace/phase1/input-context.md for the research topic and innovation list. Search for 30+ relevant papers across NL2SQL, OBDA, Multi-Agent Systems, KG+LLM, and Cognitive Architecture. Output structured results to /Users/yyzz/Desktop/MyClaudeCode/research/workspace/phase1/a1-literature-survey.json and a human-readable summary to /Users/yyzz/Desktop/MyClaudeCode/research/workspace/phase1/a1-literature-survey.md" \
  &
PID_A1=$!

# --- A2: Engineering Analyst (并行) ---
echo "🚀 Launching A2: Engineering Analyst (background)..."
"${SCRIPT_DIR}/run-agent.sh" \
  "${RESEARCH_DIR}/agents/phase1/a2-engineering-analyst.md" \
  "${MODEL_REASONING}" \
  "${BUDGET_A2}" \
  "Read,Glob,Grep,Write,Bash" \
  "Analyze the Smart Query codebase at /Users/yyzz/Desktop/MyClaudeCode/smart-query/. Read all SKILL.md files, knowledge docs, CLAUDE.md, and ontology layer code. Extract architecture patterns, quantitative metrics, and map all 13 innovations to code locations. Output to /Users/yyzz/Desktop/MyClaudeCode/research/workspace/phase1/a2-engineering-analysis.json and .md" \
  &
PID_A2=$!

# --- A3: MAS Theorist (并行) ---
echo "🚀 Launching A3: MAS Theorist (background)..."
"${SCRIPT_DIR}/run-agent.sh" \
  "${RESEARCH_DIR}/agents/phase1/a3-mas-theorist.md" \
  "${MODEL_REASONING}" \
  "${BUDGET_A3}" \
  "WebSearch,WebFetch,Read,Write" \
  "Research multi-agent system theories and frameworks. Read /Users/yyzz/Desktop/MyClaudeCode/research/workspace/phase1/input-context.md for context. Map Smart Query to established MAS paradigms (BDI, Blackboard, etc.). Analyze LLM-based MAS systems (AutoGen, MetaGPT, CrewAI). Formalize the semantic cumulative effect using information theory. Output to /Users/yyzz/Desktop/MyClaudeCode/research/workspace/phase1/a3-mas-theory.json and .md" \
  &
PID_A3=$!

echo ""
echo "⏳ Waiting for A1, A2, A3 to complete..."
echo "   A1 PID: ${PID_A1}"
echo "   A2 PID: ${PID_A2}"
echo "   A3 PID: ${PID_A3}"
echo ""

wait $PID_A1 && echo "✅ A1 complete" || echo "❌ A1 failed"
wait $PID_A2 && echo "✅ A2 complete" || echo "❌ A2 failed"
wait $PID_A3 && echo "✅ A3 complete" || echo "❌ A3 failed"

echo ""
echo "━━━ A1/A2/A3 complete. Starting A4 (depends on A2) ━━━"
echo ""

# --- A4: Innovation Formalizer (串行，依赖 A2) ---
if [ ! -f "${RESEARCH_DIR}/workspace/phase1/a2-engineering-analysis.json" ]; then
  echo "❌ ERROR: A2 output not found. Cannot run A4."
  exit 1
fi

echo "🚀 Launching A4: Innovation Formalizer..."
"${SCRIPT_DIR}/run-agent.sh" \
  "${RESEARCH_DIR}/agents/phase1/a4-innovation-formalizer.md" \
  "${MODEL_REASONING}" \
  "${BUDGET_A4}" \
  "Read,Write" \
  "Formalize the 13 engineering innovations into academic contributions. Read /Users/yyzz/Desktop/MyClaudeCode/research/workspace/phase1/a2-engineering-analysis.json for the engineering analysis and /Users/yyzz/Desktop/MyClaudeCode/research/workspace/phase1/input-context.md for the innovation list. Cluster into 3-4 contribution themes, rank by significance, draft formal contribution statements. Output to /Users/yyzz/Desktop/MyClaudeCode/research/workspace/phase1/a4-innovations.json and .md"

echo ""
echo "╔═══════════════════════════════════════════════════╗"
echo "║  ✅ Phase 1 Complete                              ║"
echo "╚═══════════════════════════════════════════════════╝"
