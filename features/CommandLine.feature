Feature: Process Command Line Arguments
  As a developer
  I want the script to support configuration options
  So I can customize the installation to my environment, which may need a different repository or branch

  Scenario: Default branch is master
    When I run `build-ceph-packages`
    Then the current branch in git should indicate `master`

  Scenario: Default repo is https://github.com/HP-Scale-out-Storage/ceph.git
    When I run `build-ceph-packages`
    Then the current repo in git should indicate `https://github.com/HP-Scale-out-Storage/ceph.git`

  Scenario: Use -r to set a new repository
    When I run `build-ceph-packages -r https://github.com/ceph/ceph.git`
    Then the current repo in git should indicate `https://github.com/ceph/ceph.git`

  Scenario: Use --repo to set a new repository
    When I run `build-ceph-packages --repo https://github.com/ceph/ceph.git`
    Then the current repo in git should indicate `https://github.com/ceph/ceph.git`

  Scenario: Use -b to set a new branch
    When I run `build-ceph-packages -b argonaut`
    Then the current branch in git should indicate `argonaut`

  Scenario: Use --branch to set a new branch
    When I run `build-ceph-packages --branch argonaut`
    Then the current branch in git should indicate `argonaut`

  Scenario: Use --help to display the help message and exit 0
    When I run `build-ceph-packages --help`
    Then the output should contain "usage: build-ceph-packages"
    And the exit status should be 0

  Scenario: Invalid repository returns an error message
    When I run `build-ceph-packages -r https://bad.repo.com`
    Then the current repo in git should indicate `https://bad.repo.com`
    And it should fail with:
      """
      Error pulling from git
      """

  Scenario: Invalid branch returns an error message
    When I run `build-ceph-packages -b badbranch`
    Then the current branch in git should indicate `badbranch`
    And it should fail with:
      """
      Error pulling from git
      """
