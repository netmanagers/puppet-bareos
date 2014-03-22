# Class: bareos::database
#
# This class enforces database resources needed by all
# bareos components
#
# This class is not to be called individually
#
class bareos::database {

  include bareos

  ### Managed resources
  require bareos::repository

  package { 'bareos-database':
    ensure  => $bareos::manage_package,
    name    => "bareos-database-${bareos::database_backend}",
    noop    => $bareos::noops,
    require => Class['bareos::repository'],
  }

  if $bareos::manage_database {
    $real_db_password = $bareos::database_password ? {
      ''      => $bareos::real_default_password,
      default => $bareos::database_password,
    }

    $script_directory = '/usr/lib/bareos/scripts'

    $db_parameters = $bareos::database_backend ? {
      'sqlite' => '',
      'mysql'  => "--host=${bareos::database_host} --user=${bareos::database_user} --password=${real_db_password} --port=${bareos::database_port} --database=${bareos::database_name}",
    }

    exec { 'create_db_and_tables':
      command     => "${script_directory}/create_${bareos::database_backend}_database;
                      ${script_directory}/make_${bareos::database_backend}_tables ${db_parameters}",
      refreshonly => true,
    }

    case $bareos::database_backend {
      'mysql': {
        require mysql::client

        $grant_query = "use mysql
          grant all privileges
            on ${bareos::database_name}.*
            to ${bareos::database_user}@localhost
            ${bareos::database_password};
          grant all privileges
            on ${bareos::database_name}.*
            to ${bareos::database_user}@\"%\"
            ${bareos::database_password};
          flush privileges;"

        $notify_create_db = $bareos::manage_database ? {
          true  => Exec['create_db_and_tables'],
          false => undef,
        }

        $require_classes = defined(Class['mysql::client']) ? {
          true  => Class['mysql::client'],
          false => undef,
        }

        mysql::query { 'grant_bareos_user_privileges':
          mysql_query => $grant_query,
          mysql_db    => undef,
          mysql_host  => $bareos::database_host,
          notify      => $notify_create_db,
          require     => $require_classes,
        }
      }
      'sqlite': {
        sqlite::db { $bareos::database_name:
          ensure   => present,
          location => "/var/lib/bareos/${bareos::database_name}.db",
          owner    => $bareos::process_user,
          group    => $bareos::process_group,
          require  => File['/var/lib/bareos'],
        }
      }
      default: {
        fail "The bareos module does not support managing the ${bareos::database_backend} backend database"
      }
    }
  }
}
