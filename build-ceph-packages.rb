#!/usr/bin/env ruby
#
# (C) Copyright 2015 Hewlett-Packard Development Company, L.P.
# All rights reserved

require 'getoptlong'

VERSION = '0.0.1'   # Current version of the script - use with --version
EXIT_SUCCESS = 0
ERROR_USAGE = 4

class Ceph
  def initialize
    @repo = 'https://github.com/HP-Scale-out-Storage/ceph.git'  # Default
    # repository to pull from
    @branch = 'master'  # Default branch to pull from
    @no_debs = false  # Set to true when user gives "--no-debs" parameter
    @out_dir = '' # Default output directory
  end

  attr_accessor :repo, :branch, :no_debs, :out_dir, :build_rpms, :build_debs
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

def process_cli_arguments(ceph)
  opts = GetoptLong.new(
    ['--help',     '-h',  GetoptLong::NO_ARGUMENT],
    ['--version',         GetoptLong::NO_ARGUMENT],
    ['--branch',   '-b',  GetoptLong::REQUIRED_ARGUMENT],
    ['--repo',     '-r',  GetoptLong::REQUIRED_ARGUMENT],
    ['--no-debs',         GetoptLong::NO_ARGUMENT],
    ['--output',   '-o',  GetoptLong::REQUIRED_ARGUMENT]
  )

  begin
    opts.each do |opt, arg|
      case opt
      when '--help'
        usage
        exit EXIT_SUCCESS

      when '--version'
        puts "#{$PROGRAM_NAME}: #{VERSION}"
        exit EXIT_SUCCESS

      when '--branch'
        ceph.branch = arg

      when '--repo'
        ceph.repo = arg

      when '--no-debs'
        ceph.no_debs = true

      when '--output'
        ceph.out_dir = arg
        Dir.mkdir(arg) unless File.directory?(arg)

      else
        usage
        exit ERROR_USAGE
      end
    end
  end
end

def create_output_directory(ceph)
  if ceph.out_dir != '' && File.directory?(ceph.out_dir) == false
    Dir.mkdir(ceph.out_dir)
  end
end

def check_environment(ceph)
  if `lsb_release -is`.match(/RHEL|CentOS/)
    ceph.build_rpms = true
    ceph.build_debs = !ceph.no_debs
  else
    ceph.build_rpms = false
    ceph.build_debs = true
  end
end

def pull_repo(ceph)
  puts "Pulling #{ceph.branch} branch from the #{ceph.repo} repo"
  puts `git clone --recursive --depth=1 --branch #{ceph.branch} #{ceph.repo}`

  if flavor == 'CentOS'
    puts %x(sudo yum install \`cat ceph/deps.rpm.txt\`)
  elsif flavor == 'Debian'
    puts %x(sudo apt-get install \`cat ceph/deps.deb.txt\`)
  end
end

ceph = Ceph.new
process_cli_arguments(ceph)
create_output_directory(ceph)
check_environment(ceph)
pull_repo(ceph)
