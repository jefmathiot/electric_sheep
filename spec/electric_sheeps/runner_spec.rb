require 'spec_helper'

describe ElectricSheeps::Runner do

  before do
    @config = ElectricSheeps::Config.new
    @config.hosts.add(id: 'some-host', name: 'some-host.tld')
    @first_project = @config.add(
      ElectricSheeps::Metadata::Project.new(id: 'first-project')
    )
    @first_project.description = 'First project description'
    @second_project = @config.add(
      ElectricSheeps::Metadata::Project.new(id: 'second-project')
    )
    @logger = mock
    @runner = subject.new(config: @config, logger: @logger)
  end

  def run_it
    ElectricSheeps::Directories.expects(:mk_work_dir!)
    @runner.run!
  end

  let(:script) do
    sequence('script')
  end

  describe 'executing projects' do

    before do
      @logger.expects(:info).in_sequence(script).
        with("Executing \"First project description\" (first-project)")
      ElectricSheeps::Directories.expects(:mk_project_dir!).with(@first_project).returns('/first_project')
      ElectricSheeps::Directories.expects(:mk_project_dir!).with(@second_project).returns('/second_project')
    end

    it 'should not have remaining projects' do
      @logger.expects(:info).in_sequence(script).
        with("Executing second-project")
      run_it
      @config.remaining.must_equal 0 
    end

    describe 'with agents' do

      class Dumb
        include ElectricSheeps::Agents::Command
        register as: 'dumb', of_type: :command

        def run(metadata)
          logger.info "I'm #{metadata.type}, my work directory is #{work_dir}"
          shell.exec('echo "" > /dev/null')
        end

      end

      class Dumber
        include ElectricSheeps::Agents::Command
        register as: 'dumber', of_type: :command

        def run(metadata)
          logger.info "I'm #{metadata.type}, my work directory is #{work_dir}"
          shell.exec('echo > /dev/null')
        end

      end

      def expects_execution_times(*metered_objects)
        metered_objects.each do |metered|
          metered.execution_time.wont_be_nil
          metered.execution_time.must_be :>, 0
        end
      end

      def append_commands(shell)
        shell.add ElectricSheeps::Metadata::Command.new(id: 'first_command',
          type: 'dumb')
        shell.add ElectricSheeps::Metadata::Command.new(id: 'second_command',
          type: 'dumber')
        shell
      end

      def expects_executions(shell, logger, sequence)
        logger.expects(:info).in_sequence(sequence).with("I'm dumb, my work directory is /first_project")
        shell.expects(:exec).in_sequence(sequence).with('echo "" > /dev/null')
        logger.expects(:info).in_sequence(sequence).with("I'm dumber, my work directory is /first_project")
        shell.expects(:exec).in_sequence(sequence).with('echo > /dev/null')
      end

      it 'wraps command executions in a local shell' do
        append_commands @first_project.add(metadata = ElectricSheeps::Metadata::Shell.new)
        shell = ElectricSheeps::Shell::LocalShell.any_instance
        @logger.expects(:info).in_sequence(script).
          with("Starting a local shell session")
        expects_executions(shell, @logger, script)
        @logger.expects(:info).in_sequence(script).
          with("Executing second-project")
        
        run_it
        expects_execution_times(@first_project, metadata)
      end

      it 'wraps command executions in a remote shell' do
        append_commands(
          @first_project.add(
            metadata = ElectricSheeps::Metadata::RemoteShell.new(
              host: 'some-host', user: 'op'
            )
          )
        )
        shell = ElectricSheeps::Shell::RemoteShell.any_instance
        shell.expects(:open!).returns(shell).in_sequence(script)
        expects_executions(shell, @logger, script)
        shell.expects(:close!).in_sequence(script).returns(shell)
        @logger.expects(:info).in_sequence(script).
          with("Executing second-project")

        run_it
        expects_execution_times(@first_project, metadata)
      end

    end 

  end

end
