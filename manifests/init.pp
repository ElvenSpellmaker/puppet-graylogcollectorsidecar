# Class: graylogcollectorsidecar
# ===========================
#
# Installs and configures graylog-collector-sidecar
# (https://github.com/Graylog2/collector-sidecar)
#
# Parameters
# ----------
#
# Document parameters here.
#
# * `version`
# Select the version of the collector to install. Defaults to 'latest',
# which selects the latest available, stable release version
# * `api_url`
# Graylog server api url (e.g. http://graylog.example.com:9000/api)
# * `tags`
# An array of tags that the collector should be set up with
#
# Examples
# --------
#
# @example
#    class { 'graylogcollectorsidecar':
#      api_url => 'http://graylog.example.com:9000/api',
#      tags => [ 'apache.accesslog' ]
#    }
#
class graylogcollectorsidecar (
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

  $_node_id = pick($node_id, $::hostname)

  case $::osfamily {
    'Debian': {
      class {
        '::graylogcollectorsidecar::dist::debian':
          version           => $version,
          api_url           => $api_url,
          tags              => $tags,
          update_interval   => $update_interval,
          tls_skip_verify   => $tls_skip_verify,
          send_status       => $send_status,
          list_log_files    => $list_log_files,
          node_id           => $_node_id,
          collector_id      => $collector_id,
          log_path          => $log_path,
          log_rotation_time => $log_rotation_time,
          log_max_age       => $log_max_age,
          backends          => $backends,
          use_auth          => $use_auth,
          username          => $username,
          password          => $password
      }
    }
    'RedHat': {
      class {
        '::graylogcollectorsidecar::dist::redhat':
          version           => $version,
          api_url           => $api_url,
          tags              => $tags,
          update_interval   => $update_interval,
          tls_skip_verify   => $tls_skip_verify,
          send_status       => $send_status,
          list_log_files    => $list_log_files,
          node_id           => $_node_id,
          collector_id      => $collector_id,
          log_path          => $log_path,
          log_rotation_time => $log_rotation_time,
          log_max_age       => $log_max_age,
          backends          => $backends,
          use_auth          => $use_auth,
          username          => $username,
          password          => $password
      }
    }
    'Windows': {
      class {
        'graylogcollectorsidecar::dist::windows':
          version           => $version,
          api_url           => $api_url,
          tags              => $tags,
          update_interval   => $update_interval,
          tls_skip_verify   => $tls_skip_verify,
          send_status       => $send_status,
          list_log_files    => $list_log_files,
          node_id           => $_node_id,
          collector_id      => $collector_id,
          log_path          => $log_path,
          log_rotation_time => $log_rotation_time,
          log_max_age       => $log_max_age,
          backends          => $backends,
          use_auth          => $use_auth,
          username          => $username,
          password          => $password
      }
    }
    default: {
      err("Family ${::osfamily} not supported currently.")
    }

  }

}
