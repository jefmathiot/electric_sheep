require 'spec_helper'

describe ElectricSheep::Dsl do

  before do
    @config = ElectricSheep::Config.new
    @dsl = ElectricSheep::Dsl.new(@config)
    @dsl.host "some-host", hostname: "some-host.tld", description: "Some host"
  end

  def check_properties(obj, expected)
    expected.each do |key, value|
      obj.send(key).must_equal value
    end
  end

  it "raises an error on method missing" do
    -> { @dsl.orphan_method }.must_raise ElectricSheep::SheepException
  end

  describe ElectricSheep::Dsl::AbstractDsl do
    it "raises an error on method missing" do
      -> {
        ElectricSheep::Dsl::AbstractDsl.new.orphan_method
      }.must_raise ElectricSheep::SheepException
    end
  end

  describe ElectricSheep::Dsl::JobDsl do
    it "raises an error on class unknown" do
      err = -> {
        ElectricSheep::Dsl::JobDsl.new(@config,nil,{}).resource('Unknown')
      }.must_raise ElectricSheep::SheepException
      err.message.must_equal "Resource 'Unknown' in Sheepfile is undefined"
    end
  end

  it "makes hosts available" do
    (host = @config.hosts.get('some-host')).wont_be_nil
    check_properties host, id: "some-host", hostname: "some-host.tld",
      description: "Some host"
  end

  it 'defines the local working directory' do
    @dsl.working_directory '/local/directory'
    @config.hosts.localhost.working_directory.must_equal '/local/directory'
  end

  it 'allows defaults for agents' do
    options={command: 'id'}
    ElectricSheep::Agents::Register.expects(:set_defaults_for).with(options)
    @dsl.defaults_for options
  end

  it 'allows encrypted values' do
    value = @dsl.encrypted('XXXXX')
    value.must_be_instance_of ElectricSheep::Metadata::Encrypted
  end

  [:encrypt, :decrypt].each do |verb|

    it 'allows the definition of encryption options' do
      @dsl.send verb, with: path='/some/public/key'
      @config.send("#{verb}ion_options").with.must_equal path
    end

  end

  describe "registering a job" do

    def build_job(options={}, &block)
      @dsl.job 'some-job', options, &block
      @config.queue.first
    end

    it "appends the job to the configuration" do
      job = build_job(description: "Some random job") do
        resource :database, name: 'mydb'
      end
      job.wont_be_nil
      job.id.must_equal "some-job"
      job.description.must_equal "Some random job"
    end

    it 'sets the initial resource' do
      job = build_job do
        resource :database, name: 'mydb'
      end
      job.starts_with.must_be_instance_of ElectricSheep::Resources::Database
    end

    it 'allows encrypted values' do
      value = nil
      build_job do
        value = encrypted('XXXXX')
      end
      value.must_be_instance_of ElectricSheep::Metadata::Encrypted
    end

    it 'assigns a schedule' do
      job = build_job do
        schedule "hourly", past: "30"
      end
      job.schedule.must_be_instance_of ElectricSheep::Metadata::Schedule::Hourly
    end

    it 'appends a notifier' do
      job = build_job do
        notify via: "email"
      end
      job.notifiers.first.must_be_instance_of ElectricSheep::Metadata::Notifier
      job.notifiers.first.send(:agent).must_equal "email"
    end

    module ShellSpecs
      extend ActiveSupport::Concern

      class DoNothing
        include ElectricSheep::Command

        register as: 'do_nothing'

      end

      included do
        describe "adding a command" do
          def build_command(options={})
            build_shell do
              do_nothing options
            end
            @command = @shell.queue.first
          end

          it "appends the command to the shell's queue" do
            build_command
            @command.must_be_instance_of ElectricSheep::Metadata::Command
            @command.agent.must_equal :do_nothing
          end

        end
      end

    end

    describe "adding a remote shell" do

      def build_shell(&block)
        job = build_job do
          opts = {as: "op"}
          remotely opts, &block
        end
        @shell = job.queue.first
      end

      it "appends the shell to the job's queue" do
        build_shell
        @shell.must_be_instance_of ElectricSheep::Metadata::RemoteShell
        @shell.user.must_equal "op"
      end

      include ShellSpecs
    end

    describe "adding a local shell" do

      def build_shell(&block)
        job = build_job do
          locally &block
        end
        @shell = job.queue.first
      end

      it "appends the shell to the job's queue" do
        build_shell
        @shell.must_be_instance_of ElectricSheep::Metadata::Shell
      end

      include ShellSpecs
    end

    def self.describe_transport(type)
      describe "adding a #{type}" do
        it "appends the transport to the job's queue" do
          job = build_job do
            send type, to: 'some-host', using: :scp
          end
          transport = job.queue.first
          transport.must_be_instance_of ElectricSheep::Metadata::Transport
          transport.action.must_equal type
        end
      end
    end

    describe_transport :move
    describe_transport :copy

    it "appends an encryptor to the job's queue" do
      job = build_job do
        encrypt
      end
      job.queue.first.must_be_instance_of ElectricSheep::Metadata::Encryptor
    end

  end

end
