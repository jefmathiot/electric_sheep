module ElectricSheep
  module Notifier
    extend ActiveSupport::Concern
    include Agent

    def initialize(project, logger, metadata)
      @project = project
      @logger = logger
      @metadata = metadata
    end
  end
end
