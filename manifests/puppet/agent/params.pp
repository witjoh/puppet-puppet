class puppet::params (
  $pme = $::puppet_master_env,
  $puppet_conf_file = '/etc/puppetlabs/puppet/puppet.conf',
  $puppet_ca_server = "p5ca-${pme}.${facts['domain']}",
  $puppet_server = "p5-${pme}.${facts['domain']}",
  $puppet_report_server = $puppet_server,
  $puppet_db_server = "p5db-${pme}.${facs['domain']}",
  $puppet_agent_splay = true,
  $puppet_agent_runinterval = '30m',
  $puppet_agent_environment = 'production',
  $puppet_master_environment_timeout = '10s',
  $repos = {
    'puppet' => {
      ensure   => 'present',
      baseurl  => 'http://your.puppet.repo/repo/puppet5/el7-x86_64',
      descr    => 'puppet packages',
      enabled  => '1',
      gpgcheck => '0',
    }
  },
) {
}
