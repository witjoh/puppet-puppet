# installs the ca master
#
class puppet::puppet::server::ca_master (
  String           $version             = $puppet::puppet::params::version,
  String           $java_args           = $puppet::puppet::params::java_args,
  Stdlib::Fqdn     $ca_server           = $puppet::puppet::params::ca_server,
  Stdlib::Fqdn     $puppetdb_server     = $puppet::puppet::params::puppetdb_server,
  Stdlib::Fqdn     $main_server         = $puppet::puppet::params::puppet_server,
  Optional[String] $extra_dns_alt_names = undef,
  String           $environment         = $puppet::puppet::params::environment,
  String           $runinterval         = $puppet::puppet::params::runinterval,
  Integer          $jruby_instances     = $puppet::puppet::params::jruby_instances,
  Boolean          $monolitic           = false,
  Boolean          $manage_repo         = true,
) inherits puppet::puppet::params
{

  if $manage_repo {
    include puppet::puppet::repo
    Class['puppet::puppet::repo'] -> Class['puppetserver']
  }

  if $trusted['authenticated'] == 'remote' {
    class { puppet::puppet::agent::agent:
      is_server     => true,
      certname      => $ca_server,
      environment   => $environment,
      puppet_server => $main_server,
      runinterval   => $runinterval,
    }
  }

  if $monolitic {
    $dns_alt_names = "${ca_server},${puppetdb_server},${main_server},p6nats${server_suffix}.${facts['domain']},${extra_dns_alt_names}"
  } else {
    $dns_alt_names = "${ca_server},p6nats${server_suffix}.${facts['domain']},${extra_dns_alt_names}"
  }

  class { 'puppetserver':
    certname        => $ca_server,
    enable_ca       => true,
    version         => $version,
    autosign        => true,
    java_args       => $java_args,
    main_server     => $main_server,
    dns_alt_names   => $dns_alt_names,
    environment     => $environment,
    runinterval     => $runinterval,
    jruby_instances => $jruby_instances,
  }

  if ! $monolitic {
    class { 'puppetdb::master::config':
      puppetdb_server => $puppetdb_server,
    }

    if find_file('/etc/puppetlabs/puppet/ssl/ca/ca_crl.pem') {
      @@file{ '/etc/puppetlabs/puppet/ssl/ca/ca_crl.pem':
        ensure  => file,
        owner   => 'puppet',
        group   => 'puppet',
        mode    => '0644',
        content => file('/etc/puppetlabs/puppet/ssl/ca/ca_crl.pem'),
      }
    }

    @@host { "${facts['hostname']}${server_suffix}.${facts['domain']}":
      ensure  => present,
      comment => 'Puppet CA Master',
      ip      => $facts['ipaddress'],
      tag     => "puppet_infra${server_suffix}",
    }

    Host <<| tag == "puppet_infra${server_suffix}" |>>
  }

  class { 'puppet::puppet::server::hiera':
    require => Class['puppetserver'],
  }

  include puppet::puppet::server::r10k
}
