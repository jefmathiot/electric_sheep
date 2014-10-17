require 'thor'
require 'electric_sheep'

module ElectricSheep
  class CLI < Thor

    desc "work", "Start processing projects."
    option :config, aliases: %w(-c), type: :string,
      desc: 'Configuration file containing projects', default: 'Sheepfile'
    option :project, aliases: %w(-p), type: :string,
      desc: 'Name of a single project to execute'
    def work
      begin
        logger = Log::ConsoleLogger.new(STDOUT, STDERR)
        Runner.new(
          config: configuration,
          project: options[:project],
          logger: logger
        ).run!
      rescue SheepException => ex
        logger.error "#{"[ERROR]".red} #{ex}"
      rescue => ex
        raise Thor::Error, ex.message + "\n" + ex.backtrace.join("\n")
      end
    end

    option :key, aliases: %w(-k), required: true
    desc "encrypt SECRET", "Encrypt SECRET using the provided public key"
    def encrypt(secret)
      puts Crypto.encrypt(secret, options[:key])
    end

    protected
    def configuration
      Sheepfile::Evaluator.new(options[:config]).evaluate
    end

  end
end
