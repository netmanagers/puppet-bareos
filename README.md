# Puppet module: bareos

This is a Puppet module for bareos (Backup Archiving Recovery Open Sourced), a bacula fork 
based on the second generation layout ("NextGen") of Example42 Puppet Modules.

Made by Javier Bértoli / Netmanagers

Forked from http://github.com/netmanagers/puppet-bacula

Based on Example42 modules made by Alessandro Franceschi / Lab42

Official site: http://github.com/netmanagers/puppet-bareos

Official git repository: http://github.com/netmanagers/puppet-bareos

Released under the terms of Apache 2 License.

This module requires functions provided by the Example42 Puppi module (you need it even if you don't
use and install Puppi)

For detailed info about the logic and usage patterns of Example42 modules check the DOCS directory
on Example42 main modules set.

For detailed info about bareos configuration, please check http://doc.bareos.org

## USAGE - Basic management

* Bareos consists of at least three different applications (a Director, a Storage manager, Clients)
  and a Console (CLI, GUI, etc.) to manage these resources. This module provides classes and defines
  to install and configure them all, with a fair degree of customization. Some parameters can be
  given specifically for each of these applications while others are common to all the
  classes and defines, for consistency.
  
  Please check the **docs** directory for the available parameters on each class and define.
  
  Als check *params.pp*, *init.pp* and the manifests for details.

* Adds the repositories from bareos.org. Current implementation on repositories management is crude and
  not very well tested. If you find any error, please let us know.

* Install bareos with default settings: this, by default, will install only the Client daemon
  (bareos-fd) and, following Ex42 modules standard practice, will leave all the default configuration
  as provided by your distribution.

```puppet
class { 'bareos': }
```

  You can choose which part of bareos to install on a host

```puppet
class { 'bareos:
  manage_client   => true,
  manage_storage  => false,
  manage_director => true,
  manage_console  => false,
}
```

* Install a specific version of bareos storage package

```puppet
class { 'bareos':
  manage_storage => true,
  version        => '1.0.1',
}
```

  Keep present that the client will **ALWAYS** be installed and managed, unless explicitelly said so
  setting *manage_client* to false

```puppet
class { 'bareos':
  manage_client  => false,
  manage_storage => true,
  version        => '1.0.1',
}
```

* Disable bareos service.

```puppet
class { 'bareos':
  disable => true
}
```

* Remove bareos package

```puppet
class { 'bareos':
  absent => true
}
```

* Enable auditing without making changes on existing bareos configuration *files*

```puppet
class { 'bareos':
  audit_only => true
}
```

* Module dry-run: Do not make any change on *all* the resources provided by the module

```puppet
class { 'bareos':
  noops => true
}
```


## USAGE - Overrides and Customizations

* For each of bareos applications managed you can override its configuration using \*_ source of
  \*_template variables.

* Use custom source directory for the whole configuration dir

```puppet
class { 'bareos':
  source_dir            => 'puppet:///modules/example42/bareos/conf/',
  source_director_purge => false, # Set to true to purge any existing file not present in $source_dir
}
```

* Use custom sources for config file 

```puppet
class { 'bareos':
  manage_client   => false,
  manage_director => true,
  director_source => [ "puppet:///modules/netmanagers/bareos/bareos-dir.conf-${hostname}",
                       "puppet:///modules/example42/bareos/bareos-dir.conf" ], 
}
```

* Templating in this module is **strongly recommended**, but differs from other templatings
  in the final result of bareos's configuration dir structure. As bareos permits you to split
  configuration in different files to improve manageability, we make use of this as soon as you
  choose to use templates for any of the applications. We also provide templates for all of
  bareos's daemons. Check the templates dir for more details. Remember that you can always provide
  your own if none of these suits your particular case.

  When using templates in this module, the resulting configuration directory ends up like this
  (module's default values considered):

        /etc/bareos/
                bareos-dir.conf       <= Main director config file
                director.d/           <= Director's stanzas
                   catalog-*.conf          - Catalogs
                   fileset-*.conf          - Filesets
                   job-*.conf              - Jobs 
                   jobdef-*.conf           - Jobs 
                   messages-*.conf         - Messages
                   pool-*.conf             - Pools
                   schedule-*.conf         - Schedules
                   storage-*.conf          - Storages
                clients.d/            <= Each client DIRECTOR's entry
                   client1.conf
                   client2.conf
                   clientN.conf
                bareos-sd.conf        <= Main storage config file
                storage.d/            <= Storage's stanzas
                   device-*.conf           - Devices
                bareos-fd.conf        <= Client config file
                bconsole.conf         <= Console config file

  For each possible stanza we provide a define to create them. Please check the manifests headers
  to see the available parameters for each.

* Add a new device to the storage daemon, using the included template and default values:

```puppet
bareos::storage::device { 'new_device':
  media_type     => 'File',
  archive_device => '/some/backup/dir',
}
```

* Automatically include a custom subclass

```puppet
class { 'bareos':
  my_class => 'example42::my_bareos',
}
```


## USAGE - Example42 extensions management 
* Activate puppi (recommended, but disabled by default)

```puppet
class { 'bareos':
  puppi => true,
}
```

* Activate puppi and use a custom puppi_helper template (to be provided separately with a puppi::helper define ) to customize the output of puppi commands 

```puppet
class { 'bareos':
  puppi        => true,
  puppi_helper => 'myhelper', 
}
```

* Activate automatic monitoring (recommended, but disabled by default). This option requires the usage of Example42 monitor and relevant monitor tools modules

```puppet
class { 'bareos':
  monitor      => true,
  monitor_tool => [ 'nagios' , 'monit' , 'munin' ],
}
```

* Activate automatic firewalling. This option requires the usage of Example42 firewall and relevant firewall tools modules

```puppet
class { 'bareos':       
  firewall      => true,
  firewall_tool => 'iptables',
  firewall_src  => '10.42.0.0/24',
  firewall_dst  => $ipaddress_eth0,
}
```


## CONTINUOUS TESTING

Travis {<img src="https://travis-ci.org/netmanagers/puppet-bareos.png?branch=master" alt="Build Status" />}[https://travis-ci.org/netmanagers/puppet-bareos]
