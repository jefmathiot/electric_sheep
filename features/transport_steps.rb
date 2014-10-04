Given(/^a local file$/) do
  @resource_name = "dummy.file"
  step "a 102400 byte file named \"#{@resource_name}\""
end

Given(/^a local file for "(.*?)"$/) do |project|
  step "a remote file in the project \"#{project}\""
end

Given(/^a remote file in the project "(.*?)"$/) do |project|
  @project = project
  "/tmp/acceptance/#{project}".tap do |project_directory|
    @resource_name="#{project_directory}/dummy.file"
    ssh_run_simple("mkdir -p #{project_directory}")
    ssh_run_simple("echo 'content' >> #{@resource_name}")
  end
  assert_remote_file_exists? @resource_name
end

Given(/^a remote bucket$/) do
  @bucket_path = "s3/my-bucket"
  step "a directory named \"#{@bucket_path}\""
end

Given(/^a remote file$/) do
  @resource_name = "#{@bucket_path}/my-project/dummy.file"
  step "a 102400 byte file named \"#{@resource_name}\""
end

Then(/^the file should have been moved to the remote host$/) do
  assert_remote_file_exists? "/tmp/acceptance/#{@project}/#{timestamped_resource(@resource_name)}"
  refute_local_file_exists? @resource_name
end

Then(/^the file should have been copied to the remote host$/) do
  assert_remote_file_exists? "/tmp/acceptance/#{@project}/#{timestamped_resource(@resource_name)}"
  assert_local_file_exists? @resource_name
end

Then(/^the file should have been moved to the localhost$/) do
  step "a file matching %r<#{@project}/dummy-\\d{8}-\\d{6}.file> should exist"
  refute_remote_file_exists? @resource_name
end

Then(/^the file should have been copied to the localhost$/) do
  step "a file matching %r<#{@project}/dummy-\\d{8}-\\d{6}.file> should exist"
  assert_remote_file_exists? @resource_name
end

Then(/^the file should have been moved to the remote host in default directory$/) do
  assert_remote_file_exists? "~/.electric_sheep/#{@project}/#{timestamped_resource(@resource_name)}"
  refute_local_file_exists? @resource_name
end

Then(/^the file should have been copied and moved to the two remote hosts$/) do
  assert_remote_file_exists? "/tmp/acceptance/#{@project}/#{timestamped_resource(@resource_name)}"
  assert_remote_file_exists? "/tmp/acceptance_backup/#{@project}/#{timestamped_resource(@resource_name)}"
  refute_local_file_exists? @resource_name
end

Then(/^the file should have been (copied|moved) to the remote bucket$/) do |op|
  step "a file matching %r<#{@bucket_path}/my-project/dummy-\\d{8}-\\d{6}.file> should exist"
  if op=='moved'
    refute_local_file_exists? @resource_name
  else
    step "a file named \"#{@resource_name}\" should exist"
  end
end

Then(/^the S3 object should have been moved to the localhost$/) do
  step "a file matching %r<#{@project}/dummy-\\d{8}-\\d{6}.file> should exist"
  refute_local_file_exists? "#{@bucket_path}/#{@project}/dummy.file"
end

Then(/^the S3 object should have been copied to the localhost$/) do
  step "a file matching %r<#{@project}/dummy-\\d{8}-\\d{6}.file> should exist"
  assert_local_file_exists? "#{@bucket_path}/my-project/dummy.file"
end
