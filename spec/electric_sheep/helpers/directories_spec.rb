require 'spec_helper'

describe ElectricSheep::Helpers::Directories do

  let(:seq) do
    sequence('shell')
  end

  let(:host) do
    mock
  end

  describe 'returning working directory' do
    it 'defaults to home' do
      host.expects(:working_directory).returns(nil)
      subject.working_directory(host).must_equal '$HOME/.electric_sheep'
    end

    it 'uses the host working directory if any' do
      host.expects(:working_directory).returns('/tmp')
      subject.working_directory(host).must_equal '/tmp'
    end
  end

  describe 'returning project directory' do
    it 'uses the project id' do
      host.expects(:working_directory).returns('/tmp')
      project=mock
      project.expects(:id).returns('SOME PROJECT')
      subject.project_directory(host, project).must_equal "/tmp/some\\ project"
    end
  end
end
