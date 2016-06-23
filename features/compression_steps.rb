Then(/^an archive containing the file should have been created on the remote host$/) do
  archive="/tmp/acceptance/#{@job}/dummy-*-*.tar.gz"
  assert_remote_file_exists?(archive)
  ssh_run_simple("tar -ztf #{archive} | grep dummy.file", 10)
end

Then(/^an archive should have been created on the remote host$/) do
  @archive="/tmp/acceptance/#{@job}/dummy-*-*.tar.gz"
  assert_remote_file_exists?(@archive)
end

Then(/^an archive containing the files should have been created on the remote host$/) do
  step 'an archive should have been created on the remote host'
  @files.each do |file|
    ssh_run_simple("tar -ztf #{@archive} | grep #{file}", 10)
  end
end

Then(/^an archive containing one of the files should have been created on the remote host$/) do
  step 'an archive should have been created on the remote host'
  # Ensure the first file is present
  ssh_run_simple("tar -ztf #{@archive} | grep #{@files.first}", 10)
  # Ensure the archive contains two entries : the directory a single file
  ssh_run_simple("if [ $(tar -ztf #{@archive} | wc -l) -ne 2 ]; then exit 1; fi;", 10)
end

Then(/^I am notified the compression command failed$/) do
  step "the output should match /No such file or directory/"
end
