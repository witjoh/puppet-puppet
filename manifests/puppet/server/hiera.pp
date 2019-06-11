# configures hiera using template
#
# Parameters are only used in the hiera.yaml.erb
#
class puppet::puppet::server::hiera (
  Stdlib::Absolutepath $datadir     = "${settings::codedir}/environments/%{environment}/hieradata",
  String               $private_key = 'private_key.pkcs7.pem',
  String               $public_key  = 'public_key.pkcs7.pem',
) {

  file { "${settings::confdir}/eyaml":
    ensure => directory,
    owner  => 'puppet',
    group  => 'puppet',
    mode   => '0750',
  }

  file { "${settings::confdir}/eyaml/keys":
    ensure => directory,
    owner  => 'puppet',
    group  => 'puppet',
    mode   => '0750',
  }

  file { "${settings::confdir}/eyaml/keys/${private_key}":
    ensure  => file,
    owner   => 'puppet',
    group   => 'puppet',
    mode    => '0600',
    source  => "puppet:///modules/puppet/${private_key}",
  }

  file { "${settings::confdir}/eyaml/keys/${public_key}":
    ensure  => file,
    owner   => 'puppet',
    group   => 'puppet',
    mode    => '0600',
    source  => "puppet:///modules/puppet/${public_key}",
  }

  file { "${settings::confdir}/hiera.yaml":
    ensure  => file,
    owner   => 'puppet',
    group   => 'puppet',
    mode    => '0600',
    content => template('puppet/hiera.yaml.erb'),
  }
}
