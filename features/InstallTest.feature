Feature: Test for all of the package and dependency installations
  As a developer
  I want to verify proper installation of all packages and dependencies

  Background:
    Given I am running on a CentOS or RHEL machine

  Scenario: Check dependencies are properly installed
    When I run build-ceph with ""
    Then the dependencies in the list should all be installed

  Scenario: Check that a spec file is created properly
    When I run build-ceph with ""
    Then a spec file should be created

  Scenario: Check the package has been properly output
    When I run build-ceph with ""
    Then the package should be in the output directory
