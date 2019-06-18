class puppet::puppetdb::database::repo {

  # default, we use the postgresql yum repos
  if $facts['operatingsystem'] in ['CentOS', 'RedHat']  {

    package { 'epel-release':
      ensure => present,
    }

    package { 'pgdg-redhat-repo':
      ensure   => present,
      source   => "https://download.postgresql.org/pub/repos/yum/reporpms/EL-${facts['os']['release']['major']}-${facts['os']['architecture']}/pgdg-redhat-repo-latest.noarch.rpm",
      provider => 'rpm',
    }

  } else {
    fail("Only RedHat and CentOS are supported, got: ${facts['os']['name']} !")
  }
}
