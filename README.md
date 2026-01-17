# 🏭 Mini TDD Factory (迷你 AI 軟體工廠)

這是一個專為學員設計的超簡單自動化開發工具。
你不需要很會寫程式，只要負責「許願」(寫需求)，AI 就會幫你「寫功能」並且「自我檢查」！

本專案由 AI (Gemini + Antigravity) 協助開發，致敬《Ralph Wiggum》的無腦快樂開發精神。

---

## 🚀 這是什麼？

想像你有一個不知疲倦的 AI 實習生：
1. 你告訴他要做什麼 (寫在需求檔)。
2. 你列出任務清單 (寫在任務檔)。
3. **他會自動幫你寫測試、寫程式、修正錯誤，直到全部完成。**

這就是 **Mini TDD Factory**。


## 📦 如何使用 (給學員的懶人包)

### 方法一：使用 Template (推薦)
1. 點擊本頁面上方的綠色按鈕 **"Use this template"** -> **"Create a new repository"**。
2. 建立屬於你自己的 Repo。
3. 把你的新 Repo Clone 到電腦上。
4. 執行重置腳本：`./reset_project.sh`。

### 方法二：直接下載 ZIP

### 第一步：準備環境
請確保你的電腦已經安裝：
1. **Node.js**: [下載安裝](https://nodejs.org/)
2. **Gemini CLI**: 這是 AI 的大腦，請確認已安裝並設定好。

### 第二步：下載專案
```bash
git clone https://github.com/richblack/Mini-TDD-Factory.git
cd Mini-TDD-Factory
```
*(或者直接下載 ZIP 解壓縮)*

### 第三步：開始新專案
我們提供了一個「一鍵重置」指令，幫你把範例清乾淨：
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

### 第六步 (進階)：語言與設計
- **首次啟動時**：`factory.sh` 會問你要用什麼語言 (JS/Python/Go)，選一個你喜歡的即可。AI 會自動處理細節。
- **RFP/design.md**：如果你有特定的技術要求（例如：「請使用 OOP 設計」或「資料庫使用 SQLite」），可以寫在這個檔案裡，AI 會參考它來寫程式。

### 第五步：啟動工廠
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

## 🙏 特別感謝
- **Developer**: Antigravity (Google DeepMind)
- **Model**: Gemini 2.0
- **Concept**: Ralph Wiggum "Verification Driven Development"
