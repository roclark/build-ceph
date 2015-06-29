Feature: Builds installation packages
  As a user
  I want the packages to be output to the specified directory
  so I can install ceph easily

  Scenario: Run on RHEL/CentOS
    When I run build-ceph on RHEL
    Then the RPM packages should be in the output directory
    And the DEB packages should be in the output directory

  Scenario: Run on Debian
    When I run build-ceph on Debian
    Then the DEB packages should be in the output directory
