# Define bareos::director::pool
#
# Used to create pool resources
#
define bareos::director::pool (
  $type = 'Backup',
  $maximum_volume_jobs = '1',
  $maximum_volume_bytes = '1G',
  $recycle = true,
  $action_on_purge = 'truncate',
  $auto_prune = true,
  $volume_retention = '1 month',
  $volume_use_duration = '',
  $label_format = 'Volume-',
  $storage = '',
  $options_hash = {},
  $template = 'bareos/director/pool.conf.erb'
) {

  include bareos

  $manage_director_service_autorestart = $bareos::service_autorestart ? {
    true    => Service[$bareos::director_service],
    default => undef,
  }

  $manage_pool_file_content = $template ? {
    ''      => undef,
    default => template($template),
  }

  file { "pool-${name}.conf":
    ensure  => $bareos::manage_file,
    path    => "${bareos::director_configs_dir}/pool-${name}.conf",
    mode    => $bareos::config_file_mode,
    owner   => $bareos::config_file_owner,
    group   => $bareos::config_file_group,
    require => Package[$bareos::director_package],
    notify  => $manage_director_service_autorestart,
    content => $manage_pool_file_content,
    replace => $bareos::manage_file_replace,
    audit   => $bareos::manage_audit,
  }

}

