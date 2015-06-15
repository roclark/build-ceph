require 'rspec/expectations'
require 'aruba'
include RSpec::Matchers

When(/^I run "([^"]*)"$/) do |command|
  @output = `#{command}`
end

Then(/^the output should contain "([^"]*)"$/) do |expected_result|
  expect(@output).to include(expected_result)
end

Then(/^the exit status should be 0$/) do
  expect($?.exitstatus).to be_zero
end

Then(/^it should fail with$/) do |string|
  expect(@output).to include(string)
end
