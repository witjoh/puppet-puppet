class puppet::puppet::repo {

  if $facts['virtual'] == 'kvm' {
    $baseurl = 'file:///vagrant/repos/puppet5/el/7/x86_64'
  } else {
    if $facts['puppet_master_env'] {
      $baseurl = "http://your.local.mirror/repo/puppet5_${facts['puppet_master_env']}/el/7/x86_64/"
    } else {
      $baseurl = 'http://yum.puppet.com/puppet5/el/7/x86_64/'
    }
  }

  yumrepo { 'puppet5':
    ensure   => present,
    baseurl  => $baseurl,
    descr    => 'Puppet5 packages',
    enabled  => '1',
    gpgcheck => '0',
  }
}
