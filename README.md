# 🏭 Mini TDD Factory (迷你 AI 軟體工廠)

> **這是個許願池「只要你能把願望講清楚，AI 就能幫你實現。」**

這是一個讓 AI 自動幫你寫程式、跑測試的開發工廠。
不管你是什麼程度的開發者 (或 Vibe Coder)，這裡只有一個原則：**「把規格寫好，剩下的交給 AI。」**

---

## 🏆 給管理者/助教：如何設定為 Template

如果您希望學員能直接使用這個 Repo 作為專案模板，請執行以下步驟：

1. 將此專案 Push 到 GitHub。
2. 進入 GitHub Repo 頁面，點擊 **Settings** (設定)。
3. 在 General 頁面中，勾選 **Template repository**。
4. 完成！

---

## 📦 如何使用 (給學員的懶人包)

### 方法一：GitHub Template (推薦)
如果助教已經將此 Repo 設為 Template：
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

## � 這是什麼？(自動開發原理)

想像你有一個 **不知疲倦的 AI 實習生**：
1. 你告訴他要做什麼 (寫在需求檔)。
2. 你列出任務清單 (寫在任務檔)。
3. **他會自動幫你寫測試、寫程式、修正錯誤，直到全部完成。**

這就是 **Mini TDD Factory** 的核心精神 —— **TDD (測試驅動開發)** 的自動化。

### ⚙️ 自動修正迴圈 (The Magic Loop)
工廠啟動後，它會進入一個 **「寫測試 -> 寫程式 -> 修正」** 的無限迴圈：
1.  **AI 嘗試寫程式**。
2.  **跑測試**：如果有紅燈 (錯誤)，AI 會看到錯誤訊息。
3.  **自動修正**：AI 會根據錯誤，自己修改程式碼，然後**再跑一次**。
4.  **直到綠燈**：直到所有測試都通過，它才會停下來跟你邀功。
> 簡單說：**它會自己 debug，直到做對為止。**

---

## 🧱 為了便於重構：樂高法 (Lego Method)

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

### 第四步：啟動工廠
在終端機輸入：
```bash
./factory.sh
```
然後你就可以去喝咖啡了。AI 會開始它的 Magic Loop，直到你看見綠燈。
