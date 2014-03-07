# Define bareos::director::fileset
#
# Used to create filesets resources
#
define bareos::director::fileset (
  $signature = 'MD5',
  $compression = '',
  $onefs = '',
  $fstype = '',
  $recurse = '',
  $sparse = '',
  $noatime = '',
  $mtimeonly = '',
  $keepatime = '',
  $checkfilechanges = '',
  $hardlinks = '',
  $ignorecase = '',
  $include = '',
  $exclude = '',
  $ignore_fileset_changes = '',
  $options_hash = {},
  $template = 'bareos/director/fileset.conf.erb'
) {

  include bareos

  $manage_director_service_autorestart = $bareos::service_autorestart ? {
    true    => Service[$bareos::director_service],
    default => undef,
  }

  $array_filesets_fstype = is_array($fstype) ? {
    false     => $fstype ? {
      ''      => [],
      default => [$fstype],
    },
    default   => $fstype,
  }

  $array_filesets_include = is_array($include) ? {
    false     => $include ? {
      ''      => [],
      default => [$include],
    },
    default   => $include,
  }

  $array_filesets_exclude = is_array($exclude) ? {
    false     => $exclude ? {
      ''      => [],
      default => [$exclude],
    },
    default   => $exclude,
  }

  $manage_fileset_file_content = $template ? {
    ''      => undef,
    default => template($template),
  }

  file { "fileset-${name}.conf":
    ensure  => $bareos::manage_file,
    path    => "${bareos::director_configs_dir}/fileset-${name}.conf",
    mode    => $bareos::config_file_mode,
    owner   => $bareos::config_file_owner,
    group   => $bareos::config_file_group,
    require => Package[$bareos::director_package],
    notify  => $manage_director_service_autorestart,
    content => $manage_fileset_file_content,
    replace => $bareos::manage_file_replace,
    audit   => $bareos::manage_audit,
  }

}

