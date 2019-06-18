# wrapper around the puppetlabs/puppetdb module to
# install the postgresql database
#
class puppet::puppetdb::database::postgresql (
  String  $database_name     = $puppet::puppetdb::params::database_name,
  String  $database_user     = $puppet::puppetdb::params::database_user,
  String  $database_password = $puppet::puppetdb::params::database_password,
  Boolean $monolitic         = false,
  Boolean $manage_repo       = true,
  Boolean $use_scl           = false
) inherits puppet::puppetdb::params
{

  if $manage_repo {
    include puppet::puppetdb::database::repo
  }

  if $monolitic == false {
    include puppet::puppet::agent::agent
  }

  if $use_scl {

    # SCL does not set the library path, so we get the following error
    # error while loading shared libraries: libpq.so.rh-postgresql96-5
    # so we add this to the system ldconfig

    ldconfig::entry { 'rh-postgresql96':
      ensure  => present,
      paths   => ['/opt/rh/rh-postgresql96/root/usr/lib64',],
      require => Class['postgresql::client'],
      before  => Class['postgresql::server'],
    }

    # set postgresql globals first
    class { 'postgresql::globals':
      manage_package_repo  => false,
      version              => '9.6',
      client_package_name  => 'rh-postgresql96-postgresql',
      contrib_package_name => 'rh-postgresql96-postgresql-contrib',
      server_package_name  => 'rh-postgresql96-postgresql-server',
      datadir              => "/var/opt/rh/rh-postgresql96/lib/${database_name}",
      bindir               => '/opt/rh/rh-postgresql96/root/usr/bin',
      service_name         => 'rh-postgresql96-postgresql',
      needs_initdb         => true,
      encoding             => 'UTF8',
    }

    class {'postgresql::client':
      file_ensure    => 'file',
      package_ensure => 'present',
      require        => Class['puppet::puppetdb::database::user'],
    }

    class {'postgresql::server':
      postgres_password       => $database_password,
      listen_addresses        => '*',
      require                 => Class['puppet::puppetdb::database::user'],
    }

    postgresql::server::pg_hba_rule { "allow network to access ${database_name} database":
      description => 'Open up PostgreSQL for access from 0.0.0.0/0',
      type        => 'host',
      database    => $database_name,
      user        => $database_user,
      address     => '0.0.0.0/0',
      auth_method => 'md5',
    }

    class {'postgresql::server::contrib':
      package_ensure => present,
    }

    # create the puppetdb database
    postgresql::server::db { $database_name:
      user     => $database_user,
      password => $database_password,
      grant    => 'all',
    }

    file {'/var/log/pgsql':
      ensure => link,
      target => "/var/opt/rh/rh-postgresql96/lib/${database_name}/pg_log",
    }

    postgresql::server::extension { 'pg_trgm':
      database => $database_name,
      require  => Postgresql::Server::Db[$database_name],
    }
  }

  if $monolitic == false {
    @@host { "${facts['hostname']}${server_suffix}.${facts['domain']}":
      ensure       => present,
      comment      => 'Puppet postgresql',
      ip           => $facts['ipaddress'],
      tag          => "puppet_infra_postgresql${server_suffix}",
    }

    Host <<| tag == "puppet_infra${server_suffix}" |>>
    Host <<| tag == "puppet_infra_postgresql${server_suffix}" |>>
  }
}
