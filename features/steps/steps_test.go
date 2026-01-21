package steps

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"factory/server" // 引用主要的 server 設定

	"github.com/cucumber/godog"
	"github.com/gin-gonic/gin"
)

// --- 新增的結構定義 ---

// PersonaDNA 代表用戶的特質資料。
type PersonaDNA struct {
	CoreIdentity      map[string]string `json:"core_identity"`
	ValuesAndBeliefs  map[string]string `json:"values_and_beliefs"`
}

// ConversationTurn 代表對話中的一輪。
type ConversationTurn struct {
	Author  string
	Message string
}

// --- 更新的 testContext ---

// testContext 儲存步驟之間共享的狀態
type testContext struct {
	// API 測試相關
	router      *gin.Engine
	resp        *httptest.ResponseRecorder
	requestBody string

	// Agent Loop 測試相關
	dna          *PersonaDNA
	conversation []ConversationTurn
	lastError    error
}


// --- Step Implementations ---

// Generic Steps
func (tc *testContext) iSendAGETRequestTo(path string) error {
	req, err := http.NewRequestWithContext(context.Background(), http.MethodGet, path, nil)
	if err != nil {
		return fmt.Errorf("failed to create request: %w", err)
	}
	tc.resp = httptest.NewRecorder()
	tc.router.ServeHTTP(tc.resp, req)
	return nil
}

func (tc *testContext) theResponseCodeShouldBe(statusCode int) error {
	if tc.resp.Code != statusCode {
		bodyBytes, _ := io.ReadAll(tc.resp.Body)
		return fmt.Errorf("expected status code %d, but got %d. Response body: %s", statusCode, tc.resp.Code, string(bodyBytes))
	}
	return nil
}

func (tc *testContext) theResponseContentShouldBe(content string) error {
	body, err := io.ReadAll(tc.resp.Body)
	if err != nil {
		return fmt.Errorf("failed to read response body: %w", err)
	}
	if strings.TrimSpace(string(body)) != content {
		return fmt.Errorf("expected response content \"%s\", but got \"%s\"", content, strings.TrimSpace(string(body)))
	}
	return nil
}

func (tc *testContext) iHaveAPersonaDNAJSONRequest(requestBody *godog.DocString) error {
	tc.requestBody = requestBody.Content
	return nil
}

