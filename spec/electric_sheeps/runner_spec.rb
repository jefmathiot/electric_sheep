require 'spec_helper'

describe ElectricSheeps::Runner do

    before do
        @config = ElectricSheeps::Config.new
        @config.hosts.add(id: 'some-host', name: 'some-host.tld')
        @project = @config.add ElectricSheeps::Metadata::Project.new(
            id: 'first-project',
            description: 'First project description'
        )
        @config.add ElectricSheeps::Metadata::Project.new(
            id: 'second-project'
        )
        @logger = mock()
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

        it 'should not have remaining projects' do
            @logger.expects(:info).in_sequence(script).
                with("Executing second-project")
            @runner.run!
            @config.remaining.must_equal 0 
        end

        describe 'with agents' do

            before do
                class Dumb
                    include ElectricSheeps::Agents::Agent
                    register as: 'dumb', of_type: :command

                    def run(metadata)
                        logger.info "I'm dumb"
                        shell.exec('echo "" > /dev/null')
                    end
                end

                class Dumber
                    include ElectricSheeps::Agents::Agent
                    register as: 'dumber', of_type: :command

                    def run(metadata)
                        logger.info "I'm dumber"
                        shell.exec('echo > /dev/null')
                    end
                end
            end

            def append_commands(shell)
                shell.add ElectricSheeps::Metadata::Command.new(id: 'first_command',
                    type: 'dumb')
                shell.add ElectricSheeps::Metadata::Command.new(id: 'second_command',
                    type: 'dumber')
                shell
            end

            it 'wraps command executions in a local shell' do
                append_commands @project.add(ElectricSheeps::Metadata::Shell.new)
                shell = ElectricSheeps::Shell::LocalShell.any_instance
                @logger.expects(:info).in_sequence(script).
                    with("Starting a local shell session")
                @logger.expects(:info).in_sequence(script).with("I'm dumb")
                shell.expects(:exec).in_sequence(script).with('echo "" > /dev/null')
                @logger.expects(:info).in_sequence(script).with("I'm dumber")
                shell.expects(:exec).in_sequence(script).with('echo > /dev/null')
                @logger.expects(:info).in_sequence(script).
                    with("Executing second-project")

                @runner.run!
            end

            it 'wraps command executions in a remote shell' do
                append_commands @project.add(
                    ElectricSheeps::Metadata::RemoteShell.new(host: 'some-host', user: 'op') )
                shell = ElectricSheeps::Shell::RemoteShell.any_instance
                shell.expects(:open!).returns(shell).in_sequence(script)
                @logger.expects(:info).in_sequence(script).with("I'm dumb")
                shell.expects(:exec).in_sequence(script).with('echo "" > /dev/null')
                @logger.expects(:info).in_sequence(script).with("I'm dumber")
                shell.expects(:exec).in_sequence(script).with('echo > /dev/null')
                shell.expects(:close!).in_sequence(script).returns(shell)
                @logger.expects(:info).in_sequence(script).
                    with("Executing second-project")

                @runner.run!
            end

        end 

    end

end
