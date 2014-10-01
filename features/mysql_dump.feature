Feature: MySQL Dump
  In order to backup my data
  As a backup operator
  I want to dump my MySQL database

  @current
  Scenario: Create a dump
    Given I tell the sheep to work on project "mysql-dump"
    Then a MySQL dump of the database should have been created

