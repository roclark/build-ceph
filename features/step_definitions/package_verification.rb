Given /^I am running on a CentOS or RHEL machine$/ do
  expect(`lsb_release -is`).to match(/RHEL|CentOS/)
end

Then /^the dependencies in the list should all be installed$/ do
  IO.foreach("#{RPM_DEP_LIST}") do |line|
    expect(`rpm -qa | grep -o #{line}`).to match line
  end
end

Then /^a spec file should be created$/ do
  check_file_presence("#{CEPH_SPEC}", true)
end

Then /^the package should be in the output directory$/ do
  check_file_presence('ceph.deb', true)
end
