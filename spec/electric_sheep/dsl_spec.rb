require 'spec_helper'

describe ElectricSheep::Dsl do
  let(:config) { ElectricSheep::Config.new }
  let(:evaluator) { mock }
  let(:dsl) { ElectricSheep::Dsl.new(config, evaluator) }

  def check_properties(obj, expected)
    expected.each do |key, value|
      obj.send(key).must_equal value
    end
  end

  it 'raises an error on method missing' do
    -> { dsl.foo_method }.must_raise ElectricSheep::SheepException
  end

  describe ElectricSheep::Dsl::AbstractDsl do
    it 'raises an error on method missing' do
      lambda do
        ElectricSheep::Dsl::AbstractDsl.new.foo_method
      end.must_raise ElectricSheep::SheepException
    end
  end

  describe ElectricSheep::Dsl::JobDsl do
    it 'raises an error on class unknown' do
      err = lambda do
        ElectricSheep::Dsl::JobDsl.new(config, nil, {}).resource('Unknown')
      end.must_raise ElectricSheep::SheepException
      err.message.must_equal "Resource 'Unknown' in Sheepfile is undefined"
    end
  end

  it 'makes hosts available' do
    dsl.host 'some-host', hostname: 'some-host.tld', description: 'Some host'
    (host = config.hosts.get('some-host')).wont_be_nil
    check_properties host, id: 'some-host', hostname: 'some-host.tld',
                           description: 'Some host'
  end

  it 'modifies SSH options' do
    options = { known_hosts: '/path/to/known_hosts', host_key_checking: 'strict' }
    dsl.ssh options
    check_properties config.ssh_options, options
  end

  it 'loads an external Sheepfile or directory' do
    evaluator.expects(:load).with(config, 'external/Sheepfile')
    dsl.load 'external/Sheepfile'
  end

  it 'defines the local working directory' do
    dsl.working_directory '/local/directory'
    config.hosts.localhost.working_directory.must_equal '/local/directory'
  end

  it 'allows defaults for agents' do
    options = { command: 'id' }
    ElectricSheep::Agents::Register.expects(:assign_defaults_for).with(options)
    dsl.defaults_for options
  end

  it 'allows encrypted values' do
    value = dsl.encrypted('XXXXX')
    value.must_be_instance_of ElectricSheep::Metadata::Encrypted
  end

  [:encrypt, :decrypt].each do |verb|
    it 'allows the definition of encryption options' do
      dsl.send verb, with: path = '/some/public/key'
      config.send("#{verb}ion_options").with.must_equal path
    end
  end

  describe 'registering a job' do
    def build_job(options = {}, &block)
      dsl.job 'some-job', options, &block
      config.queue.first
    end

    it 'appends the job to the configuration' do
      job = build_job(description: 'Some random job') do
        resource :database, name: 'mydb'
      end
      job.wont_be_nil
      job.id.must_equal 'some-job'
      job.description.must_equal 'Some random job'
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
        schedule 'hourly', past: '30'
        schedule 'daily', at: '00:01'
      end
      job.schedules.size.must_equal 2
      job.schedules.first
        .must_be_instance_of ElectricSheep::Metadata::Schedule::Hourly
    end

    it 'appends a notifier' do
      job = build_job do
        notify via: 'email'
      end
      job.notifiers.first.must_be_instance_of ElectricSheep::Metadata::Notifier
      job.notifiers.first.send(:agent).must_equal 'email'
    end

    module ShellSpecs
      extend ActiveSupport::Concern

      class DoNothing
        include ElectricSheep::Command

        register as: 'do_nothing'
      end

      included do
        it 'adds an encryption command' do
          config.expects(:encryption_options).returns(opts = mock)
          opts.expects(:option).with(:with).returns('public/key')
          build_shell do
            encrypt
          end
          @shell.queue.first.agent.must_equal 'encrypt'
          @shell.queue.first.send(:option, :public_key).must_equal 'public/key'
        end

        describe 'adding a command' do
          def build_command(options = {})
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

    describe 'adding a remote shell' do
      def build_shell(&block)
        job = build_job do
          opts = { as: 'op' }
          remotely opts, &block
        end
        @shell = job.queue.first
      end

      it "appends the shell to the job's queue" do
        build_shell
        @shell.must_be_instance_of ElectricSheep::Metadata::RemoteShell
        @shell.user.must_equal 'op'
      end

      include ShellSpecs
    end

    describe 'adding a local shell' do
      def build_shell(&block)
        job = build_job do
          locally(&block)
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
  end
end
