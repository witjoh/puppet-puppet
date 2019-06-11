class puppet::puppet::user
{
  user { 'puppet':
    ensure => present,
    uid    => 2050,
    gid    => 'puppet',
    home   => '/opt/puppetlabs/server/data/puppetserver',
    shell  => '/sbin/nologin',
  }

  group { 'puppet':
    ensure => present,
    gid    => 2050,
  }
}
