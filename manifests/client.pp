# = Class: bareos::client
#
# This script installs the bareos-client (fd)
#
#
# This class is not to be called directly. See init.pp for details.
#

class bareos::client {

  include bareos

  ### Client specific checks
  $real_client_password = $bareos::client_password ? {
    ''      => $bareos::real_default_password,
    default => $bareos::client_password,
  }

  $manage_client_file_content = $bareos::client_template ? {
    ''      => undef,
    default => template($bareos::client_template),
  }

  $manage_client_file_source = $bareos::client_source ? {
    ''        => undef,
    default   => $bareos::client_source,
  }

  $manage_client_service_autorestart = $bareos::bool_service_autorestart ? {
    true    => Service[$bareos::client_service],
    default => undef,
  }

  ### Managed resources
  require bareos::repository

  package { $bareos::client_package:
    ensure  => $bareos::manage_package,
    noop    => $bareos::noops,
    require => Class['bareos::repository'],
  }

  file { 'bareos-fd.conf':
    ensure  => $bareos::manage_file,
    path    => $bareos::client_config_file,
    mode    => $bareos::config_file_mode,
    owner   => $bareos::config_file_owner,
    group   => $bareos::config_file_group,
    require => Package[$bareos::client_package],
    notify  => $manage_client_service_autorestart,
    source  => $manage_client_file_source,
    content => $manage_client_file_content,
    replace => $bareos::manage_file_replace,
    audit   => $bareos::manage_audit,
    noop    => $bareos::noops,
  }

  service { $bareos::client_service:
      ensure    => $bareos::manage_service_ensure,
      name      => $bareos::client_service,
      enable    => $bareos::manage_service_enable,
      hasstatus => $bareos::service_status,
      pattern   => $bareos::client_process,
      require   => Package[$bareos::client_package],
      noop      => $bareos::noops,
    }


  ### Provide puppi data, if enabled ( puppi => true )
  if $bareos::bool_puppi == true {
    $classvars=get_class_args()
    puppi::ze { 'bareos-client':
      ensure    => $bareos::manage_file,
      variables => $classvars,
      helper    => $bareos::puppi_helper,
      noop      => $bareos::noops,
    }
  }

  ### Service monitoring, if enabled ( monitor => true )
  if $bareos::bool_monitor == true {
    if $bareos::client_port != '' {
      monitor::port { "monitor_bareos_client_${bareos::protocol}_${bareos::client_port}":
        protocol => $bareos::protocol,
        port     => $bareos::client_port,
        target   => $bareos::monitor_target,
        tool     => $bareos::monitor_tool,
        enable   => $bareos::manage_monitor,
        noop     => $bareos::noops,
      }
    }
    if $bareos::client_service != '' {
      monitor::process { 'bareos_client_process':
        process  => $bareos::client_process,
        service  => $bareos::client_service,
        pidfile  => $bareos::client_pid_file,
        user     => $bareos::process_user,
        argument => $bareos::process_args,
        tool     => $bareos::monitor_tool,
        enable   => $bareos::manage_monitor,
        noop     => $bareos::noops,
      }
    }
  }


  ### Firewall management, if enabled ( firewall => true )
  if $bareos::bool_firewall == true and $bareos::client_port != '' {
    firewall { "firewall_bareos_client_${bareos::protocol}_${bareos::client_port}":
      source      => $bareos::firewall_src,
      destination => $bareos::firewall_dst,
      protocol    => $bareos::protocol,
      port        => $bareos::client_port,
      action      => 'allow',
      direction   => 'input',
      tool        => $bareos::firewall_tool,
      enable      => $bareos::manage_firewall,
      noop        => $bareos::noops,
    }
  }


  ### Debugging, if enabled ( debug => true )
  if $bareos::bool_debug == true {
    file { 'debug_client_bareos':
      ensure  => $bareos::manage_file,
      path    => "${settings::vardir}/debug-client-bareos",
      mode    => '0640',
      owner   => 'root',
      group   => 'root',
      content => inline_template('<%= scope.to_hash.reject { |k,v| k.to_s =~ /(uptime.*|path|timestamp|free|.*password.*|.*psk.*|.*key)/ }.to_yaml %>'),
      noop    => $bareos::noops,
    }
  }


}
