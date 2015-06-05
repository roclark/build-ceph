#!/usr/bin/env ruby
#
# (C) Copyright 2015 Hewlett-Packard Development Company, L.P.
# All rights reserved

require 'optparse'


VERSION = '0.0.1'

EXIT_SUCCESS = 0

ERROR_GIT = 1
ERROR_DEPENDENCY = 2
ERROR_USAGE = 4

LOG_FILE = File.basename($PROGRAM_NAME, '.*') + '.log'


class CliOptions
  attr_reader :repo, :branch, :build_rpms,
                :build_debs, :package_manager

  def initialize
    @repo = 'https://github.com/HP-Scale-out-Storage/ceph.git'
    @branch = 'master'
    @no_debs = false
    @out_dir = ''
    @package_manager = :yum
    process_cli_arguments
    create_output_directory
    determine_package_manager
    determine_packages_to_build
  end

  def create_output_directory
    unless @out_dir.empty? || File.directory?(@out_dir)
      Dir.mkdir(@out_dir)
    end
  end

  def usage
    puts <<EOS
    usage: build-ceph-packages [-h|--help] [--version]
                         [-b|--branch=<branch-name>] [-r|--repo=<repo-url>]
                         [--no-debs] [-o|--output=<path>]

    This script builds the Ceph RPM and .deb packages from the specified branch
    of the specified git repository. On a Debian system, only the .deb packages
    will be generated. On a RHEL/CentOS system, both the RPM and .deb packages
    will be built.

    -b <branch-name>, --branch=<branch-name>
        Use the specified branch of the respository. Default is to use master.

    --no-debs
        Only generate the RPM packages.

    -o <path>, --output <path>
        Write the generated packages to the specified path.

    -r <repo-url>, --repo=<repo-url>
        Use the specified repository. The URL must be the one that git would
        recognize. If not specified,
        https://github.com/HP-Scale-out-Storage/ceph will be used.

    -h, --help      display this help and exit

        --version   output version information and exit
EOS
  end

  def process_cli_arguments
    OptionParser.new do |option|
      option.banner = usage

      option.on('-h', '--help') do
        exit EXIT_SUCCESS
      end

      option.on('--version') do
        puts "#{$PROGRAM_NAME}: #{VERSION}"
        exit EXIT_SUCCESS
      end

      option.on('--branch [BRANCH]', '-b') do |branch|
        @branch = branch
      end

      option.on('--repo [REPO]', '-r') do |repo|
        @repo = repo
      end

      option.on('--no-debs') do
        @no_debs = true
      end

      option.on('--output [OUTPUT]', '-o') do |output|
        @out_dir = output
      end
    end.parse!
  end

  def determine_package_manager
    if File.exist?('/etc/yum')
      @package_manager = :yum
    else
      @package_manager = :apt
    end
  end

  def determine_packages_to_build
    if `lsb_release -is`.match(/RHEL|CentOS/)
      @build_rpms = true
      @build_debs = !@no_debs
    else
      @build_rpms = false
      @build_debs = true
    end
  end
end

def pull_repo(branch, repo)
  puts "Pulling #{branch} branch from the #{repo} repo."
  `git clone \
    --recursive \
    --depth=1 \
    --branch #{branch} \
    #{repo} \
    &> #{LOG_FILE}`
  unless $?.success?
    fatal_error(ERROR_GIT, "Error pulling from git")
  end
end

def install_dependencies(package_manager)
  if package_manager == :yum
    `sudo yum -y install \`cat ceph/deps.rpm.txt\` &> #{LOG_FILE}`
  else
    `sudo apt-get -y install \`cat ceph/deps.deb.txt\ &> #{LOG_FILE}`
  end

  unless $?.success?
    fatal_error(ERROR_DEPENDENCY, "Error installing dependencies")
  end
end

def fatal_error(exit_code, message)
  puts "#{message}. Check #{LOG_FILE} for more details."
  exit exit_code
end

cli = CliOptions.new
pull_repo(cli.branch, cli.repo)
install_dependencies(cli.package_manager)
