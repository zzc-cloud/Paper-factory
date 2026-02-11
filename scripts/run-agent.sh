#!/usr/bin/env bash
# ============================================================
# run-agent.sh — 通用智能体执行器
# 用法: ./scripts/run-agent.sh <prompt_file> <model> <budget> <tools> <task_prompt>
# ============================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../config.env"

PROMPT_FILE="$1"
MODEL="$2"
BUDGET="$3"
TOOLS="$4"
TASK_PROMPT="$5"

AGENT_NAME=$(basename "$PROMPT_FILE" .md)
LOG_FILE="${LOG_DIR}/${AGENT_NAME}.log"

mkdir -p "$LOG_DIR"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🤖 Agent: ${AGENT_NAME}"
echo "📦 Model: ${MODEL}"
echo "💰 Budget: \$${BUDGET}"
echo "🔧 Tools: ${TOOLS}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

START_TIME=$(date +%s)

echo "$TASK_PROMPT" | claude -p \
  --model "$MODEL" \
  --system-prompt "$(cat "$PROMPT_FILE")" \
  --allowedTools "$TOOLS" \
  --max-budget-usd "$BUDGET" \
  --dangerously-skip-permissions \
  2>&1 | tee "$LOG_FILE"

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo ""
echo "✅ Agent ${AGENT_NAME} completed in ${DURATION}s"
echo "📄 Log: ${LOG_FILE}"
