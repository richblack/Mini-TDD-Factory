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

## 🆕 2026.01 新增功能
*   **Gemini 自動檢查**: 再也不用怕跑到一半發現沒裝 CLI。
*   **Dual AI Mode (Supervisor 模式)**: 讓人類監控者隨時插手，解決 AI 鬼打牆的問題。

---

## 📦 如何使用 (懶人包)

### 第一步：準備環境 (必做)
請確保你的電腦已經安裝：
1. **Node.js**: [下載安裝](https://nodejs.org/)
2. **Gemini CLI**: 這是 AI 的大腦，請確認已安裝並設定好。

### 第二步：取得專案 (二選一)
**(略：同原版 README)**

### 第三步：設定模式
編輯 `factory_config.txt`：
```text
SCOPE=All
LANGUAGE=go
MODE=Dual
```
*   `MODE=Dual`: **Supervisor 模式**。這是為了配合 **Agentic IDE (如 Cursor, Windsurf, Gemini Code Assist)** 設計的。
    *   **角色分配**: `factory.sh` 裡的 Gemini 是 **Worker** (埋頭苦幹)。IDE 裡的 AI (或人類) 是 **Supervisor** (負責決策)。
    *   **機制**: 測試失敗時，工廠會暫停。這時 Supervisor (你或是你的 IDE Agent) 可以檢查代碼、給予 Worker 新提示，或直接修復，然後按 Enter 繼續。
*   `MODE=Single`: (預設) **YOLO 模式**。工廠會無限重試直到成功，適合去睡覺時掛機。

### 第四步：許願 (這是你最重要的工作)
編輯 `RFP/requirements.md` (需求) 和 `RFP/tasks.md` (任務)。

### 第五步：選擇語言 (首次啟動)
支援 **JavaScript**, **Python**, **Go**，以及 **通用模式 (Universal Mode)**。

### 第六步：啟動工廠
```bash
./factory.sh
```

---

## ❓ 常見問題

**Q: 工廠卡住了怎麼辦？**
A: 按 `Ctrl + C` 停止。如果你開啟了 `MODE=Dual`，它會在失敗時自動暫停等你指令。

**Q: 這是用什麼做的？**
A: 核心是 `cucumber-js` (測試框架) 加上 `gemini` (AI 模型)，透過 Shell Script 串接起來的自動化迴圈。

---

## 🙏 特別感謝
- **Developer**: Antigravity (Google DeepMind)
- **Model**: Gemini 2.0
- **Concept**: Ralph Wiggum "Verification Driven Development"
