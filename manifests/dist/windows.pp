# Windows-specific handling

class graylogcollectorsidecar::dist::windows (
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

  $temp_windows_directory    = 'C:\\Temp'
  $graylog_install_directory = 'C:\\Program Files\\Graylog\\collector-sidecar'

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
        asset_filepattern => '\\.exe',
        target            => "${temp_windows_directory}\\${version}-collector-sidecar.exe"
    } ~> Exec['install_sidecar']

    # Install the exe

    # Input any server and tags here as we'll configure it later
    exec {
      'install_sidecar':
        creates => "${graylog_install_directory}\\collector_sidecar.yml",
        command => "${temp_windows_directory}\\${version}-collector-sidecar.exe /S -SERVERURL=http://foo.bar:9000 -TAGS=Windows"
    } ~> Exec['install_sidecar_service']

    # Create a sidecar service

    exec {
      'install_sidecar_service':
        command     => "\"${graylog_install_directory}\\Graylog-collector-sidecar.exe\" -service install",
        refreshonly => true
    }

    Githubreleases::Download['get_sidecar_package']
    -> Exec['install_sidecar']
    -> Exec['install_sidecar_service']
    -> Class['graylogcollectorsidecar::configure']
    -> Service['sidecar']

  }

  # Configure it

  $_collector_id = pick(
    $collector_id,
    "file:${graylog_install_directory}\\collector-id"
  )

  $_log_path = pick(
    $log_path,
    "${graylog_install_directory}\\logs"
  )

  $_backends = pick(
    $backends,
    [
      {
        name               => 'nxlog',
        enabled            => false,
        binary_path        => "C:\\Program Files (x86)\\nxlog\\nxlog.exe",
        configuration_path =>
        "${graylog_install_directory}\\generated\\nxlog.conf"
      },
      {
        name               => 'winlogbeat',
        enabled            => true,
        binary_path        => "${graylog_install_directory}\\winlogbeat.exe",
        configuration_path =>
        "${graylog_install_directory}\\generated\\winlogbeat.yml"
      },
      {
        name               => 'filebeat',
        enabled            => true,
        binary_path        => "${graylog_install_directory}\\filebeat.exe",
        configuration_path =>
        "${graylog_install_directory}\\generated\\filebeat.yml"
      }
    ]
  )

  class { 'graylogcollectorsidecar::configure':
    sidecar_yaml_file =>
      "${graylog_install_directory}\\collector_sidecar.yml",
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
