Feature: S3 transport
  In order to put my backup files into the Cloud
  As a backup operator
  I want to move and copy files and directories using the AWS S3 storage service

  Scenario: Move a file using S3 from the localhost to a remote bucket
    Given a local file
    And a remote bucket
    When I tell the sheep to work on project "s3-move-local-to-remote"
    Then the file should have been moved to the remote bucket

  Scenario: Copy a file using S3 from the localhost to a remote host
    Given a local file
    And a remote bucket
    When I tell the sheep to work on project "s3-copy-local-to-remote"
    Then the file should have been copied to the remote bucket

  Scenario: Move a file using S3 from a remote bucket to the localhost
    Given a remote bucket
    And a remote file
    When I tell the sheep to work on project "s3-move-remote-to-local"
    Then the S3 object should have been moved to the localhost

  Scenario: Copy a file using S3 from a remote bucket to the localhost
    Given a remote bucket
    And a remote file
    When I tell the sheep to work on project "s3-copy-remote-to-local"
    Then the S3 object should have been copied to the localhost

  Scenario: fail using S3
    Given a remote bucket
    And I tell the sheep to work on failing project "s3-fail"
    Then I am notified the s3 move failed
