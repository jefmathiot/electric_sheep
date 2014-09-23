require 'electric_sheep/helpers/resourceful'

module ElectricSheep
  module Transport
    extend ActiveSupport::Concern
    include Metadata::Options
    include Agent

    attr_reader :shell

    def initialize(project, logger, metadata, hosts, shell)
      @project = project
      @logger = logger
      @metadata = metadata
      @hosts = hosts
      @shell = shell
    end

    def perform
      self.send(@metadata.type)
    end

    protected
    def host(id)
      @hosts.get(id)
    end

    module ClassMethods
      def register(options={})
        ElectricSheep::Agents::Register.register(options.merge(transport: self))
      end
    end

  end
end
