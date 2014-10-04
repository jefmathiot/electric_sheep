Given(/^a remote directory containing multiple files in the project "(.*?)"$/) do |project|
  @project = project
  "/tmp/acceptance/#{project}".tap do |project_directory|
    @resource_name="#{project_directory}/dummy-directory"
    ssh_run_simple("mkdir -p #{@resource_name}")
    @files=[1, 2].map do |index|
      "dummy.file.#{index}".tap do |file|
        ssh_run_simple("echo 'content' >> #{@resource_name}/#{file}")
      end
    end
  end
  assert_remote_file_exists? @resource_name
end

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
