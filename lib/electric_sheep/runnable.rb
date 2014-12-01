module ElectricSheep
  module Runnable
    extend ActiveSupport::Concern
    include Agent

    protected
    def done!(resource)
      @project.store_product!(resource)
    end

    def input
      @project.last_product
    end

    def stat!(resource, interactor)
      resource.stat! interactor.stat(resource)
    rescue Exception => e
      logger.debug "Unable to stat resource of type #{resource.type}: #{e.message}"
    end

  end
end
