Feature: Process Command Line Arguments
  This feature is used to assess the proper parsing of
  command-line arguments given by the user. This includes
  setting variables for particular arguments and, where
  applicable, exiting the script with the proper exit code.

  Scenario: Default branch is master and default repo is https://github.com/HP-Scale-out-Storage/ceph.git
    When I run "./build-ceph-packages.rb"
    Then the output should contain "Pulling master branch from the https://github.com/HP-Scale-out-Storage/ceph.git repo."

  Scenario: Use -r to set a new repository
    When I run "./build-ceph-packages.rb -r https://github.com/ceph/ceph.git"
    Then the output should contain "from the https://github.com/ceph/ceph.git repo."

  Scenario: Use --repo to set a new repository
    When I run "./build-ceph-packages.rb --repo https://github.com/ceph/ceph.git"
    Then the output should contain "from the https://github.com/ceph/ceph.git repo."

  Scenario: Use -b to set a new branch
    When I run "./build-ceph-packages.rb -b argonaut"
    Then the output should contain "Pulling argonaut branch"

  Scenario: Use --branch to set a new branch
    When I run "./build-ceph-packages.rb --branch argonaut"
    Then the output should contain "Pulling argonaut branch"

  Scenario: Use --help to display the help message and exit 0
    When I run "./build-ceph-packages.rb --help"
    Then the exit status should be 0

  Scenario: Set an invalid repo
    When I run "./build-ceph-packages.rb -r https://bad.repo.com"
    Then the output should contain "from the https://bad.repo.com repo."
    And it should fail with
    """
    Error pulling from git
    """

  Scenario: Set an invalid branch
    When I run "./build-ceph-packages.rb -b badbranch"
    Then the output should contain "Pulling badbranch branch"
    And it should fail with
    """
    Error pulling from git
    """
