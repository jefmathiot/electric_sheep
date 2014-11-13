require 'thor'
require 'electric_sheep'

module ElectricSheep
  class CLI < Thor

    def self.startup_options
      run_options
      process_options
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

    desc "work", "Process all projects in sequence"
    run_options
    option :project, aliases: %w(-p), type: :string,
      desc: 'Name of a single project to execute'

    def work
      Runner::Inline.new(
        config: configuration,
        logger: logger,
        project: options[:project]
      ).run!
      rescue Exception => ex
        logger.error ex.message
        logger.debug ex
    end

    desc "encrypt SECRET", "Encrypt SECRET using the provided public key"
    option :key, aliases: %w(-k), required: true
    logging_options

    def encrypt(secret)
      logger.info Crypto.encrypt(secret, options[:key])
      rescue Exception => ex
        logger.error ex.message
        logger.debug ex
    end

    desc "start", "Start a daemon to process scheduled projects in the " +
      "background"
    startup_options

    def start
      master(config: configuration).start!
      rescue Exception => ex
        logger.error ex.message
        logger.debug ex
    end

    desc "stop", "Stop the daemon"
    process_options
    logging_options

    def stop
      master.stop!
      rescue Exception => ex
        logger.error ex.message
        logger.debug ex
    end

    desc "restart", "Restart the daemon"
    startup_options

    def restart
      master(config: configuration).restart!
      rescue Exception => ex
        logger.error ex.message
        logger.debug ex
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
      # TODO Configure logger output
      Lumberjack::Logger.new("electric_sheep.log", level: log_level)
    end

    def logger
      @logger ||= stdout_logger
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
