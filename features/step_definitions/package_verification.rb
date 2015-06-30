def redhat?
  `lsb_release -is`.match(/RHEL|CentOS/i)
end


When /^I run build-ceph on RHEL$/ do
  if redhat?
    run_simple("bin/build-ceph-packages -t #{TMP_DIR}", false)
  end
end

When /^I run build-ceph on Debian$/ do
  if !redhat?
    run_simple("bin/build-ceph-packages -t #{TMP_DIR}", false)
  end
end

Then /^the dependencies in the list should all be installed$/ do
  IO.foreach(RPM_DEP_LIST) do |line|
    expect(`rpm --query #{line}`).to match(/#{line}-/)
  end
end

Then /^a spec file should be created$/ do
  check_file_presence(CEPH_SPEC, true)
end

Then /^the DEB packages should be in the output directory$/ do
  File.open(DEB_PACKAGE_LIST).each do |filename|
    check_file_presence("#{filename.chomp}.deb", true)
  end
end

Then /^the RPM packages should be in the output directory$/ do
  File.open(DEB_PACKAGE_LIST).each do |filename|
    check_file_presence("#{filename.chomp}.rpm", true)
  end
end
