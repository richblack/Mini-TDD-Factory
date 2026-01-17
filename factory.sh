#!/bin/bash
# 簡易版 Gemini 自動化軟體工廠 "Ralph Lite" - YOLO 模式
# 用法: ./factory.sh

# 1. 設定
CONFIG_FILE="factory_config.txt"
TASKS_FILE="RFP/tasks.md"
REQUIREMENTS_FILE="RFP/requirements.md"

# ANSI 顏色代碼
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # 無顏色

# 0. 初始設定精靈 (Setup Wizard)
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${YELLOW}👋 歡迎來到 Mini TDD Factory！${NC}"
    echo "請選擇您要使用的開發語言："
    echo "1) JavaScript (Node.js) [預設]"
    echo "2) Python"
    echo "3) Golang"
    read -p "請輸入選項 (1-3): " lang_choice

    case "$lang_choice" in
        2) LANG_VAL="python" ;;
        3) LANG_VAL="go" ;;
        *) LANG_VAL="javascript" ;;
    esac

    echo "SCOPE=All" > "$CONFIG_FILE"
    echo "LANGUAGE=$LANG_VAL" >> "$CONFIG_FILE"
    echo -e "${GREEN}✅ 設定已儲存：使用 $LANG_VAL 開發。${NC}"
fi

# 讀取設定 (如果變數不存在則使用預設值)
SCOPE=$(grep "SCOPE=" "$CONFIG_FILE" | cut -d'=' -f2 || echo "All")
LANGUAGE=$(grep "LANGUAGE=" "$CONFIG_FILE" | cut -d'=' -f2 || echo "javascript")
DESIGN_FILE="RFP/design.md"

# 檢查相依性與環境設定
setup_environment() {
    case "$LANGUAGE" in
        javascript)
            if ! command -v npx &> /dev/null; then
                echo "❌ 錯誤: 找不到 'npx' (Node.js)。"
                exit 1
            fi
            if [ ! -d "node_modules" ]; then
                echo -e "${YELLOW}📦 [JS] 正在安裝 npm 依賴...${NC}"
                npm install
            fi
            TEST_CMD="npx cucumber-js"
            ;;
        python)
            if ! command -v python3 &> /dev/null; then
                echo "❌ 錯誤: 找不到 'python3'。"
                exit 1
            fi
            if ! command -v behave &> /dev/null; then
                echo -e "${YELLOW}📦 [Python] 正在安裝 'behave' (Gherkin runner)...${NC}"
                pip3 install behave
            fi
            TEST_CMD="behave"
            ;;
        go)
            if ! command -v go &> /dev/null; then
                echo "❌ 錯誤: 找不到 'go'。"
                exit 1
            fi
            if ! command -v godog &> /dev/null; then
                echo -e "${YELLOW}📦 [Go] 正在安裝 'godog' (Cucumber for Go)...${NC}"
                go install github.com/cucumber/godog/cmd/godog@latest
            fi
            if [ ! -f "go.mod" ]; then
                echo -e "${YELLOW}📦 [Go] 初始化 go.mod...${NC}"
                go mod init factory
                go get github.com/cucumber/godog
            fi
            # 確保 PATH 包含 go bin
            export PATH=$PATH:$(go env GOPATH)/bin
            TEST_CMD="godog run"
            ;;
        *)
            echo "❌ 錯誤: 不支援的語言 '$LANGUAGE'。請設定為 javascript, python 或 go。"
            exit 1
            ;;
    esac
}

setup_environment

echo -e "${BLUE}🏭 啟動簡易軟體工廠...${NC}"
echo -e "${BLUE}🔧 使用語言: $LANGUAGE${NC}"
echo -e "${BLUE}🧪 測試指令: $TEST_CMD${NC}"

ROUND=0

