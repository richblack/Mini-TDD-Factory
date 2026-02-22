# Mini-TDD-Factory 重構計畫

> **給 Claude Code 的指令**：請按照以下任務順序逐一執行。每完成一個任務就 git commit。所有程式碼註解使用繁體中文。

---

## 專案背景

這是一個 Ralph Wiggum Loop 自動化 TDD 工廠，透過 shell script 迴圈呼叫 Gemini CLI (`gemini --yolo`) 來自動寫測試、寫程式碼、修 bug。

目前的問題：
1. 每輪 AI 呼叫是全新 session，沒有上下文記憶
2. 錯誤訊息全量 dump，會污染 prompt
3. 預設語言是 JavaScript 但 Python 範例更完整
4. 多處 bug（檔名不一致、node_modules 殘留等）

---

## Task 0: Git 清理

### 0.1 移除 node_modules 追蹤
```bash
git rm -r --cached node_modules/
```
確保 `.gitignore` 中有 `node_modules/`（已有，不需改）。

### 0.2 移除 test_report.log 追蹤
```bash
git rm --cached test_report.log
```

### 0.3 清理混合語言殘留
刪除以下檔案（它們是 JS 範例殘留，我們改為 Python 為主）：
- `calculator.js`

保留以下檔案作為 Python 預設範例：
- `actions/calculate.py`
- `tests/test_calculate.py`
- `contracts/calculator_schema.json`
- `requirements.txt`

### 0.4 補齊缺失的 .feature 檔
目前 `features/step_definitions/math_steps.js` 存在但沒有對應的 `.feature` 檔。
由於我們改為 Python 預設：
- 刪除 `features/step_definitions/math_steps.js`
- 刪除 `features/step_definitions/` 目錄（JS cucumber 專用）
- 保留 `features/` 目錄但清空（讓 AI 根據任務自動產生 behave 的 `.feature`）

### 0.5 建立 .factory/ 工作目錄
```bash
mkdir -p .factory
```
在 `.gitignore` 加入：
```
.factory/
```
這個目錄用來存每輪的狀態紀錄，不進 git。

Commit message: `chore: clean up repo - remove node_modules tracking, JS remnants, switch to Python default`

---

## Task 1: 修正 reset_project.sh

目前的問題：
- `rm -f factory_config.txt` 但實際檔名是 `factory_config.md`
- 沒有清理 `.factory/` 目錄
- 沒有清理 Python 相關的範例檔案

改寫 `reset_project.sh`：

```bash
#!/bin/bash
# 工廠重置腳本 (Reset Project)
# 用途：清除所有範例代碼，將工廠還原為初始狀態，以便開始新專案。

echo "⚠️  警告：這將會刪除當前專案的所有程式碼、測試與需求文件！"
read -p "確定要重置工廠嗎？(y/N) " confirm

if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "已取消。"
    exit 0
fi

echo "🧹 正在清理專案..."

# 1. 刪除範例代碼 (所有語言)
rm -rf actions/ tests/ contracts/ entry/
rm -f calculator.js *.py *.go go.mod go.sum

# 2. 清空 RFP 文件 (保留標題)
cat > RFP/requirements.md << 'EOF'
# 專案需求 (Requirements)

請在此描述您的新專案需求...
EOF

cat > RFP/design.md << 'EOF'
# 系統設計 (Design)

(選填) 請在此描述系統架構、資料結構或技術細節...
EOF

cat > RFP/tasks.md << 'EOF'
# 任務列表 (Tasks)

- [ ] 任務 1
EOF

# 3. 移除設定檔 (讓使用者重新選擇語言)
rm -f factory_config.md factory_config.txt

# 4. 刪除舊的測試 (保留目錄結構)
rm -rf features/*.feature features/steps features/step_definitions
mkdir -p features/steps            # Python behave 預設

# 5. 重置日誌與工作目錄
rm -f test_report.log test_report.raw
rm -rf .factory
rm -rf __pycache__ .pytest_cache

echo "✨ 工廠已重置！"
echo "👉 下一步："
echo "1. 編輯 'RFP/requirements.md' 輸入新需求。"
echo "2. 編輯 'RFP/tasks.md' 規劃任務。"
echo "3. 執行 ./factory.sh 啟動 AI 工程師。"
```

Commit message: `fix: reset_project.sh - correct config filename, clean all artifacts`

---

## Task 2: 修正 factory_config.md

將預設語言從 `javascript` 改為 `python`：

```markdown
# Mini TDD Factory 設定檔

這是您的工廠控制面板。
此檔案同時是 Markdown (易讀) 與 Shell Script (可執行)。
請只修改 `=` 後面的數值。

## 1. 開發範圍 (Scope)
SCOPE=All

## 2. 程式語言 (Language)
支援: `python`, `javascript`, `go`，或自定義語言。
LANGUAGE=python

## 3. 工作模式 (Operation Mode)
`Single`: YOLO 模式，全自動無限重試 (適合掛機)。
`Dual`: Supervisor 模式，測試失敗時暫停，讓人類介入。
MODE=Dual

## 4. 樂高模式 (Lego Mode)
是否啟用嚴格的「樂高法」開發規範？
`true`: 啟用，強制一檔一事、Contracts First。
`false`: 停用，一般 TDD 開發。
LEGO_MODE=true
```

