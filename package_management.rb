# (C) Copyright 2015 Hewlett-Packard Development Company, L.P.
# All rights reserved

class PackageManagement
  attr_reader :build_debs, :build_rpms, :no_debs, :package_manager

  def initialize(no_debs=false)
    @no_debs = no_debs
    @package_manager = :yum
    determine_package_manager
    determine_packages_to_build
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
end
