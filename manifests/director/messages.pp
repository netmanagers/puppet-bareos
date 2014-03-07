# Define bareos::director::messages
#
# Used to create messages resources
#
define bareos::director::messages (
  $mail_command = '',
  $mail_host = 'localhost',
  $mail_from = '',
  $mail_to = '',
  $options_hash = {},
  $template = 'bareos/director/messages.conf.erb'
) {

  include bareos

  $manage_director_service_autorestart = $bareos::service_autorestart ? {
    true    => Service[$bareos::director_service],
    default => undef,
  }

  $array_mail_to = is_array($mail_to) ? {
    false     => $mail_to ? {
      ''      => [],
      default => [$mail_to],
    },
    default   => $mail_to,
  }

  $manage_messages_file_content = $template ? {
    ''      => undef,
    default => template($template),
  }

  file { "messages-${name}.conf":
    ensure  => $bareos::manage_file,
    path    => "${bareos::director_configs_dir}/messages-${name}.conf",
    mode    => $bareos::config_file_mode,
    owner   => $bareos::config_file_owner,
    group   => $bareos::config_file_group,
    require => Package[$bareos::director_package],
    notify  => $manage_director_service_autorestart,
    content => $manage_messages_file_content,
    replace => $bareos::manage_file_replace,
    audit   => $bareos::manage_audit,
  }

}

