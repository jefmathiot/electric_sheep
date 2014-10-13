Then(/^an archive containing the file should have been created on the remote host$/) do
  archive="/tmp/acceptance/#{@project}/dummy-*-*.tar.gz"
  assert_remote_file_exists?(archive)
  ssh_run_simple("tar -ztf #{archive} | grep dummy.file", 10)
end

Then(/^an archive containing the files should have been created on the remote host$/) do
  archive="/tmp/acceptance/#{@project}/dummy-*-*.tar.gz"
  assert_remote_file_exists?(archive)
  @files.each do |file|
    ssh_run_simple("tar -ztf #{archive} | grep #{file}", 10)
  end
end
