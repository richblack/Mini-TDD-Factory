Feature: Persona DNA PII Validation

  Scenario: Reject Persona DNA containing an email
    Given I have a Persona DNA JSON request with PII (email)
      """
      {
        "core_identity": {
          "mbti": "INTJ",
          "email": "test@example.com"
        },
        "values_and_beliefs": {
          "religious_beliefs": "none"
        }
      }
      """
    When I send a POST request to "/api/v1/persona/ingest" with that JSON
    Then the response code should be 400

  Scenario: Reject Persona DNA containing a phone number
    Given I have a Persona DNA JSON request with PII (phone number)
      """
      {
        "core_identity": {
          "mbti": "ENTP",
          "phone": "123-456-7890"
        },
        "values_and_beliefs": {
          "political_leanings": "liberal"
        }
      }
      """
    When I send a POST request to "/api/v1/persona/ingest" with that JSON
    Then the response code should be 400