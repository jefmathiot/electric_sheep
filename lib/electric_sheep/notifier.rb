module ElectricSheep
  module Notifier
    extend ActiveSupport::Concern
    include Agent

    attr_reader :job, :hosts

    def initialize(job, hosts, logger, metadata)
      @job = job
      @logger = logger
      @metadata = metadata
      @hosts = hosts
    end

    module ClassMethods
      def register(options = {})
        ElectricSheep::Agents::Register.register(options.merge(notifier: self))
      end
    end
  end
end
