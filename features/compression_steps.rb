Then(/^an archive should have been created on the remote host$/) do
  assert_remote_file_exists?("/tmp/acceptance/tar-gz-file/dummy.file.tar.gz")
end
