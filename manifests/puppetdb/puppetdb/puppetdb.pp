class puppet::puppetdb::puppetdb::puppetdb (
  $database_host     = $puppet::puppetdb::params::database_host,
  $database_name     = $puppet::puppetdb::params::database_name,
  $database_user     = $puppet::puppetdb::params::database_user,
  $database_password = $puppet::puppetdb::params::database_password,
  $max_threads       = undef,
  $java_heap_size    = $puppet::puppetdb::params::java_heap_size,
  $manage_host       = true,
) inherits puppet::puppetdb::params
{
  include puppet::puppet::repo
  include puppet::puppetdb::puppetdb::user
  include puppet::puppet::agent::agent
  # include choria_discovery_proxy # Choria not working atm?

  class { 'puppetdb::server':
    database_host     => $database_host,
    listen_address    => '0.0.0.0',
    database_name     => $database_name,
    database_username => $database_user,
    database_password => $database_password,
    manage_firewall   => false,
    max_threads       => $max_threads,
    java_args         => {
      '-Xmx' => $java_heap_size,
      '-Xms' => $java_heap_size,
    },
    require           => Class['puppet::puppet::repo', 'puppet::puppetdb::puppetdb::user',],
  }

  if ($manage_host) {
    @@host { "${facts['hostname']}${server_suffix}.${facts['domain']}":
        ensure       => present,
        comment      => 'Puppet DB node',
        ip           => $facts['ipaddress'],
        tag          => "puppet_infra${server_suffix}",
    }

    Host <<| tag == "puppet_infra${server_suffix}" |>>
    Host <<| tag == "puppet_infra_postgresql${server_suffix}" |>>
  }

  Class['puppetdb::server']
  -> Class['profile::choria::discovery_proxy']
}
