class puppet::puppetdb::database::user {

  # If you haver to manage ids manually.  Normally we do that in
  # hiera files, but during bootstrapping, nothung is available.

  user { 'postgres':
    ensure => present,
    uid    => 2053,
    gid    => 'postgres',
    shell  => '/bin/bash',
    home   => '/var/lib/pgsql',
  }

  group { 'postgres':
    ensure => present,
    gid    => 2053,
  }
}
