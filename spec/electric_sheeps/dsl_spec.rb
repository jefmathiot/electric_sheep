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

        describe "adding a remote shell" do

            it "appends the shell to the project's queue" do
                project = build_project do
                    remotely on: "some-host"
                end
                shell = project.next!
                shell.must_be_instance_of ElectricSheeps::Metadata::RemoteShell
                shell.host.name.must_equal "some-host.tld"
            end
        end

        describe "adding a local shell" do

            it "appends the shell to the project's queue" do
                project = build_project do
                    locally
                end
                shell = project.next!
                shell.must_be_instance_of ElectricSheeps::Metadata::Shell
            end
        end

    end

end
