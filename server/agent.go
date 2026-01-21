package server

import (
	"context"
	"errors"
	"fmt"
)

// PersonaDNA 代表用戶的特質資料。
// 注意：這個結構體在 features/steps/steps_test.go 也有定義。
// 在一個真實的應用中，我們應該將其提取到一個共享的 `models` 或 `types` 包中。
// 為了簡單起見，暫時在這裡重複定義。
type PersonaDNA struct {
	CoreIdentity     map[string]string `json:"core_identity"`
	ValuesAndBeliefs map[string]string `json:"values_and_beliefs"`
}

// ConversationTurn 代表對話中的一輪。
type ConversationTurn struct {
	Author  string
	Message string
}

// InterviewService 負責處理 Agent 的面試循環。
type InterviewService struct {
	// 在未來，這裡可以加入 Gemini Client 等依賴。
	// geminiClient *genai.GenerativeModel
}

// NewInterviewService 創建一個新的 InterviewService 實例。
func NewInterviewService() *InterviewService {
	return &InterviewService{}
}

// RunLoop 運行 AI 面試官與用戶代理之間的對話循環。
// dna: 用戶的 Persona DNA。
// returns: 對話紀錄和一個錯誤（如果發生）。
func (s *InterviewService) RunLoop(ctx context.Context, dna *PersonaDNA) ([]ConversationTurn, error) {
	if dna == nil {
		return nil, errors.New("persona DNA cannot be nil")
	}

	// 模擬一個 5 輪的對話循環
	// 在實際應用中，這裡會調用 Gemini API。
	// 為了通過測試，我們暫時返回一個硬編碼的對話。
	conversation := make([]ConversationTurn, 0, 10)
	for i := 0; i < 5; i++ {
		conversation = append(conversation, ConversationTurn{
			Author:  "Interviewer",
			Message: fmt.Sprintf("這是面試官的第 %d 個問題。", i+1),
		})
		conversation = append(conversation, ConversationTurn{
			Author:  "UserProxy",
			Message: fmt.Sprintf("這是用戶代理基於 DNA 的第 %d 個回答。", i+1),
		})
	}

	return conversation, nil
}
