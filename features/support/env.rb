require 'aruba/cucumber'
require 'rspec/expectations'

TMP_DIR = '/tmp/build-ceph-tmp'

Before do
  @dirs = Dir.pwd
end

Before do
  @aruba_timeout_seconds = 240
end
