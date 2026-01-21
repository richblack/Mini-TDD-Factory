Feature: Persona DNA Ingestion API

  Scenario: Successfully ingest a valid Persona DNA
    Given I have a valid Persona DNA JSON request
      """
      {
        "core_identity": {
          "mbti": "INTJ",
          "big_five": {
            "openness": 0.8,
            "conscientiousness": 0.7,
            "extraversion": 0.3,
            "agreeableness": 0.4,
            "neuroticism": 0.2
          },
          "values": ["freedom", "innovation"]
        },
        "values_and_beliefs": {
          "religious_beliefs": "none",
          "political_leanings": "centrist"
        }
      }
      """
    When I send a POST request to "/api/v1/persona/ingest" with that JSON
    Then the response code should be 200
    And the response contains "persona_id"