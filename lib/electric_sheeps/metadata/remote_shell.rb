module ElectricSheeps
  module Metadata
    class RemoteShell < Shell

      include Options
      optionize :host, :user

    end
  end
end
