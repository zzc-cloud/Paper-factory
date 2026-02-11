#!/usr/bin/env bash
# ============================================================
# run-phase4.sh — Phase 4: 质量保障
# D1 评审 → 评分检查 → D2 修订 → 迭代循环
# ============================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../config.env"

echo "╔═══════════════════════════════════════════════════╗"
echo "║  Phase 4: Quality Assurance (质量保障)            ║"
echo "╚═══════════════════════════════════════════════════╝"
echo ""

ITERATION=0

while [ $ITERATION -lt $MAX_REVIEW_ITERATIONS ]; do
  ITERATION=$((ITERATION + 1))
  echo "━━━ Review Iteration ${ITERATION}/${MAX_REVIEW_ITERATIONS} ━━━"
  echo ""

  # --- D1: Peer Reviewer ---
  echo "🔍 Launching D1: Peer Reviewer (Iteration ${ITERATION})..."
  "${SCRIPT_DIR}/run-agent.sh" \
    "${RESEARCH_DIR}/agents/phase4/d1-peer-reviewer.md" \
    "${MODEL_REASONING}" \
    "${BUDGET_D1}" \
    "Read,Write" \
    "Review the complete paper at /Users/yyzz/Desktop/MyClaudeCode/research/output/paper.md. Simulate 3 peer reviewers (Technical Expert, Novelty Expert, Clarity Expert). For each: provide score (1-10), strengths, weaknesses, detailed comments, questions, and recommendation. Synthesize consolidated review with prioritized action items. This is review iteration ${ITERATION}. Output to /Users/yyzz/Desktop/MyClaudeCode/research/workspace/phase4/d1-review-report.json and .md"

  echo ""

  # --- 检查评审分数 ---
  if [ -f "${RESEARCH_DIR}/workspace/phase4/d1-review-report.json" ]; then
    AVG_SCORE=$(python3 -c "
import json
with open('${RESEARCH_DIR}/workspace/phase4/d1-review-report.json') as f:
    data = json.load(f)
    if 'data' in data and 'consolidated' in data['data']:
        print(data['data']['consolidated'].get('average_score', 0))
    elif 'consolidated' in data:
        print(data['consolidated'].get('average_score', 0))
    else:
        scores = [r.get('score', 0) for r in data.get('data', {}).get('reviewers', data.get('reviewers', []))]
        print(sum(scores) / len(scores) if scores else 0)
" 2>/dev/null || echo "0")

    echo "📊 Average Review Score: ${AVG_SCORE}"

    # 检查是否通过
    PASS=$(python3 -c "print('yes' if float('${AVG_SCORE}') >= ${MIN_REVIEW_SCORE} else 'no')" 2>/dev/null || echo "no")

    if [ "$PASS" = "yes" ]; then
      echo ""
      echo "🎉 Review PASSED (score ${AVG_SCORE} >= ${MIN_REVIEW_SCORE})"
      echo ""
      break
    fi

    echo "⚠️  Review score ${AVG_SCORE} < ${MIN_REVIEW_SCORE}. Revision needed."
  else
    echo "⚠️  Review report not found. Proceeding to revision."
  fi

  # --- 检查是否还有迭代次数 ---
  if [ $ITERATION -ge $MAX_REVIEW_ITERATIONS ]; then
    echo ""
    echo "⚠️  Maximum iterations (${MAX_REVIEW_ITERATIONS}) reached. Outputting current version."
    break
  fi

  echo ""

  # --- D2: Revision Specialist ---
  echo "✏️  Launching D2: Revision Specialist (Iteration ${ITERATION})..."
  "${SCRIPT_DIR}/run-agent.sh" \
    "${RESEARCH_DIR}/agents/phase4/d2-revision-specialist.md" \
    "${MODEL_REASONING}" \
    "${BUDGET_D2}" \
    "Read,Write" \
    "Revise the paper based on peer review. Read /Users/yyzz/Desktop/MyClaudeCode/research/workspace/phase4/d1-review-report.json for review comments and /Users/yyzz/Desktop/MyClaudeCode/research/output/paper.md for the current paper. Address all critical and important issues. Output revised paper to /Users/yyzz/Desktop/MyClaudeCode/research/output/paper.md and revision log to /Users/yyzz/Desktop/MyClaudeCode/research/workspace/phase4/d2-revision-log.json and .md"

  echo ""
done

echo "╔═══════════════════════════════════════════════════╗"
echo "║  ✅ Phase 4 Complete                              ║"
echo "╚═══════════════════════════════════════════════════╝"
