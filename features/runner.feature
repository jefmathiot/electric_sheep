Feature: Run jobs
  In order to handle several jobs
  As a backup operator
  I want to choose jobs to run

  Scenario: Run all jobs from a Sheepfile even if one of them failed
    Given I tell the sheep to work on configuration "Sheepfile.runner"
    Then the job "failing-job" has been executed
    And I am notified the mysqldump failed due to an authentication failure
    And the job "successful-job" has been executed

  Scenario: Run a specific job from a Sheepfile
    Given I'm working on configuration "Sheepfile.runner"
    When I tell the sheep to work on job "successful-job"
    Then the job "failing-job" hasn't been executed
    And the job "successful-job" has been executed

  Scenario: Run an unknown job from a Sheepfile
    Given I'm working on configuration "Sheepfile.runner"
    When I tell the sheep to work on failing job "unknown"
    Then the job "failing-job" hasn't been executed
    And the job "successful-job" hasn't been executed
    And the program warns me the job is unknown

  Scenario: Run a Sheepfile with an unknown command
    Given I'm working on configuration "Sheepfile.unknown_command"
    When I tell the sheep to work on failing job "unknown-command"
    Then the job "unknown-command" hasn't been executed
    And the program warns me an "Unknown command 'unknown' in Sheepfile" error occured
