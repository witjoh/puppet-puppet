# this module installs a monolitc puppetmaster, meaning
# all components are installed on one node.
#
# This setup may only be used in a user specific puppet
# development and testing environment
#
# This should only be deployed in Sandbox or on your
# local worskstation using vagrant.
#
class puppet::puppet::server::monolitic {

  class { 'puppet::puppetdb::database::postgresql':
    monolitic => true,
  }

  class { 'puppet::puppet::server::ca_master':
    monolitic => true,
  }

  class { 'puppet::puppetdb::puppetdb::puppetdb':
    monolitic => true,
  }
}
