Given(/^a secret$/) do
  @secret = "password"
end

When(/^I tell the sheep to encrypt the secret$/) do
  options="-a -k #{acceptance_dir}/public_key.gpg #{@secret}"
  step "I successfully run `bundle exec #{electric_sheep} encrypt #{options}`"
end

Then(/^I should see the ASCII\-armored cipher text$/) do
  step "the output should match /^-----BEGIN PGP MESSAGE-----/"
end

When(/^I tell the sheep to encrypt a secret in compact format$/) do
  options="-k #{acceptance_dir}/public_key.gpg #{@secret}"
  step "I successfully run `bundle exec #{electric_sheep} encrypt #{options}`"
end

Then(/^I should only see the data part of the cipher text$/) do
  step "the output should match /^hQEMA5/"
end

Given(/^Electric Sheep has access to a valid private key$/) do
  # Do nothing, the project will fail unless the encrypted secrets are correct
end

Then(/^everything goes well$/) do
  # Do nothing, the previous step fails on error
end

Then(/^the file should have been encrypted$/) do
  filename = File.basename(Dir.glob("tmp/#{@job}/dummy-*.gpg").first)
  @encrypted_file = "#{@job}/#{filename}"
  check_file_content @encrypted_file, 'SECRET', false
end

Then(/^I should be able to decrypt it back$/) do
  output = Tempfile.new('clear-text')
  output.close
  args = "-k #{acceptance_dir}/private_key.gpg"
  args << " #{@encrypted_file}"
  args << " #{output.path}"
  step "I successfully run `bundle exec #{electric_sheep} decrypt #{args}`"
  check_file_content output.path, "SECRET\n", true
  output.unlink
end

Given(/^a local file containing private data$/) do
  @resource_name = "dummy.file"
  write_file(@resource_name, "SECRET\n")
end

Given(/^a remote file containing private data in the job "(.*?)"$/) do |job|
  step "a remote file containing \"SECRET\" in the job \"#{job}\""
end
