# This class installs the puppet-client-tools
#
class puppet::puppet::agent::tools {

  include puppet::puppet::repo

  # puppet-client-tools en puppet6 ??
  package { 'puppet-client-tools':
    ensure => present,
  }
}
