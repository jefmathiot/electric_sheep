When(/^I tell the sheep to work on project "(.*?)"$/) do |project|
  options="-c #{sheepfile} -p #{project}"
  @project=project
  step "I successfully run `bundle exec #{electric_sheep} work #{options}`"
end

When(/^I tell the sheep to work on the project$/) do
  options="-c #{sheepfile} -p #{@project}"
  step "I successfully run `bundle exec #{electric_sheep} work #{options}`"
end

When(/^I tell the sheep to work on configuration "(.*?)"$/) do |config|
  options="-c #{acceptance_dir}/#{config}"
  step "I successfully run `bundle exec #{electric_sheep} work #{options}`"
end
