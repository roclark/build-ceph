Then(/^the current git branch should be '([^']*)'$/) do |branch_name|
  pending "will use 'git branch' to see if branch_name is listed"
end

Then(/^the repository should be a clone of '([^']*)'$/) do |repo_name|
  pending "will use 'git config --get remote.origin.url'"
end
