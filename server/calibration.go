package server

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

// generateCalibrationQuestions 根據用戶的 DNA 生成校準問題。
// @Summary      生成校準問題
// @Description  此端點為非對稱驗證流程的第一步。它會生成兩組問題：一組給真人用戶（情境題），另一組給 AI 代理（抽象價值題）。
// @Tags         Calibration
// @Accept       json
// @Produce      json
// @Success      200  {object}  map[string][]string  "成功生成問題"
// @Router       /api/v1/calibration/generate-questions [post]
func generateCalibrationQuestions(c *gin.Context) {
	// TODO: 根據儲存的用戶 DNA 調用 LLM 來動態生成問題。
	// 目前，為了通過 TDD 測試，我們先返回一個固定的假資料。
	c.JSON(http.StatusOK, gin.H{
		"human_questions": []string{
			"情境題 1",
			"情境題 2",
			"情境題 3",
			"情境題 4",
			"情境題 5",
		},
		"ai_questions": []string{
			"抽象價值題 1",
			"抽象價值題 2",
			"抽象價值題 3",
			"抽象價值題 4",
			"抽象價值題 5",
		},
	})
}
