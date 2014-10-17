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

  describe 'executing projects warning' do
    it 'warns on unknown project' do
      @logger.expects(:info).never.with("Executing unknow")
      @logger.expects(:warn).with("Project \"unknow\" not present in sheepfile")
      @runner = subject.new(config: @config, project: 'unknow',
        logger: @logger)
      @runner.run!
      @config.remaining.must_equal 0
    end

    it 'warns when there is no project' do
      @config = ElectricSheep::Config.new
      @logger.expects(:info).never.with("Executing unknow")
      @logger.expects(:warn).with("No project available")
      @runner = subject.new(config: @config,
        logger: @logger)
      @runner.run!
      @config.remaining.must_equal 0
    end

  end

  describe 'executing projects' do

    before do
      @logger.expects(:info).in_sequence(script).
        with("Executing \"First project description\" (first-project)")
      @logger.expects(:success).
        with("Project \"first-project\"")
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
        @logger.expects(:success).in_sequence(script).
          with("Project \"second-project\"")
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

    describe 'with shells' do

      it 'wraps command executions in a local shell' do
        @first_project.add(metadata = ElectricSheep::Metadata::Shell.new)
        shell = ElectricSheep::Shell::LocalShell.any_instance
        shell.expects(:perform!).in_sequence(script)
        @runner.run!
        expects_execution_times(@first_project, metadata)
      end

      it 'wraps command executions in a remote shell' do
        @first_project.add(
          metadata = ElectricSheep::Metadata::RemoteShell.new(
            user: 'op'
          )
        )
        shell = ElectricSheep::Shell::RemoteShell.any_instance
        shell.expects(:perform!).in_sequence(script).returns(shell)
        @runner.run!
        expects_execution_times(@first_project, metadata)
      end

    end

    class FakeTransport
      include ElectricSheep::Transport
    end

    it 'executes transport' do

      @first_project.add metadata = ElectricSheep::Metadata::Transport.new
      metadata.expects(:agent).in_sequence(script).at_least(1).returns(FakeTransport)
      FakeTransport.any_instance.expects(:perform!).in_sequence(script)
      @runner.run!
      expects_execution_times(@first_project, metadata)
    end

  end

end
