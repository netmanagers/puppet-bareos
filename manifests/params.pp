# Class: bareos::params
#
# This class defines default parameters used by the main module class bareos
# Operating Systems differences in names and paths are addressed here
#
# == Variables
#
# Refer to bareos class for the variables defined here.
#
# == Usage
#
# This class is not intended to be used directly.
# It may be imported or inherited by other classes
#
class bareos::params {

  ### Application related parameters

  $repo_distro = $::operatingsystem ? {
    /(?i:Debian|Ubuntu|Mint)/                          => 'Debian_7.0',
    /(?i:Ubuntu)/                                      => 'xUbuntu_12.04',
    /(?i:redhat|centos|scientific|oraclelinux|fedora)/ => "${::operatingsystem}_${::operatingsystemmajrelease}",
    default                                            => 'UNKNOWN',
  }

  # One of http://download.bareos.org/bareos/release/
  $repo_flavour = 'latest'

  $manage_client   = true
  $manage_storage  = false
  $manage_director = false
  $manage_console  = false
  $manage_database = false

  # Database type
  # One of 'mysql', 'postgresql', 'sqlite'
  $database_backend = 'mysql'

  ## Common variables
  $config_dir = $::operatingsystem ? {
    default => '/etc/bareos',
  }

  $heartbeat_interval = '1 minute'
  $working_directory  = $::operatingsystem ? {
    default => '/var/lib/bareos'
  }

  $password_salt = ''
  $default_password = 'auto'

  # This values can be set in various resources. These defaults can be used to avoid repetition
  $default_catalog = ''
  $default_messages = 'standard'
  $default_file_retention = ''
  $default_job_retention  = ''
  $default_jobdef = ''
  $default_archive_device = ''

  ## Bareos client variables
  $client_name     = "${::fqdn}-fd"
  $client_port     = '9102'
  $client_address  = $::ipaddress
  $client_password = ''
  $client_max_concurrent = ''

  $client_config_file = $::operatingsystem ? {
    default => "${bareos::params::config_dir}/bareos-fd.conf",
  }

  $client_template = ''
  $client_source = ''

  $client_pid_file = $::operatingsystem ? {
    default => "${bareos::params::working_directory}/bareos-fd.${bareos::params::client_port}.pid",
  }

  $client_package = $::operatingsystem ? {
    default                   => 'bareos-filedaemon',
  }

  $client_service = $::operatingsystem ? {
    default => 'bareos-fd',
  }

  $client_process = $::operatingsystem ? {
    default => 'bareos-fd',
  }

  ## Bareos director variables
  $director_name              = "${::fqdn}-dir"
  $director_port              = '9101'
  $director_address           = $::ipaddress
  $director_max_concurrent    = '30'
  $director_password          = ''
  $director_configs_dir = "${bareos::params::config_dir}/director.d"
  $director_clients_dir = "${bareos::params::config_dir}/clients.d"

  $director_package = $::operatingsystem ? {
    default                   => 'bareos-director',
  }

  $director_config_file = $::operatingsystem ? {
    default => '/etc/bareos/bareos-dir.conf',
  }

  $director_template = ''
  $director_source = ''

  $director_service = $::operatingsystem ? {
    default => 'bareos-dir',
  }

  $director_process = $::operatingsystem ? {
    default => 'bareos-dir',
  }

  ## Bareos storage variables
  $storage_name           = "${::fqdn}-sd"
  $storage_address        = $::ipaddress
  $storage_port           = '9103'
  $storage_max_concurrent = '30'
  $storage_password       = ''
  $storage_configs_dir =  "${bareos::params::config_dir}/storage.d"

  $storage_config_file = $::operatingsystem ? {
    default => '/etc/bareos/bareos-sd.conf',
  }

  $storage_package = $::operatingsystem ? {
    default                   => 'bareos-storage',
  }

  $storage_template = ''
  $storage_source = ''

  $storage_service = $::operatingsystem ? {
    default => 'bareos-sd',
  }

  $storage_process = $::operatingsystem ? {
    default => 'bareos-sd',
  }

  $storage_device_owner = $::operatingsystem ? {
    default => 'bareos',
  }

  $storage_device_group = $::operatingsystem ? {
    /(?i:Debian|Ubuntu|Mint)/ => 'tape',
    default                   => 'disk',
  }

  ## Tray Monitor
  $traymon_name     = "${::fqdn}-mon"
  $traymon_password = ''
  $traymon_command = 'status, .status'

  ## Bareos console variables
  $console_password = ''

  $console_package = $::operatingsystem ? {
    default => 'bareos-bconsole',
  }

  $console_config_file = $::operatingsystem ? {
    default => '/etc/bareos/bconsole.conf',
  }

  $console_template = ''
  $console_source = ''

  ## Bareos database variables
  $database_host              = 'localhost'
  $database_port              = ''
  $database_name              = 'bareos'
  $database_user              = 'bareos'
  $database_password          = ''

  $service_status = $::operatingsystem ? {
    default => true,
  }

  $process_args = $::operatingsystem ? {
    default => '',
  }

  $process_user = $::operatingsystem ? {
    default => 'bareos',
  }

  $process_group = $::operatingsystem ? {
    default => 'bareos',
  }

  $config_file_mode = $::operatingsystem ? {
    default => '0644',
  }

  $config_file_owner = $::operatingsystem ? {
    default => 'root',
  }

  $config_file_group = $::operatingsystem ? {
    default => 'root',
  }

  $config_file_init = $::operatingsystem ? {
    /(?i:Debian|Ubuntu|Mint)/ => '/etc/default/bareos',
    default                   => '/etc/sysconfig/bareos',
  }

  $data_dir = $::operatingsystem ? {
    default => '/etc/bareos',
  }

  $log_dir = $::operatingsystem ? {
    default => '/var/log/bareos',
  }

  $log_file = $::operatingsystem ? {
    default => '/var/log/bareos/bareos.log',
  }

  $protocol = 'tcp'

  # General Settings
  $my_class = ''
  $source_dir = ''
  $source_dir_purge = false
  $options = ''
  $service_autorestart = true
  $version = 'present'
  $absent = false
  $disable = false
  $disableboot = false

  ### General module variables that can have a site or per module default
  $monitor = false
  $monitor_tool = ''
  $monitor_target = $::ipaddress
  $firewall = false
  $firewall_tool = ''
  $firewall_src = '0.0.0.0/0'
  $firewall_dst = $::ipaddress
  $puppi = false
  $puppi_helper = 'standard'
  $debug = false
  $audit_only = false
  $noops = undef
}
