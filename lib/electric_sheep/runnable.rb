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
  end
end