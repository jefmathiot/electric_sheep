require 'spec_helper'

describe ElectricSheep::Runner do

  let(:logger) { mock }

  let(:script) { sequence('script') }

  describe ElectricSheep::Runner::Inline do

    let(:config) do
      ElectricSheep::Config.new
    end

    let(:runner) { subject.new(config: config, logger: logger) }

    before do
      config.add(
        p=ElectricSheep::Metadata::Project.new(
          id: 'first-project',
          description: 'First project description'
        )
      )
      p.stubs(:execution_time).returns(10.112)
    end

    it 'raises when told to run an unknown project' do
      logger.expects(:info).never.with("Executing unknown")
      runner = subject.new(config: config, project: 'unknown', logger: logger)
      err = ->{ runner.run! }.must_raise RuntimeError
      err.message.must_equal "Project \"unknown\" does not exist"
    end

    describe 'executing projects' do

      before do
        logger.expects(:info).in_sequence(script).
          with("Executing \"First project description\" (first-project)")
        logger.expects(:info).
          with("Project \"first-project\" completed in 10.112 seconds")
      end

      describe 'with multiple projects' do

        before do
          config.add(
            ElectricSheep::Metadata::Project.new(id: 'second-project')
          ).tap do |p|
            p.stubs(:execution_time).returns(5.5)
          end
        end

        it 'should not have remaining projects' do
          logger.expects(:info).in_sequence(script).
            with("Executing second-project")
          logger.expects(:info).in_sequence(script).
            with("Project \"second-project\" completed in 5.500 seconds")
          runner.run!
          config.remaining.must_equal 0
        end

        it 'executes a single project when told to do so' do
          logger.expects(:info).never.with("Executing second-project")
          runner = subject.new(config: config, project: 'first-project',
            logger: logger)
          runner.run!
        end

      end

    end

  end

  describe ElectricSheep::Runner::SingleRun do

    let(:config) do
      ElectricSheep::Config.new.tap do |c|
        c.hosts.add('some-host', hostname: 'some-host.tld')
      end
    end

    let(:project) do
      config.add(
        ElectricSheep::Metadata::Project.new(id: 'project')
      ).tap do |p|
        p.stubs(:execution_time).returns(10.112)
      end
    end

    let(:resource) do
      mock.tap do |resource|
        resource.stubs(:host).returns(mock)
      end
    end

    let(:runner) do
      runner = subject.new(config, logger, project)
    end

    before do
      logger.expects(:info).in_sequence(script).
        with("Executing project")
      project.start_with! resource
    end

    def expects_execution_times(*metered_objects)
      metered_objects.each do |metered|
        metered.execution_time.wont_be_nil
        metered.execution_time.must_be :>, 0
      end
    end

    describe 'with shells' do

      it 'wraps command executions in a local shell' do
        project.add(metadata = ElectricSheep::Metadata::Shell.new)
        shell = ElectricSheep::Shell::LocalShell.any_instance
        shell.expects(:perform!).in_sequence(script)
        logger.expects(:info).in_sequence(script).
          with("Project \"project\" completed in 10.112 seconds")
        runner.run!
        expects_execution_times(project, metadata)
      end

      it 'wraps command executions in a remote shell' do
        project.add(
          metadata = ElectricSheep::Metadata::RemoteShell.new(
            user: 'op'
          )
        )
        shell = ElectricSheep::Shell::RemoteShell.any_instance
        shell.expects(:perform!).in_sequence(script).returns(shell)
        logger.expects(:info).in_sequence(script).
          with("Project \"project\" completed in 10.112 seconds")
        runner.run!
        expects_execution_times(project, metadata)
      end

    end

    class FakeTransport
      include ElectricSheep::Transport
    end

    it 'executes transport' do
      project.add metadata = ElectricSheep::Metadata::Transport.new
      metadata.expects(:agent).in_sequence(script).at_least(1).returns(FakeTransport)
      FakeTransport.any_instance.expects(:perform!).in_sequence(script)
      logger.expects(:info).in_sequence(script).
        with("Project \"project\" completed in 10.112 seconds")
      runner.run!
      expects_execution_times(project, metadata)
    end
  end
end
