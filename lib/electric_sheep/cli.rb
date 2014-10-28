require 'thor'
require 'electric_sheep'

module ElectricSheep
  class CLI < Thor

    def self.common_options
      option :config, aliases: %w(-c), type: :string,
        desc: 'Override path to configuration file', default: './Sheepfile'
      option :verbose, aliases:%w(-v), type: :boolean,
        desc: 'Show debug log', default: false
    end

    desc "work", "Process all projects in sequence"
    common_options
    option :project, aliases: %w(-p), type: :string,
      desc: 'Name of a single project to execute'

    def work
      logger=stdout_logger
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
    option :verbose, aliases:%w(-v), type: :boolean,
      desc: 'Show debug log', default: false

    def encrypt(secret)
      logger=stdout_logger
      logger.info Crypto.encrypt(secret, options[:key])
      rescue Exception => ex
        logger.error ex.message
        logger.debug ex
    end

    desc "start", "Start a daemon which processes scheduled projects in the " +
      "background"
    common_options
    option :pidfile, aliases: %w(-f), type: :string,
      desc: 'Override path to pidfile', default: './electric_sheep.pid'

    def start
      logger=file_logger
      Daemon.new(
        config: configuration,
        pidfile: options[:pidfile],
        logger: logger
      ).start!
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

  end
end
