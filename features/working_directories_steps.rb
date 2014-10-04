Given(/^a file in default directory$/) do
  @directory=`echo $HOME`.strip+"/.electric_sheep/working-directories"
  step "a 102400 byte file named \"dummy.file\""
end

Then(/^the file should be present in both local and remote default working directories$/) do
  file="/home/vagrant/.electric_sheep/working-directories/#{timestamped_resource('dummy.file')}"
  assert_remote_file_exists? file
  expect(Dir.glob("#{@directory}/*")).to include_regexp(/dummy-\d{8}-\d{6}.file/)
end
