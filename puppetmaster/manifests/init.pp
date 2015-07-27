class puppetmaster {

  include puppetmaster::devtools

  package { 'r10k_package':
  name  => 'r10k',
  provider => 'gem',
  ensure   => present,
  }

  package { 'ruby-devel':
    ensure  => present
  }

  package {'libxml2':
    ensure  => present
  }

  package {'libxml2-devel':
    ensure => present
  }

  package { 'libxslt':
    ensure => present
  }

  package { 'libxslt-devel':
    ensure => present
  }

  file { 'r10k':
  path => '/etc/r10k.yaml',
  owner => 'root',
  mode  => '0600',
  source => 'puppet:///modules/puppetmaster/r10k.yaml',
  require => Package['r10k_package'],
  }

  file { 'hiera':
    path    => '/etc/puppet/hiera.yaml',
    ensure  => present,
    owner   => 'puppet',
    mode    => '0600',
    content => template('puppetmaster/hiera.yaml.erb')
  }

  exec { 'r10kinit':
    command => 'r10k deploy environment',
    path  => ['/usr/local/bin', '/usr/bin'],
    cwd   => '/etc/',
    creates => '/etc/puppet/environment',
    require => [ Package['r10k_package'], File['r10k']],
    user  => 'root'
  }

  file { 'env':
    ensure => present,
    path => '/etc/puppet/environments/DEMO_develop/environment.conf',
    owner => 'puppet',
    mode  => '0664',
    source => 'puppet:///modules/puppetmaster/environment.conf',
    require => Exec['r10kinit'],
  }

  file { 'puppetconf':
    path   => '/etc/puppet/puppet.conf',
    ensure => present,
    owner  => 'puppet',
    mode   => '0600',
    source => 'puppet:///modules/puppetmaster/puppet.conf'
  }

  file {'manifest_dir':
    path => '/etc/puppet/environments/DEMO_develop/manifests',
    ensure => directory,
    owner  => 'puppet',
    mode   => '0700',
    require => Exec['r10kinit']
  }

  file { 'sitepp':
    ensure => present,
    path   => '/etc/puppet/environments/DEMO_develop/manifests/site.pp',
    owner  => 'puppet',
    mode   => '0600',
    source => 'puppet:///modules/puppetmaster/site.pp',
    require => File['manifest_dir']
  }

  file { 'autosign':
    ensure  => present,
    path    => '/etc/puppet/autosign.conf',
    owner   => 'puppet',
    mode    => '0600',
    source  => 'puppet:///modules/puppetmaster/autosign.conf'
  }

  file { 'initscript':
    ensure   => present,
    path     => '/etc/init.d/puppetmaster',
    owner    => 'root',
    mode     => '0700',
    source   => 'puppet:///modules/puppetmaster/initscript'
  }

  service { 'puppetmaster':
    ensure  => running,
    enable  => true,
    hasrestart => true,
    require   => [File['initscript'], Exec['r10kinit']]
  }

}
