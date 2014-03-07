# Define bareos::storage::device
#
# Used to create devices in the storage manager
#
define bareos::storage::device (
  $device_type     = 'File',
  $media_type      = '',
  $archive_device  = '',
  $label_media     = 'yes',
  $random_access   = 'yes',
  $automatic_mount = 'yes',
  $removable_media = 'no' ,
  $always_open     = false,
  $source          = '',
  $options_hash    = {},
  $template        = 'bareos/storage/device.conf.erb'
) {

  include bareos

  $manage_storage_service_autorestart = $bareos::service_autorestart ? {
    true    => Service[$bareos::storage_service],
    default => undef,
  }


  $real_archive_device = $archive_device ? {
    ''      => $bareos::default_archive_device,
    default => $archive_device,
  }

  if $real_archive_device == '' {
    fail('$archive_device parameter required for bareos::storage::device define')
  }

  if  $device_type == 'File' and
      !defined(File[$real_archive_device]) {
    # Puppet lacks recursive dir creation, and we might use subdirs as storage
    exec { 'mkdir_archive_dir':
      path    => [ '/bin', '/usr/bin' ],
      command => "mkdir -p ${real_archive_device}",
      unless  => "test -d ${real_archive_device}",
    } ->
    file { $real_archive_device:
      ensure  => directory,
      mode    => '0750',
      owner   => $bareos::storage_device_owner,
      group   => $bareos::storage_device_group,
      require => Package[$bareos::storage_package],
      notify  => $manage_storage_service_autorestart,
      audit   => $bareos::manage_audit,
      noop    => $bareos::noops,
    }
  }

  $manage_device_file_content = $template ? {
    ''      => undef,
    default => template($template),
  }

  $manage_device_file_source = $source ? {
    ''        => undef,
    default   => $source,
  }

  file { "device-${name}.conf":
    ensure  => $bareos::manage_file,
    path    => "${bareos::storage_configs_dir}/device-${name}.conf",
    mode    => $bareos::config_file_mode,
    owner   => $bareos::config_file_owner,
    group   => $bareos::config_file_group,
    require => Package[$bareos::storage_package],
    notify  => $manage_storage_service_autorestart,
    content => $manage_device_file_content,
    source  => $manage_device_file_source,
    replace => $bareos::manage_file_replace,
    audit   => $bareos::manage_audit,
  }
}
