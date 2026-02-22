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

# 3. 移除設定檔 (讓使用者重新選擇語言與 AI 引擎)
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
