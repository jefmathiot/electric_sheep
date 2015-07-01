module ElectricSheep
  module Sheepfile
    class Evaluator
      def initialize(main)
        @main = File.expand_path(main)
        @working_directory = File.dirname(@main)
      end

      def evaluate
        load(Config.new, @main)
      end

      def load(config, file)
        path = File.absolute_path(file, @working_directory)
        if File.directory?(path)
          Dir.glob("#{path}/*").each do |external_file|
            load_file(config, external_file)
          end
        else
          load_file(config, path)
        end
      end

      protected

      def readable?(path)
        File.exist?(path) && File.readable?(path)
      end

      def load_file(config, path)
        fail "Unable to evaluate #{path}" unless readable?(path)
        Dsl.new(config, self).instance_eval File.open(path, 'rb').read, path
        config
      rescue SyntaxError => e
        line = e.message[/.*:(.*):/, 1]
        raise SheepException, "Syntax error in #{path} line: #{line}"
      end
    end
  end
end
