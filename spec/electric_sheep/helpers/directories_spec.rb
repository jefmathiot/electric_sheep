require 'spec_helper'

describe ElectricSheep::Helpers::Directories do

  let(:seq) do
    sequence('shell')
  end

  [:host, :job, :interactor].each do |var|
    let(var) do
      mock
    end
  end

  let(:directories) do
    subject.new(host, job, interactor)
  end

  describe 'expanding paths' do
    it 'raises unless job directory created' do
      -> { directories.expand_path('some-file') }.must_raise RuntimeError,
        /job directory has not been created/
    end

    [nil, '/host/working/dir'].each do |working_dir|
      describe "with#{working_dir ? '' : 'out'} an explicit working directory" do
        describe 'with the job directory created' do

          let(:script) do
            sequence(:script)
          end

          let(:raw_directory) do
            "#{working_dir || '$HOME/.electric_sheep'}/unsafe\\$-job-name"
          end

          let(:job_directory) do
            "/home/user/.electric_sheep/unsafe\\$-job-name"
          end

          before do
            host.expects(:working_directory).returns(working_dir)
            job.expects(:id).returns('UNSAFE$-job-NAME')
            interactor.expects(:exec).
              with("echo \"#{raw_directory}\"").
              returns(out: job_directory)
            interactor.expects(:exec).
              with("mkdir -p \"#{job_directory}\" ; chmod 0700 \"#{job_directory}\"")
            directories.mk_job_directory!
          end

          it 'expands relative paths' do
            directories.expand_path('path').must_equal "#{job_directory}/path"
          end

          it 'does not expand absolute paths' do
            directories.expand_path('/path').must_equal "/path"
          end
        end
      end
    end
  end

end
