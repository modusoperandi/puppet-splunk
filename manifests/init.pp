# Copyright (c) 2010 TransGaming Inc. All rights reserved. Use of this source
# code is governed by a BSD-style license that can be found in the LICENSE file.

class splunk {
  
  # LightWeight Forwarder
  class forwarder {
    package { splunkforwarder:
      ensure => installed
    }
    
    service { splunk:
      ensure     => running,
      enable     => true,
      hasrestart => true,
      hasstatus  => false,
      pattern    => "splunkd",
      require    => [ File[ 
                        "/etc/init.d/splunkforwarder"
                      ],
                      Package["splunkforwarder"],
                    ],
      subscribe  => [ Package["splunkforwarder"], Exec['add-forwarder'] ]
    }
    
    # Init script (Based on `/opt/splunk/bin/splunk enable boot-start`)
    file { "/etc/init.d/splunkforwarder":
      owner => root, group => root, mode => 755,
      source => [
        "puppet:///modules/splunk/etc/forwarder-init-script.$fqdn",
        "puppet:///modules/splunk/etc/forwarder-init-script",
      ],
    }
    
    exec { "add-forwarder": 
      command => "splunk add forward-server logs.cloud.mo-stud.io:9997",
      notify => Service['splunkforwarder'],
      require => Package['splunkforwarder']
    }
    
    
    
  } # end splunk::lwf
  
  
  # Let's just manage the Splunk cert for the Splunk indexer
  class server {
    
    package { splunk:
      ensure => installed,
    }
    
    service { splunk:
      ensure     => running,
      enable     => true,
      hasrestart => true,
      hasstatus  => false,
      pattern    => "splunkd",
      require    => [ File[ 
                            "/etc/init.d/splunk",
                            "/opt/splunk/etc/system/local/inputs.conf", 
                            "/opt/splunk/etc/splunk.license", 
                            "/opt/splunk/etc/certs/cacert.pem"
                          ],
                      Package["splunk"],
                    ],
      subscribe  => [ File[ 
                            "/opt/splunk/etc/splunk.license",
                            "/opt/splunk/etc/system/local/inputs.conf",
                            "/opt/splunk/etc/certs/cacert.pem"
                          ],
                      Package["splunk"],
                    ],
    }
    
    file { "/opt/splunk/etc/splunk.license":
      owner => splunk, group => splunk, mode => 600,
      source => [
        "puppet:///modules/splunk/etc/splunk.license.$fqdn",
        "puppet:///modules/splunk/etc/splunk.license",
      ],
      require => Package['splunk'],
    }
    
    
    # Init script (Based on `/opt/splunk/bin/splunk enable boot-start`)
    file { "/etc/init.d/splunk":
      owner => root, group => root, mode => 755,
      source => [
        "puppet:///modules/splunk/etc/init-script.$fqdn",
        "puppet:///modules/splunk/etc/init-script",
      ],
    }
    # Users local to the Splunk install (e.g., admin)
    file { "/opt/splunk/etc/passwd":
      owner => splunk, group => splunk, mode => 600,
      source => [
        "puppet:///modules/splunk/etc/passwd.$fqdn",
        "puppet:///modules/splunk/etc/passwd",
      ],
      require => Package['splunk'],
    }
    file { "/opt/splunk/etc/certs":
      ensure => directory,
      owner => splunk, group => splunk, mode => 700,
      require => Package['splunk'],
    }
    
    file { "/opt/splunk/etc/certs/cacert.pem":
      owner => splunk, group => splunk, mode => 600,
      source => [
        "puppet:///modules/splunk/etc/certs/cacert.pem",
      ],
      require => Package['splunk'],
    }
    
    Service['splunk'] {
      require    => [ File[ 
                            "/etc/init.d/splunk",
                            "/opt/splunk/etc/system/local/inputs.conf", 
                            "/opt/splunk/etc/splunk.license", 
                            "/opt/splunk/etc/certs/cacert.pem", 
                            "/opt/splunk/etc/certs/splunk.pem"
                          ], 
                      Package["splunk"], 
                    ],
      subscribe  => [ File[ 
                            "/opt/splunk/etc/splunk.license", 
                            "/opt/splunk/etc/certs/cacert.pem",
                            "/opt/splunk/etc/certs/splunk.pem",
                            "/opt/splunk/etc/system/local/inputs.conf"
                          ],
                      Package["splunk"],
                    ],
      
    }
    
    file { "/opt/splunk/etc/system/local/inputs.conf":
      owner => splunk, group => splunk, mode => 600,
      content => template("splunk/local/inputs.conf-server.erb"),
      require => Package['splunk'],
    }
    file { "/opt/splunk/etc/certs/splunk.pem":
      owner => splunk, group => splunk, mode => 600,
      source => [
        "puppet:///modules/splunk/etc/certs/$fqdn.pem",
        "puppet:///modules/splunk/etc/certs/splunk.pem",
      ],
      require => Package['splunk'],
    }
  } # end splunk::server
}
