require 'spec_helper'

describe ElectricSheep::Directories do

  DirectoriesKlazz = Class.new do
    include ElectricSheep::Directories

    def initialize(shell)
      @shell = shell
    end

    def exec(cmd)
      @shell.exec(cmd)
    end
  end

  describe DirectoriesKlazz do
    before do
      @subject = subject.new(@shell = mock)
      @seq = sequence('shell')
    end

    it 'creates the project directory' do
      project = mock
      project.stubs(:id).returns('My Project')

      @shell.expects(:exec).in_sequence(@seq).
        with('echo ${ELECTRIC_SHEEP_HOME-"$HOME/.electric_sheep"}').
        returns({out: '/es/home'})
      @shell.expects(:exec).in_sequence(@seq).
        with('mkdir -p /es/home/my\\ project ; chmod 0700 /es/home/my\\ project')

      @subject.mk_project_dir!(project)
    end
  end

end
