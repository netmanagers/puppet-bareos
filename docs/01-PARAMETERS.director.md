# == Director Specific Parameters
#
# These options are specific to the configuration of bareos director
#####################
#
# [*director_name*]
#   Name for the director resource
#   Default: "${::fqdn}-dir"
#
# [*director_port*]
#   Port where the director listens
#   Default: 9101
#
# [*director_address*]
#   Address where the director listens. Can be specified as a hostname, fqdn or ip address.
#   Default: $::ipaddress
#
# [*director_max_concurrent*]
#   Maximum number of concurrent connections this director accepts.
#   Default: 30
#
# [*director_password*]
#   Director password.
#   Default: empty, which means [*default_password*] will be used.
#
# [*director_configs_dir*]
#   Director where the different director's config files will be stored.
#   Default: /etc/bareos/director.d
#
# [*director_clients_dir*]
#   Director where the different director's clients files will be stored.
#   Default: /etc/bareos/clients.d
#
# [*director_package*]
#   The name of the client's package
#
# [*director_config_file*]
#   Bareos-dir configuration file.
#   Default: /etc/bareos/bareos-dir.conf
#
# [*director_template*]
#   Sets the path to the template to use as content for the director's configuration file
#   If defined, director config file has: content => content("$template")
#   Note source and template parameters are mutually exclusive: don't use both
#   A functional template is provided under the templates directory.
#   Default: empty.
#
# [*director_source*]
#   Sets the content of source parameter for the director's configuration file
#   If defined, director config file will have the param: source => $source
#   Default: empty.
#
# [*director_pid_file*]
#   Path of the director's pid file.
#
# [*director_service*]
#   The name of the director's service script
#
# [*director_process*]
#   The director's process name
#
# [*director_service*]
#   The name of the director's service script
#
# [*director_process*]
#   The director's process name
#
### Related defines (see headers for valid options)
#
* bareos::director::catalog
* bareos::director::client
* bareos::director::fileset
* bareos::director::job
* bareos::director::messages
* bareos::director::pool
* bareos::director::schedule
* bareos::director::storage