func (tc *testContext) iSendAPOSTRequestToWithThatJSON(path string) error {
	req, err := http.NewRequestWithContext(
		context.Background(),
		http.MethodPost,
		path,
		strings.NewReader(tc.requestBody),
	)
	if err != nil {
		return fmt.Errorf("failed to create request: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")

	tc.resp = httptest.NewRecorder()
	tc.router.ServeHTTP(tc.resp, req)
	return nil
}

func (tc *testContext) theResponseContains(content string) error {
	body, err := io.ReadAll(tc.resp.Body)
	if err != nil {
		return fmt.Errorf("failed to read response body: %w", err)
	}
	if strings.Contains(content, "persona_id") {
		var actual map[string]interface{}
		if e := json.Unmarshal(body, &actual); e != nil {
			return fmt.Errorf("failed to unmarshal actual JSON response: %s", string(body))
		}
		if _, ok := actual["persona_id"]; !ok {
			return fmt.Errorf("expected response to contain 'persona_id', but it was not found. Actual: %s", string(body))
		}
	} else if !strings.Contains(string(body), content) {
		return fmt.Errorf("expected response body to contain \"%s\", but got \"%s\"", content, strings.TrimSpace(string(body)))
	}
	return nil
}


// Agent Loop Steps
func (tc *testContext) aDefinedPersonaDNA() error {
	tc.dna = &PersonaDNA{
		CoreIdentity:     map[string]string{"mbti": "INTP"},
		ValuesAndBeliefs: map[string]string{"political_stance": "center-left"},
	}
	return nil
}

func (tc *testContext) theInterviewServiceRunsAnInterviewLoopForThisDNA() error {
	service := server.NewInterviewService()

	var serviceDNA *server.PersonaDNA
	if tc.dna != nil {
		serviceDNA = &server.PersonaDNA{
			CoreIdentity:     tc.dna.CoreIdentity,
			ValuesAndBeliefs: tc.dna.ValuesAndBeliefs,
		}
	}

	conversation, err := service.RunLoop(context.Background(), serviceDNA)

	tc.lastError = err
	tc.conversation = make([]ConversationTurn, len(conversation))
	for i, turn := range conversation {
		tc.conversation[i] = ConversationTurn{
			Author:  turn.Author,
			Message: turn.Message,
		}
	}

	return nil
}

func (tc *testContext) theReturnedConversationShouldHaveRounds(count int) error {
	expectedMessages := count * 2
	if len(tc.conversation) != expectedMessages {
		return fmt.Errorf("expected %d messages for %d rounds, but got %d", expectedMessages, count, len(tc.conversation))
	}
	return nil
}

func (tc *testContext) theConversationShouldStartWithAMessageFrom(author string) error {
	if len(tc.conversation) == 0 {
		return fmt.Errorf("conversation is empty, cannot check the first author")
	}
	if tc.conversation[0].Author != author {
		return fmt.Errorf("expected first author to be '%s', but got '%s'", author, tc.conversation[0].Author)
	}
	return nil
}

func (tc *testContext) thePersonaDNAIsEmpty() error {
	tc.dna = nil
	return nil
}

func (tc *testContext) theInterviewServiceAttemptsToRunTheInterviewLoop() error {
	return tc.theInterviewServiceRunsAnInterviewLoopForThisDNA()
}

func (tc *testContext) anErrorShouldBeReturned() error {
	if tc.lastError == nil {
		return fmt.Errorf("expected an error but got nil")
	}
	return nil
}


// --- `initializeScenario` ---

func (tc *testContext) initializeScenario(ctx *godog.ScenarioContext) {
	ctx.Before(func(ctx context.Context, sc *godog.Scenario) (context.Context, error) {
		tc.router = server.SetupRouter()
		tc.resp = nil
		tc.requestBody = ""
		tc.dna = nil
		tc.conversation = nil
		tc.lastError = nil
		return ctx, nil
	})

	// Gin Server Health Check
	ctx.When(`^I send a GET request to "([^"]*)"$`, tc.iSendAGETRequestTo)
	ctx.Then(`^the response code should be (\d+)$`, tc.theResponseCodeShouldBe)
	ctx.Then(`^the response content should be "([^"]*)"$`, tc.theResponseContentShouldBe)

	// Persona Ingestion & PII
	ctx.Given(`^I have a valid Persona DNA JSON request$`, tc.iHaveAPersonaDNAJSONRequest)
	ctx.Given(`^I have a Persona DNA JSON request with PII \(email\)$`, tc.iHaveAPersonaDNAJSONRequest)
	ctx.Given(`^I have a Persona DNA JSON request with PII \(phone number\)$`, tc.iHaveAPersonaDNAJSONRequest)
	ctx.When(`^I send a POST request to "([^"]*)" with that JSON$`, tc.iSendAPOSTRequestToWithThatJSON)
	ctx.Then(`^the response contains "([^"]*)"$`, tc.theResponseContains)

	// Calibration Steps
	ctx.When(`^I send a POST request to "([^"]*)"$`, tc.iSendAPOSTRequestTo)
	ctx.Then(`^the response body should be a JSON with the following keys:$`, tc.theResponseBodyShouldBeAJSONWithTheFollowingKeys)
	ctx.Then(`^the JSON field "([^"]*)" should be an array of size (\d+)$`, tc.theJSONFieldShouldBeAnArrayOfSize)

	// Agent Loop Steps
	ctx.Given(`^a defined Persona DNA$`, tc.aDefinedPersonaDNA)
	ctx.When(`^the InterviewService runs an interview loop for this DNA$`, tc.theInterviewServiceRunsAnInterviewLoopForThisDNA)
	ctx.Then(`^the returned conversation should have (\d+) rounds$`, tc.theReturnedConversationShouldHaveRounds)
	ctx.Then(`^the conversation should start with a message from "([^"]*)"$`, tc.theConversationShouldStartWithAMessageFrom)
	ctx.Given(`^the Persona DNA is empty$`, tc.thePersonaDNAIsEmpty)
	ctx.When(`^the InterviewService attempts to run the interview loop$`, tc.theInterviewServiceAttemptsToRunTheInterviewLoop)
	ctx.Then(`^an error should be returned$`, tc.anErrorShouldBeReturned)
}

// --- TestFeatures ---

func TestFeatures(t *testing.T) {
	tc := &testContext{}
	suite := godog.TestSuite{
		ScenarioInitializer: tc.initializeScenario,
		Options: &godog.Options{
			Format: "pretty",
			Paths: []string{
				"../agent_loop.feature",
				"../gin_server.feature",
				"../persona_ingestion.feature",
				"../pii_validation.feature",
				"../calibration.feature",
			},
			TestingT: t,
		},
	}

	if suite.Run() != 0 {
		t.Fatal("non-zero status returned, failed to run feature tests")
	}
}

// iSendAPOSTRequestTo sends a POST request without a body
func (tc *testContext) iSendAPOSTRequestTo(path string) error {
	req, err := http.NewRequestWithContext(
		context.Background(),
		http.MethodPost,
		path,
		nil, // No body
	)
	if err != nil {
		return fmt.Errorf("failed to create request: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")

	tc.resp = httptest.NewRecorder()
	tc.router.ServeHTTP(tc.resp, req)
	return nil
}


// theResponseBodyShouldBeAJSONWithTheFollowingKeys checks if the response body is a JSON object with the given keys.
func (tc *testContext) theResponseBodyShouldBeAJSONWithTheFollowingKeys(keys *godog.Table) error {
	var bodyMap map[string]interface{}
	bodyBytes, err := io.ReadAll(tc.resp.Body)
	if err != nil {
		return fmt.Errorf("failed to read response body: %w", err)
	}
	// Reset body for subsequent reads
	tc.resp.Body = io.NopCloser(strings.NewReader(string(bodyBytes)))

	if err := json.Unmarshal(bodyBytes, &bodyMap); err != nil {
		return fmt.Errorf("failed to unmarshal response body into JSON: %w. Body: %s", err, string(bodyBytes))
	}

	for _, row := range keys.Rows {
		if len(row.Cells) == 0 {
			continue
		}
		key := row.Cells[0].Value
		if _, ok := bodyMap[key]; !ok {
			return fmt.Errorf("expected JSON response to have key '%s', but it was not found in body: %s", key, string(bodyBytes))
		}
	}

	return nil
}

// theJSONFieldShouldBeAnArrayOfSize checks if a specific field in the JSON response is an array of a given size.
func (tc *testContext) theJSONFieldShouldBeAnArrayOfSize(field string, expectedSize int) error {
	var bodyMap map[string]interface{}
	bodyBytes, err := io.ReadAll(tc.resp.Body)
	if err != nil {
		return fmt.Errorf("failed to read response body: %w", err)
	}
	// Reset body for subsequent reads
	tc.resp.Body = io.NopCloser(strings.NewReader(string(bodyBytes)))

	if err := json.Unmarshal(bodyBytes, &bodyMap); err != nil {
		return fmt.Errorf("failed to unmarshal response body into JSON: %w. Body: %s", err, string(bodyBytes))
	}

	value, ok := bodyMap[field]
	if !ok {
		return fmt.Errorf("expected JSON response to have key '%s', but it was not found", field)
	}

	arr, ok := value.([]interface{})
	if !ok {
		return fmt.Errorf("expected JSON field '%s' to be an array, but it is not", field)
	}

	if len(arr) != expectedSize {
		return fmt.Errorf("expected array '%s' to have size %d, but got %d", field, expectedSize, len(arr))
	}

	return nil
}
