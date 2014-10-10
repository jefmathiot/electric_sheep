Feature: SCP transport
  In order to put my backup files in safe locations
  As a backup operator
  I want to move and copy files and directories using the SCP protocol

  Scenario: Move a file using SCP from the localhost to a remote host
    Given a local file
    When I tell the sheep to work on project "scp-move-local-to-remote"
    Then the file should have been moved to the remote host

  Scenario: Copy a file using SCP from the localhost to a remote host
    Given a local file
    When I tell the sheep to work on project "scp-copy-local-to-remote"
    Then the file should have been copied to the remote host

  Scenario: Move a file using SCP from remote to local host
    Given a remote file in the project "scp-move-remote-to-local"
    When I tell the sheep to work on project "scp-move-remote-to-local"
    Then the file should have been moved to the localhost

  Scenario: Copy a file using SCP from remote to local host
    Given a remote file in the project "scp-copy-remote-to-local"
    When I tell the sheep to work on project "scp-copy-remote-to-local"
    Then the file should have been copied to the localhost

  Scenario: Copy and move a file using SCP
    Given a local file
    When I tell the sheep to work on project "scp-copy-and-move"
    Then the file should have been copied and moved to the two remote hosts

  Scenario: Recursively move a directory contents using SCP from the localhost to a remote host
    Given a local directory containing multiple files
    When I tell the sheep to work on project "scp-move-directory-local-to-remote"
    Then the directory should have been moved to the remote host

  Scenario: Recursively copy a directory contents using SCP from the localhost to a remote host
    Given a local directory containing multiple files
    When I tell the sheep to work on project "scp-copy-directory-local-to-remote"
    Then the directory should have been copied to the remote host

  Scenario: Recursively move contents of a directory using SCP from remote to local host
    Given a remote directory containing multiple files in the project "scp-move-directory-remote-to-local"
    When I tell the sheep to work on project "scp-move-directory-remote-to-local"
    Then the directory should have been moved to the localhost

  Scenario: Recursively copy contents of a directory using SCP from remote to local host
    Given a remote directory containing multiple files in the project "scp-copy-directory-remote-to-local"
    When I tell the sheep to work on project "scp-copy-directory-remote-to-local"
    Then the directory should have been copied to the localhost

