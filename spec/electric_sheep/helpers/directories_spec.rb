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
      subject.new(host,nil,nil).working_directory.must_equal '$HOME/.electric_sheep'
    end

    it 'uses the host working directory if any' do
      host.expects(:working_directory).returns('/tmp')
      subject.new(host,nil,nil).working_directory.must_equal '/tmp'
    end
  end

  describe 'returning project directory' do
    it 'uses the project id' do
      host.expects(:working_directory).returns('/tmp')
      project=mock
      project.expects(:id).returns('project_path')
      interactor = mock
      interactor.expects(:exec).with("echo \"/tmp/project_path\"").returns({out:"/tmp/some_project"})
      subject.new(host,project,interactor).project_directory.must_equal "/tmp/some_project"
    end
  end

  it 'make project directory' do
     instance = subject.new(nil,nil,interactor = mock)
     interactor.expects(:exec).with('mkdir -p folder_path ; chmod 0700 folder_path').returns({out:"folder_path"})
     instance.stubs(:project_directory).returns("folder_path")
     instance.mk_project_directory!.must_equal "folder_path"
  end
end
