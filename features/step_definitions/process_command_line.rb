Then(/^the current branch in git should indicate `([^`]*)`$/) do |branch_name|
  pending # Planning on using `git branch` and checking if 'branch_name' is
  # listed, but can't figure out how to use it on my tmp_dir
end

Then(/^the current repo in git should indicate `([^`]*)`$/) do |repo_name|
  pending # Same as above, but planning on using `git config --get
  # remote.origin.url`
end
