Feature: Agent Interview Loop

  In order to verify the core agent interaction logic,
  the developer needs to be able to run a simulated interview loop.

  Scenario: Successfully run an interview loop
    Given a defined Persona DNA
    When the InterviewService runs an interview loop for this DNA
    Then the returned conversation should have 5 rounds
    And the conversation should start with a message from "Interviewer"

  Scenario: Handle empty DNA
    Given the Persona DNA is empty
    When the InterviewService attempts to run the interview loop
    Then an error should be returned