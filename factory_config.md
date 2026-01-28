# Mini TDD Factory 設定檔

這是您的工廠控制面板。
此檔案同時是 Markdown (易讀) 與 Shell Script (可執行)。
請只修改 `=` 後面的數值。

## 1. 開發範圍 (Scope)
設定要修改的檔案範圍。
`All`: 允許 AI修改整個專案 (推薦)。
`Specific`: 僅允許修改特定檔案 (進階)。
SCOPE=All

## 2. 程式語言 (Language)
指定您的專案語言。
支援: `javascript`, `python`, `go`，或自定義語言。
LANGUAGE=javascript

## 3. 工作模式 (Operation Mode)
`Single`: YOLO 模式，全自動無限重試 (適合掛機)。
`Dual`: Supervisor 模式，測試失敗時暫停，讓人類介入 (適合搭配 Agentic IDE)。
MODE=Dual

## 4. 樂高模式 (Lego Mode)
是否啟用嚴格的「樂高法」開發規範？
`true`: 啟用 (.cursorrules.lego)，強制一檔一事、Contracts First。
`false`: 停用 (.cursorrules.standard)，一般 TDD 開發。
LEGO_MODE=true
