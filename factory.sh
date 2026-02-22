#!/bin/bash
# Mini TDD Factory - Ralph Wiggum Loop v2
# 用法: ./factory.sh
# 支援 Gemini CLI 和 Claude Code 作為 Worker/Supervisor

set -euo pipefail

# ─── 設定 ───────────────────────────────────────────────
CONFIG_FILE="factory_config.md"
TASKS_FILE="RFP/tasks.md"
REQUIREMENTS_FILE="RFP/requirements.md"
DESIGN_FILE="RFP/design.md"
HISTORY_FILE=".factory/history.md"
TEST_RESULT_FILE=".factory/test_result.txt"
ROUND_REPORT_DIR=".factory/rounds"

# 安全閥
MAX_ROUNDS=20
MAX_CONSECUTIVE_FAIL=5
MAX_NO_CHANGE=3

# ANSI 顏色
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# ─── 初始設定精靈 ──────────────────────────────────────
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${YELLOW}👋 歡迎來到 Mini TDD Factory！${NC}"

    # 選擇語言
    echo "請選擇您要使用的開發語言："
    echo "1) Python [預設]"
    echo "2) JavaScript (Node.js)"
    echo "3) Golang"
    echo "4) 其他 (自定義)"
    read -p "請輸入選項 (1-4): " lang_choice

    case "$lang_choice" in
        2) LANG_VAL="javascript" ;;
        3) LANG_VAL="go" ;;
        4)
            read -p "請輸入語言名稱 (例如 rust, ruby, c++): " custom_lang
            LANG_VAL="$custom_lang"
            read -p "請輸入測試指令 (例如 'cargo test', 'cucumber'): " custom_cmd
            ;;
        *) LANG_VAL="python" ;;
    esac

    # 選擇 AI 引擎
    echo ""
    echo "請選擇 Worker AI 引擎："
    echo "1) Gemini CLI [預設]"
    echo "2) Claude Code"
    read -p "請輸入選項 (1-2): " engine_choice

    case "$engine_choice" in
        2) ENGINE_VAL="claude" ;;
        *) ENGINE_VAL="gemini" ;;
    esac

    # 選擇監工
    echo ""
    echo "請選擇監工 (Supervisor)："
    echo "1) Claude Code 當監工 [預設] — AI 幫你盯進度，有問題自動處理"
    echo "2) Gemini CLI 當監工"
    echo "3) 無監工 (進階使用者)"
    read -p "請輸入選項 (1-3): " super_choice

    case "$super_choice" in
        2) SUPER_VAL="gemini" ;;
        3) SUPER_VAL="none" ;;
        *) SUPER_VAL="claude" ;;
    esac

    cat <<EOF > "$CONFIG_FILE"
# Mini TDD Factory 設定檔
SCOPE=All
LANGUAGE=$LANG_VAL
AI_ENGINE=$ENGINE_VAL
WORKER_MODEL=
SUPERVISOR_MODEL=
SUPERVISOR=$SUPER_VAL
MODE=Dual
LEGO_MODE=true
EOF

    # 自定義語言的測試指令
    if [ "${custom_cmd:-}" != "" ]; then
        echo "TEST_CMD=$custom_cmd" >> "$CONFIG_FILE"
    fi

    echo -e "${GREEN}✅ 設定已儲存：$LANG_VAL + $ENGINE_VAL (監工: $SUPER_VAL)${NC}"
fi

# ─── 讀取設定 ──────────────────────────────────────────
read_config() {
    local key="$1"
    local default="$2"
    grep "^${key}=" "$CONFIG_FILE" 2>/dev/null | head -1 | cut -d'=' -f2- || echo "$default"
}

