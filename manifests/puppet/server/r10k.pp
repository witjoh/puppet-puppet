# this class installs and configures r10k from packages
#
class puppet::puppet::server::r10k (
  String $git_server,
  String $git_ssh_key,
  String $git_server_key,
  String $git_server_key_type,
  String $control_repo,
) {

  file { '/etc/puppetlabs/r10k/id_deploy_gitlab_rsa':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => $git_ssh_key,
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
    content => "Host ${git_server}\n  IdentityFile   /etc/puppetlabs/r10k/id_deploy_gitlab_rsa\n  IdentitiesOnly  yes\n",
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
    match  => "^${git_server}",
    line   => "${git_server} ${git_server_key_type} ${git_server_key}",
  }

  class { 'r10k':
    remote       => "git@${git_server}:${control_repo}.git",
    mcollective  => false,
  }
}
