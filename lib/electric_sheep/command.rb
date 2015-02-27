module ElectricSheep
  module Command
    extend ActiveSupport::Concern
    include Runnable

    attr_reader :shell

    delegate :stat_file, :stat_directory, :stat_filesystem, to: :shell

    def initialize(job, logger, shell, input, metadata)
      @job = job
      @logger = logger
      @shell = shell
      @input=input
      @metadata = metadata
    end

    def run!
      stat!(input)
      output = perform!
      stat!(output)
      output
    end

    protected

    def host
      shell.host
    end

    def stat!(resource)
      if resource.stat.size.nil?
        resource.stat!(send("stat_#{resource.type}", resource))
      end
      rescue Exception => e
        logger.
          debug "Unable to stat resource of type #{resource.type}: #{e.message}"
    end

    module ClassMethods
      def register(options={})
        ElectricSheep::Agents::Register.register(options.merge(command: self))
      end
    end

  end
end
