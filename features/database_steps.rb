Then(/^a MongoDB dump of the database should have been created$/) do
  files=Dir.glob(File.join('tmp', @project, 'controldb*', 'controldb', '*.bson')).first
  raise "Dump not found" unless files
end

Then(/^a MySQL dump of the database should have been created$/) do
  file=Dir.glob(File.join('tmp', @project, 'controldb*')).first
  raise "Dump not found" unless file
  raise "Not a dump" unless File.read(file) =~ /-- Dump completed/
end

When(/^I am notified that the database backup failed$/) do
  expect(all_output.include? "mysqldump: Got error: 1045: Access denied for user 'fail_user'@'localhost'").to be(true)
  step "I am notified that the command failed"
end