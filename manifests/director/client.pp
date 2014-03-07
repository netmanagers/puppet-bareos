# Define bareos::director::client
#
# Used to create client resources
#
define bareos::director::client (
  $address = '',
  $catalog = '',
  $port = '9102',
  $password = '',
  $file_retention = '',
  $job_retention = '',
  $auto_prune = true,
  $max_concurrent = '',
  $options_hash = {},
  $template = 'bareos/director/client.conf.erb'
) {

  include bareos

  $manage_director_service_autorestart = $bareos::service_autorestart ? {
    true    => Service[$bareos::director_service],
    default => undef,
  }

  if $address == '' {
    fail('$address parameter required for bareos::director::client define')
  }

  $real_catalog = $catalog ? {
    ''      => $bareos::default_catalog,
    default => $catalog,
  }

  if $real_catalog == '' {
    fail('$catalog parameter required for bareos::director::client define')
  }

  $real_file_retention = $file_retention ? {
    ''      => $bareos::default_file_retention,
    default => $file_retention,
  }

  $real_job_retention = $job_retention ? {
    ''      => $bareos::default_job_retention,
    default => $job_retention,
  }

  $real_max_concurrent = $max_concurrent ? {
    ''      => $bareos::client_max_concurrent,
    default => $max_concurrent,
  }

  $real_password = $password ? {
    ''      => $bareos::real_default_password,
    default => $password,
  }

  $manage_client_file_content = $template ? {
    ''      => undef,
    default => template($template),
  }

  file { "client-${name}.conf":
    ensure  => $bareos::manage_file,
    path    => "${bareos::director_clients_dir}/${name}.conf",
    mode    => $bareos::config_file_mode,
    owner   => $bareos::config_file_owner,
    group   => $bareos::config_file_group,
    require => Package[$bareos::director_package],
    notify  => $manage_director_service_autorestart,
    content => $manage_client_file_content,
    replace => $bareos::manage_file_replace,
    audit   => $bareos::manage_audit,
  }

}

