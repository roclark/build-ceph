Feature: Process Command Line Arguments
  As a developer
  I want the script to support configuration options
  So I can customize the installation to my environment, which may need a different repository or branch

  Scenario: Default branch is master
    When I run build-ceph with ""
    Then the current git branch should be 'master'

  Scenario: Default repo is https://github.com/HP-Scale-out-Storage/ceph.git
    When I run build-ceph with ""
    Then the repository should be a clone of 'https://github.com/HP-Scale-out-Storage/ceph.git'

  Scenario: Use -r to set a new repository
    When I run build-ceph with "-r https://github.com/ceph/ceph.git"
    Then the repository should be a clone of 'https://github.com/ceph/ceph.git'

  Scenario: Use --repo to set a new repository
    When I run build-ceph with "--repo https://github.com/ceph/ceph.git"
    Then the repository should be a clone of 'https://github.com/ceph/ceph.git'

  Scenario: Use -b to set a new branch
    When I run build-ceph with "-b next"
    Then the current git branch should be 'next'

  Scenario: Use --branch to set a new branch
    When I run build-ceph with "--branch next"
    Then the current git branch should be 'next'

  Scenario: Use -h to display the help message
    When I run build-ceph with "-h"
    Then it should pass with "usage: build-ceph-packages"

  Scenario: Use --help to display the help message
    When I run build-ceph with "--help"
    Then it should pass with "usage: build-ceph-packages"

  Scenario: Invalid repository returns an error message
    When I run build-ceph with "-r https://bad.repo.com"
    Then it should fail with "Error pulling from git"

  Scenario: Invalid branch returns an error message
    When I run build-ceph with "-b badbranch#"
    Then it should fail with "Error pulling from git"
