module ElectricSheep
  module Rescueable
    def rescued(&block)
      yield
      rescue Exception => ex
        logger.error ex.message
        logger.debug ex
    end
  end
end