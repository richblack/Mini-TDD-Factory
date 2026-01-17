# 🏭 Mini TDD Factory (迷你 AI 軟體工廠)

這是一個超簡單自動化開發工具，Claude Code 有官方支援，本專案讓你用 Gemini CLI 也能做一樣的事。
你不需要很會寫程式，只要負責「許願」(寫需求)，AI 就會幫你「寫功能」並且「自我檢查」！

本專案由 AI (Gemini + Antigravity) 協助開發，致敬《Ralph Wiggum》的無腦快樂開發精神。

---

## 🚀 這是什麼？

想像你有一個不知疲倦的 AI 實習生：
1. 你告訴他要做什麼 (寫在需求檔)。
2. 你列出任務清單 (寫在任務檔)。
3. **他會自動幫你寫測試、寫程式、修正錯誤，直到全部完成。**

這就是 **Mini TDD Factory**。


## 📦 如何使用 (懶人包)

### 第一步：準備環境 (必做)
請確保你的電腦已經安裝：
1. **Node.js**: [下載安裝](https://nodejs.org/)
2. **Gemini CLI**: 這是 AI 的大腦，請確認已安裝並設定好。

### 第二步：取得專案 (二選一)

#### 方法 A：使用 Template (推薦)
1. 點擊本頁面上方的綠色按鈕 **"Use this template"** -> **"Create a new repository"**。
2. 建立屬於你自己的 Repo。
3. 把你的新 Repo Clone 到電腦上。

#### 方法 B：直接下載
1. 開啟終端機 (Terminal)。
2. 執行指令：
   ```bash
   git clone https://github.com/richblack/Mini-TDD-Factory.git
   cd Mini-TDD-Factory
   ```

### 第三步：初始化專案
怕你想要測試一下，付了一個簡單計算機的開發需求，你可以直接執行 factory.sh 看看效果。
但你會要寫自己的專案，提供一個「一鍵重置」指令，幫你把範例清乾淨：
```bash
./reset_project.sh
```
輸入 `y` 確認後，工廠就變回一張白紙了。

### 第四步：許願 (這是你最重要的工作)
只要編輯兩個檔案：
1. **`RFP/requirements.md` (需求)**：
   用中文寫下你要做的軟體功能。例如：「做一個匯率轉換器，輸入台幣顯示美金...」
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

然後...你就可以去喝咖啡了 ☕️。
你會看到 AI 開始自言自語、寫測試、寫程式、報錯、修正，直到看到綠色的 **✅ 所有測試通過** 為止。

---

## ❓ 常見問題

**Q: 工廠卡住了怎麼辦？**
A: 按 `Ctrl + C` 停止，檢查你的 `requirements.md` 寫得夠不夠清楚，然後重新執行 `./factory.sh`。

**Q: 我需要自己寫測試嗎？**
A: **不需要！** 只要你的任務和需求寫得夠好，AI 會自動幫你產生測試 (TDD)。當然，如果你想自己寫 Gherkin 也是可以的。

**Q: 這是用什麼做的？**
A: 核心是 `cucumber-js` (測試框架) 加上 `gemini` (AI 模型)，透過 Shell Script 串接起來的自動化迴圈。

---

## 一些背景說明（如果只想用可以不理）

這個原理是 TDD (Test-Driven Development)，也就是測試驅動開發。你用 SDD 規格寫需求，而 AI 會幫你用 Gherkin 測試來驗證，這個是 BDD (Behavior-Driven Development) 的手法，而 AI 會把你的 Gherkin 檔案轉成測試檔進行測試，如果失敗，AI 會自動修正直到測試通過，所以你可以去睡覺，或是追劇。

為什麼叫工廠？一個終端機裡可以跑一組 Gemini CLI，如果你的電腦夠強，可以同時開多個終端機，跑多組 Gemini CLI，就可以同時開發多個專案，你就有個程式碼生產線了。

## 🙏 特別感謝
- **Developer**: Antigravity (Google DeepMind)
- **Model**: Gemini 2.0
- **Concept**: Ralph Wiggum "Verification Driven Development"
