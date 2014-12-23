require 'electric_sheep/version'
require 'active_support'
require 'active_support/core_ext'

require 'electric_sheep/queue'
require 'electric_sheep/rescueable'
require 'electric_sheep/config'
require 'electric_sheep/crypto'
require 'electric_sheep/helpers'
require 'electric_sheep/master'
require 'electric_sheep/dsl'
require 'electric_sheep/logger'
require 'electric_sheep/metadata'
require 'electric_sheep/resources'
require 'electric_sheep/runner'
require 'electric_sheep/sheepfile'
require 'electric_sheep/interactors'
require 'electric_sheep/shell'
require 'electric_sheep/sheep_exception'
require 'electric_sheep/agents'
require 'electric_sheep/commands'
require 'electric_sheep/transports'
require 'electric_sheep/notifiers'

module ElectricSheep
  class << self
    def template_path
      @_template_path ||= File.join(gem_path, 'templates')
    end

    def gem_path
      @_gem_path ||= File.expand_path(File.join(File.dirname(__FILE__), '..'))
    end
  end
end

I18n.enforce_available_locales=false
