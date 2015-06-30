# Define bareos::director::messages
#
# Used to create messages resources
#
# Valid parameters are:
#
# $mail_command     - path to the smtp command used to send email
# $mail_from        - email address used in the from: field
# $mail_to          - email address used in the to: field
# $mail_host        - smtp server used to send the email
# $mail_type        - message type to send by email
# $mailonerror_type - message type sent on job error
# $console          - message type sent to the bareos console
# $catalog          - message type sent to the catalog database
# $append           - Append messages to a log file
# $options_hash     - Extra configuration values
#
define bareos::director::messages (
  $mail_command = '',
  $mail_from = '',
  $mail_to = '',
  $mail_host = 'localhost',
  $mail_type = 'all, !skipped',
  $mailonerror_type = 'all',
  $console = 'all, !skipped, !saved',
  $catalog = 'all, !skipped, !saved',
  $append = "\"${bareos::log_file}\" = all, !skipped",
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

  $array_append = is_array($append) ? {
    false     => $append ? {
      ''      => [],
      default => [$append],
    },
    default   => $append,
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
