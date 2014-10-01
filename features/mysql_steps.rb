Then(/^a MySQL dump of the database should have been created$/) do
  file=Dir.glob(File.join('tmp', @project, 'controldb*')).first
  raise "Dump not found" unless file
  raise "Not a dump" unless File.read(file) =~ /-- Dump completed/
end
