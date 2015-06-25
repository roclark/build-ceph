Then /^the dependencies in the list should all be installed$/ do
  IO.foreach(RPM_DEP_LIST) do |line|
    expect(`rpm --query #{line}`).to match(/#{line}-/)
  end
end

Then /^a spec file should be created$/ do
  check_file_presence("#{CEPH_SPEC}", true)
end

Then /^the packages should be in the output directory$/ do
  if `lsb_release -is`.match(/RHEL|CentOS/)
    %w[ceph-common fuse rbd-fuse devel radosgw resource-agents librados2
      libradosstriper1 librbd1 libcephfs1 python-ceph rest-bench ceph-test
      libcephfs_jni1 cephfs-java libs-compat].each do |filename|
      check_file_presence("#{filename}.rpm", true)
    end
  else
    %w[ceph ceph-dbg ceph-mds ceph-mds-dbg ceph-fuse ceph-fuse-dbg rbd-fuse
      rbd-fuse-dbg ceph-common ceph-common-dbg ceph-fs-common
      ceph-fs-common-dbg ceph-resource-agents librados2 librados2-dbg
      librados-dev libradosstriper1 libradosstriper-dev librbd1 librbd1-dbg
      librbd-dev libcephfs1 libcephfs1-dbg libcephfs-dev radosgw radosgw-dbg
      rest-bench rest-bench-dbg ceph-test ceph-test-dbg python-ceph
      libcephfs-java libcephfs-jni].each do |filename|
      check_file_presence("#{filename}.deb", true)
    end
  end
end
