# = Class: bareos::director
#
# This script installs the bareos-director (dir)
#
#
# This class is not to be called directly. See init.pp for details.
#

class bareos::director {

  include bareos

  ### Director specific checks

  $real_director_password = $bareos::director_password ? {
    ''      => $bareos::real_default_password,
    default => $bareos::director_password,
  }

  $manage_director_service_autorestart = $bareos::bool_service_autorestart ? {
    true    => Service[$bareos::director_service],
    default => undef,
  }


  ### Managed resources
  require bareos::repository
  include bareos::database

  package { $bareos::director_package:
    ensure  => $bareos::manage_package,
    noop    => $bareos::noops,
    require => [Class['bareos::repository'], Package['bareos-database']],
  }

  if $bareos::director_configs_dir != $bareos::config_dir and !defined(File['bareos-director_configs_dir']) {
    file { 'bareos-director_configs_dir':
      ensure  => directory,
      path    => $bareos::director_configs_dir,
      mode    => $bareos::config_file_mode,
      owner   => $bareos::config_file_owner,
      group   => $bareos::config_file_group,
      require => Package[$bareos::director_package],
      audit   => $bareos::manage_audit,
      noop    => $bareos::noops,
    }
  }

  $manage_director_file_content = $bareos::director_template ? {
    ''      => undef,
    default => template($bareos::director_template),
  }

  $manage_director_file_source = $bareos::director_source ? {
    ''        => undef,
    default   => $bareos::director_source,
  }

  if $bareos::director_clients_dir != $bareos::config_dir and !defined(File['bareos-director_clients_dir']) {
    file { 'bareos-director_clients_dir':
      ensure  => directory,
      path    => $bareos::director_clients_dir,
      mode    => $bareos::config_file_mode,
      owner   => $bareos::config_file_owner,
      group   => $bareos::config_file_group,
      require => Package[$bareos::director_package],
      audit   => $bareos::manage_audit,
      noop    => $bareos::noops,
    }
  }

  file { 'bareos-dir.conf':
    ensure  => $bareos::manage_file,
    path    => $bareos::director_config_file,
    mode    => $bareos::config_file_mode,
    owner   => $bareos::config_file_owner,
    group   => $bareos::config_file_group,
    require => Package[$bareos::director_package],
    notify  => $manage_director_service_autorestart,
    source  => $manage_director_file_source,
    content => $manage_director_file_content,
    replace => $bareos::manage_file_replace,
    audit   => $bareos::manage_audit,
    noop    => $bareos::noops,
  }

  service { $bareos::director_service:
    ensure    => $bareos::manage_service_ensure,
    name      => $bareos::director_service,
    enable    => $bareos::manage_service_enable,
    hasstatus => $bareos::service_status,
    pattern   => $bareos::director_process,
    require   => Package[$bareos::director_package],
    noop      => $bareos::noops,
  }

  ### Provide puppi data, if enabled ( puppi => true )
  if $bareos::bool_puppi == true {
    $classvars=get_class_args()
    puppi::ze { 'bareos-director':
      ensure    => $bareos::manage_file,
      variables => $classvars,
      helper    => $bareos::puppi_helper,
      noop      => $bareos::noops,
    }
  }

  ### Service monitoring, if enabled ( monitor => true )
  if $bareos::bool_monitor == true {
    if $bareos::director_port != '' {
      monitor::port { "monitor_bareos_director_${bareos::protocol}_${bareos::director_port}":
        protocol => $bareos::protocol,
        port     => $bareos::director_port,
        target   => $bareos::monitor_target,
        tool     => $bareos::monitor_tool,
        enable   => $bareos::manage_monitor,
        noop     => $bareos::noops,
      }
    }
    if $bareos::director_service != '' {
      monitor::process { 'bareos_director_process':
        process  => $bareos::director_process,
        service  => $bareos::director_service,
        pidfile  => $bareos::director_pid_file,
        user     => $bareos::process_user,
        argument => $bareos::process_args,
        tool     => $bareos::monitor_tool,
        enable   => $bareos::manage_monitor,
        noop     => $bareos::noops,
      }
    }
  }


  ### Firewall management, if enabled ( firewall => true )
  if $bareos::bool_firewall == true and $bareos::director_port != '' {
    firewall { "firewall_bareos_client_${bareos::protocol}_${bareos::director_port}":
      source      => $bareos::firewall_src,
      destination => $bareos::firewall_dst,
      protocol    => $bareos::protocol,
      port        => $bareos::director_port,
      action      => 'allow',
      direction   => 'input',
      tool        => $bareos::firewall_tool,
      enable      => $bareos::manage_firewall,
      noop        => $bareos::noops,
    }
  }


  ### Debugging, if enabled ( debug => true )
  if $bareos::bool_debug == true {
    file { 'debug_director_bareos':
      ensure  => $bareos::manage_file,
      path    => "${settings::vardir}/debug-director-bareos",
      mode    => '0640',
      owner   => 'root',
      group   => 'root',
      content => inline_template('<%= scope.to_hash.reject { |k,v| k.to_s =~ /(uptime.*|path|timestamp|free|.*password.*|.*psk.*|.*key)/ }.to_yaml %>'),
      noop    => $bareos::noops,
    }
  }

}

