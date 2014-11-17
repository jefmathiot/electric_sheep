module ElectricSheep
  module Rescueable

    def logger
      raise "Undefined logger, please override"
    end

    def rescued(&block)
      yield
      false
      rescue Exception => ex
        logger.error ex.message
        logger.debug ex
        true
    end
  end
end
