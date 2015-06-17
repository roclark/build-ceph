Then(/^the current git branch should be '([^']*)'$/) do |branch_name|
  expect(`cd /tmp/build-ceph-tmp/ && git branch`).to match branch_name
end

Then(/^the repository should be a clone of '([^']*)'$/) do |repo_name|
  expect(`cd /tmp/build-ceph-tmp/ && git config --get remote.origin.url`).to \
    match repo_name
end

Then /^it should (pass|fail) with "([^"]*)"$/ do |pass_fail, partial_output|
  self.__send__("assert_#{pass_fail}ing_with", partial_output)
end
