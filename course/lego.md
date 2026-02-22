# Lego 說明

「我要把這個專案改為「樂高化」的 GitHub 專案模板。這個模板的目的是為了實踐『解耦重構（Refactor-Ready）』的開發規範。

這個想法來自於「開發時就考慮重構」，因為 vibe coder 並不知道 AI 幫他做了什麼，如果很多事情沒有定義，會是未來的技術債，由於 AI 重構速度很快，所以我教他們「保留需求而不是原始碼」，他們要跟 AI 合作精密的需求文件，但他們不會理解如何讓程式解耦、原子化這件事，所以讓 Gemini CLI, Antigravity, Claude Code 幫他們開發時會自己知道「我要讓程式樂高化」。

這樣的好處是，它不會寫出 2000 行的 main.py，而是會把每個 function 拆開，未來發現要修改，直接把那個檔案整個換掉就好。

下面是 Gemini 寫的，請幫我完成以下結構與文件的初始化，但這個模板原本的功能是 TDD 自動開發工廠，要結合起來，所以你給我一個想法不一定完全按照它的說法，原本模板是用來用 Gherkin TDD 開發，內含 SDD, BDD 文件，而現在要加上對 AI Agent 的規範：

1. 建立標準資料夾結構：

/contracts：存放資料結構定義（JSON Schema 或 Pydantic Models）。

/actions：存放核心業務邏輯，實行『一檔一事』，每個檔案禁止超過 80 行。

/entry：存放進入點（如 API 路由、CLI 指令），不寫業務邏輯，僅呼叫 actions。

/tests：存放自動化測試，每個 action 必須配對一個 test。

2. 建立核心規範文件： 請在根目錄建立一個 .cursorrules（或 .clauderc）以及一個 AI_RULES.md，內容必須包含以下『樂高法』行為準則：

原則一： 禁止寫任何超過 100 行的檔案。如果邏輯太複雜，必須拆分成多個 action。

原則二： 必須先在 /contracts 定義輸入輸出，並在 /tests 寫好測試，最後才去 /actions 實作邏輯。

原則三： 程式碼必須是『無狀態（Stateless）』的，所有的資料記憶必須存儲於外部資料庫。

原則四： 只要測試不通過，該零件（Action）就是失敗的，必須重寫。

3. 建立範例零件： 請幫我寫一個簡單的 hello-world 範例，包含：

/contracts/user_schema.json

/actions/greet_user.py

/tests/test_greet_user.py

最後，請幫我寫一份 README.md，用白話文告訴學生：『這是你的保命招式，壞了就換，不用修。』」