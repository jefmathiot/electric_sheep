Feature: SCP transport
  In order to put my backup files in safe locations
  As a backup operator
  I want to move and copy files and directories using the SCP protocol

  Scenario: Move a file using SCP from the localhost to a remote host
    Given a local file for "scp-move-local-to-remote"
    When I tell the sheep to work on project "scp-move-local-to-remote"
    Then the file should have been moved to the remote host

  Scenario: Copy a file using SCP from the localhost to a remote host
    Given a local file for "scp-copy-local-to-remote"
    When I tell the sheep to work on project "scp-copy-local-to-remote"
    Then the file should have been copied to the remote host

  Scenario: Move a file using SCP from remote to local host
    Given a remote file for "scp-move-remote-to-local"
    When I tell the sheep to work on project "scp-move-remote-to-local"
    Then the file should have been moved to the localhost

  Scenario: Copy a file using SCP from remote to local host
    Given a remote file for "scp-copy-remote-to-local"
    When I tell the sheep to work on project "scp-copy-remote-to-local"
    Then the file should have been copied to the localhost

  Scenario: Copy and move a file using SCP
    Given a local file for "scp-copy-and-move"
    When I tell the sheep to work on project "scp-copy-and-move"
    Then the file should have been copy and moved to the remotes host
