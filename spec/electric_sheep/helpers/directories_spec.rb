require 'spec_helper'

describe ElectricSheep::Helpers::Directories do

  let(:seq) do
    sequence('shell')
  end

  [:host, :project, :interactor].each do |var|
    let(var) do
      mock
    end
  end

  let(:directories) do
    subject.new(host, project, interactor)
  end

  describe 'expanding paths' do
    it 'raises unless project directory created' do
      -> { directories.expand_path('some-file') }.must_raise RuntimeError,
        /Project directory has not been created/
    end

    [nil, '/host/working/dir'].each do |working_dir|
      describe "with#{working_dir ? '' : 'out'} an explicit working directory" do
        describe 'with the project directory created' do

          let(:script) do
            sequence(:script)
          end

          let(:raw_directory) do
            "#{working_dir || '$HOME/.electric_sheep'}/unsafe\\$-project-name"
          end

          let(:project_directory) do
            "/home/user/.electric_sheep/unsafe\\$-project-name"
          end

          before do
            host.expects(:working_directory).returns(working_dir)
            project.expects(:id).returns('UNSAFE$-PROJECT-NAME')
            interactor.expects(:exec).
              with("echo \"#{raw_directory}\"").
              returns(out: project_directory)
            interactor.expects(:exec).
              with("mkdir -p \"#{project_directory}\" ; chmod 0700 \"#{project_directory}\"")
            directories.mk_project_directory!
          end

          it 'expands relative paths' do
            directories.expand_path('path').must_equal "#{project_directory}/path"
          end

          it 'does not expand absolute paths' do
            directories.expand_path('/path').must_equal "/path"
          end
        end
      end
    end
  end

end
