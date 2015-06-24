When /^I run build-ceph$/ do
  run_simple("bin/build-ceph-packages -t #{TMP_DIR}", false)
end

When /^I run build-ceph with "([^"]*)"$/ do |options|
  run_simple("bin/build-ceph-packages #{options} -t #{TMP_DIR}", false)
end

Then /^the current git branch should be '([^']*)'$/ do |branch_name|
  command = "cd #{TMP_DIR} && git branch"
  expect(`#{command}`).to match branch_name
end

Then /^the repository should be a clone of '([^']*)'$/ do |repo_name|
  command = "cd #{TMP_DIR} && git config --get remote.origin.url"
  expect(`#{command}`).to match repo_name
end

Then /^it should (pass|fail) with "([^"]*)"$/ do |pass_fail, partial_output|
  self.__send__("assert_#{pass_fail}ing_with", partial_output)
end
