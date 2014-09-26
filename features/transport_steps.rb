Given(/^a local file$/) do
  @resource_name="dummy.file"
  step "a 102400 byte file named \"#{@resource_name}\""
end

Given(/^a local file for "(.*?)"$/) do |folder|
  @resource_name='../'+folder+"/dummy.file"
  step "a 102400 byte file named \"#{@resource_name}\""
end

Given(/^a remote file for "(.*?)"$/) do |folder|
  @project = folder
  @folder = '/tmp/acceptance/'+folder
  @resource_name='/tmp/acceptance/'+folder+"/dummy.file"
  ssh_run_simple("mkdir -p #{ @folder}")
  ssh_run_simple("touch #{ @resource_name}")
  assert_remote_file_exists? @resource_name
end

Then(/^the file should have been moved to the remote host$/) do
  assert_remote_file_exists? "/tmp/acceptance/#{@project}/#{@resource_name}"
  refute_local_file_exists? @resource_name
end

Then(/^the file should have been copied to the remote host$/) do
  assert_remote_file_exists? "/tmp/acceptance/#{@project}/#{@resource_name}"
  assert_local_file_exists? @resource_name
end

Then(/^the file should have been moved to the localhost$/) do
  assert_local_file_exists? '../../tmp/'+@project+"/dummy.file"
  refute_remote_file_exists? @resource_name
end

Then(/^the file should have been copied to the localhost$/) do
  assert_local_file_exists? "../../tmp/"+@project+"/dummy.file"
  assert_remote_file_exists? @resource_name
end

Then(/^the file should have been moved to the remote host in default directory$/) do
  assert_remote_file_exists? "~/.electric_sheep/#{@project}/#{@resource_name}"
  refute_local_file_exists? @resource_name
end

Then(/^the file should have been copy and moved to the remotes host$/) do
  assert_remote_file_exists? "/tmp/acceptance/#{@project}/#{@resource_name}"
  assert_remote_file_exists? "/tmp/acceptance_backup/#{@project}/#{@resource_name}"
  refute_local_file_exists? @resource_name
end

Given(/^a remote bucket$/) do
  @bucket_path="tmp/s3/my-bucket"
  step "a directory named \"#{@bucket_path}\""
end

Then(/^the file should have been (copied|moved) to the remote bucket$/) do |op|
  step "a file named \"#{@bucket_path}/my-project/#{@resource_name}\" should exist"
  if op=='moved'
    refute_local_file_exists? @resource_name
  else
    step "a file named \"#{@resource_name}\" should exist"
  end
end