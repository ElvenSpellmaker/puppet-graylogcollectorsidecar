# RedHat-specific handling

class graylogcollectorsidecar::dist::redhat (
  $api_url,
  $tags,
  $update_interval   = undef,
  $tls_skip_verify   = undef,
  $send_status       = undef,
  $list_log_files    = undef,
  $node_id           = undef,
  $collector_id      = undef,
  $log_path          = undef,
  $log_rotation_time = undef,
  $log_max_age       = undef,
  $backends          = undef,
  $version           = 'latest',
  $use_auth          = undef,
  $username          = undef,
  $password          = undef
) {

  if ($::installed_sidecar_version == $version) {
    debug("Already installed sidecard version ${version}")
  } else {
    # Download package

    # Versions have to be downloaded using tags, the latest release not (https://github.com/dodevops/puppet-graylogcollectorsidecar/issues/2)
    if $version == 'latest' {
      $is_tag = false
    } else {
      $is_tag = true
    }

    githubreleases::download {
      'get_sidecar_package':
        author            => 'Graylog2',
        repository        => 'collector-sidecar',
        release           => $version,
        is_tag            => $is_tag,
        use_auth          => $use_auth,
        username          => $username,
        password          => $password,
        asset             => true,
        asset_filepattern => "${::architecture}\\.rpm",
        target            => '/tmp/collector-sidecar.rpm'
    }

    # Install the package

    package {
      'graylog-sidecar':
        ensure   => 'installed',
        name     => 'collector-sidecar',
        provider => 'rpm',
        source   => '/tmp/collector-sidecar.rpm'
    }

    # Create a sidecar service

    exec {
      'install_sidecar_service':
        creates => '/etc/init/collector-sidecar.conf',
        command => 'graylog-collector-sidecar -service install',
        path    => [ '/usr/bin', '/bin' ]
    }

    Githubreleases::Download['get_sidecar_package']
    -> Package['graylog-sidecar']
    -> Exec['install_sidecar_service']
    -> Class['graylogcollectorsidecar::configure']
    -> Service['sidecar']

  }

  # Configure it

  $_collector_id = pick(
    $collector_id,
    'file:/etc/graylog/collector-sidecar/collector-id'
  )

  $_log_path = pick(
    $log_path,
    '/var/log/graylog/collector-sidecar'
  )

  $_backends = pick(
    $backends,
    [
      {
        name               => 'nxlog',
        enabled            => false,
        binary_path        => '/usr/bin/nxlog',
        configuration_path =>
        '/etc/graylog/collector-sidecar/generated/nxlog.conf'
      },
      {
        name               => 'filebeat',
        enabled            => true,
        binary_path        => '/usr/bin/filebeat',
        configuration_path =>
        '/etc/graylog/collector-sidecar/generated/filebeat.yml'
      }
    ]
  )

  class { 'graylogcollectorsidecar::configure':
    sidecar_yaml_file =>
      '/etc/graylog/collector-sidecar/collector_sidecar.yml',
    api_url           => $api_url,
    tags              => $tags,
    update_interval   => $update_interval,
    tls_skip_verify   => $tls_skip_verify,
    send_status       => $send_status,
    list_log_files    => $list_log_files,
    node_id           => $node_id,
    collector_id      => $_collector_id,
    log_path          => $_log_path,
    log_rotation_time => $log_rotation_time,
    log_max_age       => $log_max_age,
    backends          => $_backends
  } ~> Service['sidecar']

  # Start the service

  service {
    'sidecar':
      ensure => running,
      name   => 'collector-sidecar'
  }

}
