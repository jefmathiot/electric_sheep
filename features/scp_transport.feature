Feature: SCP transport
  In order to put my backup files in safe locations
  As a backup operator
  I want to move and copy files and directories using the SCP protocol

  Scenario: Move a file using SCP from the localhost to a remote host
    Given a local file
    When I tell the sheep to work on project "scp-move-local-to-remote"
    Then the file should have been moved to the remote host

  Scenario: Move a file using SCP from the localhost to a remote host without working directory
    Given a local file
    When I tell the sheep to work on project "scp-move-local-to-remote-without-working-directory"
    Then the file should have been moved to the remote host in default directory

  Scenario: Copy and move a file using SCP
    Given a local file
    When I tell the sheep to work on project "scp-copy-and-move"
    Then the file should have been copy and moved to the remotes host