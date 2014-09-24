Given(/^a file in default directory$/) do
  @resource_name=`echo $HOME`.strip+"/.electric_sheep/working-directories/dummy.file"
  step "a 102400 byte file named \"#{@resource_name}\""
end

Then(/^the file should be present in both local and remote default working directories$/) do
  step "a file named \"#{@resource_name}\" should exist"
  file="/home/vagrant/.electric_sheep/working-directories/dummy.file"
  assert_remote_file_exists? file
end
