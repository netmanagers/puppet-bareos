# == Storage Specific Parameters
#
# These options are specific to the configuration of bareos storage
#####################
#
# [*storage_name*]
#   Name for the storage resource
#   Default: ${::fqdn}-sd
#
# [*storage_address*]
#   Address where the storage listens. Can be specified as a hostname, fqdn or ip address.
#   Default: $::ipaddress
#
# [*storage_port*]
#   Port where the storage listens
#   Default: 9103'
#
# [*storage_max_concurrent*]
#   Maximum number of concurrent connections this storage accepts.
#   Default: 30
#
# [*storage_password*]
#   Storage password.
#   Default: empty, which means [*default_password*] will be used.
#
# [*storage_configs_dir*]
#   Storage where the different storage's config files will be stored.
#   Default: /etc/bareos/storage.d
#
# [*storage_config_file*]
#   Bareos-dir configuration file.
#   Default: /etc/bareos/bareos-sd.conf
#
# [*storage_package*]
#   The name of the storage package
#
# [*storage_template*]
#   Sets the path to the template to use as content for the storage's configuration file
#   If defined, storage config file has: content => content("$template")
#   Note source and template parameters are mutually exclusive: don't use both
#   A functional template is provided under the templates storagey.
#   Default: empty.
#
# [*storage_source*]
#   Sets the content of source parameter for the storage's configuration file
#   If defined, storage config file will have the param: source => $source
#   Default: empty.
#
# [*storage_service*]
#   The name of the storage's service script
#
# [*storage_process*]
#The storage's process name
#
#
### Related defines (see headers for valid options)
#
* bareos::storage::device
