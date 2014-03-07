# Define bareos::director::storage
#
# Used to create storage resources
#
define bareos::director::storage (
  $device = '',
  $media_type = '',
  $address = '',
  $sd_port = '9103',
  $password = '',
  $max_concurrent = '',
  $allow_compression = 'Yes',
  $source = '',
  $options_hash = {},
  $template = 'bareos/director/storage.conf.erb'
) {

  include bareos

  $manage_director_service_autorestart = $bareos::service_autorestart ? {
    true    => Service[$bareos::director_service],
    default => undef,
  }

  $real_password = $password ? {
    ''      => $bareos::real_default_password,
    default => $password,
  }

  $manage_storage_file_content = $template ? {
    ''      => undef,
    default => template($template),
  }

  $manage_storage_file_source = $source ? {
    ''        => undef,
    default   => $source,
  }

  file { "storage-${name}.conf":
    ensure  => $bareos::manage_file,
    path    => "${bareos::director_configs_dir}/storage-${name}.conf",
    mode    => $bareos::config_file_mode,
    owner   => $bareos::config_file_owner,
    group   => $bareos::config_file_group,
    require => Package[$bareos::director_package],
    notify  => $manage_director_service_autorestart,
    source  => $manage_storage_file_source,
    content => $manage_storage_file_content,
    replace => $bareos::manage_file_replace,
    audit   => $bareos::manage_audit,
  }

}

