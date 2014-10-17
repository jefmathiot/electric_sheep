module ElectricSheep
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
          begin
            Dsl.new(config).instance_eval File.open(@path, 'rb').read
          rescue SyntaxError => e
            line = e.message[/.*:(.*):/,1]
            raise SheepException, "Syntax error in #{@path} line: #{line}"
          end
        end
      end

      def readable?
        File.exists?(@path) && File.readable?(@path)
      end
    end
  end
end
