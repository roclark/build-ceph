require 'aruba/cucumber'
require 'rspec/expectations'

TMP_DIR = '/tmp/build-ceph-tmp'
RPM_DEP_LIST = File.join("#{TMP_DIR}", 'deps.rpm.txt')
RPM_NAME = 'ceph-0.88.tar.bz2'

Before do
  @dirs = Dir.pwd
end

Before do
  @aruba_timeout_seconds = 240
end
