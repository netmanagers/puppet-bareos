require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe 'bareos::director::client' do

  let(:title) { 'bareos::director::client' }
  let(:node) { 'rspec.example42.com' }
  let(:facts) do
    {
      :ipaddress       => '10.42.42.42',
      :operatingsystem => 'Debian',
      :service_autorestart => true,
      :bareos_director_service => 'bareos-dir',
      :bareos_default_password => 'bareos'
    }
  end

  describe 'Test client.conf is created with no options' do
    let(:params) do
      {
        :name => 'sample1',
        :address => '1.2.3.4',
        :catalog => 'MyCatalog',
      }
    end
    let(:expected) do
'# This file is managed by Puppet. DO NOT EDIT.

Client {
  Name = "sample1"
  Address = 1.2.3.4
  FDPort = 9102
  Password = "bareos"
  Catalog = "MyCatalog"
  AutoPrune = true
  HeartbeatInterval = 1 minute
}
'
    end
    it 'should generate a valid client configuration' do
      should contain_file('client-sample1.conf').with_path('/etc/bareos/clients.d/sample1.conf').with_content(expected)
    end
  end

  describe 'Test client.conf is created with all main options' do
    let(:params) do
      {
        :name => 'sample2',
        :address => '5.6.7.8',
        :catalog => 'another_catalog',
        :port => '5555',
        :password => 'this_pazz',
        :file_retention => '2 jiffies',
        :job_retention => '1 eon',
        :auto_prune => false,
        :max_concurrent => '12'
      }
    end

    let(:expected) do
'# This file is managed by Puppet. DO NOT EDIT.

Client {
  Name = "sample2"
  Address = 5.6.7.8
  FDPort = 5555
  Password = "this_pazz"
  Catalog = "another_catalog"
  FileRetention = 2 jiffies
  JobRetention = 1 eon
  AutoPrune = false
  MaximumConcurrentJobs = 12
  HeartbeatInterval = 1 minute
}
'
    end
    it 'should generate a client config with most of its parameters set' do
      should contain_file('client-sample2.conf').with_path('/etc/bareos/clients.d/sample2.conf').with_content(expected)
    end

    it 'should automatically restart the service, by default' do
      should contain_file('client-sample2.conf').with_notify('Service[bareos-dir]')
    end
  end

end

