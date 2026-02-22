# 💎 Mini TDD Factory：全方位開發與自動化指南

這份指南是為 **Mini TDD Factory** 使用者與學生設計的完整手冊。
它涵蓋了從學科理論到工廠實作腳本，再到自動化測試底層原理的全面知識。

---

## 🏗️ 第一部分：軟體開發方法論 (學理篇)

在工廠中，我們將軟體工程的三大支柱對應到具體的檔案：

### 1. SDD (Software Design Document) - 軟體設計文件
> **角色**：解決「怎麼蓋？」的問題。
- **概念**：定義系統架構、資料結構、API 介面與模組關係。
- **工廠實作**：對應於 `RFP/design.md`。
  - 當你有特定的技術堅持 (例如：「必須使用 Factory Pattern」、「資料庫使用 SQLite」)，這就是你對 AI 下達建築藍圖的地方。

### 2. BDD (Behavior Driven Development) - 行為驅動開發
> **角色**：解決「做什麼？」的問題。
- **概念**：使用自然語言 (Gherkin 語法) 撰寫使用者情境，讓不懂程式的人也能看懂需求。
- **工廠實作**：對應於 `features/*.feature`。
  - AI 會將你的需求 (`requirements.md`) 轉化為這裡的場景 (Scenarios)。

### 3. TDD (Test Driven Development) - 測試驅動開發
> **角色**：解決「做對了嗎？」的問題。
- **概念**：遵循「紅燈 (測試失敗) -> 綠燈 (測試通過) -> 重構」的循環。
- **工廠實作**：這是 `factory.sh` 的核心迴圈。
  - 工廠會優先確保測試失敗 (代表有新需求未實作)，然後寫程式讓它通過。

---

## ⚙️ 第二部分：程式工廠實施指南 (實作篇)

Mini TDD Factory 透過一個簡單的 Shell Script (`factory.sh`) 來模擬一個「AI 軟體工程師」的思考迴路。

### Step 1: 環境解鎖 (Setup Wizard)
工廠具備**多語言適應能力**。
- **自動偵測**：首次啟動時，腳本會透過「設定精靈」詢問你想使用的語言 (JS/Python/Go 或其他)。
- **設定檔**：選擇結果會儲存於 `factory_config.txt`，定義了：
  - `LANGUAGE`: 開發語言。
  - `TEST_CMD`: 測試指令 (如 `npx cucumber-js`, `behave`, `cargo test`)。

### Step 2: 自動化迴圈 (The Loop)
`factory.sh` 是一個無窮迴圈的狀態機，每一輪循環 (Loop) 都在做以下判斷：

1. **執行測試 (Test)**
   - 執行 `TEST_CMD` 並將結果輸出到 `test_report.log`。
   
2. **狀態感知 (Perceive)**
   - **🔴 紅燈 (Exit Code != 0)**：代表程式有 Bug 或功能未完工。
   - **🟢 綠燈 (Exit Code == 0)**：代表現有功能都正常。

3. **決策 (Decide)**
   - 若 **🔴 紅燈** -> **MISSION**: 「修復程式碼以通過測試」。
   - 若 **🟢 綠燈** -> **MISSION**: 「從 `tasks.md` 挑選下一個未完成任務，並實作之 (或是先寫測試)」。

4. **行動 (Act - YOLO Mode)**
   - 呼叫 `gemini --yolo`。
   - 將 **專案檔案** + **測試報告** + **當前任務** 打包傳給 AI。
   - AI 直接修改檔案系統 (File System)，不需要人類複製貼上。

---

## � 第三部分：透視引擎蓋 (原理篇)

### 1. 為什麼會出現「Undefined」與「Pending」？
- **Undefined**: 代表 Gherkin 劇本寫好了 (Feature)，但演員 (Step Definitions) 還沒請到。這是 TDD 的第一步。
- **Pending**: 代表任務在 `tasks.md` 中尚未打勾。工廠會持續工作直到 Pending 歸零。

### 2. 通用模式 (Universal Mode) 的原理
原本工廠只支援 JS/Python/Go，但我們加入了「通用介面」：
- 只要你能提供一個 **「測試指令 (Test Command)」**，並且該指令在由失敗轉成功時會回傳正確的 Exit Code (1 -> 0)。
- AI 就能夠「盲寫」任何語言 (Rust, C++, Ruby...)。
- **關鍵**：AI 依賴 `test_report.log` 的輸出來修正自己。只要 Compiler 或 Test Runner 的報錯訊息夠清楚，AI 就能自我修正。

### 3. 安全機制
- **Git**: 雖然是 YOLO (You Only Look Once) 模式，但我們建議使用者在滿意時手動 Commit。
- **Reset**: `reset_project.sh` 提供了隨時回到原點的能力。

---

## 🎓 總結：工廠管理員的哲學

在這個模式下，你不再是「撰寫代碼」的工人，而是「設計工廠」的廠長。
你的工作從「如何寫 `for` 迴圈」變成了：
1. **需求是否清晰？** (`requirements.md`)
2. **任務拆分是否合理？** (`tasks.md`)
3. **架構是否穩固？** (`design.md`)

**這就是 AI 時代的工程師升級之路。**