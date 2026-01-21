package server

import (
	"bytes"
	"encoding/json"
	"io"
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
)

// SetupRouter 配置 Gin 路由器並定義所有 API 端點。
func SetupRouter() *gin.Engine {
	// 關閉 Gin 的調試模式輸出，讓日誌更乾淨
	gin.SetMode(gin.ReleaseMode)
	router := gin.Default()

	// 健康檢查端點
	router.GET("/health", func(c *gin.Context) {
		c.String(http.StatusOK, "OK")
	})

	// API v1 路由群組
	v1 := router.Group("/api/v1")
	{
		v1.POST("/persona/ingest", personaIngestHandler)
		v1.POST("/calibration/generate-questions", generateCalibrationQuestions)
	}

	return router
}

// personaIngestHandler 處理 Persona DNA 的傳入請求。
func personaIngestHandler(c *gin.Context) {
	var dna map[string]interface{}

	// 讀取請求內文
	bodyBytes, err := io.ReadAll(c.Request.Body)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "無法讀取請求內文"})
		return
	}
	// 重設請求內文，以防後續需要再次讀取
	c.Request.Body = io.NopCloser(bytes.NewBuffer(bodyBytes))

	// 檢查 JSON 格式是否正確
	if err := json.Unmarshal(bodyBytes, &dna); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "無效的 JSON 格式"})
		return
	}

	// 檢查 PII (個人身份資訊)
	jsonString := string(bodyBytes)
	if strings.Contains(jsonString, `"email"`) || strings.Contains(jsonString, `"phone"`) {
		c.JSON(http.StatusBadRequest, gin.H{"error": "偵測到 PII (個人身份資訊)"})
		return
	}

	// 檢查必填欄位
	if _, ok := dna["core_identity"]; !ok {
		c.JSON(http.StatusBadRequest, gin.H{"error": "缺少 core_identity 欄位"})
		return
	}
	if _, ok := dna["values_and_beliefs"]; !ok {
		c.JSON(http.StatusBadRequest, gin.H{"error": "缺少 values_and_beliefs 欄位"})
		return
	}

	// 所有驗證通過，回傳成功訊息與一個模擬的 persona_id
	c.JSON(http.StatusOK, gin.H{"persona_id": "dummy-persona-id"})
}