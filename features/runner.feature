Feature: Run projects
  In order to handle several projects
  As a backup operator
  I want to choose projects to run

  Scenario: Run all projects from a Sheepfile even if one of them failed
    Given I tell the sheep to work on configuration "Sheepfile.test"
    Then the project "failling-project" has been executed
      And I am notified that the command failed
      And the project "working-project" has been executed

  Scenario: Run a specific project from a Sheepfile
    Given I'm working on configuration "Sheepfile.test"
    When I tell the sheep to work on project "working-project"
    Then the project "failling-project" hasn't been executed
      And the project "working-project" has been executed

  Scenario: Run an unknown project from a Sheepfile
    Given I'm working on configuration "Sheepfile.test"
    When I tell the sheep to work on project "unknown"
    Then the project "failling-project" hasn't been executed
      And the project "working-project" hasn't been executed
      And the sheep tell me the project is unknown

  Scenario: Run a Sheepfile with unknown command
    Given I'm working on configuration "Sheepfile.test_unknown_command"
    When I tell the sheep to work on project "unknown"
    Then the project "unknown" hasn't been executed
      And the sheep tell me the error "Unknown command 'unknown' in Sheepfile" occurs