# == Console and Tray Monitor Related Parameters
#
# Tray monitor specific options
# These options are specific to the configuration of bareos's tray monitor
#####################
#
# [*traymon_name*]
#   Name for the tray monitor resource
#   Default: ${::fqdn}-mon
#
# [*traymon_password*]
#   Default: empty, which means [*default_password*] will be used.
#
# [*traymon_command*]
#   Default: 'status, .status'
#
#####################
# Console specific options
# These options are specific to the configuration of bareos storage
#####################
#
# [*console_password*]
#   Default: empty, which means [*default_password*] will be used.
#
# [*console_package*]
#   The name of the console package
#
# [*console_config_file *]
#   Bconsole configuration file.
#   Default: /etc/bareos/bconsole.conf
#
# [*console_template *]
#   Sets the path to the template to use as content for the console's configuration file
#   If defined, console config file has: content => content("$template")
#   Note source and template parameters are mutually exclusive: don't use both
#   A functional template is provided under the templates consoley.
#   Default: empty.
#
# [*console_source *]
#   Sets the content of source parameter for the console's configuration file
#   If defined, console config file will have the param: source => $source
#   Default: empty.
