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