SCOPE=$(read_config "SCOPE" "All")
LANGUAGE=$(read_config "LANGUAGE" "python")
AI_ENGINE=$(read_config "AI_ENGINE" "gemini")
WORKER_MODEL=$(read_config "WORKER_MODEL" "")
SUPERVISOR_MODEL=$(read_config "SUPERVISOR_MODEL" "")
SUPERVISOR=$(read_config "SUPERVISOR" "none")
MODE=$(read_config "MODE" "Dual")
LEGO_MODE=$(read_config "LEGO_MODE" "false")
CONFIG_TEST_CMD=$(read_config "TEST_CMD" "")

# ─── 套用樂高模式 ─────────────────────────────────────
if [ "$LEGO_MODE" == "true" ] && [ -f ".cursorrules.lego" ]; then
    cp .cursorrules.lego .cursorrules 2>/dev/null || true
    echo -e "${GREEN}🧱 [LEGO] 樂高模式已啟用${NC}"
elif [ -f ".cursorrules.standard" ]; then
    cp .cursorrules.standard .cursorrules 2>/dev/null || true
fi

# ─── 環境檢查 ──────────────────────────────────────────
setup_environment() {
    # 自定義測試指令優先
    if [ -n "$CONFIG_TEST_CMD" ]; then
        TEST_CMD="$CONFIG_TEST_CMD"
        echo -e "${YELLOW}🔧 使用自定義測試指令: $TEST_CMD${NC}"
        return
    fi

    case "$LANGUAGE" in
        python)
            if ! command -v python3 &> /dev/null; then
                echo "❌ 錯誤: 找不到 'python3'。" && exit 1
            fi
            if [ -f "requirements.txt" ]; then
                pip3 install -r requirements.txt -q 2>/dev/null || true
            fi
            if ! command -v behave &> /dev/null; then
                echo -e "${YELLOW}📦 正在安裝 behave...${NC}"
                pip3 install behave -q
            fi
            TEST_CMD="behave --no-capture"
            ;;
        javascript)
            if ! command -v npx &> /dev/null; then
                echo "❌ 錯誤: 找不到 'npx' (Node.js)。" && exit 1
            fi
            if [ ! -d "node_modules" ]; then
                echo -e "${YELLOW}📦 正在安裝 npm 依賴...${NC}"
                npm install
            fi
            TEST_CMD="npx cucumber-js"
            ;;
        go)
            if ! command -v go &> /dev/null; then
                echo "❌ 錯誤: 找不到 'go'。" && exit 1
            fi
            if ! command -v godog &> /dev/null; then
                echo -e "${YELLOW}📦 正在安裝 godog...${NC}"
                go install github.com/cucumber/godog/cmd/godog@latest
            fi
            export PATH=$PATH:$(go env GOPATH)/bin
            TEST_CMD="godog run"
            ;;
        *)
            echo -e "${RED}❌ 未知語言 '$LANGUAGE' 且未設定 TEST_CMD。${NC}"
            read -p "請輸入測試指令: " manual_cmd
            [ -z "$manual_cmd" ] && echo "❌ 無法繼續。" && exit 1
            TEST_CMD="$manual_cmd"
            ;;
    esac

    # 檢查 Worker AI 引擎
    case "$AI_ENGINE" in
        gemini)
            if ! command -v gemini &> /dev/null; then
                echo -e "${RED}❌ 找不到 'gemini' 指令。${NC}"
                echo "請參考 https://github.com/google-gemini/gemini-cli 安裝 Gemini CLI。"
                exit 1
            fi
            ;;
        claude)
            if ! command -v claude &> /dev/null; then
                echo -e "${RED}❌ 找不到 'claude' 指令。${NC}"
                echo "請參考 https://docs.anthropic.com/en/docs/claude-code 安裝 Claude Code。"
                exit 1
            fi
            ;;
        *)
            echo -e "${RED}❌ 未知 AI 引擎: '$AI_ENGINE'${NC}"
            exit 1
            ;;
    esac

    # 檢查 Supervisor 引擎 (如果啟用)
    if [ "$SUPERVISOR" != "none" ]; then
        case "$SUPERVISOR" in
            claude)
                if ! command -v claude &> /dev/null; then
                    echo -e "${RED}❌ 監工設定為 claude 但找不到 'claude' 指令。${NC}"
                    exit 1
                fi
                ;;
            gemini)
                if ! command -v gemini &> /dev/null; then
                    echo -e "${RED}❌ 監工設定為 gemini 但找不到 'gemini' 指令。${NC}"
                    exit 1
                fi
                ;;
        esac
    fi
}

