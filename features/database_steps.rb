Then(/^a MongoDB dump of the database should have been created$/) do
  files=Dir.glob(File.join('tmp', @job, 'control\*db*', 'control\*db', '*.bson')).first
  raise "Dump not found" unless files
end

Then(/^a dump should exist with "(.*?)" and without "(.*?)"$/) do |contents, excluded|
  file = Dir.glob(File.join('tmp', @job, "control\*db*")).first
  raise 'Dump not found' unless file
  raise 'Not a dump' unless File.read(file) =~ /#{contents}/
  raise 'Should have excluded table2' if File.read(file) =~ /#{excluded}/
end

Then(/^a dump of the MySQL database should have been created$/) do
  step 'a dump should exist with "CREATE TABLE `table1`" ' \
    'and without "CREATE TABLE `table2`"'
end

Then(/^a dump of the PostgreSQL database should have been created$/) do
  step 'a dump should exist with "CREATE TABLE table1" ' \
    'and without "CREATE TABLE table2"'
end

Then(/^I am notified the mysqldump failed due to an authentication failure$/) do
  step 'the output should contain "mysqldump: Got error: 1045"'
end

Then(/^I am notified the mysqldump failed due to an unknown database$/) do
  step 'the output should contain "mysqldump: Got error: 1044"'
end

Then(/^I am notified the mongodump command failed$/) do
  step 'the output should contain "Command terminated with exit status: 255"'
end

Then(/^I am notified the pg_dump failed due to an authentication failure$/) do
  step 'the output should contain "password authentication failed for user"'
end

Then(/^I am notified the pg_dump failed due to an unknown database$/) do
  step 'the output should match /database "unknown" does not exist/'
end
