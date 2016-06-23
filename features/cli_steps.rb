When(/^I'm working on configuration "(.*?)"$/) do |configuration|
  @sheepfile = "#{acceptance_dir}/#{configuration}"
end

Then(/^I should be able to tell the sheep to work on job "(.*?)"$/) do |job|
  options = "-c #{sheepfile} -j \"#{job}\""
  @job = job
  step "I successfully run `bundle exec #{electric_sheep} work #{options}`"
end

When(/^I tell the sheep to work on job "(.*?)"$/) do |job|
  options = "-c #{sheepfile} -j \"#{job}\""
  @job = job
  step "I successfully run `bundle exec #{electric_sheep} work #{options}`"
end

When(/^I tell the sheep to work on failing job "(.*?)"$/) do |job|
  options = "-c #{sheepfile} -j \"#{job}\""
  @job = job
  step "I run `bundle exec #{electric_sheep} work #{options}`"
  step 'the exit status should be 1'
end

Then(/^the job "(.*?)" has been executed$/) do |job|
  expect(all_commands.map(&:output).join("\n"))
    .to match(/Executing \"#{job}\"/)
end

Then(/^the job "(.*?)" hasn't been executed$/) do |job|
  expect(all_commands.map(&:output).join("\n"))
    .to_not match(/Executing \"#{job}\"/)
end

When(/^I tell the sheep to work on the job$/) do
  options = "-c #{sheepfile} -j \"#{@job}\""
  step "I run `bundle exec #{electric_sheep} work #{options}`"
end

When(/^I tell the sheep to work on configuration "(.*?)"$/) do |config|
  options = "-c #{acceptance_dir}/#{config}"
  step "I run `bundle exec #{electric_sheep} work #{options}`"
end

Then(/^the program warns me the job is unknown$/) do
  step 'the output should match /job "unknown" does not exist/'
end

Then(/^the program warns me an "(.*?)" error occured$/) do |error|
  step "the output should match /#{error}/"
end
