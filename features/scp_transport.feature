Feature: SCP transport
  In order to put my backup files in safe locations
  As a backup operator
  I want to move and copy files and directories using the SCP protocol

  Scenario: Move a file using SCP from the localhost to a remote host
    Given a local file
    When I tell the sheep to work on project "scp-move-local-to-remote"
    Then the file should have been moved to the remote host

