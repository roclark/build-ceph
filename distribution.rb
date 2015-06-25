# (C) Copyright 2015 Hewlett-Packard Development Company, L.P.
# All rights reserved

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
    fail_if_error(ERROR_BUILD, 'Error building RPM package')
  end

  def install_dependencies
    %x{sudo yum -y install `cat deps.rpm.txt` &>> #{LOG_FILE}}
    fail_if_error(ERROR_DEPENDENCY, 'Error installing dependencies')
  end
end


class Debian < Distribution
  def build_packages
    `(sudo apt-get install dpkg-dev && dpkg-checkbuilddeps && dpkg-build) \
      &>> #{LOG_FILE}`
    fail_if_error(ERROR_BUILD, 'Error building .deb package')
  end

  def install_dependencies
    %x{sudo apt-get -y install `cat deps.deb.txt` &>> #{LOG_FILE}}
    fail_if_error(ERROR_DEPENDENCY, 'Error installing dependencies')
  end
end
