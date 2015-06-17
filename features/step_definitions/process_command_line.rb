Then(/^the current git branch should be '([^']*)'$/) do |branch_name|
  puts `cd /tmp/build-ceph-tmp/ && git branch`
  #pending "will use 'git branch' to see if branch_name is listed"
end

Then(/^the repository should be a clone of '([^']*)'$/) do |repo_name|
  puts `cd /tmp/build-ceph-tmp/ && git config --get remote.origin.url && pwd`
  #pending "will use 'git config --get remote.origin.url'"
end

Then /^it should (pass|fail) with "([^"]*)"$/ do |pass_fail, partial_output|
  self.__send__("assert_#{pass_fail}ing_with", partial_output)
end
