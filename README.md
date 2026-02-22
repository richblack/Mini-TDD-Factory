# Mini TDD Factory v2 (迷你 AI 軟體工廠)

> **許願池：你負責許願，AI 負責實現。**

你不需要很會寫程式。你只需要：
1. 用中文寫下你想做什麼
2. 列出步驟
3. 按下啟動，去喝咖啡

AI 會自動幫你寫程式、跑測試、修 bug，直到全部搞定。

---

## 快速開始 (5 分鐘)

### 準備

- [Python 3](https://www.python.org/downloads/)
- [Gemini CLI](https://github.com/google-gemini/gemini-cli) 或 [Claude Code](https://docs.anthropic.com/en/docs/claude-code) (至少裝一個)
- Git

### 開始

```bash
# 1. 取得專案 (或用 GitHub 上方的 "Use this template" 按鈕)
git clone https://github.com/richblack/Mini-TDD-Factory.git
cd Mini-TDD-Factory

# 2. 如果要做新專案，先重置
./reset_project.sh

# 3. 許願：編輯這兩個檔案
#    RFP/requirements.md  ← 寫你要做什麼
#    RFP/tasks.md          ← 把目標拆成小步驟

# 4. 啟動工廠 (首次會問你選什麼語言和 AI)
./factory.sh
```

就這樣！工廠會自己跑，全部完成或遇到問題會自動停下來。

---

## 想知道現在做到哪了？

工廠預設會有一個 AI 監工 (Claude Code) 幫你盯著。它每輪都會看 Worker 做了什麼，方向不對會自動糾正，真的搞不定才會停下來通知你。

你不用看 log，想知道進度隨時打開 `.factory/latest_report.md` 就好。

> 不想要監工？在 `factory_config.md` 把 `SUPERVISOR=claude` 改成 `SUPERVISOR=none`。
> 詳見[技術文件](docs/technical.md#監工模式)。

---

## 設定

編輯 `factory_config.md`：

| 設定 | 說明 | 預設值 |
|------|------|--------|
| LANGUAGE | 開發語言 | python |
| AI_ENGINE | 做事的 AI (gemini/claude) | gemini |
| SUPERVISOR | 監工 AI (claude/gemini/none) | claude |
| MODE | Single (全自動) / Dual (失敗暫停) | Dual |
| LEGO_MODE | 樂高法規範 | true |

更多設定說明請見[技術文件](docs/technical.md#設定詳解)。

---

## 常見問題

**工廠卡住了？** → `Ctrl + C` 停止，看 `.factory/history.md`，調整需求後重跑。

**我需要自己寫測試嗎？** → 不用，AI 會自動產生。

**支援什麼語言？** → 預設 Python，也支援 JavaScript、Go，或任何你能指定測試指令的語言。

**Gemini 和 Claude 哪個好？** → 都可以，也可以混著用。詳見[技術文件](docs/technical.md#ai-引擎與監工)。

---

## 版本

目前版本：**v2.0.0** (2026-02-22)

主要改進：支援雙 AI 引擎、監工模式、Git 記憶、安全閥。

完整版本紀錄請見 [CHANGELOG.md](CHANGELOG.md)。

---

## 特別感謝

- **Concept**: Geoffrey Huntley — "Ralph Wiggum Loop" (Verification Driven Development)
- **Developer**: Antigravity (Google DeepMind)
- **v2 Refactor**: Claude Code (Anthropic Claude Opus)
- **AI Engines**: Gemini CLI, Claude Code
- **Framework**: Cucumber / Behave (BDD)
