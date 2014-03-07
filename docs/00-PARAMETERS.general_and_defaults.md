# == General Parameters and Defaults
#
# These parameters control the general behaviour of bareos's packages
#####################
#
# [*manage_client*]    #   Default: true
# [*manage_storage*]   #   Default: false
# [*manage_director*]  #   Default: false
# [*manage_console*]   #   Default: false
# [*manage_database*]  #   Default: false
#   Select which part of a bareos installation you want to manage in this host.
#   By default, the module just installs *bareos-client*, so in its simplest invocation
#   you can use it to install all your clients.
#   All bareos daemons can be installed on any given host.
#
# [*heartbeat_interval*]
#   Keepalive interval used in various parts of bareos
#   Default: 1 minute
#
# [*working_directory*]
#   Directory where bareos stores its files.
#   As some versions of bareos use /var/spool/bareos and others /var/lib/bareos, we
#   Create [*working_directory*] and make sure /var/lib/bareos is a symlink to it.
#   Default: /var/spool/bareos
#
#
#
#####################
# Defaults values
# These defaults set values that usually are required in multiple bareos's resources.
# Specifying them as defaults here, let you simplify your configurations, yet allowing
# to override them as needed.
#####################
#
# [*default_catalog*]
#   Catalog where to store bareos's records.
#   Default: bareos
#
# [*default_messages*]
#   Resource where messages will be directed to if no other specified.
#   Default: standard
#
# [*default_file_retention*]
#   Default file retention, if no other specified for a given resource.
#   Default: 60 days (bareos's default)
#
# [*default_job_retention*]
#   Default job retention if no other specified for a given resource.
#   Default: 180 days (bareos's default)
#
# [*default_jobdef*]
#   A jobdef declaration to be used as a default to create jobs, if no other specified.
#   Default: empty
#
# [*default_archive_device*]
#   When specifying multiple storage devices, a default archive device to be used
#   when no other specified.
#
# [*password_salt*]
#   Uses a salt with FQDN_RAND when generating the main password.
#   If you do not use this, the password can be reverse engineered very easily.
#   Example: $password_salt = 'smeg'
#
# [*default_password*]
#   Password to be useed everywhere where bareos requires a password, from the
#   database to all the clients and no specific password was declared.
#   Accepted values:
#     * Any string you want to use as a password.
#     * 'auto': a random password is generated and stored in
#       $config_dir/default_password
#     * empty: no default_password will be used.
#   If any of {director,console,traymon,client,storage}_password is given,
#   it will override this one for that particular password.
#   Default: 'auto'
