#!/usr/bin/env ruby
#
<<<<<<< HEAD
# This script is designed to create packages that will be
# used to install Ceph. The script determines which package
# to create depending on the user's environment (RPM package for
# CentOS 7.1 systems and .deb package for Debian Jesse systems).
#
# In addition, the user can pass optional parameters to select
# which repository and branch to retrieve source from (defaults
# to master branch of HP's repository).
#
# This script is written by Robert Clark and was created on
# Friday May 29 at 2:05PM Central Time
#

require 'getoptlong'

version		=	"0.0.1"		# Current version of the script - use with --version
in_repo		=	"https://github.com/HP-Scale-out-Storage/ceph.git" 	# Default repository to pull from
in_branch	=	"master"	# Default branch to pull from
nodebs		=	false		# Set to true when user gives "--no-debs" parameter
out_dir		=	"outputs"	# Default output directory
out_param	=	false		# Set to true when user gives a valid output parameter
os_support	=	['CentOS 7.1', 'Debian 8.0']	# List of supported operating systems. Add/edit values if future operating systems are to be supported

opts 		= 	GetoptLong.new(
	[ '--help',		'-h', 	GetoptLong::NO_ARGUMENT ],
	[ '--version', 			GetoptLong::NO_ARGUMENT ],
	[ '--branch', 	'-b', 	GetoptLong::REQUIRED_ARGUMENT ],
	[ '--repo', 	'-r',	GetoptLong::REQUIRED_ARGUMENT ],
	[ '--no-debs', 			GetoptLong::NO_ARGUMENT ],
	[ '--output',	'-o',	GetoptLong::REQUIRED_ARGUMENT ]
)

def printusage
	puts "usage: build-ceph-packages [-h|--help] [--version]"
    puts "                           [-b|--branch=<branch-name>] [-r|--repo=<repo-url>]"
    puts "                           [--no-debs] [-o|--output=<path>]"
    puts
    puts "This script builds the Ceph RPM and .deb packages from the specified branch of the specified git repository. On a Debian system, only the .deb packages will be generated. On a RHEL/CentOS system, both the RPM and .deb packages will be built."
    puts
    puts "  -b <branch-name>, --branch=<branch-name>"
    puts "    Use the specified branch of the respository. Default is to use master."
    puts
    puts "  --no-debs"
    puts "    Only generate the RPM packages."
    puts
    puts "  -o <path>, --output <path>"
    puts "    Write the generated packages to the specified path."
    puts
    puts "  -r <repo-url>, --repo=<repo-url>"
    puts "    Use the specified repository. The URL must be the one that git would recognize. If not specified, https://github.com/HP-Scale-out-Storage/ceph will be used."
    puts "  -h, --help      display this help and exit"
    puts "      --version   output version information and exit"
    puts
end

begin
	opts.each do |opt, arg|
		case opt
			# Display the script usage and exit with status 0
			when "--help"
				printusage()

				exit 0

			# Display the current version number of the script and exit with status 0
			when "--version"
				puts "Current version of build-ceph-packages: #{version}"

				exit 0

			# Get the branch as input from the user and store it in the 'branch' variable
			when "--branch"
				in_branch = arg

			# Get the repository as input from the user and store it in the 'repository' variable
			when "--repo"
				in_repo = arg

			# User specified to only generate the RPM packages
			when "--no-debs"
				nodebs = true

			# Set the output directory as specified by the user
			# If the directory already exists, set the output to that directory
			# Otherwise, create the directory
			when "--output"
				out_dir 	= arg
				out_param 	= true

				if File.directory?(arg) == false
					Dir.mkdir(arg)
				end

		end
	end

# Catch exceptions if any - print the usage and exit the script with status 1
rescue
	printusage()

	exit 4
end
			
if out_param == false && File.directory?(out_dir) == false
	Dir.mkdir(out_dir)
end

# Detect the environment the script is being executed on
flavor 			= `lsb_release -s -i`
release 		= `lsb_release -s -r`
release_short	= release.split(".")
release_short 	= release_short[0] + '.' + release_short[1]
puts "Detected running in environment: #{flavor}"
puts "Version number: #{release}" 

# Verify the utility is running in an approved environment
# If not, notify the user and exit the script
# See array "os_support" for list of supported environments
full_ver = "#{flavor} #{release_short}"
full_ver = full_ver.tr("\n", "")

if os_support.include? full_ver
	puts "#{full_ver} is supported"
else
	puts "#{full_ver} is not supported by this script"
	puts "build-ceph-packages requires #{os_support}"
	puts "Exiting script..."
	
	exit 2
end

# Pull the specified branch from the specified repo
puts "Pulling #{in_branch} branch from #{in_repo} repo"
puts `git clone --recursive --depth=1 --branch #{in_branch} #{in_repo}`

exit 0
=======
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

class CliOptions
  attr_reader :repo, :branch, :build_rpms,
                :build_debs, :package_manager

  def initialize
    @repo = 'https://github.com/HP-Scale-out-Storage/ceph.git'
    @branch = 'master'
    @no_debs = false
    @out_dir = ''
    @package_manager = :yum
    self.process_cli_arguments
    self.create_output_directory
    self.determine_package_manager
    self.determine_packages_to_build
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

cli = CliOptions.new
pull_repo(cli.branch, cli.repo)
install_dependencies(cli.package_manager)
>>>>>>> 1536550ac3ae3ad9460a3a19a3cdda8270c9a4d4
