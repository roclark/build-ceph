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

GIT_LOG = 'git_log.txt'
DEPENDENCY_LOG = 'dependency_log.txt'

class CLI
  attr_reader :repo, :branch, :build_rpms,
                :build_debs, :package_manager

  def initialize
    @repo = 'https://github.com/HP-Scale-out-Storage/ceph.git'
    @branch = 'master'
    @no_debs = false
    @out_dir = ''
    @package_manager = :yum
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

def pull_repo(branch, repo)
  puts "Pulling #{branch} branch from the #{repo} repo"
  `git clone \
    --recursive \
    --depth=1 \
    --branch #{branch} \
    #{repo} \
    &> #{GIT_LOG}`
  unless $?.success?
    puts "Error pulling from git. Check #{GIT_LOG} for more details."
    exit ERROR_GIT
  end
end

def install_dependencies(package_manager)
  if package_manager == :yum
    `sudo yum -y install \`cat ceph/deps.rpm.txt\` &> #{DEPENDENCY_LOG}`
  else
    `sudo apt-get -y install \`cat ceph/deps.deb.txt\ &> #{DEPENDENCY_LOG}`
  end

  unless $?.success?
    puts "Error installing dependencies. Check #{DEPENDENCY_LOG} for details."
    exit ERROR_DEPENDENCY
  end
end

cli = CLI.new
cli.process_cli_arguments
cli.create_output_directory
cli.determine_package_manager
cli.packages_to_build
pull_repo(cli.branch, cli.repo)
install_dependencies(cli.package_manager)
