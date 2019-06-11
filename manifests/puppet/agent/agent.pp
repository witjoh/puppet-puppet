class puppet::puppet::agent::agent (
  Boolean      $is_server         = false,
  String       $certname          = $trusted['certname'],
  String       $version           = $puppet::puppet::params::agent_version,
  String       $environment       = $puppet::puppet::params::agent_environment,
  Stdlib::Fqdn $ca_server         = $puppet::puppet::params::ca_server,
  Stdlib::Fqdn $puppet_server     = $puppet::puppet::params::puppet_server,
  Stdlib::Fqdn $report_server     = $puppet::puppet::params::report_server,
  Boolean      $splay             = $puppet::puppet::params::agent_splay,
  String       $runinterval       = $puppet::puppet::params::runinterval,
  Boolean      $usecacheonfailure = $puppet::puppet::params::agent_usecacheonfailure,
) inherits puppet::puppet::params {

  include puppet::puppet::repo

  package { 'puppet-agent':
    ensure => $version,
  }

  service { 'puppet':
    ensure  => running,
    enable  => true,
    require => Package['puppet-agent'],
  }

  $_certname = pick($certname, downcase($facts['fqdn']))

  ## both for server_agent as agent_agent configuration

  $config = '/etc/puppetlabs/puppet/puppet.conf'

  Ini_setting {
    ensure  => present,
    path    => $config,
    section => 'agent',
  }

  ini_setting { 'agent_splay':
    setting => 'splay',
    value   => $splay,
  }

  ini_setting { 'agent_usecacheonfailure':
    setting => 'usecacheonfailure',
    value   => $usecacheonfailure,
  }

  if (!$is_server) {
    ini_setting { 'agent_runinterval':
      setting => 'runinterval',
      value   => $runinterval,
    }

    ini_setting { 'agent_environment':
      setting => 'environment',
      value   => $environment,
    }

    ini_setting { 'agent_certname':
      setting => 'certname',
      value   => $_certname,
    }

    ini_setting { 'agent_ca_server':
      setting => 'ca_server',
      value   => $ca_server,
    }

    ini_setting { 'agent_server':
      setting => 'server',
      value   => $puppet_server,
    }

    Host <<| tag == "puppet_infra${server_suffix}" |>>

  }
}
