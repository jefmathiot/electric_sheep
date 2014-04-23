module ElectricSheep
  module Agent
    attr_reader :logger

    protected
    def done!(resource)
      @project.store_product!(resource)
    end

    def resource
      @project.last_product
    end

    def option(name)
      option = @metadata.send(name)
      return option.decrypt(@project.private_key) if option.respond_to?(:decrypt)
      option
    end
  end
end
