# == Class: solr
#
# Full description of class solr here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { 'solr':
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2015 Your name here, unless otherwise noted.
#
class solr	(
			$tomcatfile,
			$solrfile,
			$srcdir='/usr/local/src',
			$installdir='/opt/solr',
			$tomcatdir='/opt/tomcat-solr',
			$java_package='openjdk-7-jre',
		) inherits params {

	Exec {
		path => '/usr/sbin:/usr/bin:/sbin:/bin',
	}

	package { $java_package:
		ensure => 'installed',
	}

	exec { "check java ${installdir}":
		command => "update-alternatives --display java",
		require => Package[$java_package],
	}

	file { "${srcdir}/tomcat.tgz":
		ensure => 'present',
		owner => 'root',
		group => 'root',
		mode => '0444',
		source => $tomcatfile,
		require => Exec["check java ${installdir}"],
		notify => Exec["untar tomcat ${installdir}"],
	}

	exec { "mkdir p ${tomcatdir}":
		command => "mkdir -p ${tomcatdir}",
		creates => $tomcatdir,
		require => File["${srcdir}/tomcat.tgz"],
	}

	group { 'solr':
        	ensure => present,
		require => File["${srcdir}/tomcat.tgz"],
        }

	user { 'solr':
		ensure => present,
		shell => "/bin/bash",
	        gid => 'solr',
        	managehome => true,
        	home => $installdir,
        	require => Group['solr'],
	}		
	
	file { $tomcatdir:
		ensure => 'directory',
		owner => 'solr',
		group => 'solr',
		mode => '0755',
		require => Group['solr'],
	}

	exec { "untar tomcat ${installdir}":
		command => "tar xzf ${srcdir}/tomcat.tgz -C ${tomcatdir} --owner solr --strip 1",
		require => File[$tomcatdir],
	}

	# instalo solr
	
	file { "${srcdir}/solr.tgz":
		ensure => 'present',
		owner => 'root',
		group => 'root',
		mode => '0444',
		source => $solrfile,
		require => Exec["check java ${installdir}"],
		notify => Exec["untar solr ${installdir}"],
	}
	
	exec { "untar solr ${installdir}":
		command => "tar xzf ${srcdir}/solr.tgz --wildcards solr*/server/webapps/solr.war --strip 3 -C ${installdir} --owner solr",
		require => File["${srcdir}/solr.tgz"],
	}
	

}
