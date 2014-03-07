# Define bareos::director::job
#
# Used to create job/jobdef resources
#
# Valid parameters are:
#
# $client      - Name of the client where to run the job.
#                REQUIRED if you want to set up a job.
#                If not given, the definition sets up a JOBDEF
# $use_as_def  - If true, creates a jobdef instead of a job.
#                Default: false
# $type        - One of Backup, Restore, Verify or Admin
# $storage     - Where the job will be run. Can be an array
define bareos::director::job (
  $client = '',
  $type = 'Backup',
  $level = '',
  $fileset = '',
  $storage = '',
  $pool = '',
  $prefer_mounted_volumes = '',
  $write_bootstrap = '',
  $job_schedule = '',
  $priority = '',
  $messages = '',
  $where = '',
  $use_as_def = false,
  $jobdef = '',
  $client_run_before_job = '',
  $run_before_job = '',
  $client_run_after_job = '',
  $run_after_job = '',
  $options_hash = {},
  $template = 'bareos/director/job.conf.erb'
) {

  include bareos

  $manage_director_service_autorestart = $bareos::service_autorestart ? {
    true    => Service[$bareos::director_service],
    default => undef,
  }

  if $use_as_def  ==  true or $client == '' {
    $job_name = "jobdef-${name}"
  } else {
    $job_name = "job-${client}-${name}"
  }

  $real_jobdef = $jobdef ? {
    ''      => $bareos::default_jobdef,
    default => $jobdef,
  }

  $real_messages = $messages ? {
    ''      => $bareos::default_messages,
    default => $messages,
  }

  $manage_job_file_content = $template ? {
    ''      => undef,
    default => template($template),
  }

  file { "${job_name}.conf":
    ensure  => $bareos::manage_file,
    path    => "${bareos::director_configs_dir}/${job_name}.conf",
    mode    => $bareos::config_file_mode,
    owner   => $bareos::config_file_owner,
    group   => $bareos::config_file_group,
    require => Package[$bareos::director_package],
    notify  => $manage_director_service_autorestart,
    content => $manage_job_file_content,
    replace => $bareos::manage_file_replace,
    audit   => $bareos::manage_audit,
  }

}
