# Define bareos::director::catalog
#
# Used to create catalog resources
#
define bareos::director::catalog (
  $db_driver = 'mysql',
  $db_address = 'localhost',
  $db_port = '',
  $db_name = 'bareos',
  $db_user = 'bareos',
  $db_password = '',
  $options_hash = {},
  $template = 'bareos/director/catalog.conf.erb'
) {

  include bareos

  $manage_director_service_autorestart = $bareos::service_autorestart ? {
    true    => Service[$bareos::director_service],
    default => undef,
  }

  $real_password = $db_password ? {
    ''      => $bareos::real_default_password,
    default => $db_password,
  }

  $manage_catalog_file_content = $template ? {
    ''      => undef,
    default => template($template),
  }

  file { "catalog-${name}.conf":
    ensure  => $bareos::manage_file,
    path    => "${bareos::director_configs_dir}/catalog-${name}.conf",
    mode    => $bareos::config_file_mode,
    owner   => $bareos::config_file_owner,
    group   => $bareos::config_file_group,
    require => Package[$bareos::director_package],
    notify  => $manage_director_service_autorestart,
    content => $manage_catalog_file_content,
    replace => $bareos::manage_file_replace,
    audit   => $bareos::manage_audit,
  }


}

