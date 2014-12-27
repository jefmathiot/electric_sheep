module ElectricSheep
  module Notifier
    extend ActiveSupport::Concern
    include Agent

    attr_reader :project, :hosts

    def initialize(project, hosts, logger, metadata)
      @project = project
      @logger = logger
      @metadata = metadata
      @hosts = hosts
    end

    module ClassMethods
      def register(options={})
        ElectricSheep::Agents::Register.register(options.merge(notifier: self))
      end
    end

  end
end
