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

# 檢查相依性
if ! command -v gemini &> /dev/null; then
    echo "❌ 錯誤: 找不到 'gemini' CLI。請確認已安裝並位於 PATH 中。"
    exit 1
fi
if ! command -v npx &> /dev/null; then
    echo "❌ 錯誤: 找不到 'npx'。請安裝 Node.js。"
    exit 1
fi

echo -e "${BLUE}🏭 啟動簡易軟體工廠...${NC}"

# 如果缺少 node_modules 則安裝依賴
if [ ! -d "node_modules" ]; then
    echo -e "${YELLOW}📦 正在安裝相依套件...${NC}"
    npm install
fi

ROUND=0

while :
do
    ((ROUND++))
    echo -e "\n${BLUE}🔄 --- 第 $ROUND 輪循環 ---${NC}"

    # 2. 執行測試
    echo "🧪 正在執行測試..."
    # 執行 cucumber-js 並將輸出導向日誌
    npx cucumber-js > test_report.log 2>&1
    TEST_EXIT_CODE=$?
    
    # 解析測試結果 (Mac 相容)
    SUMMARY_LINE=$(tail -n 3 test_report.log | grep "scenarios")
    
    FAILED_COUNT=$(echo "$SUMMARY_LINE" | grep -o "[0-9]* failed" | awk '{print $1}')
    [ -z "$FAILED_COUNT" ] && FAILED_COUNT=0
    
    PASSED_COUNT=$(echo "$SUMMARY_LINE" | grep -o "[0-9]* passed" | awk '{print $1}')
    [ -z "$PASSED_COUNT" ] && PASSED_COUNT=0
    
    UNDEFINED_COUNT=$(echo "$SUMMARY_LINE" | grep -o "[0-9]* undefined" | awk '{print $1}')
    [ -z "$UNDEFINED_COUNT" ] && UNDEFINED_COUNT=0
    
    # 將未定義視為錯誤
    TOTAL_ISSUES=$((FAILED_COUNT + UNDEFINED_COUNT))
    
    echo -e "📊 狀態: ${GREEN}${PASSED_COUNT} 通過${NC} | ${RED}${FAILED_COUNT} 失敗${NC} | ${YELLOW}${UNDEFINED_COUNT} 未定義${NC}"

    # 3. 檢查任務狀態
    PENDING_TASKS=$(grep -c "\[ \]" "$TASKS_FILE")
    echo "📋 待辦任務數: $PENDING_TASKS"

    # 4. 決定 AI 任務 (Mission)
    MISSION=""
    
    if [ $TEST_EXIT_CODE -eq 0 ] && [ "$PENDING_TASKS" -eq 0 ]; then
        echo -e "${GREEN}✅ 所有測試通過且任務已完成！工廠停機。${NC}"
        # 可選擇在此自動 commit
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
           - ⚠️ 如果**有**但測試失敗：請修正功能程式碼 (`.js`) 或 步驟定義 (`features/step_definitions/`)。
        3. 實作功能以通過測試。
        4. 只有在測試通過 (Green Light) 後，才能在 '$TASKS_FILE' 中打勾。
        "
    else
        # 測試失敗
        echo -e "${RED}👉 測試失敗。正在修正程式碼。${NC}"
        MISSION="
        【🔴 狀態：測試失敗】
        測試未通過。你需要修正程式碼或測試定義。
        
        失敗數量: $FAILED_COUNT
        
        請讀取 'test_report.log' (已提供於 context) 並修正錯誤。
        "
    fi

    # 5. 讀取設定範圍
    SCOPE_TXT=$(grep "SCOPE=" "$CONFIG_FILE" 2>/dev/null || echo "SCOPE=All")
    
    # 6. 呼叫 Gemini
    echo "🤖 呼叫 Gemini (YOLO)..."
    
    # 建構 Prompt
    FILES=$(find . -maxdepth 3 -not -path '*/.*' -not -path './node_modules*')
    
    gemini --yolo "
    你是軟體工廠中的 AI 工程師 (第 $ROUND 輪)。
    目前請使用 **繁體中文** 進行思考與回覆，程式碼註解也請使用繁體中文。
    
    [設定]
    $SCOPE_TXT
    
    [工作區檔案]
    $FILES
    
    [任務目標]
    $MISSION
    
    [測試日誌]
    $(cat test_report.log | tail -n 20)
    
    [指令]
    - 分析 $REQUIREMENTS_FILE 中的需求。
    - 檢查 $TASKS_FILE。
    - 如果正在實作新功能，你必須建立缺失的 Step Definitions。
    - 重要：目前位於目錄 $(pwd)。
    - 不需要請求許可，直接寫入程式碼。
    "

    echo -e "${YELLOW}⏳ 等待 5 秒後進入下一輪...${NC}"
    sleep 5
done