# ─── AI 呼叫抽象層 ────────────────────────────────────
# 統一 Worker 和 Supervisor 的 AI 呼叫介面

call_worker() {
    local prompt="$1"

    case "$AI_ENGINE" in
        gemini)
            local model_flag=""
            [ -n "$WORKER_MODEL" ] && model_flag="--model $WORKER_MODEL"
            gemini --yolo $model_flag "$prompt"
            ;;
        claude)
            local model_flag=""
            [ -n "$WORKER_MODEL" ] && model_flag="--model $WORKER_MODEL"
            claude -p "$prompt" \
                --dangerously-skip-permissions \
                $model_flag \
                --allowedTools "Read,Edit,Write,Bash" \
                2>/dev/null || true
            ;;
    esac
}

call_supervisor() {
    local prompt="$1"

    case "$SUPERVISOR" in
        claude)
            local model_flag=""
            [ -n "$SUPERVISOR_MODEL" ] && model_flag="--model $SUPERVISOR_MODEL"
            claude -p "$prompt" \
                --output-format json \
                $model_flag \
                --allowedTools "Read,Bash(cat *),Bash(git diff *),Bash(git log *)" \
                2>/dev/null || echo '{"result":"CONTINUE"}'
            ;;
        gemini)
            local model_flag=""
            [ -n "$SUPERVISOR_MODEL" ] && model_flag="--model $SUPERVISOR_MODEL"
            gemini $model_flag --output-format json -p "$prompt" 2>/dev/null || echo '{"response":"CONTINUE"}'
            ;;
        *)
            echo '{"result":"CONTINUE"}'
            ;;
    esac
}

# ─── 工具函數 ──────────────────────────────────────────

# 初始化 git (如果還沒有)
init_git() {
    if [ ! -d ".git" ]; then
        git init -q
        git add -A
        git commit -m "factory: initial state" -q
    fi
}

# Git 快照 — 在 AI 改動前記錄狀態
snapshot_before() {
    git add -A 2>/dev/null
    git diff --cached --quiet || git commit -m "factory: round-${ROUND}-before" -q 2>/dev/null
}

# Git diff — 取得 AI 這輪改了什麼
get_round_diff() {
    git add -A 2>/dev/null
    DIFF_STAT=$(git diff --cached --stat 2>/dev/null || echo "")
    DIFF_DETAIL=$(git diff --cached 2>/dev/null | head -200 || echo "")

    if [ -n "$DIFF_STAT" ]; then
        git commit -m "factory: round-${ROUND} changes" -q 2>/dev/null
        return 0  # 有改動
    else
        return 1  # 沒改動
    fi
}

# 執行測試並解析結果
run_tests() {
    $TEST_CMD > test_report.raw 2>&1 || true
    TEST_EXIT_CODE=${PIPESTATUS[0]:-$?}

    local SUMMARY
    SUMMARY=$(tail -n 15 test_report.raw)

    # 解析 pass/fail 數量 (寬鬆匹配，適用 behave/cucumber/pytest)
    PASSED_COUNT=$(echo "$SUMMARY" | grep -oE "[0-9]+ passed" | head -1 | awk '{print $1}')
    FAILED_COUNT=$(echo "$SUMMARY" | grep -oE "[0-9]+ (failed|error)" | head -1 | awk '{print $1}')
    [ -z "$PASSED_COUNT" ] && PASSED_COUNT=0
    [ -z "$FAILED_COUNT" ] && FAILED_COUNT=0

    # 抽取失敗訊息 (只取最相關的部分，不超過 40 行)
    FAILURE_DETAILS=$(grep -A 5 -E "(FAILED|ERROR|AssertionError|assert|Traceback|failing)" test_report.raw | head -40)

    # 寫入結果檔
    cat > "$TEST_RESULT_FILE" <<RESULT
exit_code=$TEST_EXIT_CODE
passed=$PASSED_COUNT
failed=$FAILED_COUNT
---
$FAILURE_DETAILS
RESULT
}

