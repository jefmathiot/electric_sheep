Given(/^a local file$/) do
  step 'a local file named "dummy.file"'
end

Given(/^a local file named with special characters$/) do
  step 'a local file named "dummy *.file"'
end

Given(/^a local file named "(.*?)"$/) do |file|
  @resource_name = file
  step "a 102400 byte file named \"#{@resource_name}\""
end

Given(/^a local directory containing multiple files$/) do
  step 'a local directory named "dummy-directory" containing multiple files'
end

Given(/^a local directory named "(.*?)" containing multiple files$/) do |dir|
  @resource_name = dir
  step "a directory named \"#{@resource_name}\""
  STDOUT.puts `ls -la tmp`
  with_multiple_files(@resource_name) do |directory, file|
    step "a 102400 byte file named \"#{directory}/#{file}\""
  end
  assert_local_file_exists? @resource_name
end

Given(/^a local directory named with special characters$/) do
  step 'a local directory named "dummy *directory" containing multiple files'
end

Given(/^a local directory containing multiple files in the job "(.*?)"$/) do |job|
  @job = job
  job.tap do |job_directory|
    step "a directory named \"#{job_directory}\""
    with_multiple_files(@resource_name) do |directory, file|
      step "a 102400 byte file named \"#{directory}/#{file}\""
    end
  end
end

Given(/^a remote file$/) do
  @resource_name = "#{@bucket_path}/my-job/dummy.file"
  step "a 102400 byte file named \"#{@resource_name}\""
end

Given(/^a remote file containing "(.*?)" in the job "(.*?)"$/) do |content, job|
  @job = job
  "/tmp/acceptance/#{job}".tap do |job_directory|
    @resource_name = "#{job_directory}/dummy.file"
    ssh_run_simple("mkdir -p #{job_directory}")
    ssh_run_simple("echo '#{content}' >> #{@resource_name}")
  end
  assert_remote_file_exists? @resource_name
end

Given(/^a remote file in the job "(.*?)"$/) do |job|
  step "a remote file containing \"content\" in the job \"#{job}\""
end

Given(/^a remote directory containing multiple files in the job "(.*?)"$/) do |job|
  @job = job
  "/tmp/acceptance/#{job}".tap do |job_directory|
    @resource_name = "#{job_directory}/dummy-directory"
    ssh_run_simple("mkdir -p #{@resource_name}")
    with_multiple_files(@resource_name) do |directory, file|
      ssh_run_simple("echo 'content' >> #{directory}/#{file}")
    end
  end
  assert_remote_file_exists? @resource_name
end
