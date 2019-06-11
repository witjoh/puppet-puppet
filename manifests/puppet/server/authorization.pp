# This class groups all authorization settings on a puppetserver
#
class puppet::puppet::server::authorization {

  puppet_authorization::rule { "puppetlabs tasks file contents":
    match_request_path   => "/puppet/v3/file_content/tasks",
    match_request_type   => "path",
    match_request_method => "get",
    allow                => ["*"],
    sort_order           => 510,
    path                 => "/etc/puppetlabs/puppetserver/conf.d/auth.conf",
  }

  puppet_authorization::rule { "puppetlabs tasks":
    match_request_path   => "/puppet/v3/tasks",
    match_request_type   => "path",
    match_request_method => "get",
    allow                => ["*"],
    sort_order           => 510,
    path                 => "/etc/puppetlabs/puppetserver/conf.d/auth.conf",
  }
}