# 寫入每輪回報 (供 Supervisor 和人類查看)
write_round_report() {
    local status_emoji="🔴"
    [ "$TEST_EXIT_CODE" -eq 0 ] && status_emoji="🟢"

    local report_file="$ROUND_REPORT_DIR/round_${ROUND}.md"

    cat > "$report_file" <<REPORT
# 第 ${ROUND} 輪回報 ${status_emoji}

## 測試結果
- 狀態: $([ "$TEST_EXIT_CODE" -eq 0 ] && echo "通過" || echo "失敗")
- 通過: ${PASSED_COUNT} | 失敗: ${FAILED_COUNT}
- Exit Code: ${TEST_EXIT_CODE}

## AI 改動
${DIFF_STAT:-無改動}

## 待辦任務
$(grep -c "\[ \]" "$TASKS_FILE" 2>/dev/null || echo "0") 個待辦

## 連續失敗
${CONSECUTIVE_FAIL} 輪

## 失敗細節
$([ "$TEST_EXIT_CODE" -ne 0 ] && cat "$TEST_RESULT_FILE" || echo "無")
REPORT

    # 更新最新回報的捷徑
    cp "$report_file" ".factory/latest_report.md"
}

# 記錄歷史
record_history() {
    local status_emoji="🔴"
    [ "$TEST_EXIT_CODE" -eq 0 ] && status_emoji="🟢"

    cat >> "$HISTORY_FILE" <<HIST
### Round $ROUND [$status_emoji]
- 測試: $PASSED_COUNT passed / $FAILED_COUNT failed (exit: $TEST_EXIT_CODE)
- 改動: $DIFF_STAT
---
HIST
}

# ─── Supervisor 審查 ──────────────────────────────────

run_supervisor() {
    if [ "$SUPERVISOR" == "none" ]; then
        return 0
    fi

    echo -e "${BLUE}🕵️ 監工正在審查第 $ROUND 輪回報...${NC}"

    local SUPER_PROMPT="你是 TDD 工廠的監工 (Supervisor)。你有全局視野，負責監控 Worker AI 的工作品質。

[第 ${ROUND} 輪回報]
$(cat .factory/latest_report.md)

[工廠歷史]
$(tail -n 40 "$HISTORY_FILE" 2>/dev/null || echo "第一輪")

[需求規格]
$(cat "$REQUIREMENTS_FILE")

[任務列表]
$(cat "$TASKS_FILE")

請判斷 Worker 的狀態並回覆你的決定 (純文字即可)：

1. CONTINUE — Worker 方向正確，讓它繼續。
2. REDIRECT — Worker 卡住或方向錯誤，給出新的指示讓它下一輪執行。
3. INTERVENE — 問題太大，你直接介入修正程式碼。
4. ESCALATE — 你也解決不了，回報人類。

回覆格式：
ACTION: CONTINUE/REDIRECT/INTERVENE/ESCALATE
REASON: (一句話說明原因)
INSTRUCTIONS: (如果是 REDIRECT，給 Worker 的新指示)
"

    local DECISION
    DECISION=$(call_supervisor "$SUPER_PROMPT")

    # 解析 Supervisor 決定 (寬鬆匹配，支援不同 AI 的輸出格式)
    local ACTION
    ACTION=$(echo "$DECISION" | grep -oE "(CONTINUE|REDIRECT|INTERVENE|ESCALATE)" | head -1)
    [ -z "$ACTION" ] && ACTION="CONTINUE"

    echo -e "${BLUE}🕵️ 監工決定: ${ACTION}${NC}"

    # 記錄 Supervisor 決定
    echo "Supervisor Round $ROUND: $ACTION" >> ".factory/supervisor_log.txt"
    echo "$DECISION" >> ".factory/supervisor_log.txt"
    echo "---" >> ".factory/supervisor_log.txt"

    case "$ACTION" in
        CONTINUE)
            echo -e "${GREEN}🕵️ 監工: Worker 方向正確，繼續。${NC}"
            ;;
        REDIRECT)
            local INSTRUCTIONS
            INSTRUCTIONS=$(echo "$DECISION" | sed -n '/INSTRUCTIONS:/,$p' | tail -n +1)
            echo -e "${YELLOW}🕵️ 監工: 給 Worker 新指示${NC}"
            SUPERVISOR_INSTRUCTIONS="$INSTRUCTIONS"
            ;;
        INTERVENE)
            echo -e "${RED}🕵️ 監工: 直接介入修正！${NC}"
            local INTERVENE_PROMPT="你是監工 AI，Worker 連續失敗，你需要直接介入修正程式碼。
