# = Class: bareos::storage
#
# This script installs the bareos-storage (sd)
#
#
# This class is not to be called directly. See init.pp for details.
#

class bareos::storage {

  include bareos

  ### Storage specific checks
  $real_storage_password = $bareos::storage_password ? {
    ''      => $bareos::real_default_password,
    default => $bareos::storage_password,
  }

  $manage_storage_file_content = $bareos::storage_template ? {
    ''      => undef,
    default => template($bareos::storage_template),
  }

  $manage_storage_file_source = $bareos::storage_source ? {
    ''        => undef,
    default   => $bareos::storage_source,
  }

  $manage_storage_service_autorestart = $bareos::bool_service_autorestart ? {
    true    => Service[$bareos::storage_service],
    default => undef,
  }

  ### Managed resources
  require bareos::repository
  include bareos::database

  package { $bareos::storage_package:
    ensure  => $bareos::manage_package,
    noop    => $bareos::noops,
    require => [Class['bareos::repository'], Package['bareos-database']],
  }

  if  $bareos::storage_configs_dir != $bareos::config_dir and
      !defined(File['bareos-storage_configs_dir']) {
    file { 'bareos-storage_configs_dir':
      ensure  => directory,
      path    => $bareos::storage_configs_dir,
      mode    => $bareos::config_file_mode,
      owner   => $bareos::config_file_owner,
      group   => $bareos::config_file_group,
      require => Package[$bareos::storage_package],
      audit   => $bareos::manage_audit,
      noop    => $bareos::noops,
    }
  }

  file { 'bareos-sd.conf':
    ensure  => $bareos::manage_file,
    path    => $bareos::storage_config_file,
    mode    => $bareos::config_file_mode,
    owner   => $bareos::config_file_owner,
    group   => $bareos::config_file_group,
    require => Package[$bareos::storage_package],
    notify  => $manage_storage_service_autorestart,
    source  => $manage_storage_file_source,
    content => $manage_storage_file_content,
    replace => $bareos::manage_file_replace,
    audit   => $bareos::manage_audit,
    noop    => $bareos::noops,
  }

  service { $bareos::storage_service:
    ensure    => $bareos::manage_service_ensure,
    name      => $bareos::storage_service,
    enable    => $bareos::manage_service_enable,
    hasstatus => $bareos::service_status,
    pattern   => $bareos::storage_process,
    require   => Package[$bareos::storage_package],
    noop      => $bareos::noops,
  }

  ### Provide puppi data, if enabled ( puppi => true )
  if $bareos::bool_puppi == true {
    $classvars=get_class_args()
    puppi::ze { 'bareos-storage':
      ensure    => $bareos::manage_file,
      variables => $classvars,
      helper    => $bareos::puppi_helper,
      noop      => $bareos::noops,
    }
  }


  ### Service monitoring, if enabled ( monitor => true )
  if $bareos::bool_monitor == true {
    if $bareos::storage_port != '' {
      monitor::port { "monitor_bareos_storage_${bareos::protocol}_${bareos::storage_port}":
        protocol => $bareos::protocol,
        port     => $bareos::storage_port,
        target   => $bareos::monitor_target,
        tool     => $bareos::monitor_tool,
        enable   => $bareos::manage_monitor,
        noop     => $bareos::noops,
      }
    }
    if $bareos::storage_service != '' {
      monitor::process { 'bareos_storage_process':
        process  => $bareos::storage_process,
        service  => $bareos::storage_service,
        pidfile  => $bareos::storage_pid_file,
        user     => $bareos::process_user,
        argument => $bareos::process_args,
        tool     => $bareos::monitor_tool,
        enable   => $bareos::manage_monitor,
        noop     => $bareos::noops,
      }
    }
  }


  ### Firewall management, if enabled ( firewall => true )
  if $bareos::bool_firewall == true and $bareos::storage_port != '' {
    firewall { "firewall_bareos_storage_${bareos::protocol}_${bareos::storage_port}":
      source      => $bareos::firewall_src,
      destination => $bareos::firewall_dst,
      protocol    => $bareos::protocol,
      port        => $bareos::storage_port,
      action      => 'allow',
      direction   => 'input',
      tool        => $bareos::firewall_tool,
      enable      => $bareos::manage_firewall,
      noop        => $bareos::noops,
    }
  }


  ### Debugging, if enabled ( debug => true )
  if $bareos::bool_debug == true {
    file { 'debug_storage_bareos':
      ensure  => $bareos::manage_file,
      path    => "${settings::vardir}/debug-storage-bareos",
      mode    => '0640',
      owner   => 'root',
      group   => 'root',
      content => inline_template('<%= scope.to_hash.reject { |k,v| k.to_s =~ /(uptime.*|path|timestamp|free|.*password.*|.*psk.*|.*key)/ }.to_yaml %>'),
      noop    => $bareos::noops,
    }
  }

}

