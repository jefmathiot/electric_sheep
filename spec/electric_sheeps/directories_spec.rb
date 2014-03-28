require 'spec_helper'

describe ElectricSheeps::Directories do

  before do
    subject.instance_variable_set :@work_dir, nil
    FileUtils.rm_rf "#{ENV['ELECTRIC_SHEEPS_HOME']}"
  end

  describe 'without a home' do

    before do
      @es_home = ENV['ELECTRIC_SHEEPS_HOME']
      ENV['ELECTRIC_SHEEPS_HOME'] = nil
    end

    after do
      ENV['ELECTRIC_SHEEPS_HOME'] = @es_home 
    end

    it "uses a sub-directory of the user's home as the work directory" do
      subject.work_dir.must_equal "#{ENV['HOME']}/.electric_sheeps"
    end

  end

  it "uses a sub-directory of the electric sheeps home as the work directory" do
    subject.work_dir.must_equal "#{ENV['ELECTRIC_SHEEPS_HOME']}"
  end

  it 'creates the work directory' do
    subject.mk_work_dir!
    File.directory?(subject.work_dir).must_equal true
    assert_0700(subject.work_dir)
  end

  describe 'with a project' do

    before do
      @project = ElectricSheeps::Metadata::Project.new(id: 'a Project')
    end

    it "uses a sub-directory of the work directory as the project's home" do
      subject.project_dir(@project).must_equal "#{ENV['ELECTRIC_SHEEPS_HOME']}/a\\ project"
    end

    it 'create the project directory' do
      subject.mk_project_dir!(@project)
      subject.project_dir(@project).tap do |dir|
        File.directory?(dir).must_equal true
        assert_0700(dir)
      end
    end

  end

  def assert_0700(directory)
    File.stat(directory).mode.to_s(8)[-4,4].must_equal '0700'
  end
end
