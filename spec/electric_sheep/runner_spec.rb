require 'spec_helper'

describe ElectricSheep::Runner do

  before do
    resource=mock
    resource.stubs(:host).returns(mock)
    @config = ElectricSheep::Config.new
    @config.hosts.add('some-host', hostname: 'some-host.tld')
    @first_project = @config.add(
      ElectricSheep::Metadata::Project.new(id: 'first-project',
        description: 'First project description')
    )
    @first_project.start_with! resource
    @logger = mock
    @runner = subject.new(config: @config, logger: @logger)
  end


  let(:script) do
    sequence('script')
  end

  describe 'executing projects' do

    before do
      @logger.expects(:info).in_sequence(script).
        with("Executing \"First project description\" (first-project)")
    end

    describe 'with multiple projects' do

      before do
        @second_project = @config.add(
          ElectricSheep::Metadata::Project.new(id: 'second-project')
        )
      end

      it 'should not have remaining projects' do
        @logger.expects(:info).in_sequence(script).
          with("Executing second-project")
        @runner.run!
        @config.remaining.must_equal 0 
      end

      it 'executes a single project when told to do so' do
        @logger.expects(:info).never.with("Executing second-project")
        @runner = subject.new(config: @config, project: 'first-project',
          logger: @logger)
        @runner.run!
        @config.remaining.must_equal 0
      end

    end

    def expects_execution_times(*metered_objects)
      metered_objects.each do |metered|
        metered.execution_time.wont_be_nil
        metered.execution_time.must_be :>, 0
      end
    end

    describe 'with commands' do

      class Dumb
        include ElectricSheep::Command
        register as: 'dumb', of_type: :command

        def perform
          logger.info "I'm #{self.class}"
          shell.exec('echo "" > /dev/null')
        end

      end

      class Dumber
        include ElectricSheep::Command
        register as: 'dumber', of_type: :command

        def perform
          logger.info "I'm #{self.class}"
          shell.exec('echo > /dev/null')
        end

      end

      def append_commands(shell)
        shell.add ElectricSheep::Metadata::Command.new(type: 'dumb')
        shell.add ElectricSheep::Metadata::Command.new(type: 'dumber')
        shell
      end

      def expects_executions(shell, logger, sequence)
        logger.expects(:info).in_sequence(sequence).
          with("I'm Dumb")
        shell.expects(:exec).in_sequence(sequence).with('echo "" > /dev/null')

        logger.expects(:info).in_sequence(sequence).
          with("I'm Dumber")
        shell.expects(:exec).in_sequence(sequence).
          with('echo > /dev/null')
      end

      it 'wraps command executions in a local shell' do
        append_commands @first_project.add(metadata = ElectricSheep::Metadata::Shell.new)
        shell = ElectricSheep::Shell::LocalShell.any_instance
        shell.expects(:open!).in_sequence(script)
        shell.expects(:mk_project_directory!).in_sequence(script)
        expects_executions(shell, @logger, script)
        @runner.run!
        expects_execution_times(@first_project, metadata)
      end

      it 'wraps command executions in a remote shell' do
        append_commands(
          @first_project.add(
            metadata = ElectricSheep::Metadata::RemoteShell.new(
              user: 'op'
            )
          )
        )
        shell = ElectricSheep::Shell::RemoteShell.any_instance
        shell.expects(:open!).returns(shell).in_sequence(script)
        shell.expects(:mk_project_directory!).in_sequence(script)
        expects_executions(shell, @logger, script)
        shell.expects(:close!).in_sequence(script).returns(shell)

        @runner.run!
        expects_execution_times(@first_project, metadata)
      end

    end

    class FakeTransport
      include ElectricSheep::Transport
    end

    it 'executes transport' do
      @first_project.add metadata = ElectricSheep::Metadata::Transport.new
      metadata.expects(:agent).in_sequence(script).returns(FakeTransport)
      FakeTransport.any_instance.expects(:perform).in_sequence(script)
      @runner.run!
      expects_execution_times(@first_project, metadata)
    end

  end

end
