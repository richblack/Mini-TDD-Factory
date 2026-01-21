package main

import (
	"factory/server"
)

func main() {
	// 設定並取得 Gin 路由器
	router := server.SetupRouter()

	// 啟動伺服器，預設監聽於 0.0.0.0:8080
	// 如果需要，可以傳入參數指定不同的位址，例如 router.Run(":9090")
	router.Run()
}