while :
do
    ((ROUND++))
    echo -e "\n${BLUE}🔄 --- 第 $ROUND 輪循環 ---${NC}"

    # 2. 執行測試
    echo "🧪 正在執行測試..."
    # 執行測試並將輸出導向日誌
    $TEST_CMD > test_report.log 2>&1
    TEST_EXIT_CODE=$?
    
    # 解析測試結果 (通用邏輯: 尋找 passed/failed 關鍵字)
    # 針對不同工具的輸出格式可能需要微調，這裡使用較寬鬆的 grep
    
    SUMMARY_LINE=$(tail -n 10 test_report.log)
    
    # 嘗試抓取數字 (這部分可能需要根據不同語言的 runner 輸出調整，但 AI 可以讀 log 自己判斷)
    FAILED_COUNT=$(echo "$SUMMARY_LINE" | grep -oE "[0-9]+ failed" | head -n 1 | awk '{print $1}')
    [ -z "$FAILED_COUNT" ] && FAILED_COUNT=0
    
    PASSED_COUNT=$(echo "$SUMMARY_LINE" | grep -oE "[0-9]+ passed" | head -n 1 | awk '{print $1}')
    [ -z "$PASSED_COUNT" ] && PASSED_COUNT=0
    
    # 如果是 godog 或 behave，輸出格式可能略有不同，但我們先依賴 test_report.log 給 AI 看
    
    echo -e "📊 狀態: ${GREEN}Test Exit Code: $TEST_EXIT_CODE${NC}"

    # 3. 檢查任務狀態
    PENDING_TASKS=$(grep -c "\[ \]" "$TASKS_FILE")
    echo "📋 待辦任務數: $PENDING_TASKS"

    # 4. 決定 AI 任務 (Mission)
    MISSION=""
    
    if [ $TEST_EXIT_CODE -eq 0 ] && [ "$PENDING_TASKS" -eq 0 ]; then
        echo -e "${GREEN}✅ 所有測試通過且任務已完成！工廠停機。${NC}"
        exit 0
    elif [ $TEST_EXIT_CODE -eq 0 ]; then
        # 測試通過，但還有任務
        echo -e "${YELLOW}👉 測試通過。推進下一個任務。${NC}"
        MISSION="
        【🟢 狀態：測試通過 | 🟡 待辦任務：$PENDING_TASKS】
        目前的程式碼通過了所有現有測試。
        你的目標是從 tasks.md 中挑選下一個「未完成」的任務並實作它。
        
        1. 讀取 '$TASKS_FILE' 並鎖定當前要執行的「未完成任務」。
        2. **關鍵步驟 (TDD)**：檢查 `features/` 目錄中是否有對應此任務的 Gherkin `.feature` 測試檔。
           - ❌ 如果**沒有**：請先不要寫功能程式碼！請根據 '$REQUIREMENTS_FILE' 的描述，為此任務撰寫一個 `.feature` 檔案。
           - ⚠️ 如果**有**但測試失敗：請修正功能程式碼 ($LANGUAGE) 或 步驟定義。
        3. 實作功能以通過測試。
        4. 只有在測試通過 (Green Light) 後，才能在 '$TASKS_FILE' 中打勾。
        "
    else
        # 測試失敗
        echo -e "${RED}👉 測試失敗。正在修正程式碼。${NC}"
        MISSION="
        【🔴 狀態：測試失敗】
        測試未通過。你需要修正程式碼或測試定義。
        
        請讀取 'test_report.log' (已提供於 context) 並修正錯誤。
        "
    fi

    # 5. 呼叫 Gemini
    echo "🤖 呼叫 Gemini (YOLO)..."
    
    # 建構 Prompt
    FILES=$(find . -maxdepth 3 -not -path '*/.*' -not -path './node_modules*' -not -path './__pycache__*')
    
    # 读取 Design 文件內容 (如果存在)
    DESIGN_CONTENT=""
    if [ -f "$DESIGN_FILE" ]; then
        DESIGN_CONTENT=$(cat "$DESIGN_FILE")
    fi
    
    gemini --yolo "
    你是軟體工廠中的 AI 工程師 (第 $ROUND 輪)。
    目前指定的開發語言是：**$LANGUAGE**。
    請使用 **繁體中文** 進行思考與回覆，程式碼註解也請使用繁體中文。
    
    [設定]
    語言: $LANGUAGE
    範圍: $SCOPE
    
    [工作區檔案]
    $FILES
    
    [需求規格]
    $(cat "$REQUIREMENTS_FILE")
    
    [系統設計 (Design)]
    $DESIGN_CONTENT
    
    [任務列表]
    $MISSION
    
    [測試日誌]
    $(cat test_report.log | tail -n 50)
    
    [指令]
    - 參考 Design 文件中的架構規範 (如果有)。
    - 如果是 Python，Step Definitions 通常在 features/steps/。
    - 如果是 Go，通常使用 godog，測試檔為 *_test.go。
    - 不管學員是否知道怎麼寫，你必須負責處理語言細節。
    - 不需要請求許可，直接寫入程式碼。
    "

    echo -e "${YELLOW}⏳ 等待 5 秒後進入下一輪...${NC}"
    sleep 5
done
