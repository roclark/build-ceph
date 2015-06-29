Feature: Builds installation packages
  As a user
  I want the packages to be output to the specified directory
  so I can install ceph easily

  Scenario: The packages are created
    When I run build-ceph
    Then the packages should be in the output directory