語言: $LANGUAGE

[需求] $(cat "$REQUIREMENTS_FILE")
[測試結果] $(cat "$TEST_RESULT_FILE")
[工廠歷史] $(tail -n 20 "$HISTORY_FILE")

請直接修正程式碼，讓測試通過。"

            call_supervisor "$INTERVENE_PROMPT"
            ;;
        ESCALATE)
            echo -e "${RED}⚠️ 監工: 問題超出 AI 能力，需要人類介入！${NC}"
            echo -e "${RED}📋 詳情請查看 .factory/latest_report.md${NC}"
            read -p "按 Enter 繼續，或 Ctrl+C 停止..."
            ;;
    esac
}

# ─── Prompt 組裝（核心改進）──────────────────────────────

compose_prompt() {
    local PROMPT=""

    # 固定部分：角色 + 安全規則 (簡短)
    PROMPT+="你是 TDD 軟體工廠的 Worker AI (第 $ROUND 輪)。
語言: $LANGUAGE | 範圍: $SCOPE

[安全限制]
- 禁止刪除不是你建立的檔案（RFP/、factory.sh、reset_project.sh 等不可動）
- 禁止執行破壞性系統指令 (rm -rf /, 格式化等)
- 所有操作限制在工作區內
- 使用繁體中文回覆，程式碼註解也用繁體中文

"

    # 需求 (每輪都需要，但只讀不改)
    PROMPT+="[需求規格]
$(cat "$REQUIREMENTS_FILE")

"

    # 設計文件 (如果有)
    if [ -f "$DESIGN_FILE" ] && [ -s "$DESIGN_FILE" ]; then
        PROMPT+="[系統設計]
$(cat "$DESIGN_FILE")

"
    fi

    # 監工指示 (如果有)
    if [ -n "${SUPERVISOR_INSTRUCTIONS:-}" ]; then
        PROMPT+="[🕵️ 監工指示 — 這是來自監工 AI 的指令，請優先遵守]
$SUPERVISOR_INSTRUCTIONS

"
        SUPERVISOR_INSTRUCTIONS=""  # 用完清空
    fi

    # 動態部分：根據前後輪狀態差異給不同指令
    if [ "$PREV_EXIT_CODE" -eq 0 ] && [ "$TEST_EXIT_CODE" -ne 0 ]; then
        # 上輪 PASS → 這輪 FAIL = 你剛才搞壞了
        PROMPT+="[🔴 情況：你上輪的改動導致測試從 PASS 變 FAIL]
你上輪改了以下檔案：
$DIFF_STAT

具體 diff：
$DIFF_DETAIL

[指令] 你的上一輪修改引入了 bug，請 revert 或修正。只關注 diff 和 error 的交集。
"

    elif [ "$PREV_EXIT_CODE" -ne 0 ] && [ "$TEST_EXIT_CODE" -ne 0 ]; then
        # 連續 FAIL
        if [ "$CONSECUTIVE_FAIL" -ge 3 ]; then
            PROMPT+="[🔴🔴🔴 警告：你已經連續 $CONSECUTIVE_FAIL 輪失敗]
過去幾輪的紀錄：
$(tail -n 30 "$HISTORY_FILE" 2>/dev/null || echo "無紀錄")

[指令] 停下來。不要重複之前的做法。重新讀需求規格，想一個完全不同的實作策略。如果是測試本身有問題，也可以修改測試。
"
        else
            PROMPT+="[🔴 情況：測試仍然失敗 (連續第 $CONSECUTIVE_FAIL 輪)]
"
            if [ -n "$DIFF_STAT" ]; then
                PROMPT+="你上輪的改動：
$DIFF_STAT
"
            fi
        fi

    elif [ "$PREV_EXIT_CODE" -ne 0 ] && [ "$TEST_EXIT_CODE" -eq 0 ]; then
        # FAIL → PASS = 修好了，推進下一個任務
        PROMPT+="[🟢 情況：測試全部通過！推進下一個任務]
"

    else
        # PASS → PASS = 第一輪或持續成功
        PROMPT+="[🟢 情況：所有測試通過，推進下一個任務]
"
    fi

    # 當前任務 (只給第一個未完成的，不是全部)
    local CURRENT_TASK
    CURRENT_TASK=$(grep -m1 "\[ \]" "$TASKS_FILE" || echo "")
    local PENDING_COUNT
    PENDING_COUNT=$(grep -c "\[ \]" "$TASKS_FILE" || echo "0")

    if [ -n "$CURRENT_TASK" ]; then
        PROMPT+="[當前任務] ($PENDING_COUNT 個待辦)
$CURRENT_TASK

[TDD 流程]
1. 檢查 features/ 是否有此任務的 .feature 測試檔
   - 沒有 → 先寫 .feature 和 step definition（不要寫功能程式碼）
   - 有但測試失敗 → 修正功能程式碼
2. 實作功能使測試通過
3. 測試通過後在 tasks.md 中把 [ ] 改為 [x]
"
    fi

    # 失敗時才附加錯誤資訊 (精簡版，不是 full dump)
    if [ "$TEST_EXIT_CODE" -ne 0 ]; then
        PROMPT+="[失敗的測試資訊]
$(cat "$TEST_RESULT_FILE")
"
    fi

    # 指令提醒
    PROMPT+="[執行規則]
- 如果是 Python：step definitions 放在 features/steps/，用 behave 框架
- 如果是 JS：step definitions 放在 features/step_definitions/，用 cucumber-js
- 不需要請求許可，直接讀寫檔案
- 一次只做一個任務，做完就停
"

    echo "$PROMPT"
}

