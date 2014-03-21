require "#{File.join(File.dirname(__FILE__),'..','spec_helper.rb')}"

describe 'bareos' do

  let(:title) { 'bareos' }
  let(:node) { 'rspec.example42.com' }
  let(:facts) { { :ipaddress => '10.42.42.42', :operatingsystem => 'Debian' } }

  describe 'Test customizations - source_dir' do
    let(:params) { {:source_dir => "puppet:///modules/monit/dir/spec" , :source_dir_purge => true } }
    it { should contain_file('bareos.dir').with_purge('true') }
    it { should contain_file('bareos.dir').with_force('true') }
  end

  describe 'Test include bareos::client' do
    let(:params) { {:manage_client => true } }
    it { should contain_class('bareos::client') }
  end

  describe 'Test include bareos::storage' do
    let(:params) { {:manage_storage => true } }
    it { should contain_class('bareos::storage') }
  end

  describe 'Test include bareos::director' do
    let(:params) { {:manage_director => true } }
    it { should contain_class('bareos::director') }
  end

  describe 'Test include bareos::console' do
    let(:params) { {:manage_console => true } }
    it { should contain_class('bareos::console') }
  end

  describe 'Test not include bareos::client' do
    let(:params) { {:manage_client => 'false' } }
    it { should_not contain_class('bareos::client') }
  end

  describe 'Test not include bareos::storage' do
    let(:params) { {:manage_storage => 'false' } }
    it { should_not contain_class('bareos::storage') }
  end

  describe 'Test not include bareos::director' do
    let(:params) { {:manage_director => 'false' } }
    it { should_not contain_class('bareos::director') }
  end

  describe 'Test not include bareos::console' do
    let(:params) { {:manage_console => 'false' } }
    it { should_not contain_class('bareos::console') }
  end
end

