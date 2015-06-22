@announce
Feature: Test for all of the package and dependency installations
  As a developer
  I want to verify proper installation of all packages and dependencies

  Background:
    Given I am running on a CentOS or RHEL machine

  Scenario: Check dependencies are properly installed
    When I run build-ceph with ""
    Then the dependencies in the list should all be installed
