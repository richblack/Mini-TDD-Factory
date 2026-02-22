# 技術文件

這份文件說明 Mini TDD Factory 的運作原理和進階設定。
如果你只是想用，看 [README](../README.md) 就夠了。

---

## 自動開發原理：The Ralph Wiggum Loop

核心機制叫做 **The Ralph Wiggum Loop** (致敬 *The Simpsons* 中鍥而不捨的角色 Ralph)：

> **"I'm helping!" - Ralph Wiggum**

這個概念由 Geoffrey Huntley 提出，核心精神是 **「外部驗證驅動 (External Verification Driven)」**。
我們不相信 AI 說的「我做好了」，我們只相信「測試通過」。

工廠啟動後，會進入一個迴圈：
1. **AI 嘗試寫程式**
2. **跑測試**：如果有紅燈 (錯誤)，AI 會看到錯誤訊息
3. **自動修正**：AI 根據錯誤修改程式碼，再跑一次
4. **直到綠燈**：所有測試都通過才停下來

### v2 的改進

- **Git 記憶**：每輪 AI 改動都會 commit，下一輪收到「你上輪改了什麼」的 diff，不再失憶
- **智慧 Prompt**：根據測試狀態切換策略
  - pass→fail：「你上輪搞壞了，revert 或修正」
  - fail→fail (連續)：「停下來，換個策略」
  - fail→pass：「修好了，推進下一個任務」
- **安全閥**：不會無限跑
  - 最大輪次：20 輪
  - 連續失敗上限：5 輪
  - 無動作偵測：3 輪沒改檔案就停機

---

## 樂高式開發

為什麼要用樂高法？因為 **AI 寫程式很快，但維護很爛**。

當專案變大時，AI 往往會改 A 壞 B，因為程式碼之間「牽一髮動全身」。
樂高式開發的核心就是 **解耦**：

- **壞了就換**：每個功能都是獨立的小積木。壞了直接刪掉叫 AI 重寫一個。
- **一檔一事**：每個檔案只做一件事，絕對不超過 100 行。
- **超級解耦**：A 積木壞了，絕對不會影響到 B 積木。

```text
/
├── contracts/  # 說明書：定義資料長怎樣 (Schema)
├── tests/      # 測試儀：驗證積木是好的 (Tests)
├── actions/    # 積木區：核心邏輯，壞了直接丟掉重寫 (Logic)
└── entry/      # 接頭：API 或是 CLI 指令 (Entry Points)
```

設定 `LEGO_MODE=true` 啟用（預設開啟）。

---

## AI 引擎與監工

### 支援的 AI 引擎

| 引擎 | Worker 指令 | Supervisor 指令 |
|------|------------|----------------|
| Gemini CLI | `gemini --yolo "prompt"` | `gemini --output-format json -p "prompt"` |
| Claude Code | `claude -p "prompt" --dangerously-skip-permissions` | `claude -p "prompt" --output-format json` |

### Worker + Supervisor 任意組合

你可以自由組合做事的 (Worker) 和監工的 (Supervisor)：

| 組合 | 適合場景 |
|------|---------|
| Gemini Worker + 無監工 | 最便宜，簡單任務 |
| Gemini Worker + Claude 監工 | 推薦：便宜做事 + 聰明監工 |
| Claude Worker + 無監工 | 高品質，中等任務 |
| Claude Worker + Gemini 監工 | 高品質做事 + 便宜監工 |

### 監工模式

監工是另一個 AI，它每輪都會讀 Worker 的回報，用全局視野做出判斷：

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

監工每輪會做出四種判斷之一：

| 判斷 | 意思 |
|------|------|
| **CONTINUE** | Worker 方向正確，讓它繼續 |
| **REDIRECT** | Worker 卡住或方向錯，給它新指示 |
| **INTERVENE** | 問題太大，監工直接下場修程式碼 |
| **ESCALATE** | 監工也解決不了，暫停等人類介入 |

監工的判斷記錄在 `.factory/supervisor_log.txt`。

### 指定模型

在 `factory_config.md` 中可以指定 Worker 和 Supervisor 各自使用的模型：

```
WORKER_MODEL=gemini-2.5-flash
SUPERVISOR_MODEL=opus
```

留空則使用各引擎的預設模型。

---

## 設定詳解

編輯 `factory_config.md` 可以調整以下設定：

| 設定 | 說明 | 預設值 | 選項 |
|------|------|--------|------|
| SCOPE | 開發範圍 | All | All / Specific |
| LANGUAGE | 開發語言 | python | python / javascript / go / 自定義 |
| AI_ENGINE | Worker AI 引擎 | gemini | gemini / claude |
| WORKER_MODEL | Worker 使用的模型 | (引擎預設) | 見各引擎文件 |
| SUPERVISOR_MODEL | 監工使用的模型 | (引擎預設) | 見各引擎文件 |
| SUPERVISOR | 監工引擎 | claude | claude / gemini / none |
| MODE | 工作模式 | Dual | Single (全自動) / Dual (失敗時暫停) |
| LEGO_MODE | 樂高法規範 | true | true / false |
| TEST_CMD | 自定義測試指令 | (自動偵測) | 任意 shell 指令 |

### 自定義測試指令

如果你的專案不是用 behave / cucumber / godog，可以設定 `TEST_CMD`：

```
TEST_CMD=npx vitest
TEST_CMD=cargo test
TEST_CMD=pytest
```

---

## 檔案結構

```text
Mini-TDD-Factory/
├── factory.sh              # 工廠主程式
├── factory_config.md       # 設定檔
├── reset_project.sh        # 重置腳本
├── RFP/                    # 你的需求文件
│   ├── requirements.md     # 需求規格
│   ├── design.md           # 系統設計 (選填)
│   └── tasks.md            # 任務列表
├── .factory/               # 工廠運行時產生 (不進 git)
│   ├── history.md          # 完整歷史
│   ├── latest_report.md    # 最新一輪回報
│   ├── supervisor_log.txt  # 監工判斷記錄
│   └── rounds/             # 每輪回報
├── features/               # BDD 測試
│   └── steps/              # Step definitions
├── actions/                # 核心邏輯 (樂高積木)
├── contracts/              # 資料 Schema
├── tests/                  # 單元測試
└── entry/                  # 進入點 (API/CLI)
```
