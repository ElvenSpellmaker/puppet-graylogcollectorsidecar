require 'spec_helper'

describe 'graylogcollectorsidecar' do

  context 'on Windows/x86_64' do

    let(:facts) {
      {
          :osfamily => 'Windows',
          :architecture => 'x86_64',
          :installed_sidecar_version => ''
      }
    }

    let(:params) {
      {
          :version => '0.1.0-beta.2',
          :api_url => 'http://graylog.example.com',
          :log_path => 'C:\\Program Files\\Graylog\\collector-sidecar\\logs',
          :tags => [
              'default'
          ]
      }
    }

    it { should compile }
    it {
      should contain_remote_file('fetch.C:\Temp\0.1.0-beta.2-collector-sidecar.exe')
    }
    #it { should contain_package('graylog-sidecar') }
    it { should contain_service('sidecar') }
    it { should contain_class('graylogcollectorsidecar::configure') }
    it {
      should contain_yaml_setting('sidecar_set_server')
                 .with_value('http://graylog.example.com')
    }
    it { should contain_yaml_setting('sidecar_set_tags') }
    it { should contain_yaml_setting('sidecar_set_log_path')
                 .with_value('C:\\Program Files\\Graylog\\collector-sidecar\\logs')
    }
    it { should_not contain_yaml_setting('sidecar_set_list_log_files') }
    it { should contain_yaml_setting('sidecar_set_backends')}

  end


end
