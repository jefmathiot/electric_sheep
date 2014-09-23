Then(/^the file should be present in both local and remote default working directories$/) do
  file="/home/vagrant/.electric_sheep/working-directories/#{@resource_name}"
  step "a file named \"#{file}\" should exist"
  assert_remote_file_exists? file
end
