Feature: MySQL Dump
  In order to backup my data
  As a backup operator
  I want to dump my MySQL database

  Scenario: Create a dump
    Given I tell the sheep to work on project "mysql-dump"
    Then a dump of the MySQL database should have been created

  Scenario: Authentication error
    Given I tell the sheep to work on failing project "mysql-dump-auth-fail"
    Then I am notified the mysqldump failed due to an authentication failure

  Scenario: Unknown database error
    Given I tell the sheep to work on failing project "mysql-dump-unknown-db-fail"
    Then I am notified the mysqldump failed due to an unknown database
