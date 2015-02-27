require 'thor'
require 'electric_sheep'

module ElectricSheep
  class CLI < Thor
    include Rescueable

    def self.startup_options
      run_options
      process_options
      option :workers, aliases: %w(-w), type: :numeric,
        desc: 'Maximum number of parallel workers', default: 1
      option :logfile, aliases: %w(-l), type: :string,
        desc: 'Override path to log file', default: './electric_sheep.log'
    end

    def self.run_options
      option :config, aliases: %w(-c), type: :string,
        desc: 'Override path to configuration file', default: './Sheepfile'
      logging_options
    end

    def self.logging_options
      option :verbose, aliases:%w(-v), type: :boolean,
        desc: 'Show debug log', default: false
    end

    def self.process_options
      option :pidfile, aliases: %w(-f), type: :string,
        desc: 'Override path to pidfile', default: './electric_sheep.pid'
    end

    desc "work", "Process all jobs in sequence"
    run_options
    option :job, aliases: %w(-j), type: :string,
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

    desc "encrypt SECRET", "Encrypt SECRET using the provided public key"
    option :key, aliases: %w(-k), required: true,
      desc: "The GPG public key"
    option :standard_armor, aliases: %w(-a), type: :boolean, default: false,
      desc: "Output the standard ASCII-armored"
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

    desc "start", "Start a master process"
    option :daemon, aliases: %w(-d), type: :boolean, default: false,
      desc: "Place processes in the background"
    startup_options
    def start
      launch_master(:start!)
    end

    desc "stop", "Stop the master process"
    process_options
    logging_options

    def stop
      rescued(true) do
        master.stop!
      end
    end

    desc "restart", "Restart the master process"
    startup_options

    def restart
      launch_master(:restart!)
    end

    desc "version", "Show version and git revision"
    def version
      puts ElectricSheep.revision
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
      path=File.expand_path(options[:logfile] || 'electric_sheep.log')
      Lumberjack::Logger.new(path, level: log_level)
    end

    def logger
      @logger ||= stdout_logger
    end

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

    def master(opts={})
      @logger=file_logger
      Master.new({
        pidfile: options[:pidfile],
        logger: logger
      }.merge(opts))
    end

  end
end
