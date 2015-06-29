def redhat?
  `lsb_release -is`.match(/REHL|CentOS/i)
end


Then /^the dependencies in the list should all be installed$/ do
  IO.foreach(RPM_DEP_LIST) do |line|
    expect(`rpm --query #{line}`).to match(/#{line}-/)
  end
end

Then /^a spec file should be created$/ do
  check_file_presence("#{CEPH_SPEC}", true)
end

Then /^the packages should be in the output directory$/ do
  if redhat?
    File.open(RPM_PACKAGE_LIST).each do |filename|
      check_file_presence("#{filename.gsub("\n","")}.rpm", true)
    end
  else
    File.open(DEB_PACKAGE_LIST).each do |filename|
      check_file_presence("#{filename.gsub("\n","")}.deb", true)
    end
  end
end
