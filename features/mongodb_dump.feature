Feature: MongoDB Dump
  In order to backup my data
  As a backup operator
  I want to dump my MongoDB database

  Scenario: Create a dump
    Given I tell the sheep to work on project "mongodb-dump"
    Then a MongoDB dump of the database should have been created

  Scenario: Authentication error on a dump
    Given I tell the sheep to work on failing project "mongodb-dump-auth-fail"
    Then I am notified that the command failed
# @pending
#   Scenario: Error on an unknown database dump
#     Given I tell the sheep to work on failing project "mongodb-dump-unknown-db-fail"
#     Then I am notified that the command failed