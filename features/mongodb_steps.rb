Then(/^a MongoDB dump of the database should have been created$/) do
  files=Dir.glob(File.join(@project, 'controldb*', 'controldb', '*.bson')).first
  raise "Dump not found" unless files
end