# ─── 主程式 ────────────────────────────────────────────

setup_environment
init_git
mkdir -p .factory "$ROUND_REPORT_DIR"
: > "$HISTORY_FILE"

# 引擎顯示名稱
WORKER_LABEL="$AI_ENGINE"
[ -n "$WORKER_MODEL" ] && WORKER_LABEL="$AI_ENGINE ($WORKER_MODEL)"
SUPER_LABEL="$SUPERVISOR"
[ -n "$SUPERVISOR_MODEL" ] && [ "$SUPERVISOR" != "none" ] && SUPER_LABEL="$SUPERVISOR ($SUPERVISOR_MODEL)"

echo -e "${BLUE}🏭 啟動 Mini TDD Factory v2${NC}"
echo -e "${BLUE}🔧 語言: $LANGUAGE | Worker: $WORKER_LABEL | 監工: $SUPER_LABEL${NC}"
echo -e "${BLUE}🧪 測試: $TEST_CMD | 上限: $MAX_ROUNDS 輪${NC}"
echo ""

ROUND=0
PREV_EXIT_CODE=0
CONSECUTIVE_FAIL=0
NO_CHANGE_COUNT=0
DIFF_STAT=""
DIFF_DETAIL=""
SUPERVISOR_INSTRUCTIONS=""

