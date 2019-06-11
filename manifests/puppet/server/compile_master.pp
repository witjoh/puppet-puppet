# installs a compile master
#
class puppet::puppet::server::compile_master (
  String       $version          = $puppet::puppet::params::version,
  String       $java_args        = $puppet::puppet::params::java_args,
  Stdlib::Fqdn $ca_server        = $puppet::puppet::params::ca_server,
  Stdlib::Fqdn $puppetdb_server  = $puppet::puppet::params::puppetdb_server,
  Stdlib::Fqdn $main_server      = $puppet::puppet::params::puppet_server,
  String       $dns_alt_names    = $puppet::puppet::params::dns_alt_names,
  String       $environment      = $puppet::puppet::params::environment,
  String       $runinterval      = $puppet::puppet::params::runinterval,
  Integer      $jruby_instances  = $puppet::puppet::params::jruby_instances,
) inherits puppet::puppet::params
{
  include puppet::puppet::user
  include puppet::puppet::repo
  include puppet::puppet::server::authorization

  if $trusted['authenticated'] == 'remote' {
    class { puppet::puppet::agent::agent:
      is_server => true,
      certname      => $ca_server,
      environment   => $environment,
      puppet_server => $main_server,
      runinterval   => $runinterval,
    }
  }

  file { '/etc/puppetlabs/puppet/ssl/ca':
    ensure => directory,
    owner  => 'puppet',
    group  => 'puppet',
    mode   => '0755',
    before => Class['puppetserver'],
  }

  File <<| title == '/etc/puppetlabs/puppet/ssl/ca/ca_crl.pem' |>> {
    before => Class['puppetserver'],
  }

  class { 'puppetserver':
    certname        => $trusted['certname'],
    ca_server       => $ca_server,
    enable_ca       => false,
    version         => $version,
    java_args       => $java_args,
    main_server     => $main_server,
    dns_alt_names   => $dns_alt_names,
    environment     => $environment,
    runinterval     => $runinterval,
    jruby_instances => $jruby_instances,
    require         => Class['puppet::puppet::user', 'puppet::puppet::repo'],
  }

  class { 'puppetdb::master::config':
    puppetdb_server => $puppetdb_server,
  }

  class { 'puppet::puppet::server::hiera':
    require => Class['puppetserver'],
  }

  include puppet::puppet::server::r10k

  @@host { "${facts['hostname']}${server_suffix}.${facts['domain']}":
    ensure       => present,
    host_aliases => "p5m${server_suffix}.${facts['domain']}",
    comment      => 'Puppet Compile Master',
    ip           => $facts['ipaddress'],
    tag          => "puppet_infra${server_suffix}",
  }

  Host <<| tag == "puppet_infra${server_suffix}" |>>

  Class['puppetserver']
  -> Class['puppet::puppet::server::authorization']
}
