Feature: MongoDB Dump
  In order to backup my data
  As a backup operator
  I want to dump my MongoDB database

  Scenario: Create a dump
    Given I tell the sheep to work on project "mongodb-dump"
    Then a MongoDB dump of the database should have been created

