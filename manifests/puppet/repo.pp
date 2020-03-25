class puppet::puppet::repo (
  Integer $puppet_version = 6,
) {

  if ! $puppet_version in [ 5, 6 ] {
    fail("Only puppet 5 or puppet 6 version is supported, got puppet${puppet_version}")
  }

  case $facts['os']['name'] {
    'RedHat','CentOS': {
      $os_flavor = 'el'
    }
    'Fedora': {
      $os_flavor = 'fedora'
    }
    default: {
      fail("Only RedHat family based distros are supported: got ${os['name']}")
    }
  }

  file { "/etc/pki/rpm-gpg/RPM-GPG-KEY-puppet${puppet_version}-release":
    ensure => present,
    source => 'https://yum.puppetlabs.com/RPM-GPG-KEY-puppet',
  }

  yumrepo { "puppet${puppet_version}":
    ensure   => present,
    baseurl  => "https://yum.puppetlabs.com/puppet${puppet_version}/${os_flavor}/${facts['os']['release']['major']}/${facts['os']['architecture']}",
    descr    => "Puppet ${puppet_version}  Repository ${os_flavor} ${facts['os']['release']['major']} - ${facts['os']['architecture']}",
    enabled  => '1',
    gpgcheck => '1',
    gpgkey   => "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppet${puppet_version}-release",
    require  => File["/etc/pki/rpm-gpg/RPM-GPG-KEY-puppet${puppet_version}-release"],
  }
}
