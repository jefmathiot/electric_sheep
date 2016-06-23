require 'spec_helper'

describe ElectricSheep::Helpers::ShellSafe do
  ShellSafeKlazz = Class.new do
    include ElectricSheep::Helpers::ShellSafe
  end

  describe ShellSafeKlazz do
    it 'escapes shell expressions' do
      ShellSafeKlazz.new.shell_safe('"expression').must_equal '\"expression'
    end
  end
end
