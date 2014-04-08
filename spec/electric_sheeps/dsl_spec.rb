require 'spec_helper'

describe ElectricSheeps::Dsl do
  before do
    @config = ElectricSheeps::Config.new
    @dsl = ElectricSheeps::Dsl.new(@config)
    @dsl.host "some-host", hostname: "some-host.tld", description: "Some host"
  end

  def check_properties(obj, expected)
    expected.each do |key, value|
      obj.send(key).must_equal value
    end
  end

  it "makes hosts available" do
    (host = @config.hosts.get('some-host')).wont_be_nil
    check_properties host, id: "some-host", hostname: "some-host.tld", description: "Some host"
  end

  describe "registering a project" do

    def build_project(options={}, &block) 
      @dsl.project 'some-project', options, &block
      @config.next!
    end

    it "appends the project to the configuration" do
      project = build_project(description: "Some random project") do
        resource :database, name: 'mydb'
      end
      project.wont_be_nil
      project.id.must_equal "some-project"
      project.last_product.must_be_instance_of ElectricSheeps::Resources::Database
      project.description.must_equal "Some random project"
    end

    module ShellSpecs
      extend ActiveSupport::Concern

      class DoNothing
        include ElectricSheeps::Commands::Command

        register as: 'do_nothing'

      end

      included do
        describe "adding a command" do

          def build_command(options={})
            build_shell do
              do_nothing options
            end
            @command = @shell.next!
          end

          it "appends the command to the shell's queue" do
            build_command
            @command.must_be_instance_of ElectricSheeps::Metadata::Command
            @command.type.must_equal :do_nothing
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
        @shell.host.must_equal "some-host"
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

