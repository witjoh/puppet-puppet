# class that generates the node definitions of the different parts
# of your puppet infrastructure.
# This should contain only one include, aka roles principle
#
class puppet::puppet::server::nodes {

  if $facts['puppet_master_env'] {
    $server_suffix = "-${facts['puppet_master_env']}"
  } else {
    $server_suffix = ""
  }

  file { "${settings::manifest}/p5ca${server_suffix}.${facts['domain']}.pp":
    ensure  => file,
    content => template('puppet/nodes/ca_master_node.pp.erb'),
  }

  file { "${settings::manifest}/p5pg${server_suffix}.${facts['domain']}.pp":
    ensure  => file,
    content => template('puppet/nodes/postgresql_node.pp.erb'),
  }

  file { "${settings::manifest}/p5db${server_suffix}.${facts['domain']}.pp":
    ensure  => file,
    content => template('puppet/nodes/puppetdb_node.pp.erb'),
  }

  file { "${settings::manifest}/p5m${server_suffix}.${facts['domain']}.pp":
    ensure  => file,
    content => template('puppet/nodes/compile_master_node.pp.erb'),
  }
}
