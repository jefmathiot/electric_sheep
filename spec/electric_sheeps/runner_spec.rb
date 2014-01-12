require 'spec_helper'

describe ElectricSheeps::Runner do
    before do
        @config = ElectricSheeps::Config.new
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

        describe 'with shells and transports' do

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
                shell = @project.add ElectricSheeps::Metadata::Shell.new
                shell.add ElectricSheeps::Metadata::Command.new(id: 'first_command',
                    agent: 'dumb')
                shell.add ElectricSheeps::Metadata::Command.new(id: 'second_command',
                    agent: 'dumber')
            end
            it 'should execute shells and transport' do
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

        end 

    end

end
