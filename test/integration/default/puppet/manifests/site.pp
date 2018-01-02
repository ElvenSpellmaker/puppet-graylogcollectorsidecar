class {
  '::graylogcollectorsidecar':
    api_url         => 'https://graylog.company.com',
    version         => '0.1.0',
    tags            => [
      'TESTTAG',
    ],
    tls_skip_verify => true,
    log_max_age     => 4711,
}