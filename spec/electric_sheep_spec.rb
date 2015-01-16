require 'spec_helper'

describe ElectricSheep do

  it 'provides the path to the gem installation' do
    subject.gem_path.must_equal `pwd`.chomp
  end

  it 'provides the path to the templates' do
    subject.template_path.must_equal "#{subject.gem_path}/templates"
  end

  it 'provides the version' do
    subject.version.must_equal ElectricSheep::VERSION
  end

  describe 'providing the revision hash' do

    before do
      subject.instance_variable_set(:@sha, nil)
    end

    after do
      ENV['ELECTRIC_SHEEP_REVISION'] = nil
    end

    it 'uses the revision in cache' do
      subject.instance_variable_set(:@sha, 'xxxxxxx')
      subject.git_revision.must_equal 'xxxxxxx'
    end

    it 'gets the hash from an environment variable' do
      ENV['ELECTRIC_SHEEP_REVISION'] = '0123456' + 'x' * 33
      subject.git_revision.must_equal '0123456'
    end

    it 'get the hash from the git repository' do
      GitRev::Sha.any_instance.expects(:short).returns 'fedcba9'
      subject.git_revision.must_equal 'fedcba9'
    end

    it 'returns an unknown revision when unable to get it' do
      GitRev::Sha.any_instance.expects(:short).raises 'An exception'
      subject.git_revision.must_equal '-------'
    end

  end

  it 'merges the version and git revision' do
    subject.expects(:version).returns('0.0.0')
    subject.expects(:git_revision).returns('0000000')
    subject.revision.must_equal '0.0.0 0000000'
  end

end
