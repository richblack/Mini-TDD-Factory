Feature: Asymmetric Calibration Service

  Scenario: Successfully generate calibration questions
    Given the server is running
    When I send a POST request to "/api/v1/calibration/generate-questions"
    Then the response code should be 200
    And the response body should be a JSON with the following keys:
      | human_questions |
      | ai_questions    |
    And the JSON field "human_questions" should be an array of size 5
    And the JSON field "ai_questions" should be an array of size 5
