#!/usr/bin/env ruby
#
# (C) Copyright 2015 Hewlett-Packard Development Company, L.P.
# All rights reserved

require 'optparse'
require 'tmpdir'
require 'fileutils'


VERSION = '0.0.1'

EXIT_SUCCESS = 0

ERROR_GIT = 1
ERROR_DEPENDENCY = 2
ERROR_CONFIG = 3
ERROR_USAGE = 4
ERROR_BUILD = 5

LOG_FILE = Dir.pwd + '/' + File.basename($PROGRAM_NAME, '.*') + '.log'


class String
  def strip_heredoc
    indent = scan(/^[ \t]*(?=\S)/).min_by(&:size).size || 0
    gsub(/^[\t]{#{indent}}/,'').chomp
  end
end


class CliOptions
  attr_reader :branch, :build_debs, :build_rpms,
              :keep_tmpdir, :repo, :tmp_dir

  def initialize
    @repo = 'https://github.com/HP-Scale-out-Storage/ceph.git'
    @branch = 'master'
    @no_debs = false
    @out_dir = ''
    @package_manager = :yum
    @tmp_dir = Dir.mktmpdir
    @keep_tmpdir = false
    process_cli_arguments
    create_output_directory
    determine_package_manager
    determine_packages_to_build
  end

  private

  def create_output_directory
    unless @out_dir.empty? || File.directory?(@out_dir)
      Dir.mkdir(@out_dir)
    end
  end

  def usage
    puts <<-EOS.strip_heredoc
    usage: build-ceph-packages [-h|--help] [--version]
                         [-b|--branch=<branch-name>] [-r|--repo=<repo-url>]
                         [--no-debs] [-o|--output=<path>]
                         [-t|--tmpdir=<tmp-dir>] [-k|--keep-tmpdir]

    This script builds the Ceph RPM and .deb packages from the specified branch
    of the specified git repository. On a Debian system, only the .deb packages
    will be generated. On a RHEL/CentOS system, both the RPM and .deb packages
    will be built.
    EOS
  end

  def process_cli_arguments
    OptionParser.new do |option|
      option.banner = usage

      option.on('-b', '--branch=<branch-name>', <<-EOS.strip_heredoc) do |branch|
          Use the specified branch of the repository. Default is to use master.
          EOS
        @branch = branch
      end

      option.on('-h', '--help') do
        puts option
        exit EXIT_SUCCESS
      end

      option.on('-k', '--keep-tmpdir') do
        @keep_tmpdir = true
      end

      option.on('--no-debs') do
        @no_debs = true
      end

      option.on('-o', '--output=<output-file>') do |output|
        @out_dir = output
      end

      option.on('-r', '--repo=<repo-url>', <<-EOS.strip_heredoc) do |repo|
          Use the specified repository. The URL must be one that git would
          recognize. If not specified,
          https://github.com/HP-Scale-out-Storage/ceph will be used.
          EOS
        @repo = repo
      end

      option.on('-t', '--tmpdir=<tmp-dir>', <<-EOS.strip_heredoc) do |tmp_dir|
          Use the specified temporary directory. Default is to use a randomly
          generated tmp directory.
          EOS
        @tmp_dir = tmp_dir
      end

      option.on('--version') do
        puts "#{$PROGRAM_NAME}: #{VERSION}"
        exit EXIT_SUCCESS
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


class Distribution
  def initialize
  end

  def build_packages
    fail "This method must be implemented."
  end

  def install_dependencies
    fail "This method must be implemented."
  end
end


class RedHat < Distribution
  def build_packages
    `rpmbuild -ba ceph.spec &>> #{LOG_FILE}`
    unless $?.success?
      fail_error(ERROR_BUILD, 'Error building RPM package')
    end
  end

  def install_dependencies
    %x{sudo yum -y install `cat deps.rpm.txt` &>> #{LOG_FILE}}
    unless $?.success?
      fail_error(ERROR_DEPENDENCY, 'Error installing dependencies')
    end
  end
end


class Debian < Distribution
  def build_packages
    `(sudo apt-get install dpkg-dev && dpkg-checkbuilddeps && dpkg-build) \
      &>> #{LOG_FILE}`
    unless $?.success?
      fail_error(ERROR_BUILD, 'Error building .deb package')
  end

  def install_dependencies
    %x{sudo apt-get -y install `cat deps.deb.txt` &>> #{LOG_FILE}}
    unless $?.success?
      fail_error(ERROR_DEPENDENCY, 'Error installing dependencies')
    end
  end
end


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
  unless $?.success?
    fatal_error(ERROR_GIT, 'Error pulling from git')
  end
end

def fatal_error(exit_code, message)
  puts "#{message}. Check #{LOG_FILE} for more details."
  exit exit_code
end

def generate_config
  `(./autogen.sh && ./configure) &>> #{LOG_FILE}`
  unless $?.success?
    fatal_error(ERROR_CONFIG, 'Error setting up the configuration')
  end
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
