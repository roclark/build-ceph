#!/usr/bin/env ruby
#
# (C) Copyright 2015 Hewlett-Packard Development Company, L.P.
# All rights reserved

require 'getoptlong'
require 'optparse'

VERSION = '0.0.1'   # Current version of the script - use with --version

EXIT_SUCCESS = 0

ERROR_GIT = 1
ERROR_DEPENDENCY = 2
ERROR_USAGE = 4

GIT_LOG = 'git_log.txt'
DEPENDENCY_LOG = 'dependency_log.txt'

class CLI
  def initialize
    @repo = 'https://github.com/HP-Scale-out-Storage/ceph.git'  # Default
    # repository to pull from
    @branch = 'master'  # Default branch to pull from
    @no_debs = false  # Set to true when user gives "--no-debs" parameter
    @out_dir = '' # Default output directory
    @package_manager = :yum
  end

  def create_output_directory
    unless @out_dir.empty? || File.directory?(@out_dir)
      Dir.mkdir(@out_dir)
    end
  end

  attr_accessor :repo, :branch, :no_debs, :out_dir, :build_rpms,
                :build_debs, :package_manager

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
      option.on('-h', '--help') do
        usage
        exit EXIT_SUCCESS
      end

      option.on('--version') do
        puts "#{$PROGRAM_NAME}: #{VERSION}"
        exit EXIT_SUCCESS
      end

      option.on('--branch [BRANCH]', '-b') do |b|
        @branch = b
      end

      option.on('--repo [REPO]', '-r') do |r|
        @repo = r
      end

      option.on('--no-debs') do
        @no_debs = true
      end

      option.on('--output [OUTPUT]', '-o') do |o|
        @out_dir = o
      end
    end.parse!
  end

  def select_package_manager
    @package_manager = :apt unless File.exist?('/etc/yum')
  end

  def packages_to_build
    if `lsb_release -is`.match(/RHEL|CentOS/)
      @build_rpms = true
      @build_debs = !@no_debs
    else
      @build_rpms = false
      @build_debs = true
    end
  end
end

def pull_repo(cli)
  puts "Pulling #{cli.branch} branch from the #{cli.repo} repo"
  `git clone --recursive --depth=1 --branch #{cli.branch} #{cli.repo} > #{GIT_LOG} 2>&1`
  unless $? == 0
    puts "Error pulling from git. Check #{GIT_LOG} for more details"
    exit ERROR_GIT
  end
end

def install_dependencies(cli)
  if cli.package_manager == :yum
    puts %x(sudo yum -y install \`cat ceph/deps.rpm.txt\` > #{DEPENDENCY_LOG} 2>&1)
    unless $? == 0
      puts "Error installing dependencies. Check #{DEPENDENCY_LOG} for more details."
      exit ERROR_DEPENDENCY
    end
  elsif cli.package_manager == :apt
    puts %x(sudo apt-get -y install \`cat ceph/deps.deb.txt\` > #{DEPENDENCY_LOG} 2>&1)
    unless $? == 0
      puts "Error installing dependencies. Check #{DEPENDENCY_LOG} for more details."
      exit ERROR_DEPENDENCY
    end
  end
end

cli = CLI.new
cli.process_cli_arguments
cli.create_output_directory
cli.select_package_manager
cli.packages_to_build
pull_repo(cli)
install_dependencies(cli)
