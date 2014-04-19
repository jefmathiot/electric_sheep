require 'thor'
require 'electric_sheep'

module ElectricSheep
  class CLI < Thor
    class_option :config, aliases: %w(-c), type: :string

    desc "work", "Start processing projects."
    def work
      begin
        Runner.new(config: configuration, logger: Log::ConsoleLogger.new(STDOUT, STDERR)).run!
      rescue => ex
        raise Thor::Error, ex
      end
    end

    option :key, aliases: %w(-k), required: true
    desc "encrypt SECRET", "Encrypt SECRET using the provided public key"
    def encrypt(secret)
      puts Crypto.encrypt(secret, options[:key])
    end

    protected
    def configuration
      @config = Sheepfile::Evaluator.new(options[:config] || defaults[:config]).evaluate
    end

    def defaults
      { config: 'Sheepfile' }
    end
  end
end
