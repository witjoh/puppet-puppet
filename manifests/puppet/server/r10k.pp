# this class installs and configures r10k from packages
#
class puppet::puppet::server::r10k {

  file { '/etc/puppetlabs/r10k/id_deploy_gitlab_rsa':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0600',
    source => 'puppet:///modules/puppet/id_deploy_gitlab_rsa',
  }

  file { '/root/.ssh':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0700'
  }

  file { '/root/.ssh/config':
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => "Host git.${facts['domain']}\n  IdentityFile   /etc/puppetlabs/r10k/id_deploy_gitlab_rsa\n  IdentitiesOnly  yes\n",
  }

  file { '/root/.ssh/known_hosts':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  file_line { 'gitlab_known_hosts':
    ensure => present,
    path   => '/root/.ssh/known_hosts',
    match  => '^git.local.net,',
    line   => 'git.local.net,1.2.3.4 ecdsa-sha2-nistp256 YOUR KEY',
  }

  class { 'r10k':
    remote       => 'git@git.local.net:/control_repo_puppet5.git',
    mcollective  => false,
  }
}
