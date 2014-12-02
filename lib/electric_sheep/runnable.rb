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

    def file_resource(host, opts={})
      file_system_resource(:file, host, opts)
    end

    def directory_resource(host, opts={})
      file_system_resource(:directory, host, opts)
    end

    def file_system_resource(type, host, opts={})
      Resources.const_get(type.to_s.camelize).new(
      {
        extension: input.respond_to?(:extension) && input.extension || nil,
        basename: input.basename,
        host: host
      }.merge(opts)
      ).tap do |resource|
        resource.timestamp!(input)
      end
    end

  end
end