Commit message: `config: change default language to python`

---

## Task 3: 重寫 factory.sh 核心邏輯

這是最大的改動。完全重寫 `factory.sh`，加入以下機制：

### 3.1 設計原則

1. **用 git diff 當記憶** — 每輪 AI 改完後 commit，下一輪可以告訴 AI「你上輪改了什麼」
2. **結構化測試結果** — 不丟 raw log，解析出 pass/fail 數量和具體失敗訊息
3. **根據狀態切換 prompt** — pass→fail / fail→fail / fail→pass 用不同指令
4. **死循環偵測** — 連續 N 輪失敗或 AI 沒改檔案就停機
5. **安全上限** — MAX_ROUNDS 防止燒錢

### 3.2 完整的 factory.sh

```bash
#!/bin/bash
# Mini TDD Factory - Ralph Wiggum Loop v2
# 用法: ./factory.sh

set -euo pipefail

# ─── 設定 ───────────────────────────────────────────────
CONFIG_FILE="factory_config.md"
TASKS_FILE="RFP/tasks.md"
REQUIREMENTS_FILE="RFP/requirements.md"
DESIGN_FILE="RFP/design.md"
HISTORY_FILE=".factory/history.md"
TEST_RESULT_FILE=".factory/test_result.txt"

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

    cat <<EOF > "$CONFIG_FILE"
# Mini TDD Factory 設定檔
SCOPE=All
LANGUAGE=$LANG_VAL
MODE=Dual
LEGO_MODE=true
EOF

    # 自定義語言的測試指令
    if [ "${custom_cmd:-}" != "" ]; then
        echo "TEST_CMD=$custom_cmd" >> "$CONFIG_FILE"
    fi

    echo -e "${GREEN}✅ 設定已儲存：使用 $LANG_VAL 開發。${NC}"
fi

# ─── 讀取設定 ──────────────────────────────────────────
read_config() {
    local key="$1"
    local default="$2"
    grep "^${key}=" "$CONFIG_FILE" 2>/dev/null | head -1 | cut -d'=' -f2- || echo "$default"
}

SCOPE=$(read_config "SCOPE" "All")
LANGUAGE=$(read_config "LANGUAGE" "python")
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
            # 安裝 Python 測試依賴
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

    # 檢查 gemini CLI
    if ! command -v gemini &> /dev/null; then
        echo -e "${RED}❌ 找不到 'gemini' 指令。${NC}"
        echo "請參考 https://github.com/google-gemini/gemini-cli 安裝 Gemini CLI。"
        exit 1
    fi
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
mkdir -p .factory
: > "$HISTORY_FILE"

echo -e "${BLUE}🏭 啟動 Mini TDD Factory v2${NC}"
echo -e "${BLUE}🔧 語言: $LANGUAGE | 測試: $TEST_CMD | 上限: $MAX_ROUNDS 輪${NC}"
echo ""

ROUND=0
PREV_EXIT_CODE=0
CONSECUTIVE_FAIL=0
NO_CHANGE_COUNT=0
DIFF_STAT=""
DIFF_DETAIL=""

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

    # ── Dual Mode: Supervisor 檢查點 ──
    if [[ "$MODE" == "Dual" ]] && [ "$TEST_EXIT_CODE" -ne 0 ]; then
        echo -e "${YELLOW}🕵️ [Supervisor 模式] 測試失敗。按 Enter 讓 Worker 繼續，或 Ctrl+C 手動介入。${NC}"
        read -r
    fi

    # ── Git 快照 (記錄 AI 改動前的狀態) ──
    snapshot_before

    # ── 呼叫 Gemini ──
    echo "🤖 呼叫 Gemini (第 $ROUND 輪)..."
    PROMPT_CONTENT=$(compose_prompt)
    gemini --yolo "$PROMPT_CONTENT"

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

    # ── 記錄歷史 ──
    record_history

    echo -e "${YELLOW}⏳ 等待 3 秒...${NC}"
    sleep 3
done
```

Commit message: `feat: rewrite factory.sh v2 - git-based memory, smart prompts, safety limits`

---

## Task 4: 更新 package.json

由於預設改為 Python，`package.json` 不再是必要的啟動依賴，但保留給選 JS 的使用者：

```json
{
    "name": "mini-tdd-factory",
    "version": "2.0.0",
    "description": "Mini TDD Factory - AI 自動化軟體工廠 (Ralph Wiggum Loop)",
    "scripts": {
        "test": "cucumber-js",
        "factory": "./factory.sh"
    },
    "dependencies": {
        "@cucumber/cucumber": "^10.0.0"
    }
}
```

Commit message: `chore: update package.json for v2`

---

## Task 5: 更新 README.md

