class puppet::puppetdb::database::repo {

  yumrepo { 'rhel-server-rhscl-7-rpms':
    ensure   => present,
    baseurl  => 'http://your.local.mirror/repo/7.5.2018Q3/rhel-server-rhscl-7-rpms',
    descr    => 'rhel-server-rhscl-7-rpms',
    enabled  => '1',
    gpgcheck => '1',
    gpgkey   => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release',
  }
}

