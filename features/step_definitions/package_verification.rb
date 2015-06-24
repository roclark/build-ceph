Then /^the dependencies in the list should all be installed$/ do
  IO.foreach("#{RPM_DEP_LIST}") do |line|
    expect(`rpm --query #{line}`).to match(/#{line}-/)
  end
end

Then /^a spec file should be created$/ do
  check_file_presence("#{CEPH_SPEC}", true)
end

Then /^the packages should be in the output directory$/ do
  check_file_presence('ceph.deb', true)
end
