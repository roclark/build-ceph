#!/usr/bin/env ruby
#
# (C) Copyright 2015 Hewlett-Packard Development Company, L.P.
# All rights reserved

require 'getoptlong'

VERSION = '0.0.1'   # Current version of the script - use with --version
ERROR_UNSUPPORTED_OS = 2
ERROR_USAGE = 4
repo = 'https://github.com/HP-Scale-out-Storage/ceph.git' # Default
# repository to pull from
branch = 'master'  # Default branch to pull from
no_debs = false   # Set to true when user gives "--no-debs" parameter
out_dir = '' # Default output directory
OS_SUPPORT = [ # List of currently supported OS environments.
  'CentOS 7.1', 
  'Debian 8.0',
]

opts = GetoptLong.new(
  ['--help',     '-h',  GetoptLong::NO_ARGUMENT],
  ['--version',         GetoptLong::NO_ARGUMENT],
  ['--branch',   '-b',  GetoptLong::REQUIRED_ARGUMENT],
  ['--repo',     '-r',  GetoptLong::REQUIRED_ARGUMENT],
  ['--no-debs',         GetoptLong::NO_ARGUMENT],
  ['--output',   '-o',  GetoptLong::REQUIRED_ARGUMENT]
)

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

  --no-debs"
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
  begin
    opts.each do |option, argument|
      case option
      when '--help'
        usage
        exit 0

      when '--version'
        puts "#{$PROGRAM_NAME}"
        exit 0

      when '--branch'
        branch = argument

      when '--repo'
        repo = argument

      when '--no-debs'
        no_debs = true

      when '--output'
        out_dir = argument
        Dir.mkdir(argument) unless File.directory?(argument)
      end
    end

  rescue
    usage
    exit ERROR_USAGE
  end
end

if out_dir != '' && File.directory?(out_dir) == false
  Dir.mkdir(out_dir)
  puts "Creating new directory at #{out_dir}"
end

flavor = `lsb_release -s -i`
flavor = flavor.tr("\n", '')
release = `lsb_release -s -r`
release_short = release.split('.')
release_short = release_short[0] + '.' + release_short[1]
puts "Detected running in environment: #{flavor}"
puts "Version number: #{release}"

full_ver = "#{flavor} #{release_short}"
full_ver = full_ver.tr("\n", '')

if OS_SUPPORT.include? full_ver
  puts "#{full_ver} is supported"
else
  puts "#{full_ver} is not supported by this script"
  puts "build-ceph-packages requires #{OS_SUPPORT}"
  puts 'Exiting script...'
  exit ERROR_UNSUPPORTED_OS
end

puts "Pulling #{branch} branch from the #{repo} repo"
puts `git clone --recursive --depth=1 --branch #{branch} #{repo}`

puts 'Installing dependencies'
if flavor == 'CentOS'
  puts %x(sudo yum install \`cat ceph/deps.rpm.txt\`)
elsif flavor == 'Debian'
  puts %x(sudo apt-get install \`cat ceph/deps.deb.txt\`)
end
