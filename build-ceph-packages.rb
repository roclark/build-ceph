#!/usr/bin/env ruby
#
# (C) Copyright 2015 Hewlett-Packard Development Company, L.P.
# All rights reserved

require 'fileutils'
require 'optparse'
require 'tmpdir'

require_relative 'cli_options'
require_relative 'distribution'
require_relative 'monkey_patches/string'


VERSION = '0.0.1'

EXIT_SUCCESS = 0

ERROR_GIT = 1
ERROR_DEPENDENCY = 2
ERROR_CONFIG = 3
ERROR_USAGE = 4
ERROR_BUILD = 5

LOG_FILE = Dir.pwd + '/' + File.basename($PROGRAM_NAME, '.*') + '.log'


def delete_dir(tmp_dir)
  if Dir.exists?(tmp_dir)
    FileUtils.rm_rf(tmp_dir)
  end
end

def delete_log
  if File.exist?(LOG_FILE)
    File.delete(LOG_FILE)
  end
end

def pull_repo(branch, repo, tmp_dir)
  puts "Pulling #{branch} branch from the #{repo} repo."
  `git clone \
    --recursive \
    --depth=1 \
    --branch #{branch} \
    #{repo} \
    #{tmp_dir} \
    &>> #{LOG_FILE}`
  fail_if_error(ERROR_GIT, 'Error pulling from git')
end

def fail_if_error(exit_code, message)
  unless $?.success?
    puts "#{message}. Check #{LOG_FILE} for more details."
    exit exit_code
  end
end

def generate_config
  `(./autogen.sh && ./configure) &>> #{LOG_FILE}`
  fail_if_error(ERROR_CONFIG, 'Error setting up the configuration')
end


cli = CliOptions.new
distro = if cli.package_manager == :yum
  RedHat.new
else
  Debian.new
end
delete_log
if !cli.keep_tmpdir
  delete_dir(cli.tmp_dir)
end
pull_repo(cli.branch, cli.repo, cli.tmp_dir)
Dir.chdir(cli.tmp_dir) do
  distro.install_dependencies
  generate_config
  distro.build_packages
end
