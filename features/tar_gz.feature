Feature: Tarball Compression
  In order to reduce usage of storage and bandwidth
  As a backup operator
  I want to compress file on the remote host

  Scenario: Compress a file
    Given a remote file in the job "tar-gz-file"
    When I tell the sheep to work on the job
    Then an archive containing the file should have been created on the remote host

  Scenario: Compress a directory
    Given a remote directory containing multiple files in the job "tar-gz-directory"
    When I tell the sheep to work on the job
    Then an archive containing the files should have been created on the remote host

  Scenario: Compress a directory specifying files to exclude
    Given a remote directory containing multiple files in the job "tar-gz-directory-exclusions"
    When I tell the sheep to work on the job
    Then an archive containing one of the files should have been created on the remote host

  Scenario: Compress an unknown file
    Given I tell the sheep to work on failing job "tar-gz-unknown-file"
    Then I am notified the compression command failed
