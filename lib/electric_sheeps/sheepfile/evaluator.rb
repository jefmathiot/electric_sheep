module ElectricSheeps
  module Sheepfile
    class Evaluator
      
      def initialize(path)
        @path = File.expand_path(path)
      end

      def evaluate
        raise "Unable to evaluate #{@path}" unless readable?
        evaluate_file(Config.new)
      end

      protected
      def evaluate_file(config)
        config.tap do |config|
          Dsl.new(config).instance_eval File.open(@path, 'rb').read
        end
      end

      def readable?
        File.exists?(@path)
      end
    end
  end
end
