# class that generates the node definitions of the different parts
# of your puppet infrastructure.
# This should contain only one include, aka roles principle
#
class puppet::puppet::server::mononodes {

  if $facts['puppet_master_env'] {
    $server_suffix = "-${facts['puppet_master_env']}"
  } else {
    $server_suffix = ""
  }

  file { "${settings::manifest}/p6ca${server_suffix}.${facts['domain']}.pp":
    ensure  => file,
    content => template('puppet/nodes/ca_master_node_monolitic.pp.erb'),
  }

  file { "${settings::manifest}/p6pg${server_suffix}.${facts['domain']}.pp":
    ensure  => file,
    content => template('puppet/nodes/postgresql_node.pp.erb'),
  }

  file { "${settings::manifest}/p6db${server_suffix}.${facts['domain']}.pp":
    ensure  => file,
    content => template('puppet/nodes/puppetdb_node.pp.erb'),
  }

  file { "${settings::manifest}/p6m${server_suffix}.${facts['domain']}.pp":
    ensure  => file,
    content => template('puppet/nodes/compile_master_node.pp.erb'),
  }
}
