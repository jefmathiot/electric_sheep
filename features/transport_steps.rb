Given(/^a local file$/) do
  step "a 102400 byte file named \"dummy.file\""
end

Then(/^the file should have been moved to the remote host$/) do
  assert_remote_file_exists? ".electric_sheep/#{@project}/dummy.file"
  refute_local_file_exists? "dummy.file"
end

