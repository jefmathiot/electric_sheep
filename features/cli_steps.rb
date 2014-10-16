When(/^I'm working on configuration "(.*?)"$/) do |configuration|
  @sheepfile = "#{acceptance_dir}/#{configuration}"
end

When(/^I tell the sheep to work on project "(.*?)"$/) do |project|
  options="-c #{sheepfile} -p #{project}"
  @project=project
  step "I successfully run `bundle exec #{electric_sheep} work #{options}`"
end

When(/^I tell the sheep to work on failing project "(.*?)"$/) do |project|
  options="-c #{sheepfile} -p #{project}"
  @project=project
  step "I run `bundle exec #{electric_sheep} work #{options}`"
end

Then(/^I am notified that the command failed$/) do
  expect(all_output.include? "The last command failed").to be(true)
end

Then(/^the project "(.*?)" has been executed$/) do |project|
  expect(all_output.include? "Executing #{project}").to be(true)
end

Then(/^the project "(.*?)" hasn't been executed$/) do |project|
  expect(all_output.include? "Executing #{project}").to be(false)
end

When(/^I tell the sheep to work on the project$/) do
  options="-c #{sheepfile} -p #{@project}"
  step "I successfully run `bundle exec #{electric_sheep} work #{options}`"
end

When(/^I tell the sheep to work on configuration "(.*?)"$/) do |config|
  options="-c #{acceptance_dir}/#{config}"
  step "I successfully run `bundle exec #{electric_sheep} work #{options}`"
end

Then(/^the sheep tell me the project is unknown$/) do
  expect(all_output.include? "Project \"unknown\" not present in sheepfile").to be(true)
end
