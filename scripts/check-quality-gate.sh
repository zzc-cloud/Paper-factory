#!/usr/bin/env bash
# ============================================================
# check-quality-gate.sh — 质量门控检查
# 用法: ./scripts/check-quality-gate.sh <gate_number>
# ============================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../config.env"

GATE="$1"

check_file_exists() {
  if [ -f "$1" ]; then
    echo "  ✅ $2"
    return 0
  else
    echo "  ❌ $2 — 文件不存在: $1"
    return 1
  fi
}

PASS=true

case "$GATE" in
  1)
    echo "━━━ Quality Gate 1: Research Complete ━━━"
    check_file_exists "${RESEARCH_DIR}/workspace/phase1/a1-literature-survey.json" "A1: Literature Survey" || PASS=false
    check_file_exists "${RESEARCH_DIR}/workspace/phase1/a1-literature-survey.md" "A1: Literature Survey (MD)" || PASS=false
    check_file_exists "${RESEARCH_DIR}/workspace/phase1/a2-engineering-analysis.json" "A2: Engineering Analysis" || PASS=false
    check_file_exists "${RESEARCH_DIR}/workspace/phase1/a2-engineering-analysis.md" "A2: Engineering Analysis (MD)" || PASS=false
    check_file_exists "${RESEARCH_DIR}/workspace/phase1/a3-mas-theory.json" "A3: MAS Theory" || PASS=false
    check_file_exists "${RESEARCH_DIR}/workspace/phase1/a3-mas-theory.md" "A3: MAS Theory (MD)" || PASS=false
    check_file_exists "${RESEARCH_DIR}/workspace/phase1/a4-innovations.json" "A4: Innovations" || PASS=false
    check_file_exists "${RESEARCH_DIR}/workspace/phase1/a4-innovations.md" "A4: Innovations (MD)" || PASS=false
    ;;
  2)
    echo "━━━ Quality Gate 2: Design Complete ━━━"
    check_file_exists "${RESEARCH_DIR}/workspace/phase2/b1-related-work.json" "B1: Related Work" || PASS=false
    check_file_exists "${RESEARCH_DIR}/workspace/phase2/b2-experiment-design.json" "B2: Experiment Design" || PASS=false
    check_file_exists "${RESEARCH_DIR}/workspace/phase2/b3-paper-outline.json" "B3: Paper Outline" || PASS=false
    ;;
  3)
    echo "━━━ Quality Gate 3: Writing Complete ━━━"
    for SEC in 01-introduction 02-related-work 03-system-architecture 04-theoretical-analysis 05-experiments 06-discussion 07-conclusion; do
      check_file_exists "${RESEARCH_DIR}/workspace/phase3/sections/${SEC}.md" "Section: ${SEC}" || PASS=false
    done
    check_file_exists "${RESEARCH_DIR}/workspace/phase3/figures/all-figures.md" "Figures" || PASS=false
    check_file_exists "${RESEARCH_DIR}/workspace/phase3/figures/all-tables.md" "Tables" || PASS=false
    check_file_exists "${RESEARCH_DIR}/output/paper.md" "Assembled Paper" || PASS=false
    ;;
  4)
    echo "━━━ Quality Gate 4: Review Complete ━━━"
    check_file_exists "${RESEARCH_DIR}/workspace/phase4/d1-review-report.json" "D1: Review Report" || PASS=false
    check_file_exists "${RESEARCH_DIR}/output/paper.md" "Final Paper" || PASS=false
    ;;
  *)
    echo "❌ Unknown gate: $GATE (valid: 1, 2, 3, 4)"
    exit 1
    ;;
esac

echo ""
if [ "$PASS" = true ]; then
  echo "✅ Quality Gate ${GATE} PASSED"
  # 记录通过
  echo "{\"gate\": ${GATE}, \"status\": \"passed\", \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}" \
    > "${RESEARCH_DIR}/workspace/quality-gates/gate-${GATE}-complete.json"
  exit 0
else
  echo "❌ Quality Gate ${GATE} FAILED"
  exit 1
fi
