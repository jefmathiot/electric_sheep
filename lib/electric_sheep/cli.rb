require 'thor'
require 'electric_sheep'

module ElectricSheep
  module CryptoCLI
    extend ActiveSupport::Concern

    included do
      desc 'encrypt SECRET', 'Encrypt SECRET using the provided public key'
      option :key,
             aliases: %w(-k),
             required: true,
             desc: 'The GPG public key'
      option :standard_armor,
             aliases: %w(-a),
             type: :boolean,
             default: false,
             desc: 'Output the standard ASCII-armored'
      logging_options
      def encrypt(secret)
        rescued(true) do
          cipher = Crypto.gpg.string(Spawn)
          STDOUT.puts cipher.encrypt(
            options[:key],
            secret,
            ascii: true,
            compact: !options[:standard_armor]
          )
        end
      end

      desc 'decrypt INPUT OUTPUT',
           'Decrypt the encrypted INPUT file to OUTPUT ' \
           'using the provided private key'
      option :key,
             aliases: %w(-k),
             required: true,
             desc: 'The GPG private key'
      logging_options
      def decrypt(input, output)
        rescued(true) do
          cipher = Crypto.gpg.file(Spawn)
          cipher.decrypt(options[:key], input, output)
        end
      end
    end
  end

  module StartupCLI
    extend ActiveSupport::Concern

    included do
      desc 'start', 'Start a master process'
      option :daemon,
             aliases: %w(-d), type: :boolean, default: false,
             desc: 'Place processes in the background'
      startup_options
      def start
        launch_master(:start!)
      end

      desc 'stop', 'Stop the master process'
      process_options
      logging_options

      def stop
        rescued(true) do
          master(daemon: true).stop!
        end
      end

      desc 'restart', 'Restart the master process'
      startup_options

      def restart
        launch_master(:restart!)
      end
    end

    protected

    def launch_master(method)
      rescued(true) do
        opts = {
          config: configuration,
          workers: options[:workers],
          daemon: options[:daemon]
        }
        master(opts).send(method)
      end
    end

    def master(opts = {})
      @logger = file_logger
      Master.new({
        pidfile: options[:pidfile],
        logger: logger
      }.merge(opts))
    end
  end

  class CLI < Thor
    include Rescueable

    class << self
      def startup_options
        run_options
        process_options
        option :workers,
               aliases: %w(-w), type: :numeric,
               desc: 'Maximum number of parallel workers',
               default: 1
        option :logfile,
               aliases: %w(-l), type: :string,
               desc: 'Override path to log file',
               default: './electric_sheep.log'
      end

      def run_options
        option :config,
               aliases: %w(-c), type: :string,
               desc: 'Override path to configuration file',
               default: './Sheepfile'
        logging_options
      end

      def logging_options
        option :verbose,
               aliases: %w(-v), type: :boolean,
               desc: 'Show debug log', default: false
      end

      def process_options
        option :pidfile,
               aliases: %w(-f), type: :string,
               desc: 'Override path to pidfile',
               default: './electric_sheep.pid'
      end
    end

    include CryptoCLI
    include StartupCLI

    desc 'work', 'Process all jobs in sequence'
    run_options
    option :job,
           aliases: %w(-j), type: :string,
           desc: 'Name of a single job to execute'

    def work
      rescued(true) do
        Runner::Inline.new(
          config: configuration,
          logger: logger,
          job: options[:job]
        ).run!
      end
    end

    desc 'version', 'Show version and git revision'
    def version
      puts ElectricSheep.revision
    end

    desc 'hostkeys', 'Retrieve the SSH hosts public keys and cache them'
    run_options
    option :yes,
           aliases: %w(-y), type: :boolean,
           desc: 'Don\'t ask for confirmation before updating the key cache'
    def hostkeys
      Util::SshHostKeys.refresh(configuration, stdout_logger, options[:yes])
    end

    default_task :work

    protected

    def configuration
      Sheepfile::Evaluator.new(options[:config]).evaluate
    end

    def log_level
      options[:verbose] ? :debug : :info
    end

    def stdout_logger
      Lumberjack::Logger.new(STDOUT, level: log_level)
    end

    def file_logger
      path = File.expand_path(options[:logfile] || 'electric_sheep.log')
      Lumberjack::Logger.new(path, level: log_level)
    end

    def logger
      @logger ||= stdout_logger
    end
  end
end
