#!/usr/bin/env ruby
#
# (C) Copyright 2015 Hewlett-Packard Development Company, L.P.
# All rights reserved

require 'getoptlong'

VERSION     =   '0.0.1'   # Current version of the script - use with --version
in_repo     =   'https://github.com/HP-Scale-out-Storage/ceph.git' # Default
# repository to pull from
in_branch   =   'master'  # Default branch to pull from
nodebs      =   false   # Set to true when user gives "--no-debs" parameter
out_dir     =   'outputs' # Default output directory
out_param   =   false   # Set to true when user gives a valid output parameter
OS_SUPPORT  =   ['CentOS 7.1', 'Debian 8.0']  # List of supported operating
# systems. Add/edit values if future operating systems are to be supported

opts        =   GetoptLong.new(
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

begin
  opts.each do |opt, arg|
    case opt
    # Display the script usage and exit with status 0
    when '--help'
      usage
      exit 0

    # Display the current version number of the script and exit with status 0
    when '--version'
      puts "Current version of build-ceph-packages: #{VERSION}"
      exit 0

    # Get the branch input from user and store it in the 'in_branch' variable
    when '--branch'
      in_branch = arg

    # Get the repo input from the user and store it in the 'in_repo' variable
    when '--repo'
      in_repo = arg

    # User specified to only generate the RPM packages
    when '--no-debs'
      nodebs = true

    # Set the output directory as specified by the user
    # If the directory already exists, set the output to that directory
    # Otherwise, create the directory
    when '--output'
      out_dir   = arg
      out_param = true

      Dir.mkdir(arg) if File.directory?(arg) == false
    end
  end

# Catch exceptions if any - print the usage and exit the script with status 1
rescue
  usage
  exit 4
end

# If the output directory does not exist yet, create it
if out_param == false && File.directory?(out_dir) == false
  Dir.mkdir(out_dir)
  puts "Creating new directory at #{out_dir}"
end

# Detect the environment the script is being executed on
flavor        = `lsb_release -s -i`
flavor        = flavor.tr("\n", '')
release       = `lsb_release -s -r`
release_short = release.split('.')
release_short = release_short[0] + '.' + release_short[1]
puts "Detected running in environment: #{flavor}"
puts "Version number: #{release}"

# Verify the utility is running in an approved environment
# If not, notify the user and exit the script
# See array "os_support" for list of supported environments
full_ver = "#{flavor} #{release_short}"
full_ver = full_ver.tr("\n", '')

if OS_SUPPORT.include? full_ver
  puts "#{full_ver} is supported"
else
  puts "#{full_ver} is not supported by this script"
  puts "build-ceph-packages requires #{OS_SUPPORT}"
  puts 'Exiting script...'
  exit 2
end

# Pull the specified branch from the specified repo
puts "Pulling #{in_branch} branch from the #{in_repo} repo"
puts `git clone --recursive --depth=1 --branch #{in_branch} #{in_repo}`

# Install the dependencies based on the environment
puts 'Installing dependencies'
if flavor == 'CentOS'
  puts %x(sudo yum install \`cat ceph/deps.rpm.txt\`)
elsif flavor == 'Debian'
  puts %x(sudo apt-get install \`cat ceph/deps.deb.txt\`)
end
