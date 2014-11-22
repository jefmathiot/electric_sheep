module ElectricSheep
  module Agent
    extend ActiveSupport::Concern
    include Metadata::Options

    attr_reader :logger

    protected
    def option(name)
      option = @metadata.send(name)
      return option.decrypt(@project.private_key) if option.respond_to?(:decrypt)
      option
    end

  end
end
