# Mini TDD Factory v2 (迷你 AI 軟體工廠)

> **這是個許願池「只要你能把願望講清楚，AI 就能幫你實現。」**

- 這是一個讓 AI 自動幫你寫程式、跑測試的開發工廠，很省力。
- 不管你是什麼程度的開發者 (或 Vibe Coder)，這裡只有一個原則：**「把規格寫好，剩下的交給 AI。」**
- 限制 AI 不准寫壞程式，要修改時，因為它寫成樂高積木，每個小檔案很容易抽換。

---

## 版本說明

### v2.0.0 (2026-02-22)

- **支援雙引擎**：Worker AI 可選 Gemini CLI 或 Claude Code，不再綁定單一 AI
- **監工模式 (Supervisor)**：可用另一個 AI 當監工，每輪審查 Worker 回報，有全局觀，能解決 Worker 解不了的問題
- **可指定模型**：Worker 和 Supervisor 可各自指定模型（如 Claude Opus 監工 + Gemini Flash 做事）
- **Git 記憶**：每輪 AI 改動都會 commit，下一輪知道「上輪改了什麼」，不再失憶
- **智慧 Prompt**：根據測試狀態（pass→fail / fail→fail / fail→pass）給不同指令，不再每輪說一樣的話
- **安全閥**：最大輪次(20)、連續失敗偵測(5)、無動作偵測(3)，不會無限燒錢
- **結構化測試分析**：不再全量 dump 錯誤日誌，精準提取失敗資訊
- **每輪回報檔**：`.factory/rounds/round_N.md`，隨時可查「現在做到哪了」
- **預設改為 Python**，移除 JS 殘留
- **修正多處 bug**：設定檔名不一致、reset 腳本遺漏等

### v1.0.0

- 初始版本，使用 Gemini CLI (`gemini --yolo`) 驅動
- 基本的 Ralph Wiggum Loop：跑測試 → AI 修正 → 再跑測試
- 支援 JavaScript / Python / Go
- 樂高模式 (Lego Mode)

---

## 這是什麼？

想像你有一個不知疲倦的 AI 實習生：

1. 你告訴他要做什麼 (寫在需求檔)。
2. 你列出任務清單 (寫在任務檔)。
3. **他會自動幫你寫測試、寫程式、修正錯誤，直到全部完成。**

這就是 **Mini TDD Factory** 的核心精神 —— **TDD (測試驅動開發)** 的自動化。

### 為什麼會有這個工具？

AI 開發工具（如 Claude Code）最早就支援「完全不問就自己跑」的自動執行模式。但當時 Gemini CLI 還做不到這件事，所以我們開發了這個工廠，用 shell script 迴圈 + `gemini --yolo` 來達到同樣效果。

現在 v2 直接支援兩種 AI 引擎，你可以根據成本、速度和偏好自由選擇。

---

## 快速開始

### 第一步：準備環境

