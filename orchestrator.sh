#!/usr/bin/env bash
# ============================================================
# orchestrator.sh — 多智能体论文生成系统 主编排脚本
#
# 用法: bash orchestrator.sh [--phase N] [--from-phase N]
#   --phase N      只运行指定阶段 (1-4)
#   --from-phase N 从指定阶段开始运行到结束
#   无参数          运行完整流程 (Phase 1-4)
# ============================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"
source "./config.env"

# --- 参数解析 ---
SINGLE_PHASE=""
FROM_PHASE=1

while [[ $# -gt 0 ]]; do
  case $1 in
    --phase) SINGLE_PHASE="$2"; shift 2 ;;
    --from-phase) FROM_PHASE="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# --- 创建日志目录 ---
mkdir -p "$LOG_DIR"

# --- 开始 ---
TOTAL_START=$(date +%s)

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║                                                           ║"
echo "║   🐝 Multi-Agent Paper Generation System                  ║"
echo "║   蜂巢多智能体论文生成系统                                ║"
echo "║                                                           ║"
echo "║   Target: Cognitive Hub — Multi-Agent Architecture        ║"
echo "║           for Ontology-Driven NL Data Querying            ║"
echo "║                                                           ║"
echo "║   Agents: 12 workers + 1 orchestrator                    ║"
echo "║   Phases: Research → Design → Writing → Quality          ║"
echo "║                                                           ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""
echo "📅 Started: $(date)"
echo "📂 Research Dir: ${RESEARCH_DIR}"
echo "📂 Smart Query Dir: ${SMART_QUERY_DIR}"
echo ""

# ============================================================
# Phase 0: Setup
# ============================================================
run_setup() {
  echo "━━━ Phase 0: Setup ━━━"

  # 确保目录结构存在
  mkdir -p "${RESEARCH_DIR}/workspace/"{phase1,phase2,phase3/{sections,figures},phase4,quality-gates}
  mkdir -p "${RESEARCH_DIR}/output"
  mkdir -p "$LOG_DIR"

  # 验证 Smart Query 目录可访问
  if [ ! -f "${SMART_QUERY_DIR}/CLAUDE.md" ]; then
    echo "❌ ERROR: Smart Query project not found at ${SMART_QUERY_DIR}"
    exit 1
  fi

  # 验证 input-context.md 存在
  if [ ! -f "${RESEARCH_DIR}/workspace/phase1/input-context.md" ]; then
    echo "❌ ERROR: input-context.md not found. Please create it first."
    exit 1
  fi

  echo "✅ Setup complete"
  echo ""
}

# ============================================================
# 阶段执行函数
# ============================================================
run_phase1() {
  bash "${SCRIPT_DIR}/scripts/run-phase1.sh"
  bash "${SCRIPT_DIR}/scripts/check-quality-gate.sh" 1
}

run_phase2() {
  bash "${SCRIPT_DIR}/scripts/run-phase2.sh"
  bash "${SCRIPT_DIR}/scripts/check-quality-gate.sh" 2
}

run_phase3() {
  bash "${SCRIPT_DIR}/scripts/run-phase3.sh"
  bash "${SCRIPT_DIR}/scripts/check-quality-gate.sh" 3
}

run_phase4() {
  bash "${SCRIPT_DIR}/scripts/run-phase4.sh"
  bash "${SCRIPT_DIR}/scripts/check-quality-gate.sh" 4
}

# ============================================================
# 主流程
# ============================================================
run_setup

if [ -n "$SINGLE_PHASE" ]; then
  echo "🎯 Running single phase: ${SINGLE_PHASE}"
  echo ""
  case "$SINGLE_PHASE" in
    1) run_phase1 ;;
    2) run_phase2 ;;
    3) run_phase3 ;;
    4) run_phase4 ;;
    *) echo "❌ Invalid phase: $SINGLE_PHASE"; exit 1 ;;
  esac
else
  for PHASE in $(seq $FROM_PHASE 4); do
    echo ""
    echo "═══════════════════════════════════════════════════"
    echo "  Starting Phase ${PHASE}/4"
    echo "═══════════════════════════════════════════════════"
    echo ""
    case "$PHASE" in
      1) run_phase1 ;;
      2) run_phase2 ;;
      3) run_phase3 ;;
      4) run_phase4 ;;
    esac
  done
fi

# ============================================================
# 完成
# ============================================================
TOTAL_END=$(date +%s)
TOTAL_DURATION=$((TOTAL_END - TOTAL_START))
MINUTES=$((TOTAL_DURATION / 60))
SECONDS=$((TOTAL_DURATION % 60))

echo ""
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  🎉 Paper Generation Complete!                            ║"
echo "║                                                           ║"
echo "║  📄 Output: ${RESEARCH_DIR}/output/paper.md"
echo "║  ⏱️  Duration: ${MINUTES}m ${SECONDS}s"
echo "║  📅 Finished: $(date)"
echo "║                                                           ║"
echo "╚═══════════════════════════════════════════════════════════╝"
