module ElectricSheep
  module Rescueable

    def logger
      raise "Undefined logger, please override"
    end

    def rescued(fail_on_error = false, &block)
      yield
      false
      rescue Exception => ex
        logger.error ex.message
        logger.debug ex
        Kernel.exit 1 if fail_on_error
        true
    end

  end
end
