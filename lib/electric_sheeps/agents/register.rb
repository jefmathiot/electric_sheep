module ElectricSheeps
    module Agents
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
                    send "add_#{options[:of_type]}", options[:as].to_sym, klazz
                end

                def command(id)
                    @commands[id.to_sym]
                end

                private
                def add_command(id, klazz)
                    klazz.send :include, Agents::Command
                    @commands[id]=klazz
                end

            end
        end
    end
end
