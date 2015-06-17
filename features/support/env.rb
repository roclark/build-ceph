require 'aruba/cucumber'
require 'rspec/expectations'


Before do
  @dirs = Dir.pwd
end

Before do
  @aruba_timeout_seconds = 240
end
