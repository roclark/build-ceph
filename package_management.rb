# (C) Copyright 2015 Hewlett-Packard Development Company, L.P.
# All rights reserved

class PackageManager
  attr_reader :build_debs, :build_rpms, :distro, :package_manager

  def initialize(no_debs)
    @no_debs = no_debs
    @package_manager = :yum
    determine_package_manager
    determine_packages_to_build
    @distro = determine_distro
  end

  private

  def determine_package_manager
    if File.exist?('/etc/yum')
      @package_manager = :yum
    else
      @package_manager = :apt
    end
  end

  def determine_packages_to_build
    if `lsb_release -is`.match(/RHEL|CentOS/i)
      @build_rpms = true
      @build_debs = !@no_debs
    else
      @build_rpms = false
      @build_debs = true
    end
  end

  def determine_distro
    if @package_manager == :yum
      return RedHat.new
    else
      return Debian.new
    end
  end
end
