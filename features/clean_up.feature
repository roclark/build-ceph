Feature: Removes temporary ceph directories
  As a developer
  I want all of the temporary directories I created to be deleted
  so I am not wasting space on my machine

  Scenario: Directory is removed on successful completion
    When I run build-ceph
    Then the temporary directory should be removed

  Scenario: Directory is removed on unsuccessful exit
    When I run build-ceph with "-b badbranch"
    Then the temporary directory should be removed

  Scenario: '-k' keeps the temporary directory
    When I run build-ceph with "-k"
    Then the temporary directory should not be removed
