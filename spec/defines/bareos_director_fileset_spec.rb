require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe 'bareos::director::fileset' do

  let(:title) { 'bareos::director::fileset' }
  let(:node) { 'rspec.example42.com' }
  let(:facts) do
    {
      :ipaddress       => '10.42.42.42',
      :operatingsystem => 'Debian',
      :service_autorestart => true,
      :bareos_director_service => 'bareos-dir',
      :director_configs_dir => '/etc/bareos/director.d',
    }
  end

  describe 'Test fileset.conf is created with no options' do
    let(:params) do
      {
        :name => 'sample1',
      }
    end
    let(:expected) do
'# This file is managed by Puppet. DO NOT EDIT.

FileSet {
  Name = "sample1"
  Include {
    Options {
      signature = MD5
    }
  }
  Exclude {
  }
}
'
    end
    it { should contain_file('fileset-sample1.conf').with_path('/etc/bareos/director.d/fileset-sample1.conf').with_content(expected) }
  end

  describe 'Test fileset.conf is created with all main options' do
    let(:params) do
      {
        :name => 'sample2',
        :signature => 'MD5',
        :compression => 'GZIP',
        :onefs => 'no',
        :recurse => 'yes',
        :sparse => 'no',
        :noatime => 'no',
        :mtimeonly => 'no',
        :keepatime => 'no',
        :checkfilechanges => 'yes',
        :hardlinks => 'yes',
        :ignorecase => 'no',
        :fstype => ['ext2','ext3','ext4'],
        :include => ['/home/sebastian','/etc'],
        :exclude => ['/proc','/sys','/tmp'],
      }
    end

    let(:expected) do
'# This file is managed by Puppet. DO NOT EDIT.

FileSet {
  Name = "sample2"
  Include {
    Options {
      signature = MD5
      compression = GZIP
      onefs = no
      recurse = yes
      sparse = no
      noatime = no
      mtimeonly = no
      keepatime = no
      checkfilechanges = yes
      hardlinks = yes
      ignorecase = no
      fstype = ext2
      fstype = ext3
      fstype = ext4
    }
    File = /home/sebastian
    File = /etc
  }
  Exclude {
    File = /proc
    File = /sys
    File = /tmp
  }
}
'
    end
    it { should contain_file('fileset-sample2.conf').with_path('/etc/bareos/director.d/fileset-sample2.conf').with_content(expected) }

    it 'should automatically restart the service, by default' do
      should contain_file('fileset-sample2.conf').with_notify('Service[bareos-dir]')
    end
  end

end

