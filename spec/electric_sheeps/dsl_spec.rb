require 'spec_helper'

describe ElectricSheeps::Dsl do
    before do
        @config = ElectricSheeps::Config.new
        @dsl = ElectricSheeps::Dsl.new(@config)

        @dsl.host "some-host" do
            name "some-host.tld"
            description "Some host"
        end
    end

    def check_properties(obj, expected)
        expected.each do |key, value|
            obj.send(key).must_equal value
        end
    end

    it "makes hosts available" do
        (host = @config.hosts.get('some-host')).wont_be_nil
        check_properties host, id: "some-host", name: "some-host.tld", description: "Some host"
    end

    describe "registering a project" do

       def build_project(&block) 
            @dsl.project 'some-project', &block
            @config.next!
        end

        it "appends the project to the configuration" do
            project = build_project do
                description "Some random project"
            end
            project.wont_be_nil
            project.id.must_equal "some-project"
            project.description.must_equal "Some random project"
        end

        module ShellSpecs
            extend ActiveSupport::Concern

            included do
                describe "adding a command" do

                    def build_command(options={})
                        build_shell do
                            command "fake_agent", options
                        end
                        @command = @shell.next!
                    end

                    it "appends the command to the shell's queue" do
                        build_command
                        @command.must_be_instance_of ElectricSheeps::Metadata::Command
                        @command.id.must_equal "fake_agent"
                        @command.agent.must_equal "fake_agent"
                    end
                    
                    it "gives an alias to the command" do
                        build_command as: "alias"
                        @command.id.must_equal "alias"
                    end
                end
            end

        end

        describe "adding a remote shell" do

            def build_shell(&block)
                project = build_project do
                    opts = {on: "some-host", as: "op"}
                    remotely opts, &block
                end
                @shell = project.next!
            end

            it "appends the shell to the project's queue" do
                build_shell
                @shell.must_be_instance_of ElectricSheeps::Metadata::RemoteShell
                @shell.host.name.must_equal "some-host.tld"
                @shell.user.must_equal "op"
            end

            include ShellSpecs
        end

        describe "adding a local shell" do

            def build_shell(&block)
                project = build_project do
                    locally &block
                end
                @shell = project.next!
            end

            it "appends the shell to the project's queue" do
                build_shell
                @shell.must_be_instance_of ElectricSheeps::Metadata::Shell
            end

            include ShellSpecs
        end

        describe "adding a transport" do
            
            def build_transport(&block)
                project = build_project do
                    transport :scp, &block
                end
                @transport = project.next!
            end

            it "should append the transport to the project's queue" do
                build_transport
                @transport.must_be_instance_of ElectricSheeps::Metadata::Transport
            end

            it "should define transport ends" do
                build_transport do
                    from
                    to
                end
                @transport.from.must_be_instance_of ElectricSheeps::Metadata::TransportEnd
                @transport.to.must_be_instance_of ElectricSheeps::Metadata::TransportEnd
            end
        end

    end

end

