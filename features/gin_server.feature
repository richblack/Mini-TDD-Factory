Feature: Gin Server Startup and Basic Health Check

  Scenario: Server should start successfully and respond to health check
    When I send a GET request to "/health"
    Then the response code should be 200
    And the response content should be "OK"