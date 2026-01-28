# 🏭 Mini TDD Factory (樂高版)

> **「這是你的保命招式，壞了就換，不用修。」**

這是一個專為 AI 協作設計的「解耦重構 (Refactor-Ready)」GitHub 模板。
結合了 TDD Factory 的自動化精神與「樂高法 (Lego Methodology)」架構，讓你可以與 AI (如 Gemini, Claude, Cursor) 高效合作，且不用擔心程式碼變成無法維護的義大利麵。

---

## 🧱 核心哲學：樂高法 (The Lego Method)

在 AI 時代，**重寫的成本比除錯還低**。
我們不再維護幾千行的巨大檔案，而是把程式碼拆成一個個小積木 (Parts)。

1.  **壞了就換 (Disposable)**：如果一個功能 (Action) 壞了或寫得太爛，直接刪掉重寫，完全不用心痛。
2.  **一檔一事 (Atomic)**：每個檔案只做一件事，長度嚴格控制在 100 行以內。
3.  **契約先行 (Contracts First)**：先定義資料結構，再寫測試，最後才實作。

## 📂 專案結構 (The Box)

這個盒子裡有四個格子，請嚴格遵守分類：

```text
/
├── contracts/  # 📜 說明書：定義資料輸入輸出 (Schema)
├── tests/      # 🧪 測試儀：驗證積木是否合格 (Tests)
├── actions/    # 🧱 積木區：核心邏輯，每個檔案就像一塊樂高 (Logic)
└── entry/      # 🔌 接頭：API 路由或 CLI 指令 (Entry Points)
```

## 🚀 快速開始 (Lego Mode)

### 1. 安裝環境
確保你有 Python 3，然後安裝依賴：
```bash
pip install -r requirements.txt
```

### 2. 選擇開發模式 (必選)

本模板提供兩種 AI 開發模式，請依需求選擇：

**🧱 樂高模式 (Lego Mode)** - *推薦用於重構或精密開發*
AI 會嚴格遵守「一檔一事」與「解耦」規範，適合建立高品質、易維護的軟體。
```bash
sh mode_lego.sh
```

**🚀 標準模式 (Standard Mode)** - *推薦用於快速原型或簡單腳本*
AI 沒有架構限制，自由發揮。適合 TDD Factory 原本的快速開發流程。
```bash
sh mode_standard.sh
```

### 3. 體驗範例 (Calculator)
我們已經預放了一塊積木 (`calculate`) 給你玩玩看，這是一個簡單的加減法計算機：
```bash
pytest
```
如果看到綠色的 `PASSED`，代表你的樂高工廠運轉正常！

### 4. 開始堆積木 (如何開發)

當你要做新功能時，請依照這個順序告訴 AI：

1.  **定義契約**：在 `contracts/` 新增一個 Schema (例如 `product_schema.json`)。
2.  **寫下測試**：在 `tests/` 新增一個測試 (例如 `test_create_product.py`)。讓它先失敗 (Red)。
3.  **製作積木**：在 `actions/` 實作邏輯 (例如 `create_product.py`)。讓測試通過 (Green)。
4.  **組裝**：在 `entry/` 呼叫這個 Action。

> 💡 **小撇步**：本專案內建 `.cursorrules` 與 `AI_RULES.md`。如果你使用 Cursor 或其他 AI 工具，它們會自動讀取這些規則，並幫你寫出符合樂高標準的程式碼。

---

## 🕹️ 經典 TDD Factory 使用說明 (Standard Mode)

如果你選擇 `mode_standard.sh`，你可以使用原本的 `factory.sh` 自動化腳本。以下是 2026.01 的最新功能與設定方式。

### ✨ 新增功能 (2026.01)
*   **Gemini 自動檢查**: 再也不用怕跑到一半發現沒裝 CLI。
*   **Dual AI Mode (Supervisor 模式)**: 讓人類監控者隨時插手，解決 AI### 第三步：設定與初始化 (重要)

