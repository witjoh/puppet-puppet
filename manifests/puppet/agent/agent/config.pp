class puppet::agent::config (
  $puppet_conf_file         = $puppet::params::puppet_conf_file,
  $puppet_ca_server         = $puppet::params::puppet_ca_server,
  $puppet_report_server     = $puppet::params::puppet_report_server,
  $puppet_server            = $puppet::params::puppet_server,
  $puppet_agent_splay       = $puppet::params::puppet_agent_splay,
  $puppet_agent_runinterval = $puppet::params::puppet_agent_runinterval,
  $puppet_agent_environment = $puppet::params::puppet_agent_environment,
) {
  concat { $puppet_conf_file:
    owner => 'puppet',
    group => 'puppet',
    mode  => '0644'
  }

  concat::fragment{ 'puppet_conf_agent':
    target  => $puppet_conf_file,
    content => template("${module_name}/etc/puppetlabs/puppet/puppet.conf.agent.erb"),
    order   => '10'
  }
}
