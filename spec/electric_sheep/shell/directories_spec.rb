require 'spec_helper'

describe ElectricSheep::Shell::Directories do
  DirectoriesKlazz = Class.new do
    include ElectricSheep::Shell::Directories
    
    attr_reader :cmd, :host, :project

    def initialize
      @host, @project=Object.new, Object.new
    end

    def exec(cmd)
      @cmd=cmd
    end
  end

  describe DirectoriesKlazz do
    before do
      @subject=subject.new
      ElectricSheep::Helpers::Directories.expects(:project_directory).
        with(@subject.host, @subject.project).returns('/project/dir')
    end

    it 'returns the project directory' do
      @subject.project_directory.must_equal '/project/dir'
    end

    it 'makes the directory and its parents' do
      @subject.mk_project_directory!
      @subject.cmd.must_equal 'mkdir -p /project/dir ; chmod 0700 /project/dir'
    end
  end
end
