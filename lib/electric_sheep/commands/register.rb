module ElectricSheep
  module Commands
    module Register
      def self.register(klazz, options={})
        store.add klazz, options
      end

      def self.command(id)
        store.command(id)
      end

      private
      def self.store
        @store ||= Store.new
      end

      class Store

        def initialize
          @commands = {}
        end

        def add(klazz, options)
          @commands[options[:as].to_sym]=klazz
        end

        def command(id)
          @commands[id.to_sym]
        end

      end
    end
  end
end
