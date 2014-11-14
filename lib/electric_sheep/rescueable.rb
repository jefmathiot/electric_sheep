module ElectricSheep
  module Rescueable
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