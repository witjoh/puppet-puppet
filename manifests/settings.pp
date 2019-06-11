# this class handles all settings used in mutliple classes of this module
# and which are not handles by the specific params.pp files
#
# Just include thi class where needed and use the scoped variable 
#
class puppet::settings {

  if $facts['puppet_master_env'] {
    $server_suffix = "-${facts['puppet_master_env']}"
  } else {
    $server_suffix = ""
  }
}
