Then(/^an archive containing the file should have been created on the remote host$/) do
  assert_remote_file_exists?("#{@resource_name}.tar.gz")
  ssh_run_simple("tar -ztf #{@resource_name}.tar.gz | grep dummy.file", 10)
end

Then(/^an archive containing the files should have been created on the remote host$/) do
  assert_remote_file_exists?("#{@resource_name}.tar.gz")
  @files.each do |file|
    ssh_run_simple("tar -ztf #{@resource_name}.tar.gz | grep #{file}", 10)
  end
end
