# AI 開發規範：樂高法 (Lego Methodology)

本專案採用「樂高化」開發模式，旨在實現極致的解耦與重構友善性 (Refactor-Ready)。
請所有協作的 AI Agent 與開發者嚴格遵守以下準則。

## 1. 核心哲學：壞了就換 (Disposable Components)

我們不維護臃腫的程式碼。如果一個組件 (Action) 變得難以理解或充滿 Bug，請直接**刪除並重寫**，而不是試圖修補它。
因為每個組件都很小，重寫的成本極低。

## 2. 硬性限制 (Strict Constraints)

-   **檔案長度**：`actions/` 目錄下的檔案**嚴禁超過 100 行**。建議保持在 50-80 行之間。
-   **一檔一事**：每個檔案只做一件具體的事情。
-   **無狀態 (Stateless)**：Action 不應保存內存狀態，所有狀態必須持久化到資料庫或透過參數傳遞。

## 3. 開發流程 (Workflow)

任何功能的開發必須遵循以下順序：

1.  **Contracts First**: 在 `/contracts` 定義清晰的輸入/輸出資料結構 (Schema)。
2.  **Tests Second**: 在 `/tests` 撰寫測試案例，定義預期行為 (TDD)。
3.  **Actions Last**: 在 `/actions` 實作邏輯以通過測試。

## 4. 目錄結構職責

| 目錄 | 職責 | 規則 |
| :--- | :--- | :--- |
| `/contracts` | 定義資料契約 | 使用 JSON Schema 或 Pydantic Model。 |
| `/actions` | 核心業務邏輯 | 純函數為主，無副作用為佳。**< 100 Lines**。 |
| `/entry` | 程式進入點 | 如 API Handler, CLI Command。**不含業務邏輯**，僅呼叫 Actions。 |
| `/tests` | 自動化測試 | 必須覆蓋所有 Action。 |

## 5. 給 AI 的指令

當你被要求實作功能時：
- 不要把所有邏輯塞進一個檔案。
- 如果發現檔案變大，主動拆分出新的 Action。
- 永遠確保測試通過才算完成。
