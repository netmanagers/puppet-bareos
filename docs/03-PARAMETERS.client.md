# == Client Specific Parameters
#
# These options are specific to the configuration of bareos client
#####################
#
# [*client_name*]
#   Name for the client resource
#   Default: "${::fqdn}-fd"
#
# [*client_port*]
#   Port where the client listens
#   Default: tcp/9102
#
# [*client_address*]
#   Address where the client listens. Can be specified as a hostname, fqdn or ip address.
#   Default: "$::ipaddress"
#
# [*client_password*]
#   Client password required to connect to this host.
#   Must match the password in the corresponding [*bareos::director::client*] entry.
#   Default: empty, which means [*default_password*] will be used.
#
# [*client_max_concurrent*]
#   Maximum number of concurrent connections this client accepts.
#   Default: empty, uses bareos's default of 1.
#
# [*client_config_file*]
#   Bareos-fd configuration file. 
#   Default: /etc/bareos/bareos-fd.conf
#
# [*client_template*]
#   Sets the path to the template to use as content for the client's configuration file
#   If defined, client config file has: content => content("$template")
#   Note source and template parameters are mutually exclusive: don't use both
#   A functional template is provided under the templates directory.
#   Default: empty.
#   
# [*client_source*]
#   Sets the content of source parameter for the client's configuration file
#   If defined, client config file will have the param: source => $source
#   Default: empty.
#
# [*client_pid_file*]
#   Path of the client's pid file. 
#
# [*client_package*]
#   The name of the client's package
#
# [*client_service*]
#   The name of the client's service script
#
# [*client_process*]
#   The client's process name