重寫 README，修正以下問題：
- 步驟編號重複（兩個「第五步」）
- 預設語言改為 Python
- 加入 v2 的新功能說明（git 記憶、智慧 prompt、安全閥）
- 加入 Gemini CLI 的正確安裝連結
- 移除錯誤的 `npm install -g @google/generative-ai` 安裝指引

```markdown
# 🏭 Mini TDD Factory v2 (迷你 AI 軟體工廠)

這是一個專為學員設計的自動化開發工具。
你不需要很會寫程式，只要負責「許願」(寫需求)，AI 就會幫你寫功能並自我檢查！

致敬《Ralph Wiggum》的無腦快樂開發精神 — 讓 AI 做工，你喝咖啡。

---

## 🚀 這是什麼？

想像你有一個不知疲倦的 AI 實習生：

1. 你告訴他要做什麼 (寫在需求檔)。
2. 你列出任務清單 (寫在任務檔)。
3. **他會自動幫你寫測試、寫程式、修正錯誤，直到全部完成。**

### v2 改進

- 🧠 **Git 記憶**：每輪 AI 改動都會被記錄，下一輪知道「上輪改了什麼」
- 🎯 **智慧 Prompt**：根據測試狀態（pass→fail / fail→fail / fail→pass）給不同指令
- 🛡️ **安全閥**：最大輪次限制、連續失敗偵測、無動作偵測，不會無限燒錢
- 📊 **結構化測試分析**：不再全量 dump 錯誤日誌，精準提取失敗資訊

---

## 📦 使用方法

### 第一步：準備環境

1. **Python 3**: [下載安裝](https://www.python.org/downloads/)
2. **Gemini CLI**: [安裝指南](https://github.com/google-gemini/gemini-cli)
3. **Git**: 需要 git 來追蹤每輪的改動

### 第二步：取得專案

```bash
# 方法 A：使用 Template (推薦)
# 點擊 GitHub 頁面上方的 "Use this template" 按鈕

# 方法 B：直接 clone
git clone https://github.com/richblack/Mini-TDD-Factory.git
cd Mini-TDD-Factory
```

### 第三步：初始化 (如果要開始新專案)

```bash
./reset_project.sh
```

### 第四步：許願 (你最重要的工作)

編輯兩個檔案：

1. **`RFP/requirements.md`**：用中文寫下你要做的軟體功能
2. **`RFP/tasks.md`**：把大目標拆成小步驟

進階使用者可以編輯 `RFP/design.md` 指定技術架構。

### 第五步：啟動工廠

```bash
./factory.sh
```

首次執行會詢問開發語言（預設 Python）。
然後你就可以去喝咖啡了 ☕

工廠會在以下情況自動停機：
- ✅ 所有測試通過且任務完成
- ⛔ 達到最大輪次 (預設 20 輪)
- ⛔ 連續失敗超過 5 輪
- ⛔ AI 連續 3 輪沒有修改任何檔案

---

## ⚙️ 設定

編輯 `factory_config.md` 可以調整：

| 設定 | 說明 | 預設值 |
|------|------|--------|
| LANGUAGE | 開發語言 | python |
| MODE | Single (全自動) / Dual (失敗時暫停) | Dual |
| LEGO_MODE | 樂高法嚴格規範 | true |
| TEST_CMD | 自定義測試指令 | (自動偵測) |

---

## ❓ 常見問題

**Q: 工廠卡住怎麼辦？**
A: 按 `Ctrl + C` 停止，檢查 `.factory/history.md` 看過去每輪做了什麼，調整需求後重新執行。

**Q: 我需要自己寫測試嗎？**
A: 不需要！AI 會根據你的需求自動產生 Gherkin 測試 (BDD)。

**Q: 支援哪些語言？**
A: 預設 Python，也支援 JavaScript、Go，以及任何你能指定測試指令的語言。

---

## 🙏 致謝

- **Concept**: Ralph Wiggum "Verification Driven Development"
- **Model**: Gemini CLI
- **Framework**: Cucumber / Behave (BDD)
```

Commit message: `docs: rewrite README for v2 - fix numbering, Python default, new features`

---

## Task 6: 更新 .gitignore

確保 `.gitignore` 包含以下內容（合併去重）：

```
# System
.DS_Store

# Dependencies
node_modules/
__pycache__/
.pytest_cache/
*.pyc

# Factory runtime
.factory/
.cursorrules
test_report.log
test_report.raw
*.log

# Python
*.egg-info/
dist/
build/

# Go
vendor/
```

Commit message: `chore: update .gitignore for v2`

---

## 執行順序摘要

1. Task 0: Git 清理（移除 node_modules 追蹤、JS 殘留）
2. Task 1: 修正 reset_project.sh
3. Task 2: 修正 factory_config.md（預設 Python）
4. Task 3: 重寫 factory.sh（核心改進）
5. Task 4: 更新 package.json
6. Task 5: 重寫 README.md
7. Task 6: 更新 .gitignore

每個 Task 完成後獨立 commit，commit message 已標註在各 Task 末尾。