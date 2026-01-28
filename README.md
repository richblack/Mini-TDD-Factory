# 🏭 Mini TDD Factory (迷你 AI 軟體工廠)

> **這是個許願池「只要你能把願望講清楚，AI 就能幫你實現。」**

- 這是一個讓 AI 自動幫你寫程式、跑測試的開發工廠，很省力。
- 不管你是什麼程度的開發者 (或 Vibe Coder)，這裡只有一個原則：**「把規格寫好，剩下的交給 AI。」**
- 限制 AI 不准寫壞程式，要修改時，因為它寫成樂高積木，每個小檔案很容易抽換。

---

## 📦 如何使用 (懶人包)

### 方法一：GitHub Template (推薦)

1. 在 GitHub 頁面點擊綠色的 **"Use this template"** 按鈕。
2. 選擇 **"Create a new repository"**。
3. 把你新建立的 Repo Clone 到電腦上。
4. 執行重置腳本：`./reset_project.sh`。

### 方法二：直接下載
如果不使用 GitHub Template：
```bash
git clone https://github.com/richblack/Mini-TDD-Factory.git
cd Mini-TDD-Factory
./reset_project.sh
```

---

## 自動開發及受限的樂高式開發

身為與 AI 合作的開發者，想解決 2 個問題：
- **自動開發**：你希望 AI 幫你寫程式，但它每個動作都問你，變成你陪它開發。
- **樂高式開發**：AI 剛開始寫程式很快，但找錯、修改卻很慢，功能越多越容易出錯。

### 自動開發是什麼？

想像你有一個 **不知疲倦的 AI 實習生**：
1. 你告訴他要做什麼 (寫在需求檔)。
2. 你列出任務清單 (寫在任務檔)。
3. **他會自動幫你寫測試、寫程式、修正錯誤，直到全部完成。**

這就是 **Mini TDD Factory** 的核心精神 —— **TDD (測試驅動開發)** 的自動化。

### 什麼是樂高式開發

為了讓 AI 更好改程式，我們導入了「樂高化」的結構。
如果你選擇用它 (`LEGO_MODE=true`)，AI 會嚴格遵守以下原則，這對 AI 特別友善：

*   **壞了就換**：每個功能都是獨立的小積木。如果一個積木寫爛了，直接刪掉叫 AI 重寫一個，三秒鐘的事。
*   **一檔一事**：每個檔案只做一件事，絕對不超過 100 行。
*   **超級解耦**：A 積木壞了，絕對不會影響到 B 積木。

```text
/
├── contracts/  # 📜 說明書：定義資料長怎樣 (Schema)
├── tests/      # 🧪 測試儀：驗證積木是好的 (Tests)
├── actions/    # 🧱 積木區：核心邏輯，壞了直接丟掉重寫 (Logic)
└── entry/      # 🔌 接頭：API 或是 CLI 指令 (Entry Points)
```

---

## 🛠 開始製作你的第一個功能

### 第一步：安裝環境
確保你有 Python 3，然後安裝必要套件：
```bash
pip install -r requirements.txt
```

### 第二步：檢查設定
打開 `factory_config.md`，確認這兩行是對的：
```markdown
LANGUAGE=python
LEGO_MODE=true
```

### 第三步：許願 (Make a Wish)
你只需要編輯這兩個檔案 (用中文寫)：
1.  **`RFP/requirements.md` (需求書)**：
    寫下你想做什麼。
    > *例：「我要做一個匯率轉換器，輸入台幣顯示美金...」*
2.  **`RFP/tasks.md` (任務單)**：
    把大目標切成小步驟，打勾勾給 AI 看。
    > - [ ] 取得目前匯率
    > - [ ] 實作轉換計算

> 需求規格參考 SDD (Spec Drive Development)，用 Epic, User Story, EARS, Design, Tasks 組成，把需求告訴 AI 要它產生即可，我們不細說。

### 第四步：啟動工廠
在終端機輸入：
```bash
./factory.sh
```
然後你就可以去喝咖啡了。AI 會開始它的 Magic Loop，直到你看見綠燈。

---

## 如果有興趣理解更多

按照前面說明你應該可以開始了，如果想理解更多，請看以下說明。

### 自動開發

這裡採用的是 **The Magic Loop (自動修正迴圈)** 機制：
工廠啟動後，它會進入一個 **「寫測試 -> 寫程式 -> 修正」** 的無限迴圈：

1.  **AI 嘗試寫程式**。
2.  **跑測試**：如果有紅燈 (錯誤)，AI 會看到錯誤訊息。
3.  **自動修正**：AI 會根據錯誤，自己修改程式碼，然後**再跑一次**。
4.  **直到綠燈**：直到所有測試都通過，它才會停下來跟你邀功。
> 簡單說：**它會自己 debug，直到做對為止。**

### 樂高式開發

為了實踐 **「解耦重構 (Refactor-Ready)」**，我們在 [`course/lego.md`](course/lego.md) 中定義了更詳細的規範：

1.  **原則一 (小)**：禁止寫任何超過 100 行的檔案。
2.  **原則二 (序)**：先定義資料 (`contracts`)，再寫測試 (`tests`)，最後才實作 (`actions`)。
3.  **原則三 (淨)**：程式碼必須是「無狀態 (Stateless)」的。
4.  **原則四 (換)**：只要測試不通過，該積木就視為失敗，直接重寫比除錯快。

這樣做的好處是，我們不再維護龐大的原始碼，而是維護「需求」與「積木」。

---

## 🙏 特別感謝
- **Developer**: Antigravity (Google DeepMind)
- **Model**: Gemini 2.0
- **Concept**: Ralph Wiggum "Verification Driven Development"
