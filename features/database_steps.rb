Then(/^a MongoDB dump of the database should have been created$/) do
  files=Dir.glob(File.join('tmp', @project, 'controldb*', 'controldb', '*.bson')).first
  raise "Dump not found" unless files
end

Then(/^a MySQL dump of the database should have been created$/) do
  file=Dir.glob(File.join('tmp', @project, 'controldb*')).first
  raise "Dump not found" unless file
  raise "Not a dump" unless File.read(file) =~ /-- Dump completed/
end

Then(/^I am notified the mysqldump failed due to an authentication failure$/) do
  step "the output should contain \"mysqldump: Got error: 1045\""
end

Then(/^I am notified the mysqldump failed due to an unknown database$/) do
  step "the output should contain \"mysqldump: Got error: 1044\""
end

Then(/^I am notified the mongodump command failed$/) do
  step "the output should contain \"Command terminated with exit status : 255\""
end