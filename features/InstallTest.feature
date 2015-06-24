Feature: Installs packages and dependencies
  As a developer
  I want the build dependencies to be automatically installed so the build
  won't break for missing dependencies.

  Scenario: Dependencies are installed
    When I run build-ceph
    Then all the dependencies should be installed

  Scenario: A spec file is generated
    When I run build-ceph
    Then a spec file should be created

  Scenario: Check the package has been properly output
    When I run build-ceph
    Then the package should be in the output directory
