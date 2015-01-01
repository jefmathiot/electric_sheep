require 'spec_helper'
require 'electric_sheep/cli'

describe ElectricSheep::CLI do

  let(:logger){ mock }
  let(:config){ mock }

  def expects_stdout_logger(level)
    Lumberjack::Logger.expects(:new).with(kind_of(IO), {level: level}).
      returns(logger)
  end

  def expects_file_logger(level)
    Lumberjack::Logger.expects(:new).with("electric_sheep.log", {level: level}).
      returns(logger)
  end

  def expects_evaluator(f='Sheepfile')
    ElectricSheep::Sheepfile::Evaluator.expects(:new).with(f).
      returns(mock(evaluate: config))
  end

  def self.ensure_verbosity(logger_type=:stdout, &block)

    describe 'with the verbose option' do

      before do
        send "expects_#{logger_type}_logger", :debug
      end

      it 'enables verbose logging' do
        self.instance_eval &block
      end

    end

  end

  def self.concise(logger_type=:stdout, &block)

    describe 'without the verbose option' do

      before do
        send "expects_#{logger_type}_logger", :info
      end

      self.instance_eval &block

    end

  end

  def self.ensure_exception_handling(&block)
    it 'logs the exception and fails' do
      logger.expects(:error).with("fail")
      logger.expects(:debug).with(kind_of(Exception))
      Exception.any_instance.stubs(:backtrace).returns('backtrace')
      Kernel.expects(:exit).with(1)
      self.instance_eval &block
    end
  end

  describe 'working' do

    describe 'on successful invocation' do

      before do
        ElectricSheep::Runner::Inline.expects(:new).
          with(all_of(
            has_entry(config: config),
            has_entry(project: 'some-project'),
            has_entry(logger: logger)
          )).returns(mock(run!: true))
      end

      ensure_verbosity do
        expects_evaluator
        subject.new([], config: 'Sheepfile', project: 'some-project', verbose: true).work
      end

      concise do

        it 'gets the job done' do
          expects_evaluator
          subject.new([], config: 'Sheepfile', project: 'some-project').work
        end

        it 'overrides the path to configuration file' do
          expects_evaluator('Lambfile')
          subject.new([], config: 'Lambfile', project: 'some-project').work
        end

      end

    end

    concise do
      ensure_exception_handling do
        ElectricSheep::Sheepfile::Evaluator.expects(:new).
          raises(Exception.new('fail'))
        subject.new.work
      end
    end

  end

  describe 'encrypting plain text' do

    concise do

      it 'encrypts secrets' do
        ElectricSheep::Crypto.expects(:encrypt).with('SECRET', '/some/key').
          returns('CIPHER')
        logger.expects(:info).with("CIPHER")
        subject.new([], key: '/some/key').encrypt('SECRET')
      end

      ensure_exception_handling do
        ElectricSheep::Crypto.expects(:encrypt).with('SECRET', '/some/key').
          raises(Exception.new('fail'))
        subject.new([], key: '/some/key').encrypt('SECRET')
      end
    end

  end

  describe 'controlling the master process' do

    let(:master){ mock }

    def expects_master(options)
      ElectricSheep::Master.expects(:new).with(options).returns(master)
    end

    def expects_startup(method, master_options, config_file=nil, workers=nil)
      expects_evaluator(config_file || 'Sheepfile')
      expects_control(method,
        {config: config, workers: workers}.merge(master_options),
      )
    end

    def expects_control(method, master_options={})
      expects_master({pidfile: nil, logger: logger}.merge(master_options))
      master.expects(method)
    end

    def self.ensure_startup(action)

      describe "#{action}ing" do

        it '#{action}s a master' do
          expects_startup("#{action}!", {})
          subject.new([], config: 'Sheepfile').send(action)
        end

        it 'overrides the path to configuration file' do
          expects_startup("#{action}!", {}, 'Lambfile')
          subject.new([], config: 'Lambfile').send(action)
        end

        it 'overrides the path to pidfile' do
          expects_startup("#{action}!", {pidfile: '/tmp/es.lock'})
          subject.new([], config: 'Sheepfile', pidfile: '/tmp/es.lock').
            send(action)
        end

        it 'overrides the maximum number of workers' do
          expects_startup("#{action}!", {workers: 2})
          subject.new([], config: 'Sheepfile', workers: 2).send(action)
        end

      end

    end

    describe 'on successful invocation' do

      concise(:file) do

        ensure_startup(:start)
        ensure_startup(:restart)

        describe "stopping" do

          it 'stops the master' do
            expects_control(:stop!)
            subject.new([]).stop
          end

          it 'overrides the path to pidfile' do
            expects_control(:stop!, {pidfile: '/tmp/es.lock'})
            subject.new([], pidfile: '/tmp/es.lock').stop
          end

        end

      end

      [:start, :restart].each do |action|
        describe "#{action}ing" do
          ensure_verbosity(:file) do
            expects_startup("#{action}!", {})
            subject.new([], config: 'Sheepfile', verbose: true).send(action)
          end
        end

        describe 'stopping' do
          ensure_verbosity(:file) do
            expects_control(:stop!)
            subject.new([], verbose: true).stop
          end
        end

      end
    end

    [:start, :stop, :restart].each do |action|

      describe "on #{action}" do

        concise(:file) do
          ensure_exception_handling do
            expects_evaluator if [:start, :restart].include?(action)
            ElectricSheep::Master.expects(:new).raises(Exception.new('fail'))
            subject.new([], config: 'Sheepfile').send(action)
          end
        end

      end

    end

  end

end
