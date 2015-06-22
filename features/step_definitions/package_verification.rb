Given /^I am running on a CentOS machine$/ do
  expect(`lsb_release -is`).to match(/RHEL|CentOS/)
end

Then /^the dependencies in the list should all be installed$/ do
  IO.foreach("#{RPM_DEP_LIST}") do |line|
    expect(`rpm -qa | grep -o #{line}`).to match line
  end
end
