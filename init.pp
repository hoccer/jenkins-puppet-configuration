define line($file, $line, $ensure = 'present') {
    case $ensure {
        default : { err ( "unknown ensure value ${ensure}" ) }
        present: {
            exec { "/bin/echo '${line}' >> '${file}'":
                unless => "/bin/grep -qFx '${line}' '${file}'"
            }
        }
        absent: {
            exec { "/bin/grep -vFx '${line}' '${file}' | /usr/bin/tee '${file}' > /dev/null 2>&1":
              onlyif => "/bin/grep -qFx '${line}' '${file}'"
            }

            # Use this resource instead if your platform's grep doesn't support -vFx;
            # note that this command has been known to have problems with lines containing quotes.
            # exec { "/usr/bin/perl -ni -e 'print unless /^\\Q${line}\\E\$/' '${file}'":
            #     onlyif => "/bin/grep -qFx '${line}' '${file}'"
            # }
        }
    }
}


include backuppc-client
include deployment-user
include nrpe
include apt

notice("Jenkins certificate location set to: ${$::jenkins_cert}")

# HAProxy installation & configuration
apt::ppa { 'ppa:vbernat/haproxy-1.5': }

class { 'haproxy':
  global_options   => {
    'daemon'  => '',
    'maxconn' => '256',
  },
   defaults_options => {
    'mode'    => 'http',
    'option'  => 'forwardfor',
    'timeout' => [
      'connect 5s',
      'client 50s',
      'server 50s',
      'tunnel 1h'
    ],
  },
  require => Apt::PPA['ppa:vbernat/haproxy-1.5'],
}

haproxy::listen { 'https-in':
   ipaddress => '*',
   ports     => '443',
   bind_options => {
     'ssl crt' => $::jenkins_cert,
     },
   options   => {
     'reqadd'  => "X-Forwarded-Proto:\\ https",
     'server' => 'server1 127.0.0.1:8080 maxconn 32',
   },
 }

# Jenkins installation & configuration
class { 'jenkins':
  service_enable => false,
  service_ensure => 'stopped',
}

file_line { 'jenkins_run_standalone_false':
  path => '/etc/default/jenkins',
  line => 'RUN_STANDALONE=false',
  match => "^RUN_STANDALONE=.*$",
  require => Class['jenkins::service'],
}

# Jetty installation & configuration
$jetty_version = '9.2.0.v20140526'

class { 'jetty':
  version => $jetty_version,
  user => 'jenkins',
  group => 'jenkins',
  require => Class['jenkins::package'],
}
->
file_line { 'jetty_no_start':
  path => '/etc/default/jetty',
  line => 'NO_START=0',
  ensure => 'present',
}
->
exec { 'jenkins.xml':
  command => "cp files/jenkins.xml /opt/jetty/webapps/",
  path => '/usr/local/bin/:/bin/',
}
->
exec { 'jetty-deploy.xml':
  command => "cp files/jetty-deploy.xml /opt/jetty/etc/",
  path => '/usr/local/bin/:/bin/',
}
->
file_line { 'configure_jetty-deploy.xml':
 path => "/opt/jetty/etc/jetty.conf",
 line => 'jetty-deploy.xml',
 ensure => 'present',
}
->
exec { 'jetty.xml':
 command => "cp files/jetty.xml /opt/jetty/etc/",
 path => '/usr/local/bin/:/bin/',
}
->
exec { 'jetty_restart':
  command => 'sudo service jetty restart',
  path => '/usr/bin/:/usr/bin/:/bin/',
}
