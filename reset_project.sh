#!/bin/bash
# 工廠重置腳本 (Reset Project)
# 用途：清除所有範例代碼 (計算機)，將工廠還原為初始狀態，以便開始新專案。

echo "⚠️  警告：這將會刪除當前專案的所有程式碼、測試與需求文件！"
read -p "確定要重置工廠嗎？(y/N) " confirm

if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "已取消。"
    exit 0
fi

echo "🧹 正在清理專案..."

# 1. 刪除範例代碼 (所有語言)
rm -f calculator.js *.py *.go go.mod go.sum

# 2. 清空 RFP 文件 (保留標題)
echo "# 專案需求 (Requirements)" > RFP/requirements.md
echo -e "\n請在此描述您的新專案需求..." >> RFP/requirements.md

echo "# 系統設計 (Design)" > RFP/design.md
echo -e "\n(選填) 請在此描述系統架構、資料結構或技術細節..." >> RFP/design.md

echo "# 任務列表 (Tasks)" > RFP/tasks.md
echo -e "\n- [ ] 任務 1" >> RFP/tasks.md

# 3. 移除設定檔 (讓使用者重新選擇語言)
rm -f factory_config.txt

# 3. 刪除舊的測試 (保留目錄結構)
rm -f features/*.feature
rm -rf features/steps features/step_definitions
mkdir -p features/step_definitions # JS 預設
mkdir -p features/steps            # Python 預設

# 4. 重置日誌與依賴緩存 (視需要)
rm -f test_report.log
rm -rf __pycache__

echo "✨ 工廠已重置！"
echo "👉 下一步："
echo "1. 編輯 'RFP/requirements.md' 輸入新需求。"
echo "2. 編輯 'RFP/tasks.md' 規劃任務。"
echo "3. 執行 ./factory.sh 啟動 Gemini AI 工程師。"
