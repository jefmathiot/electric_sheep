Feature: Tarball Compression
  In order to reduce usage of storage and bandwidth
  As a backup operator
  I want to compress file on the remote host

  @current
  Scenario: Compress a file
    Given a remote file for "tar-gz-file"
    When I tell the sheep to work on project "tar-gz-file"
    Then an archive should have been created on the remote host
