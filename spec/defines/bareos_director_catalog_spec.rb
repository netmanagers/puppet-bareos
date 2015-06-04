require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe 'bareos::director::catalog' do

  let(:title) { 'bareos::director::catalog' }
  let(:node) { 'rspec.example42.com' }
  let(:facts) do
    {
      :ipaddress       => '10.42.42.42',
      :operatingsystem => 'Debian',
      :service_autorestart => true,
      :bareos_director_service => 'bareos-dir',
      :bareos_default_password => 'bareos',
    }
  end

  describe 'Test catalog.conf is created with no options' do
    let(:params) do
      {
        :name => 'sample1',
      }
    end
    let(:expected) do
'# This file is managed by Puppet. DO NOT EDIT.

Catalog {
  Name = "sample1"
  DBDriver = mysql
  DBAddress = localhost
  DBName = "bareos"; dbuser = "bareos"; dbpassword = "bareos";
}
'
    end
    it { should contain_file('catalog-sample1.conf').with_path('/etc/bareos/director.d/catalog-sample1.conf').with_content(expected) }
  end

  describe 'Test catalog.conf is created with all main options' do
    let(:params) do
      {
        :name => 'sample2',
        :db_driver => 'postgres',
        :db_address => '10.0.0.3',
        :db_port => '3824',
        :db_name => 'test',
        :db_user => 'netmanagers',
        :db_password => 'password',
      }
    end
    let(:expected) do
'# This file is managed by Puppet. DO NOT EDIT.

Catalog {
  Name = "sample2"
  DBDriver = postgres
  DBAddress = 10.0.0.3
  DBPort = 3824
  DBName = "test"; dbuser = "netmanagers"; dbpassword = "password";
}
'
    end
    it { should contain_file('catalog-sample2.conf').with_path('/etc/bareos/director.d/catalog-sample2.conf').with_content(expected) }

    it 'should automatically restart the director service' do
      should contain_file('catalog-sample2.conf').with_notify('Service[bareos-dir]')
    end
  end

end

