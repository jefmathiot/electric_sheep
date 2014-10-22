Feature: Run projects
  In order to handle several projects
  As a backup operator
  I want to choose projects to run

  Scenario: Run all projects from a Sheepfile even if one of them failed
    Given I tell the sheep to work on configuration "Sheepfile.runner"
    Then the project "failing-project" has been executed
    And I am notified that the command failed
    And the project "successful-project" has been executed

  Scenario: Run a specific project from a Sheepfile
    Given I'm working on configuration "Sheepfile.runner"
    When I tell the sheep to work on project "successful-project"
    Then the project "failing-project" hasn't been executed
    And the project "successful-project" has been executed

  Scenario: Run an unknown project from a Sheepfile
    Given I'm working on configuration "Sheepfile.runner"
    When I tell the sheep to work on project "unknown"
    Then the project "failing-project" hasn't been executed
    And the project "successful-project" hasn't been executed
    And the program warns me the project is unknown

  Scenario: Run a Sheepfile with an unknown command
    Given I'm working on configuration "Sheepfile.unknown_command"
    When I tell the sheep to work on project "unknown-command"
    Then the project "unknown-command" hasn't been executed
    And the program warns me an "Unknown command 'unknown' in Sheepfile" error occured
