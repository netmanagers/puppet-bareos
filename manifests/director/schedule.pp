# Define bareos::director::schedule
#
# Used to create schedules
#
define bareos::director::schedule (
  $run_spec = '',
  $options_hash = {},
  $template = 'bareos/director/schedule.conf.erb'
) {

  include bareos

  $manage_director_service_autorestart = $bareos::service_autorestart ? {
    true    => Service[$bareos::director_service],
    default => undef,
  }

  $array_run_spec = is_array($run_spec) ? {
    false     => $run_spec ? {
      ''      => [],
      default => [$run_spec],
    },
    default   => $run_spec,
  }

  $manage_schedule_file_content = $template ? {
    ''      => undef,
    default => template($template),
  }

  file { "schedule-${name}.conf":
    ensure  => $bareos::manage_file,
    path    => "${bareos::director_configs_dir}/schedule-${name}.conf",
    mode    => $bareos::config_file_mode,
    owner   => $bareos::config_file_owner,
    group   => $bareos::config_file_group,
    require => Package[$bareos::director_package],
    notify  => $manage_director_service_autorestart,
    content => $manage_schedule_file_content,
    replace => $bareos::manage_file_replace,
    audit   => $bareos::manage_audit,
  }


}

