# Changelog

## v2.0.0 (2026-02-22)

### 新功能
- **支援雙引擎**：Worker AI 可選 Gemini CLI 或 Claude Code，不再綁定單一 AI
- **監工模式 (Supervisor)**：可用另一個 AI 當監工，每輪審查 Worker 回報，有全局觀，能解決 Worker 解不了的問題
- **可指定模型**：Worker 和 Supervisor 可各自指定模型（如 Claude Opus 監工 + Gemini Flash 做事）
- **Git 記憶**：每輪 AI 改動都會 commit，下一輪知道「上輪改了什麼」，不再失憶
- **智慧 Prompt**：根據測試狀態（pass→fail / fail→fail / fail→pass）給不同指令
- **安全閥**：最大輪次(20)、連續失敗偵測(5)、無動作偵測(3)，不會無限燒錢
- **結構化測試分析**：不再全量 dump 錯誤日誌，精準提取失敗資訊
- **每輪回報檔**：`.factory/rounds/round_N.md`，隨時可查「現在做到哪了」

### 修正
- 修正 `reset_project.sh` 中 `factory_config.txt` → `factory_config.md` 檔名錯誤
- 修正 `reset_project.sh` 未清理 `actions/`、`tests/`、`contracts/`、`.factory/` 目錄
- 修正 `factory.sh` 中 Gemini CLI 安裝指引錯誤
- 移除 `test_report.log` 的 git 追蹤
- 移除 JS 殘留檔案 (`calculator.js`、`math_steps.js`、`package-lock.json`)

### 變更
- 預設語言從 JavaScript 改為 Python
- 重寫 `factory.sh` 核心邏輯
- 重寫 `README.md`，技術細節移至 `docs/technical.md`

## v1.0.0

- 初始版本，使用 Gemini CLI (`gemini --yolo`) 驅動
- 基本的 Ralph Wiggum Loop：跑測試 → AI 修正 → 再跑測試
- 支援 JavaScript / Python / Go
- 樂高模式 (Lego Mode)
