class puppet::puppetdb::database::repo {

  if ( $facts['operatingsystem']=="CentOS" ) {

    package { 'centos-release-scl':
        ensure => present,
    }

  } else {
    yumrepo { 'rhel-server-rhscl-7-rpms':
      ensure   => present,
      baseurl  => 'http://your.local.mirror/repo/7.5.2018Q3/rhel-server-rhscl-7-rpms',
      descr    => 'rhel-server-rhscl-7-rpms',
      enabled  => '1',
      gpgcheck => '1',
      gpgkey   => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release',
    }
  }
}
