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

        before do
            @dsl.project 'some-project' do
                description "Some random project"
            end
            @project = @config.next!
        end

        it "appends the project to the configuration" do
            @project.wont_be_nil
            @project.id.must_equal "some-project"
            @project.description.must_equal "Some random project"
        end

    end

    describe "adding a remote shell" do

        it "adds the shell to the project's queue" do
            project = @dsl.project 'some-project' do
                remotely on: "some-host"
            end
            shell = project.next!
            shell.wont_be_nil
            shell.host.name.must_equal "some-host.tld"
        end
    end

end
