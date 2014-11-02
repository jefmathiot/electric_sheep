Given(/^a remote bucket$/) do
  @bucket_path = "s3/my-bucket"
  step "a directory named \"#{@bucket_path}\""
end

Then(/^the file should have been moved to the remote host$/) do
  assert_remote_file_exists? "/tmp/acceptance/#{@project}/#{timestamped_resource(@resource_name)}"
  refute_local_file_exists? @resource_name
end

Then(/^the file should have been copied to the remote host$/) do
  assert_remote_file_exists? "/tmp/acceptance/#{@project}/#{timestamped_resource(@resource_name)}"
  assert_local_file_exists? @resource_name
end

Then(/^the file should exist on the localhost$/) do
  step "a file matching %r<#{@project}/dummy-\\d{8}-\\d{6}.file> should exist"
end

Then(/^the file should have been moved to the localhost$/) do
  step "the file should exist on the localhost"
  refute_remote_file_exists? @resource_name
end

Then(/^the file should have been copied to the localhost$/) do
  step "the file should exist on the localhost"
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

Then(/^the directory should exist on the remote host$/) do
  @files.each do |file|
    assert_remote_file_exists? "/tmp/acceptance/#{@project}/#{timestamped_resource(@resource_name)}/#{file}"
  end
end

Then(/^the directory should have been moved to the remote host$/) do
  step "the directory should exist on the remote host"
  refute_local_file_exists? @resource_name
end

Then(/^the directory should have been copied to the remote host$/) do
  step "the directory should exist on the remote host"
  assert_local_file_exists? @resource_name
end

Then(/^the directory should exist on the localhost$/) do
  @files.each do |file|
    step "a file matching %r<#{@project}/dummy-directory-\\d{8}-\\d{6}/#{file}> should exist"
  end
end

Then(/^the directory should have been moved to the localhost$/) do
  step "the directory should exist on the localhost"
  refute_remote_file_exists? @resource_name
end

Then(/^the directory should have been copied to the localhost$/) do
  step "the directory should exist on the localhost"
  refute_remote_file_exists? @resource_name
end

Then(/^the S3 object should have been moved to the localhost$/) do
  step "a file matching %r<#{@project}/dummy-\\d{8}-\\d{6}.file> should exist"
  refute_local_file_exists? "#{@bucket_path}/#{@project}/dummy.file"
end

Then(/^the S3 object should have been copied to the localhost$/) do
  step "a file matching %r<#{@project}/dummy-\\d{8}-\\d{6}.file> should exist"
  assert_local_file_exists? "#{@bucket_path}/my-project/dummy.file"
end

Then(/^I am notified the (?:s3|scp) move failed$/) do
  step "the output should match /No such file or directory/"
end
