module ElectricSheeps
  module Metadata
    class RemoteShell < Shell

      include Options
      options :host, :user

    end
  end
end
