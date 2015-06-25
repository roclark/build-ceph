Feature: Builds installation packages
  As a developer
  I want the packages to be output to the specified directory
  so they can be easily retrieved for future use

  Scenario: The packages are created
    When I run build-ceph
    Then the packages should be in the output directory
