module ElectricSheep
  module Notifier
    extend ActiveSupport::Concern
    include Agent

    def initialize(project, logger, metadata)
      @project = project
      @logger = logger
      @metadata = metadata
    end

    module ClassMethods
      def register(options={})
        ElectricSheep::Agents::Register.register(options.merge(command: self))
      end
    end
  end
end
