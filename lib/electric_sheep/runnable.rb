module ElectricSheep
  module Runnable
    extend ActiveSupport::Concern
    include Agent

    attr_reader :input

    protected

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
