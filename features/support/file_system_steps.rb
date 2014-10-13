Given(/^a local file$/) do
  @resource_name = "dummy.file"
  step "a 102400 byte file named \"#{@resource_name}\""
end

Given(/^a local directory containing multiple files$/) do
  @resource_name="dummy-directory"
  step "a directory named \"#{@resource_name}\""
  with_multiple_files(@resource_name) do |directory, file|
    step "a 102400 byte file named \"#{directory}/#{file}\""
  end
  assert_local_file_exists? @resource_name
end

Given(/^a local directory containing multiple files in the project "(.*?)"$/) do |project|
  @project = project
  "#{project}".tap do |project_directory|
    step "a directory named \"#{project_directory}\""
    with_multiple_files(@resource_name) do |directory, file|
      step "a 102400 byte file named \"#{directory}/#{file}\""
    end
  end
end

Given(/^a remote file$/) do
  @resource_name = "#{@bucket_path}/my-project/dummy.file"
  step "a 102400 byte file named \"#{@resource_name}\""
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

Given(/^a remote directory containing multiple files in the project "(.*?)"$/) do |project|
  @project = project
  "/tmp/acceptance/#{project}".tap do |project_directory|
    @resource_name="#{project_directory}/dummy-directory"
    ssh_run_simple("mkdir -p #{@resource_name}")
    with_multiple_files(@resource_name) do |directory, file|
      ssh_run_simple("echo 'content' >> #{directory}/#{file}")
    end
  end
  assert_remote_file_exists? @resource_name
end