#### 1. 設定工作模式
編輯 `factory_config.md` (已預先建立)：
此檔案是 Markdown 格式，方便閱讀，請只修改 `=` 後面的數值。

```markdown
# Mini TDD Factory 設定檔
LANGUAGE=python
MODE=Dual
LEGO_MODE=true
```

*   `LEGO_MODE=false`: **🚀 標準模式**。無架構限制，自由發揮。
*   `MODE=Dual`: **Supervisor 模式**。測試失敗時暫停，讓人類/IDE 介入。適合配合 Agentic IDE 使用。
*   `MODE=Single`: **YOLO 模式**。全自動重試，適合掛機。

#### 2. 重置專案 (可選)
怕你想要測試一下，附了一個簡單計算機的開發需求，你可以直接執行 factory.sh 看看效果。
但你會要寫自己的專案，提供一個「一鍵重置」指令，幫你把範例清乾淨：
```bash
./reset_project.sh
```
輸入 `y` 確認後，工廠就變回一張白紙了。

### 步驟：許願 (Make a Wish)
只要編輯兩個檔案：
1. **`RFP/requirements.md` (需求)**：
   用中文寫下你要做的軟體功能。
2. **`RFP/tasks.md` (任務)**：
   把大目標拆成小步驟。例如：
   - [ ] 取得目前匯率
   - [ ] 實作轉換計算
   - [ ] 顯示結果

*可以用 SDD 規格寫需求，把你想做的告訴 AI，它會用 Epics, User Stories, Tasks 幫你拆解。*

### 第五步：選擇語言 (首次啟動)
支援 **JavaScript**, **Python**, **Go**，以及 **通用模式 (Universal Mode)**。
- 內建支援 (JS/Py/Go)：工廠會自動幫你安裝依賴。
- **通用模式 (任何語言)**：
  - 選擇 "4) 其他"。
  - 輸入語言名稱 (如 `Rust`, `Ruby`, `C++`)。
  - 輸入該語言的 Gherkin 測試指令 (如 `cargo test`, `cucumber`)。
  - AI 就會根據你的設定，自動上網搜尋並撰寫該語言的 Gherkin 測試與實作代碼。

*如果你有更進階的技術要求 (例如資料庫規格)，SDD 會產生 `RFP/design.md`，寫在裡面 AI 會讀。*

### 第六步：啟動工廠
在終端機輸入：
```bash
./factory.sh
```
工廠啟動時，會自動根據 `LEGO_MODE` 設定載入對應的 AI 規範 (`.cursorrules`)。

---

## 🚀 快速開始

### 1. 安裝環境
確保你有 Python 3，然後安裝依賴：
```bash
pip install -r requirements.txt
```

### 2. 設定專案
打開 `factory_config.md` 確認設定：
```markdown
LANGUAGE=python
LEGO_MODE=true
```

### 3. 體驗範例 (Calculator)
我們已經預放了一塊積木 (`calculate`) 給你玩玩看，這是一個簡單的加減法計算機：
```bash
pytest
```
如果看到綠色的 `PASSED`，代表你的樂高工廠運轉正常！

### 4. 開始堆積木 (如何開發)
執行 `./factory.sh` 開始自動開發，或者手動依照以下順序告訴 AI：

---

## 🤖 給 AI 的指令 (Lego Mode)

如果你是用 Cursor 或 Claude 開發，請確定它有讀到根目錄的 `AI_RULES.md`。
它會知道：
- **絕對不可以**寫超過 100 行的程式碼。
- **一定要**先寫測試。
- **不可以**把邏輯寫在 entry 裡。

## ❓ 常見問題 (FAQ)

**Q: 工廠卡住了怎麼辦？**
A: 按 `Ctrl + C` 停止，檢查你的 `requirements.md` 寫得夠不夠清楚，然後重新執行 `./factory.sh`。
如果你開啟了 `MODE=Dual`，它會在失敗時自動暫停等你指令。

**Q: 我需要自己寫測試嗎？**
A: **不需要！** 只要你的任務和需求寫得夠好，AI 會自動幫你產生測試 (TDD)。
