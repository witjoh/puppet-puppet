class puppet::puppetdb::puppetdb::user {

  user { 'puppetdb':
    ensure => present,
    uid    => 2054,
    gid    => 'puppetdb',
    shell  => '/bin/bash',
    home   => '/opt/puppetlabs/server/data/puppetdb',
  }

  group { 'puppetdb':
    ensure => present,
    gid    => 2054,
  }
}
