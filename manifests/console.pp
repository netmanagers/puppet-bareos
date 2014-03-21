# = Class: bareos::console
#
# This script installs the bareos-manage_console
#
#
# This class is not to be called directly. See init.pp for details.
#

class bareos::console {

  include bareos

  $real_console_password = $bareos::console_password ? {
    ''      => $bareos::real_default_password,
    default => $bareos::console_password,
  }

  $manage_console_file_content = $bareos::console_template ? {
    ''      => undef,
    default => template($bareos::console_template),
  }

  $manage_console_file_source = $bareos::console_source ? {
    ''        => undef,
    default   => $bareos::console_source,
  }

  ### Managed resources
  require bareos::repository

  package { $bareos::console_package:
    ensure  => $bareos::manage_package,
    noop    => $bareos::noops,
    require => Class['bareos::repository'],
  }

  file { 'bconsole.conf':
    ensure  => $bareos::manage_file,
    path    => $bareos::console_config_file,
    mode    => $bareos::config_file_mode,
    owner   => $bareos::config_file_owner,
    group   => $bareos::config_file_group,
    require => Package[$bareos::console_package],
    source  => $manage_console_file_source,
    content => $manage_console_file_content,
    replace => $bareos::manage_file_replace,
    audit   => $bareos::manage_audit,
    noop    => $bareos::noops,
  }


}

