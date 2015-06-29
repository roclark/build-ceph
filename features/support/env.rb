require 'aruba/cucumber'
require 'rspec/expectations'


CEPH_SPEC = 'ceph.spec'
DEB_PACKAGE_LIST = 'deb_package_list.txt'
TMP_DIR = '/tmp/build-ceph-tmp'
RPM_PACKAGE_LIST = 'rpm_package_list.txt'
RPM_DEP_LIST = File.join("#{TMP_DIR}", 'deps.rpm.txt')


Before do
  @dirs = Dir.pwd
end

Before do
  @aruba_timeout_seconds = 240
end
