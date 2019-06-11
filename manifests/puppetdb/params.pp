class puppet::puppetdb::params {

  include puppet::settings
  $server_suffix = $puppet::settings::server_suffix

  $database_name = 'puppetdb'
  $database_user = 'pgsql_puppetdb'
  $database_password = 'fjskjfkdl'
  $database_host = "p5pg${server_suffix}.${facts['domain']}"
  $var_lib_puppetdb_lv_size = '10g'
  $java_heap_size = '2g'
}