# 第一次跑測試 (取得初始狀態)
run_tests
PREV_EXIT_CODE=$TEST_EXIT_CODE

while :
do
    ((ROUND++))
    echo -e "\n${BLUE}🔄 ─── 第 $ROUND 輪 ───${NC}"

    # ── 安全閥檢查 ──
    if [ "$ROUND" -gt "$MAX_ROUNDS" ]; then
        echo -e "${RED}⛔ 已達最大輪次 ($MAX_ROUNDS)，停機。${NC}"
        echo "請檢查 .factory/history.md 了解進度。"
        exit 1
    fi

    # ── 檢查完成條件 ──
    PENDING_TASKS=$(grep -c "\[ \]" "$TASKS_FILE" || echo "0")

    if [ "$TEST_EXIT_CODE" -eq 0 ] && [ "$PENDING_TASKS" -eq 0 ]; then
        echo -e "${GREEN}✅ 所有測試通過且任務已完成！工廠停機。${NC}"
        exit 0
    fi

    # ── 狀態顯示 ──
    echo -e "📊 測試: ${PASSED_COUNT} passed / ${FAILED_COUNT} failed | 📋 待辦: $PENDING_TASKS"

    # ── Dual Mode: 人類檢查點 ──
    if [[ "$MODE" == "Dual" ]] && [ "$SUPERVISOR" == "none" ] && [ "$TEST_EXIT_CODE" -ne 0 ]; then
        echo -e "${YELLOW}🕵️ [Dual 模式] 測試失敗。按 Enter 讓 Worker 繼續，或 Ctrl+C 手動介入。${NC}"
        read -r
    fi

    # ── Git 快照 (記錄 AI 改動前的狀態) ──
    snapshot_before

    # ── 呼叫 Worker AI ──
    echo "🤖 呼叫 $WORKER_LABEL (第 $ROUND 輪)..."
    PROMPT_CONTENT=$(compose_prompt)
    call_worker "$PROMPT_CONTENT"

    # ── 偵測 AI 是否改了檔案 ──
    if get_round_diff; then
        echo -e "${GREEN}📝 AI 修改了檔案:${NC}"
        echo "$DIFF_STAT"
        NO_CHANGE_COUNT=0
    else
        ((NO_CHANGE_COUNT++))
        echo -e "${YELLOW}⚠️ AI 沒有修改任何檔案 ($NO_CHANGE_COUNT/$MAX_NO_CHANGE)${NC}"
        DIFF_STAT=""
        DIFF_DETAIL=""
        if [ "$NO_CHANGE_COUNT" -ge "$MAX_NO_CHANGE" ]; then
            echo -e "${RED}❌ AI 連續 $NO_CHANGE_COUNT 輪沒有動作，停機。${NC}"
            exit 1
        fi
    fi

    # ── 儲存上一輪狀態 ──
    PREV_EXIT_CODE=$TEST_EXIT_CODE

    # ── 執行測試 ──
    echo "🧪 執行測試..."
    run_tests

    # ── 更新連續失敗計數 ──
    if [ "$TEST_EXIT_CODE" -ne 0 ]; then
        ((CONSECUTIVE_FAIL++))
        if [ "$CONSECUTIVE_FAIL" -ge "$MAX_CONSECUTIVE_FAIL" ]; then
            echo -e "${RED}⛔ 連續失敗 $CONSECUTIVE_FAIL 輪，停機。${NC}"
            record_history
            exit 1
        fi
    else
        CONSECUTIVE_FAIL=0
    fi

    # ── 記錄歷史與回報 ──
    record_history
    write_round_report

    # ── Supervisor 審查 ──
    run_supervisor

    echo -e "${YELLOW}⏳ 等待 3 秒...${NC}"
    sleep 3
done
