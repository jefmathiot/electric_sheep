Feature: PostgreSQL Dump
  In order to backup my data
  As a backup operator
  I want to dump my PostgreSQL database

  Scenario: Create a dump
    Given I tell the sheep to work on project "postgresql-dump"
    Then a dump of the PostgreSQL database should have been created

  Scenario: Create a dump as a superuser
    Given I tell the sheep to work on project "postgresql-dump-sudo"
    Then a dump of the PostgreSQL database should have been created

  Scenario: Authentication error
    Given I tell the sheep to work on failing project "postgresql-dump-auth-fail"
    Then I am notified the pg_dump failed due to an authentication failure

  Scenario: Unknown database error
    Given I tell the sheep to work on failing project "postgresql-dump-unknown-db-fail"
    Then I am notified the pg_dump failed due to an unknown database
