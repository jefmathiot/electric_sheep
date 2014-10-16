Feature: MySQL Dump
  In order to backup my data
  As a backup operator
  I want to dump my MySQL database

  Scenario: Create a dump
    Given I tell the sheep to work on project "mysql-dump"
    Then a MySQL dump of the database should have been created

  Scenario: Error on a dump
    Given I tell the sheep to work on failing project "mysql-dump-auth-fail"
    Then I am notified that the database backup failed

  Scenario: Error on an unknown database dump
    Given I tell the sheep to work on failing project "mysql-dump-unknown-db-fail"
    Then I am notified that the command failed