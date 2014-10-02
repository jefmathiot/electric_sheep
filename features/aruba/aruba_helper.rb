module Aruba
  module Api

    # The path to the directory which should contain all your test data
    # You might want to overwrite this method to place your data else where.
    #
    # @return [Array]
    #   The directory path: Each subdirectory is a member of an array
    def dirs
      @dirs ||= ['tmp']
    end

  end
end