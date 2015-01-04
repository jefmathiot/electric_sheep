Feature: PostgreSQL Dump
  In order to backup my data
  As a backup operator
  I want to dump my PostgreSQL database

  @pending
  Scenario: Create a dump
    Given I tell the sheep to work on project "postgresql-dump"
    Then a PostgreSQL dump of the database should have been created

  @pending
  Scenario: Create a dump as a superuser
    Given I tell the sheep to work on project "postgresql-dump-sudo"
    Then a PostgreSQL dump of the database should have been created

  @pending
  Scenario: Authentication error
    Given I tell the sheep to work on failing project "postgresql-dump-auth-fail"
    Then I am notified the pg_dump failed due to an authentication failure

  @pending
  Scenario: Unknown database error
    Given I tell the sheep to work on failing project "postgresql-dump-unknown-db-fail"
    Then I am notified the pg_dump failed due to an unknown database
