Feature: Removes temporary directories
  As a developer
  I want all of the temporary directories I created to be deleted
  so I am not wasting space on my machine

  Scenario: Directory is removed on successful completion
    When I run build-ceph
    Then the temporary directory should not exist

  Scenario: Directory is removed on unsuccessful exit
    When I run build-ceph with "-b badbranch"
    Then the temporary directory should not exist

  Scenario: '-k' keeps the temporary directory
    When I run build-ceph with "-k"
    Then the temporary directory should exist

  Scenario: '--keep-tmpdir' keeps the temporary directory
    When I run build-ceph with "--keep-tmpdir"
    Then the temporary directory should exist