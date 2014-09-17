When(/^I tell the sheep to work on project "(.*?)"$/) do |project|
  options="-c #{sheepfile} -p #{project}"
  @project=project
  step "I successfully run `bundle exec #{electric_sheep} work #{options}`"
end

