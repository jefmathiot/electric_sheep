Feature: Default working directories
  In order to get started easily
  As a backup operator
  I want Electric Sheep to handle its working directories seamlessly

  Scenario: Upload a file and get it back
    Given a file in default directory
    When I tell the sheep to work on configuration "Sheepfile.default"
    Then the file should be present in both local and remote default working directories
