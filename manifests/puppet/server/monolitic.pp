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

  include puppet::settings
  $server_suffix = $puppet::settings::server_suffix

  class { 'puppet::puppetdb::database::postgresql':
    monolitic => true,
  }

  class { 'puppet::puppet::server::ca_master':
    ca_server       => "master${server_suffix}.${facts['domain']}",
    puppetdb_server => "master${server_suffix}.${facts['domain']}",
    main_server     => "master${server_suffix}.${facts['domain']}",
    monolitic       => true,
    before          => Class['puppetdb'],
  }

  include puppetdb

  host { $facts['fqdn']:
    ensure       => 'present',
    host_aliases => [$facts['hostname'], "master${server_suffix}.${facts['domain']}", "master${server_suffix}"],
    ip           => $ipaddress4,
  }

}
