require 'thor'
require 'electric_sheep'

module ElectricSheep
  class CLI < Thor

    desc "work", "Process projects in a single sequence."
    option :config, aliases: %w(-c), type: :string,
      desc: 'Configuration file', default: 'Sheepfile'
    option :project, aliases: %w(-p), type: :string,
      desc: 'Name of a single project to execute'
    option :verbose, aliases:%w(-v), type: :boolean,
      desc: 'Show debug log', default: false

    def work
      begin
        logger = Log::ConsoleLogger.new(STDOUT, STDERR, options[:verbose])
        Runner::Inline.new(
          config: configuration,
          project: options[:project],
          logger: logger
        ).run!
      rescue Exception => ex
        logger.error ex.message
        logger.debug ex.backtrace
      end
    end

    default_task :work

    desc "encrypt SECRET", "Encrypt SECRET using the provided public key"
    option :key, aliases: %w(-k), required: true
    option :verbose, aliases:%w(-v), type: :boolean,
      desc: 'Show debug log', default: false

    def encrypt(secret)
        logger = Log::ConsoleLogger.new(STDOUT, STDERR, options[:verbose])
        logger.info Crypto.encrypt(secret, options[:key])
      rescue Exception => ex
        logger.error ex.message
        logger.debug ex.backtrace
    end

    protected
    def configuration
      Sheepfile::Evaluator.new(options[:config]).evaluate
    end

  end
end
