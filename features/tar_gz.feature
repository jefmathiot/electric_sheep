Feature: Tarball Compression
  In order to reduce usage of storage and bandwidth
  As a backup operator
  I want to compress file on the remote host

  Scenario: Compress a file
    Given a remote file in the project "tar-gz-file"
    When I tell the sheep to work on the project
    Then an archive containing the file should have been created on the remote host

  Scenario: Compress a directory
    Given a remote directory containing multiple files in the project "tar-gz-directory"
    When I tell the sheep to work on the project
    Then an archive containing the files should have been created on the remote host
