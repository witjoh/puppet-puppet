# class puppet::bootstrap
#
# This class should only be used with puppet apply
# All stuff that needs to be setup after the installation of
# the puppet agent should go in this class
#
class puppet::bootstrap {

  file { '/opt/puppetlabs/facter/facts.d/':
    ensure => directory,
    mode   => '0755',
  }
}
