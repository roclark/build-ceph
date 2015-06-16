require 'rspec/expectations'
require 'aruba'
require 'aruba/config'
include RSpec::Matchers

Given(/^([^`]*) exists$/) do |file_name|
  check_file_presence(Dir.pwd + '/' + file_name, true)
end
