module Support
  module Command
    include Options

    class NilMetadata
      def method_missing(method, *args, &block)
        nil
      end
    end

    def requires(*options)
      options.each do |option|
        subject.new(mock, mock, mock, mock, NilMetadata.new).tap do |subject|
          expects_validation_error(subject, option,
            "Option #{option} is required")
        end
      end
    end
  end
end
