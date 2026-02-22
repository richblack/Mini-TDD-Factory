# Mini TDD Factory 設定檔

這是您的工廠控制面板。
此檔案同時是 Markdown (易讀) 與 Shell Script (可執行)。
請只修改 `=` 後面的數值。

## 1. 開發範圍 (Scope)
SCOPE=All

## 2. 程式語言 (Language)
支援: `python`, `javascript`, `go`，或自定義語言。
LANGUAGE=python

## 3. AI 引擎 (AI Engine)
Worker AI 使用的引擎。
`gemini`: Gemini CLI (gemini --yolo)
`claude`: Claude Code (claude -p --dangerously-skip-permissions)
AI_ENGINE=gemini

## 4. AI 模型 (AI Model)
指定 Worker 和 Supervisor 使用的模型 (留空則使用各引擎預設值)。
Gemini 範例: `gemini-2.5-pro`, `gemini-2.5-flash`
Claude 範例: `opus`, `sonnet`
WORKER_MODEL=
SUPERVISOR_MODEL=

## 5. 監工模式 (Supervisor)
`none`: 無監工，只靠 bash 腳本判斷。
`claude`: Claude Code 當監工，每輪審查 Worker 回報。
`gemini`: Gemini CLI 當監工。
SUPERVISOR=none

## 6. 工作模式 (Operation Mode)
`Single`: YOLO 模式，全自動無限重試 (適合掛機)。
`Dual`: Supervisor 模式，測試失敗時暫停，讓人類介入。
MODE=Dual

## 7. 樂高模式 (Lego Mode)
是否啟用嚴格的「樂高法」開發規範？
`true`: 啟用，強制一檔一事、Contracts First。
`false`: 停用，一般 TDD 開發。
LEGO_MODE=true