1. **Python 3**: [下載安裝](https://www.python.org/downloads/)
2. **AI 引擎** (至少裝一個)：
   - [Gemini CLI](https://github.com/google-gemini/gemini-cli) — `npm install -g @anthropic/gemini-cli` 或參考官方文件
   - [Claude Code](https://docs.anthropic.com/en/docs/claude-code) — `npm install -g @anthropic/claude-code`
3. **Git**: 需要 git 來追蹤每輪的改動

### 第二步：取得專案

```bash
# 方法 A：使用 Template (推薦)
# 點擊 GitHub 頁面上方的 "Use this template" 按鈕

# 方法 B：直接 clone
git clone https://github.com/richblack/Mini-TDD-Factory.git
cd Mini-TDD-Factory
```

### 第三步：初始化 (如果要開始新專案)

```bash
./reset_project.sh
```

### 第四步：許願 (你最重要的工作)

編輯兩個檔案：

1. **`RFP/requirements.md`**：用中文寫下你要做的軟體功能
2. **`RFP/tasks.md`**：把大目標拆成小步驟

進階使用者可以編輯 `RFP/design.md` 指定技術架構。

### 第五步：啟動工廠

```bash
./factory.sh
```

首次執行會詢問開發語言、AI 引擎和監工設定。
然後你就可以去喝咖啡了。

工廠會在以下情況自動停機：
- 所有測試通過且任務完成
- 達到最大輪次 (預設 20 輪)
- 連續失敗超過 5 輪
- AI 連續 3 輪沒有修改任何檔案

---

## AI 引擎與監工

### Worker + Supervisor 任意組合

你可以自由組合 Worker（做事的）和 Supervisor（監工的）：

| 組合 | 適合場景 |
|------|---------|
| Gemini Worker + 無監工 | 最便宜，簡單任務 |
| Gemini Worker + Claude 監工 | 推薦：便宜做事 + 聰明監工 |
| Claude Worker + 無監工 | 高品質，中等任務 |
| Claude Worker + Gemini 監工 | 高品質做事 + 便宜監工 |

### 監工怎麼運作？

```
你 (人類)
  │ 隨時可查 .factory/latest_report.md
  ▼
監工 AI (Supervisor)
  │ 每輪讀 Worker 回報
  │ 決定: CONTINUE / REDIRECT / INTERVENE / ESCALATE
  ▼
工人 AI (Worker)
  │ 每輪寫程式 → 跑測試 → 寫回報
  ▼
.factory/rounds/round_N.md (每輪狀態檔)
```

監工每輪會做出判斷：
- **CONTINUE**：Worker 方向正確，繼續
- **REDIRECT**：Worker 卡住了，給它新指示
- **INTERVENE**：監工直接介入修正程式碼
- **ESCALATE**：問題超出 AI 能力，暫停等你來看

你不在的時候，監工自動運作。你想知道進度時，打開 `.factory/latest_report.md` 就能看到最新狀態。

### 指定模型

在 `factory_config.md` 中可以指定具體模型：

```
WORKER_MODEL=gemini-2.5-flash
SUPERVISOR_MODEL=opus
```

---

## 設定

編輯 `factory_config.md` 可以調整：

| 設定 | 說明 | 預設值 |
|------|------|--------|
| LANGUAGE | 開發語言 | python |
| AI_ENGINE | Worker 引擎 (gemini/claude) | gemini |
| WORKER_MODEL | Worker 模型 | (引擎預設) |
| SUPERVISOR | 監工引擎 (none/claude/gemini) | none |
| SUPERVISOR_MODEL | 監工模型 | (引擎預設) |
| MODE | Single (全自動) / Dual (失敗時暫停) | Dual |
| LEGO_MODE | 樂高法嚴格規範 | true |
| TEST_CMD | 自定義測試指令 | (自動偵測) |

---

## 自動開發及受限的樂高式開發

身為與 AI 合作的開發者，想解決 2 個問題：
- **自動開發**：你希望 AI 幫你寫程式，但它每個動作都問你，變成你陪它開發。
- **樂高式開發**：AI 剛開始寫程式很快，但找錯、修改卻很慢，功能越多越容易出錯。

### 自動開發原理：The Ralph Wiggum Loop

這裡採用的核心機制稱為 **The Ralph Wiggum Loop** (致敬 *The Simpsons* 中鍥而不捨的角色 Ralph)：

> **"I'm helping!" - Ralph Wiggum**

這個概念由 Geoffrey Huntley 提出，核心精神是 **「外部驗證驅動 (External Verification Driven)」**。
我們不相信 AI 說的「我做好了」，我們只相信「測試通過」。

工廠啟動後，會進入一個迴圈：
1. **AI 嘗試寫程式**。
2. **跑測試**：如果有紅燈 (錯誤)，AI 會看到錯誤訊息。
3. **自動修正**：AI 會根據錯誤，自己修改程式碼，然後再跑一次。
4. **直到綠燈**：直到所有測試都通過，它才會停下來。

v2 的改進是讓 AI 不再「失憶」— 每輪都知道上輪做了什麼（透過 git diff），而且根據狀態切換策略，不會傻傻重複一樣的錯。

### 什麼是樂高式開發

為了讓 AI 更好改程式，我們導入了「樂高化」的結構。
如果你選擇用它 (`LEGO_MODE=true`)，AI 會嚴格遵守以下原則：

* **壞了就換**：每個功能都是獨立的小積木。壞了直接刪掉叫 AI 重寫一個。
* **一檔一事**：每個檔案只做一件事，絕對不超過 100 行。
* **超級解耦**：A 積木壞了，絕對不會影響到 B 積木。

```text
/
├── contracts/  # 說明書：定義資料長怎樣 (Schema)
├── tests/      # 測試儀：驗證積木是好的 (Tests)
├── actions/    # 積木區：核心邏輯，壞了直接丟掉重寫 (Logic)
└── entry/      # 接頭：API 或是 CLI 指令 (Entry Points)
```

---

## 常見問題

**Q: 工廠跑的時候，我怎麼知道進度？**
A: 打開 `.factory/latest_report.md` 就能看到最新一輪的狀態。完整歷史在 `.factory/history.md`。如果有設監工，監工的判斷記錄在 `.factory/supervisor_log.txt`。

**Q: 工廠卡住怎麼辦？**
A: 按 `Ctrl + C` 停止，檢查 `.factory/history.md` 看過去每輪做了什麼，調整需求後重新執行。

**Q: 我需要自己寫測試嗎？**
A: 不需要！AI 會根據你的需求自動產生 Gherkin 測試 (BDD)。

**Q: 支援哪些語言？**
A: 預設 Python，也支援 JavaScript、Go，以及任何你能指定測試指令的語言。

**Q: Gemini 和 Claude 哪個比較好？**
A: 看用途。Gemini Flash 便宜適合做事，Claude Opus 適合當監工做品質把關。你可以自由組合。

---

## 特別感謝

- **Concept**: Geoffrey Huntley "Ralph Wiggum Loop" (Verification Driven Development)
- **Developer**: Antigravity (Google DeepMind)
- **AI Engines**: Gemini CLI, Claude Code
- **Framework**: Cucumber / Behave (BDD)
