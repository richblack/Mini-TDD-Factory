# MatchGPT - Sprint 2 Requirements: Calibration & Truth

**Sprint 1 Status**: Core API & Agent Loop 已完成。
**Sprint 2 Goal**: 實作「非對稱驗證 (Asymmetric Verification)」與「資料持久化 (Persistence)」。

## 1. Feature: Asymmetric Calibration Service
*   **目標**: 驗證用戶是本人，且沒有 "Game the system"。
*   **邏輯**:
    *   **Step A (Human Track)**: 系統生成 5 題具體情境題 (Contextual Qs)。
    *   **Step B (AI Track)**: 系統生成 5 題抽象價值題 (Abstract Qs) 給 `UserProxy`。
    *   **Step C (Comparison)**: 使用 LLM 比較兩組答案的「內在一致性 (Consistency)」。
*   **API**:
    *   `POST /api/v1/calibration/generate-questions`: 根據 DNA 生成題目。
    *   `POST /api/v1/calibration/verify`: 接收 User Answers，比對 Agent Answers，回傳 Pass/Fail。

## 2. Feature: Differential Diagnosis (Conflict Resolution)
*   **目標**: 當 Input 包含多個來源 (e.g., Gemini JSON + ChatGPT JSON) 時，解決衝突。
*   **邏輯**:
    *   若 user 上傳了 `composite_dna` (包含 source_a, source_b)，系統需找出差異點。
    *   *Simple Version (Sprint 2)*: 若欄位衝突，優先採用 "Gemini" 源作為保守估計 (Hard constraint)，"ChatGPT" 作為社交潤滑 (Soft constraint)。

## 3. Feature: Persistence (PostgreSQL + pgvector)
*   **目標**: 將驗證通過的 User Profile 存入資料庫。
*   **Schema**:
    *   Table `users`: id, dna_payload, is_verified (bool).
    *   Table `embeddings`: user_id, vector (1536 dim).
*   **Action**: 驗證通過後，將最終合成的 DNA 轉為 embedding 並儲存。
